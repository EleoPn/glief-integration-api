/**
 * @description       :
 * @author            : Eleonore Pean
 * @group             :
 * @last modified on  : 03-19-2025
 * @last modified by  : Eleonore Pean
 **/
public with sharing class LegalEntityController {
  private final static String CLASS_NAME = LegalEntityController.class.getName();

  /**
   * Retrieves a Legal Entity based on its LEI.
   * If the LEI is not found in Salesforce, it is fetched from an external service and inserted.
   *
   * @param lei The Legal Entity Identifier (must be exactly 20 characters).
   * @return LegalEntity__c The existing or newly inserted Legal Entity record.
   * @throws AuraHandledException If the LEI is invalid or if an error occurs.
   */
  @AuraEnabled
  public static LegalEntity__c getLegalEntityDetails(String lei) {
    try {
      // Validate LEI format
      if (String.isBlank(lei) || lei.length() != 20) {
        throw new AuraHandledException('Invalid LEI. It must be exactly 20 characters.');
      }

      // Check if the entity already exists in Salesforce
      List<LegalEntity__c> entities = [
        SELECT
          LegalName__c,
          LEI__c,
          Status__c,
          Category__c,
          InitialRegistrationDate__c,
          RegistrationStatus__c,
          Jurisdiction__c,
          LastUpdateDate__c,
          NextRenewalDate__c,
          LegalAddress__c,
          LegalCity__c,
          LegalPostalCode__c,
          LegalCountry__c
        FROM LegalEntity__c
        WHERE LEI__c = :lei
        LIMIT 1
      ];

      if (!entities.isEmpty()) {
        return entities[0]; // Return the existing entity (NO insert)
      }

      // Fetch from external service
      LegalEntity__c newEntity = LegalEntityCalloutService.fetchLegalEntity(lei);

      // Insert only if a valid entity is retrieved
      if (newEntity != null) {
        insert newEntity;
        return newEntity;
      } else {
        throw new AuraHandledException('Legal Entity not found.');
      }
    } catch (Exception e) {
      LogService.createLog('ERROR', CLASS_NAME, 'handleAfterInsert', e.getMessage());
      throw new AuraHandledException(System.Label.TXT_ERR_RETRIEVE_DATA);
    }
  }
}
