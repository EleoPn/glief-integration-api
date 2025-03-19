/**
 * @description       : Unit tests for LegalEntityCalloutService and LegalEntityResponseParser.
 * @author            : Eleonore Pean
 * @group             :
 * @last modified on  : 03-18-2025
 * @last modified by  : Eleonore Pean
 **/
@isTest
public with sharing class LegalEntityCalloutServiceTest {
  @testSetup
  static void setupTestData() {
    // Insert test data if needed (e.g., mock LegalEntity__c records)
  }

  @IsTest
  static void testFetchLegalEntity_Success() {
    // Mock a successful HTTP response
    Test.setMock(
      HttpCalloutMock.class,
      new LegalEntityCalloutMock(
        200,
        '{"data":[{"attributes":{"lei":"1234567890ABCDEF","entity":{"legalName":{"name":"Test Entity"},"category":"GENERAL","jurisdiction":"LU","status":"ACTIVE"},"registration":{"status":"ISSUED","initialRegistrationDate":"2015-07-30T01:44:43Z","lastUpdateDate":"2024-07-12T12:59:07Z","nextRenewalDate":"2025-08-03T00:00:06Z"}}}]}'
      )
    );

    Test.startTest();
    LegalEntity__c result = LegalEntityCalloutService.fetchLegalEntity('1234567890ABCDEF');
    Test.stopTest();

    System.assertNotEquals(null, result, 'Result should not be null');
    System.assertEquals('1234567890ABCDEF', result.LEI__c, 'LEI should match');
    System.assertEquals('Test Entity', result.LegalName__c, 'Legal name should match');
  }

  @IsTest
  static void testFetchLegalEntity_NotFound() {
    // Mock a 404 Not Found response
    Test.setMock(HttpCalloutMock.class, new LegalEntityCalloutMock(404, ''));

    try {
      Test.startTest();
      LegalEntityCalloutService.fetchLegalEntity('INVALID_LEI');
      Test.stopTest();
      System.assert(false, 'Expected CalloutException was not thrown');
    } catch (CalloutException e) {
      System.assert(e.getMessage().contains('Legal Entity not found'), 'Exception should indicate entity not found');
    }
  }

  @IsTest
  static void testFetchLegalEntity_ServerError() {
    // Mock a 500 Internal Server Error response
    Test.setMock(HttpCalloutMock.class, new LegalEntityCalloutMock(500, 'Internal Server Error'));

    try {
      Test.startTest();
      LegalEntityCalloutService.fetchLegalEntity('1234567890ABCDEF');
      Test.stopTest();
      System.assert(false, 'Expected CalloutException was not thrown');
    } catch (CalloutException e) {
      System.assert(e.getMessage().contains('Server Error'), 'Exception should indicate server error');
    }
  }

  @IsTest
  static void testParseResponse_ValidJson() {
    String jsonResponse = '{"data":[{"attributes":{"lei":"1234567890ABCDEF","entity":{"legalName":{"name":"Test Entity"},"category":"Corporation","jurisdiction":"US","status":"Active"},"registration":{"status":"Issued","initialRegistrationDate":"2023-01-01T00:00:00Z","lastUpdateDate":"2024-01-01T00:00:00Z","nextRenewalDate":"2025-01-01T00:00:00Z"}}}]}';

    Test.startTest();
    LegalEntity__c result = LegalEntityResponseParser.parseResponse(jsonResponse);
    Test.stopTest();

    System.assertNotEquals(result, null, 'Result should not be null');
    System.assertEquals('1234567890ABCDEF', result.LEI__c, 'LEI should match');
    System.assertEquals('Test Entity', result.LegalName__c, 'Legal name should match');
    System.assertEquals('Corporation', result.Category__c, 'Category should match');
    System.assertEquals('US', result.Jurisdiction__c, 'Jurisdiction should match');
    System.assertEquals('Active', result.Status__c, 'Status should match');
  }

  @IsTest
  static void testParseResponse_EmptyDataArray() {
    String emptyJson = '{"data":[]}';

    Test.startTest();
    LegalEntity__c result = LegalEntityResponseParser.parseResponse(emptyJson);
    Test.stopTest();

    System.assertEquals(null, result, 'Result should be null');
    System.assertEquals(1, [SELECT COUNT() FROM Log__c], 'A log should be created');
  }

  @IsTest
  static void testParseResponse_InvalidJson() {
    String invalidJson = '{"data":[{"attributes":{"lei":"1234567890ABCDEF","entity":}}]}'; // Malformed JSON
    Test.startTest();
    LegalEntity__c result = LegalEntityResponseParser.parseResponse(invalidJson);
    Test.stopTest();
    Assert.areEqual(null, result, 'Result should be null');
    Assert.areEqual(1, [SELECT COUNT() FROM Log__c], 'Log should be created');
  }

  @IsTest
  static void testParseResponse_MissingFields() {
    String missingFieldsJson = '{"data":[{"attributes":{"lei":"1234567890ABCDEF","entity":{}}}]}';

    Test.startTest();
    LegalEntity__c result = LegalEntityResponseParser.parseResponse(missingFieldsJson);
    Test.stopTest();

    System.assertNotEquals(null, result, 'Result should not be null');
    System.assertEquals('1234567890ABCDEF', result.LEI__c, 'LEI should still be present');
    System.assertEquals(null, result.LegalName__c, 'Legal name should be null');
    System.assertEquals(null, result.Category__c, 'Category should be null');
    System.assertEquals(null, result.Jurisdiction__c, 'Jurisdiction should be null');
  }

  @IsTest
  static void testParseResponse_InvalidDateFormat() {
    String invalidDateJson = '{"data":[{"attributes":{"lei":"1234567890ABCDEF","entity":{"legalName":{"name":"Test Entity"}},"registration":{"initialRegistrationDate":"INVALID_DATE","lastUpdateDate":"INVALID_DATE","nextRenewalDate":"INVALID_DATE"}}}]}';

    Test.startTest();
    LegalEntity__c result = LegalEntityResponseParser.parseResponse(invalidDateJson);
    Test.stopTest();

    System.assertEquals(null, result.InitialRegistrationDate__c, 'Invalid date should return null');
    System.assertEquals(null, result.LastUpdateDate__c, 'Invalid date should return null');
    System.assertEquals(null, result.NextRenewalDate__c, 'Invalid date should return null');
  }
}
