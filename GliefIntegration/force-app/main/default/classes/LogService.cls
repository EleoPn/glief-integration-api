/**
 * @description       : Utility class for logging errors and important system events into a custom Salesforce object.
 *                      This class provides a centralized logging mechanism to store logs in the Log__c object.
 * @author            : Eleonore Pean
 * @group             : 
 * @last modified on  : 03-18-2025
 * @last modified by  : Eleonore Pean
**/
public with sharing class LogService {

    /**
     * @description  Creates a log entry in the Log__c custom object.
     *               This method is used to track errors, warnings, and other important events.
     * @param logType   The type of log (e.g., 'ERROR', 'INFO', 'WARNING').
     * @param className The name of the class where the log is being recorded.
     * @param taskName  The specific task or method associated with this log.
     * @param details   A detailed description of the log event.
     */
    public static void createLog(String logType, String className, String taskName, String details) {
        try {
            insert new Log__c(
                ClassName__c = className, 
                Task__c = taskName, 
                Description__c = details, 
                Type__c = logType
            );
        } catch (Exception e) {
            // If logging fails, print the error message to system debug logs
            System.debug(LoggingLevel.ERROR, 'Failed to log error: ' + e.getMessage());
        }
    }
}
