// Bold_ContactTriggerHandler.cls - Trigger handler for Contact country enrichment
/**
 * @description Trigger handler for the Contact object using Kevin O'Hara Trigger Framework.
 *              Handles after insert logic to enqueue Nationalize.io API callout.
 * @author Araz
 * @date April 06, 2026
 * @version 1.1
 */
public without sharing class Bold_ContactTriggerHandler extends TriggerHandler {

    public override void afterInsert() {
        Set<Id> contactIds = new Set<Id>();

        // Filter only Contacts that have FirstName
        for (Contact con : (List<Contact>) Trigger.new) {
            if (String.isNotBlank(con.FirstName)) {
                contactIds.add(con.Id);
            }
        }

        // Enqueue the Queueable only if we have contacts to process
        if (!contactIds.isEmpty()) {
            System.enqueueJob(new Bold_ContactNationalizeQueueable(new List<Id>(contactIds)));
        }
    }
}