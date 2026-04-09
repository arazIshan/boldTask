/**
 * @author Araz
 * @date April 10, 2026
 * @description Trigger Handler for Contact using Kevin O'Hara Framework.
 *              Strong recursion prevention for Queueable updates.
 */
public class Bold_ContactTriggerHandler extends TriggerHandler {

    // Strong recursion guard flag
    private static Boolean isQueueableUpdateRunning = false;

    /**
     * Called from Queueable to tell the trigger that the update is coming from Queueable job.
     */
    public static void setQueueableUpdateRunning() {
        isQueueableUpdateRunning = true;
    }

    public override void afterInsert() {
        // Prevent recursion - if this is triggered by Queueable update, skip everything
        if (isQueueableUpdateRunning) {
            isQueueableUpdateRunning = false;   // reset flag after skipping
            return;
        }

        Set<Id> contactIds = new Set<Id>();

        for (Contact con : (List<Contact>) Trigger.new) {
            if (String.isNotBlank(con.FirstName)) {
                contactIds.add(con.Id);
            }
        }

        if (!contactIds.isEmpty()) {
            System.enqueueJob(new Bold_ContactNationalizeQueueable(contactIds));
        }
    }
}