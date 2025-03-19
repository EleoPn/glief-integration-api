/**
 * @description       : This class is responsible for upserting LegalEntity__c records in Salesforce.
 *                      It ensures that duplicate records are avoided by using the LEI (Legal Entity Identifier)
 *                      as an external ID. The class also handles potential database errors and logs them.
 * @author            : Eleonore Pean
 * @group             :
 * @last modified on  : 03-19-2025
 * @last modified by  : Eleonore Pean
 **/
public with sharing class LegalEntityUpdater {
  private final static String CLASS_NAME = LegalEntityUpdater.class.getName();

  /**
   * @description  Performs an upsert operation on a list of LegalEntity__c records.
   *               Uses the LEI__c field as an external ID to prevent duplication.
   *               Captures and logs any errors that occur during the upsert operation.
   * @param lstLegalEntityToUpsert List of LegalEntity__c records to be upserted.
   */
  public static void upsertLegalEntity(List<LegalEntity__c> lstLegalEntityToUpsert) {
    if (lstLegalEntityToUpsert == null || lstLegalEntityToUpsert.isEmpty()) {
      LogService.createLog('WARN', CLASS_NAME, 'upsertLegalEntity', 'No records provided for upsert.');
      return;
    }

    try {
      // Upsert operation using LEI__c as the external ID field
      Database.UpsertResult[] results = Database.upsert(lstLegalEntityToUpsert, LegalEntity__c.LEI__c, false);

      // Process the results to check for errors
      for (Integer i = 0; i < results.size(); i++) {
        Database.UpsertResult result = results[i];

        if (!result.isSuccess()) {
          LegalEntity__c failedRecord = lstLegalEntityToUpsert[i];

          for (Database.Error err : result.getErrors()) {
            String errorMessage = 'Upsert failed for LegalEntity__c (LEI: ' + failedRecord.LEI__c + ') - Error: ' + err.getMessage();
            LogService.createLog('ERROR', CLASS_NAME, 'upsertLegalEntity', errorMessage);
          }
        }
      }
    } catch (Exception ex) {
      LogService.createLog('ERROR', CLASS_NAME, 'upsertLegalEntity', 'Exception: ' + ex.getTypeName() + ' - ' + ex.getMessage());
    }
  }
}
