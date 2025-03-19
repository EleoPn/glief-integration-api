/**
 * @description       : 
 * @author            : Eleonore Pean
 * @group             : 
 * @last modified on  : 03-18-2025
 * @last modified by  : Eleonore Pean
**/
@isTest
public class LegalEntityBatchTest {
    
    @isTest
    static void testTriggerBatchExecutionWithMock() {
        // Utiliser un mock pour simuler la réponse API
        Test.setMock(HttpCalloutMock.class, 
            new LegalEntityCalloutMock(200, 
                '{"data":[{"attributes":{"lei":"1234567890ABCDEF","entity":{"legalName":{"name":"Test Entity"},"category":"GENERAL","jurisdiction":"LU","status":"ACTIVE"},"registration":{"status":"ISSUED","initialRegistrationDate":"2015-07-30T01:44:43Z","lastUpdateDate":"2024-07-12T12:59:07Z","nextRenewalDate":"2025-08-03T00:00:06Z"}}}]}')
        );

        Test.startTest();
        // Insert legalEntity to launch trigger
        LegalEntity__c entity = new LegalEntity__c(LEI__c = '1234567890ABCDEF');
        insert entity;
        // simulate end of batch
        Test.stopTest();

        // check that legal entity was updated by the batch
        LegalEntity__c updatedEntity = [SELECT LEI__c, Category__c FROM LegalEntity__c WHERE LEI__c = '1234567890ABCDEF' LIMIT 1];
        Assert.areNotEqual(null, updatedEntity.Category__c, 'LegalEntity should have been updated in the database');
    }

    @isTest
    static void testTriggerBatchExecutionWithMockInvalid() {
        // Utiliser un mock pour simuler la réponse API
        Test.setMock(HttpCalloutMock.class, 
            new LegalEntityCalloutMock(200, 
                '{"data":[{"attributes":{"lei":"1234567890ABCDEF09181","entity":{"legalName":{"name":"Test Entity"},"category":"GENERAL","jurisdiction":"LU","status":"ACTIVE"},"registration":{"status":"ISSUED","initialRegistrationDate":"2015-07-30T01:44:43Z","lastUpdateDate":"2024-07-12T12:59:07Z","nextRenewalDate":"2025-08-03T00:00:06Z"}}}]}')
        );

        Test.startTest();
        // Insert legalEntity to launch trigger
        LegalEntity__c entity = new LegalEntity__c(LEI__c = '1234567890ABCDEF09181');
        try {
            insert entity;
        } catch (DmlException e) {
            // Assert that the error message is related to LEI length validation
            System.assert(e.getMessage().contains('STRING_TOO_LONG'), 
                'Expected validation error for LEI length');
        }

        // check that legal entity was updated by the batch
        Assert.isTrue([SELECT LEI__c, Category__c FROM LegalEntity__c].isEmpty(), 'LegalEntity should not have been created in the database');
    }

    @isTest
    static void testUpdateWithInvalidPicklist() {

        Test.startTest();
        // Insert legalEntity to launch trigger
        LegalEntity__c entity = new LegalEntity__c(LEI__c = '1234567890ABCDEF', Jurisdiction__c = 'TESTKO');
        try {
            LegalEntityUpdater.upsertLegalEntity(new List<LegalEntity__c>{entity});
        } catch (DmlException e) {
            // Assert that the error message is related to LEI length validation
            System.assert(e.getMessage().contains('Picklist'), 
                'Expected validation error for invalid picklist');
        }

        // check that legal entity was updated by the batch
        Assert.isTrue([SELECT LEI__c, Category__c FROM LegalEntity__c WHERE LEI__c = :entity.LEI__c LIMIT 1].isEmpty(), 'LegalEntity should have been created in the database');
        Assert.isFalse([SELECT Id From Log__c].isEmpty(), 'Log__c should have been created');
    }
}