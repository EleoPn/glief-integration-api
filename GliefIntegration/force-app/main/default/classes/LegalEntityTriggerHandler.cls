/**
 * @description       : This trigger handler is responsible for processing LegalEntity__c records
 *                      after they have been inserted. It collects the LEIs from new records and
 *                      triggers a batch process to fetch additional legal entity data from the API.
 * @author            : Eleonore Pean
 * @group             :
 * @last modified on  : 03-19-2025
 * @last modified by  : Eleonore Pean
 **/
public with sharing class LegalEntityTriggerHandler {
  private final static String CLASS_NAME = LegalEntityTriggerHandler.class.getName();

  /**
   * @description Handles the after-insert trigger event by collecting LEIs from the new records
   *              and initiating a batch job to fetch additional legal entity details.
   * @param newRecords The list of newly inserted LegalEntity__c records.
   */
  public static void handleAfterInsert(List<LegalEntity__c> newRecords) {
    Set<String> leiSet = new Set<String>();

    try {
      // Extract LEIs from the new records
      for (LegalEntity__c entity : newRecords) {
        if (!String.isBlank(entity.LEI__c) && String.isBlank(entity.RegistrationStatus__c)) {
          leiSet.add(entity.LEI__c);
        }
      }

      // Start batch processing if there are valid LEIs that are not yet processed
      if (!leiSet.isEmpty() && !System.isBatch()) {
        LegalEntityBatch batch = new LegalEntityBatch(new List<String>(leiSet));
        Database.executeBatch(batch, 100);
      }
    } catch (Exception e) {
      // Log the exception for debugging and error tracking
      LogService.createLog('ERROR', CLASS_NAME, 'handleAfterInsert', e.getMessage());
    }
  }
}
