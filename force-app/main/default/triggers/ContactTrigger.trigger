// ContactTrigger.trigger - Thin trigger using Kevin O'Hara Trigger Framework
/**
 * @description Thin trigger on Contact object using Kevin O'Hara Trigger Framework.
 *              All trigger events are declared (framework best practice).
 *              Only afterInsert logic is implemented in the handler.
 * @author Araz
 * @date April 06, 2026
 * @version 1.1
 */
trigger ContactTrigger on Contact (
    before insert, before update, before delete,
    after insert, after update, after delete, after undelete
) {
    // Framework automatically routes to the correct handler method
    new Bold_ContactTriggerHandler().run();
}