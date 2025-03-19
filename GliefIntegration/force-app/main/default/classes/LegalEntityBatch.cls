/**
 * @description       : This batch class is responsible for fetching Legal Entity data from an external API 
 *                      based on a list of LEI (Legal Entity Identifiers) and updating the corresponding records in Salesforce.
 *                      It implements Database.Batchable to process data in chunks and Database.AllowsCallouts 
 *                      to allow external API callouts during execution.
 * @author            : Eleonore Pean
 * @group             : 
 * @last modified on  : 03-18-2025
 * @last modified by  : Eleonore Pean
**/
public class LegalEntityBatch implements Database.Batchable<String>, Database.AllowsCallouts {
    private final static String CLASS_NAME = LegalEntityBatch.class.getName();
    
    // List of LEI (Legal Entity Identifiers) to process
    private List<String> lstLei;

    /**
     * @description  Constructor to initialize the batch with a list of LEI identifiers.
     * @param lstLei List of Legal Entity Identifiers (LEI) that need to be processed.
     */
    public LegalEntityBatch(List<String> lstLei){
        this.lstLei = lstLei;
    }

    /**
     * @description  Start method for the batch job.
     *               This method returns an iterable list of LEIs that will be processed in chunks.
     * @param bc Batchable context instance.
     * @return Iterable list of LEI strings.
     */
    public Iterable<String> start(Database.BatchableContext bc) {
        return lstLei;
    }

    /**
     * @description  Execute method that processes each batch of LEIs.
     *               Calls the external API for each LEI to fetch legal entity data, then upserts the records in Salesforce.
     * @param bc       Batchable context instance.
     * @param lstLei   List of LEI identifiers to process in the current batch.
     */
    public void execute(Database.BatchableContext bc, List<String> lstLei) {
        try {
            List<LegalEntity__c> lstLegalEntityToUpsert = new List<LegalEntity__c>();

            // Iterate through each LEI and fetch its corresponding Legal Entity data
            for(String lei : lstLei) {
                LegalEntity__c legalEntity = LegalEntityCalloutService.fetchLegalEntity(lei);
                if (legalEntity != null) {
                    lstLegalEntityToUpsert.add(legalEntity);
                }
            }

            // Upsert the list of legal entities if there are valid records
            if(lstLegalEntityToUpsert.size() > 0) {
                LegalEntityUpdater.upsertLegalEntity(lstLegalEntityToUpsert);
            }
        } catch (Exception e) {
            // Log any exceptions that occur during execution
            LogService.createLog('ERROR', CLASS_NAME, 'execute', e.getTypeName() + ': ' + e.getMessage());
        }
    }

    @SuppressWarnings('PMD.EmptyCatchBlock')
    public void finish(Database.BatchableContext bc) {
        // We might want to consider handling failures in job execution (retrieving failed Leis at parsing and inserting)
        // for example - rollback insertion of the LegalEntity if we did not succeed in retrieving the data
        // or retry the job if the external service is unavailable at the time of job execution
    }
}
