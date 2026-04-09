/**
 * @author Araz
 * @date April 10, 2026
 * @description Queueable class that performs the HTTP callout to Nationalize.io API.
 *              Includes strong recursion prevention and respects callout limits.
 */
public class Bold_ContactNationalizeQueueable implements Queueable, Database.AllowsCallouts {

    private Set<Id> contactIds;

    public Bold_ContactNationalizeQueueable(Set<Id> contactIds) {
        this.contactIds = contactIds;
    }

    public void execute(QueueableContext context) {
        
        // === STRONG RECURSION PREVENTION ===
        Bold_ContactTriggerHandler.setQueueableUpdateRunning();

        // Get API configuration from Custom Metadata
        Bold_Nationalize_Settings__mdt settings = [
            SELECT API_Base_URL__c, Timeout_Seconds__c 
            FROM Bold_Nationalize_Settings__mdt 
            WHERE DeveloperName = 'Default' 
            LIMIT 1
        ];

        List<Contact> contacts = [SELECT Id, FirstName FROM Contact WHERE Id IN :contactIds AND FirstName != null];
        List<Contact> contactsToUpdate = new List<Contact>();

        // Process at most 100 records per job to respect callout limits
        Integer processedThisJob = 0;

        // Track remaining ids to process in a subsequent job (if any)
        Set<Id> remainingIds = new Set<Id>();

        for (Contact con : contacts) {
            if (processedThisJob >= 100) {
                remainingIds.add(con.Id);
                continue;
            }

            try {
                String endpoint = settings.API_Base_URL__c + '/?name=' + EncodingUtil.urlEncode(con.FirstName, 'UTF-8');

                Http http = new Http();
                HttpRequest req = new HttpRequest();
                req.setEndpoint(endpoint);
                req.setMethod('GET');
                req.setTimeout(Integer.valueOf(settings.Timeout_Seconds__c) * 1000);

                HttpResponse res = http.send(req);

                if (res.getStatusCode() == 200) {
                    Bold_NationalizeResponse response = (Bold_NationalizeResponse)JSON.deserialize(res.getBody(), Bold_NationalizeResponse.class);
                    String countryCode = response.getHighestProbabilityCountry();

                    if (String.isNotBlank(countryCode)) {
                        con.Country__c = countryCode;
                        contactsToUpdate.add(con);
                    }
                }
            } catch (Exception e) {
                // Silent error handling in production
            }

            processedThisJob++;
        }

        if (!contactsToUpdate.isEmpty()) {
            update contactsToUpdate;
        }

        // If there are still records to process, enqueue another job only for the remaining ids
        if (!remainingIds.isEmpty()) {
            System.enqueueJob(new Bold_ContactNationalizeQueueable(remainingIds));
        }
    }
}