// Bold_TestDataFactory.cls - Reusable test data
/**
 * @description Test Data Factory for the project.
 * @author Araz
 * @date April 06, 2026
 * @version 1.1
 */
@isTest
public without sharing class Bold_TestDataFactory {

    public static Contact createContact(String firstName, String lastName) {
        return new Contact(FirstName = firstName, LastName = lastName);
    }

    public static Contact createAndInsertContact(String firstName, String lastName) {
        Contact con = createContact(firstName, lastName);
        insert con;
        return con;
    }

    public static List<Contact> createAndInsertContacts(List<String> firstNames, String lastName) {
        List<Contact> contacts = new List<Contact>();
        for (String fn : firstNames) {
            contacts.add(createContact(fn, lastName));
        }
        insert contacts;
        return contacts;
    }
}