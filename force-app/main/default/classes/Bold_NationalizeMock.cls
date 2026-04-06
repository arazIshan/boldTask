// Bold_NationalizeMock.cls - HttpCalloutMock for tests
/**
 * @description HttpCalloutMock implementation for Nationalize.io API tests.
 * @author Araz
 * @date April 06, 2026
 * @version 1.1
 */
@isTest
public without sharing class Bold_NationalizeMock implements HttpCalloutMock {
    private String scenario;

    public Bold_NationalizeMock(String scenario) {
        this.scenario = scenario;
    }

    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');

        String sc = (scenario == null) ? '' : scenario.toLowerCase();
        if (sc == 'success') {
            // Always return TR with the highest probability regardless of requested name
            res.setBody('{"name":"Any","country":[{"country_id":"TR","probability":0.9},{"country_id":"US","probability":0.1}]}');
            res.setStatusCode(200);
        } else if (sc == 'empty') {
            res.setBody('{"name":"InvalidName123","country":[]}');
            res.setStatusCode(200);
        } else if (sc == 'error') {
            res.setBody('{"error":"API down"}');
            res.setStatusCode(500);
        } else if (sc == 'exception') {
            throw new CalloutException('Simulated callout exception');
        } else {
            // Unknown scenario - make tests fail loudly by throwing so typos are visible
            throw new CalloutException('Unknown mock scenario: ' + scenario);
        }
        return res;
    }
}