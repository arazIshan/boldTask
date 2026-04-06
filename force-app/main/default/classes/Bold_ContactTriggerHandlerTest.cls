// Bold_ContactTriggerHandlerTest.cls - Full test coverage
/**
 * @description Comprehensive test class for Bold_ContactTriggerHandler and Queueable.
 * @author Araz
 * @date April 06, 2026
 * @version 1.1
 */
@isTest
private without sharing class Bold_ContactTriggerHandlerTest {

    @isTest
    static void testSuccessScenario() {
        Test.setMock(HttpCalloutMock.class, new Bold_NationalizeMock('success'));
        Test.startTest();
        Contact con = Bold_TestDataFactory.createAndInsertContact('Araz', 'Test');
        Test.stopTest();
        Contact updated = [SELECT Country__c FROM Contact WHERE Id = :con.Id];
        System.assertEquals('TR', updated.Country__c, 'Country__c should be TR on success');
    }

    @isTest
    static void testEmptyResponseScenario() {
        Test.setMock(HttpCalloutMock.class, new Bold_NationalizeMock('empty'));
        Test.startTest();
        Contact con = Bold_TestDataFactory.createAndInsertContact('InvalidName123', 'Test');
        Test.stopTest();
        Contact updated = [SELECT Country__c FROM Contact WHERE Id = :con.Id];
        System.assert(String.isBlank(updated.Country__c), 'Country__c should remain blank on empty response');
    }

    @isTest
    static void testErrorScenario() {
        Test.setMock(HttpCalloutMock.class, new Bold_NationalizeMock('error'));
        Test.startTest();
        Contact con = Bold_TestDataFactory.createAndInsertContact('ErrorTest', 'Test');
        Test.stopTest();
        Contact updated = [SELECT Country__c FROM Contact WHERE Id = :con.Id];
        System.assert(String.isBlank(updated.Country__c), 'Country__c should remain blank on API error');
    }

    @isTest
    static void testCalloutExceptionScenario() {
        Test.setMock(HttpCalloutMock.class, new Bold_NationalizeMock('exception'));
        Test.startTest();
        Contact con = Bold_TestDataFactory.createAndInsertContact('ExceptionTest', 'Test');
        Test.stopTest();
        Contact updated = [SELECT Country__c FROM Contact WHERE Id = :con.Id];
        System.assert(String.isBlank(updated.Country__c), 'Country__c should remain blank on callout exception');
    }

    @isTest
    static void testBlankFirstNameScenario() {
        Test.startTest();
        Contact con = Bold_TestDataFactory.createAndInsertContact('', 'TestBlank');
        Test.stopTest();
        Contact updated = [SELECT Country__c FROM Contact WHERE Id = :con.Id];
        System.assert(String.isBlank(updated.Country__c));
    }

    @isTest
    static void testBulkInsertScenario() {
        Test.setMock(HttpCalloutMock.class, new Bold_NationalizeMock('success'));
        Test.startTest();
        List<Contact> contacts = Bold_TestDataFactory.createAndInsertContacts(new List<String>{'Araz', 'Mehmet', 'Ayse'}, 'BulkTest');
        Test.stopTest();
        List<Contact> updated = [SELECT Country__c FROM Contact WHERE Id IN :contacts];
        System.assertEquals(3, updated.size());
        for (Contact c : updated) {
            System.assertEquals('TR', c.Country__c, 'All bulk contacts should have Country__c = TR');
        }
    }

    @isTest
    static void testNationalizeResponseWrapper() {
        Bold_NationalizeResponse resp = new Bold_NationalizeResponse();
        resp.name = 'Test';

        Bold_NationalizeResponse.Country us = new Bold_NationalizeResponse.Country();
        us.country_id = 'US';
        us.probability = 0.6;

        Bold_NationalizeResponse.Country tr = new Bold_NationalizeResponse.Country();
        tr.country_id = 'TR';
        tr.probability = 0.8;

        resp.country = new List<Bold_NationalizeResponse.Country>{us, tr};

        System.assertEquals('TR', resp.getHighestProbabilityCountry());
    }
}