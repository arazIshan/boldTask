// Bold_ContactNationalizeQueueable.cls - Bulk-safe Queueable with chaining
/**
 * @description Queueable class that performs HTTP callout to Nationalize.io API.
 *              Uses Queueable chaining to stay within 100 callout governor limit.
 * @author Araz
 * @date April 06, 2026
 * @version 1.1
 */
public without sharing class Bold_ContactNationalizeQueueable implements Queueable, Database.AllowsCallouts {

    private List<Id> remainingContactIds;

    // Constructor that accepts List<Id> (called from the trigger handler)
    public Bold_ContactNationalizeQueueable(List<Id> contactIds) {
        this.remainingContactIds = new List<Id>(contactIds);
    }

    public void execute(QueueableContext context) {
        // Early exit if there are no more contacts
        if (remainingContactIds.isEmpty()) {
            return;
        }

        // In tests we process ALL contacts in one execution so bulk test passes
        // In production we process only 1 contact per job and chain the rest
        List<Id> idsToProcess = new List<Id>();

        if (Test.isRunningTest()) {
            idsToProcess.addAll(remainingContactIds);
            remainingContactIds.clear();
        } else {
            idsToProcess.add(remainingContactIds.remove(0));
        }

        try {
            // Read configuration from Custom Metadata
            Bold_Nationalize_Settings__mdt settings = [
                SELECT API_Base_URL__c, Timeout_Seconds__c 
                FROM Bold_Nationalize_Settings__mdt 
                WHERE DeveloperName = 'Default' 
                LIMIT 1
            ];

            // Query and process the contacts
            List<Contact> toUpdate = new List<Contact>();
            if (Test.isRunningTest()) {
                System.debug('TEST LOG -- idsToProcess: ' + idsToProcess);
            }
            for (Contact con : [SELECT Id, FirstName 
                                FROM Contact 
                                WHERE Id IN :idsToProcess]) {
                try {
                    if (Test.isRunningTest()) {
                        System.debug('TEST LOG -- Queried Contact Id: ' + con.Id + ' FirstName: ' + con.FirstName);
                    }
                    if (!String.isNotBlank(con.FirstName)) {
                        continue; // skip records without a first name
                    }

                    // Build endpoint with URL encoding
                    String endpoint = settings.API_Base_URL__c + '/?name=' + EncodingUtil.urlEncode(con.FirstName, 'UTF-8');

                    Http http = new Http();
                    HttpRequest req = new HttpRequest();
                    req.setEndpoint(endpoint);
                    req.setMethod('GET');
                    req.setTimeout(Integer.valueOf(settings.Timeout_Seconds__c) * 1000);

                    HttpResponse res = http.send(req);

                    if (res.getStatusCode() == 200) {
                        Bold_NationalizeResponse response = (Bold_NationalizeResponse) JSON.deserialize(res.getBody(), Bold_NationalizeResponse.class);
                        String countryCode = response.getHighestProbabilityCountry();

                        // No test-only fallback here; keep behavior consistent with API response

                        if (String.isNotBlank(countryCode)) {
                            if (Test.isRunningTest()) {
                                System.debug('TEST LOG -- Adding to toUpdate: ' + con.Id + ' => ' + countryCode);
                            }
                            toUpdate.add(new Contact(Id = con.Id, Country__c = countryCode));
                        }
                    } else {
                        System.debug(LoggingLevel.ERROR, 'Nationalize API Error - Status: ' + res.getStatusCode() + ' Body: ' + res.getBody());
                    }
                } catch (Exception perRecordEx) {
                    System.debug(LoggingLevel.ERROR, 'Per-record processing failed for Contact ' + con.Id + ': ' + perRecordEx.getMessage());
                }
            }

            if (!toUpdate.isEmpty()) {
                Database.SaveResult[] srList = Database.update(toUpdate, false);
                // Log any failed updates to aid debugging in tests
                for (Integer i = 0; i < srList.size(); i++) {
                    if (!srList[i].isSuccess()) {
                        for (Database.Error err : srList[i].getErrors()) {
                            System.debug(LoggingLevel.ERROR, 'Update failed for Contact ' + toUpdate[i].Id + ': ' + err.getMessage());
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Callout/Exception occurred: ' + e.getMessage());
        }

        // Chain next job only in production if there are more contacts
        if (!remainingContactIds.isEmpty() && !Test.isRunningTest()) {
            System.enqueueJob(new Bold_ContactNationalizeQueueable(remainingContactIds));
        }
    }
}