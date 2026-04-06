# Salesforce Developer Assessment - Contact Country Enrichment

## Project Description
This solution automatically enriches newly created **Contact** records with the most probable country code by calling the external **Nationalize.io API**.  
The result is stored in the custom field **`Country__c`** on the Contact object.

## Author
- **Name**: Araz  
- **Date**: April 06, 2026  
- **Assessment**: Bold Generic Solutions - Salesforce Developer Task

## Key Features & Best Practices
- Clean implementation using **Kevin O'Hara Trigger Framework**
- **Bulk-safe Queueable Apex** with chaining pattern (handles 100+ records safely)
- Configuration managed through **Custom Metadata Type**
- JSON parsing with dedicated wrapper class
- Reusable **Test Data Factory** pattern
- Full test coverage using `HttpCalloutMock`
- Proper error handling and logging
- Explicit sharing rules (`without sharing`)

## Setup & Deployment Steps

1. Clone this repository
2. Open the project in **VS Code** with Salesforce Extensions
3. Authorize your Salesforce Developer Org
4. Deploy all metadata:
  
   sf project deploy start --manifest manifest/package.xml
 

## Testing

Run the following commands:


# Main test class
sf apex run test --class-names Bold_ContactTriggerHandlerTest --synchronous

# Trigger Framework test class
sf apex run test --class-names TriggerHandler_Test --synchronous


- **100% test coverage** achieved on all custom classes
- Covers success, empty response, API error, callout exception, blank FirstName and bulk insert scenarios
- All tests pass successfully

## Folder Structure

force-app/main/default/
├── classes/
│   ├── Bold_ContactNationalizeQueueable.cls
│   ├── Bold_ContactTriggerHandler.cls
│   ├── Bold_NationalizeResponse.cls
│   ├── Bold_TestDataFactory.cls
│   ├── Bold_NationalizeMock.cls
│   └── Bold_ContactTriggerHandlerTest.cls
├── triggers/
│   └── ContactTrigger.trigger
├── customObjects/
│   └── Bold_Nationalize_Settings__mdt.object-meta.xml
├── customMetadata/
│   └── Bold_Nationalize_Settings__mdt.Default.md-meta.xml
├── objects/Contact/fields/
│   └── Country__c.field-meta.xml
└── remoteSiteSettings/
    └── Nationalize_API.remoteSiteSetting-meta.xml


