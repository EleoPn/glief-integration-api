/**
 * @description       : 
 * @author            : Eleonore Pean
 * @group             : 
 * @last modified on  : 03-18-2025
 * @last modified by  : Eleonore Pean
**/
trigger LegalEntity on LegalEntity__c (after insert) {
    if(Trigger.isAfter && Trigger.isInsert){
        LegalEntityTriggerHandler.handleAfterInsert(Trigger.new);
    }
}