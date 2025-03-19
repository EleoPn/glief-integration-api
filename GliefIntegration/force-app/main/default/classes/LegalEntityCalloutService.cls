/**
 * @description       : This class is responsible for making callouts to the GLEIF API
 *                      to fetch legal entity information using an LEI.
 *                      It processes API responses and handles errors accordingly.
 * @author            : Eleonore Pean
 * @group             :
 * @last modified on  : 03-19-2025
 * @last modified by  : Eleonore Pean
 **/
public with sharing class LegalEntityCalloutService {
  private final static String CLASS_NAME = LegalEntityCalloutService.class.getName();
  private static final String NAMED_CREDENTIAL = 'callout:GLEIF_API';

  /**
   * @description  Fetches a LegalEntity__c record from the GLEIF API using the given LEI.
   * @param lei The Legal Entity Identifier (LEI) of the entity to be retrieved.
   * @return A populated LegalEntity__c sObject if found, or throws an exception if an error occurs.
   * @throws CalloutException if the API returns an error or the response is unexpected.
   */
  public static LegalEntity__c fetchLegalEntity(String lei) {
    if (String.isBlank(lei)) {
      throw new CalloutException('LEI cannot be null or empty');
    }

    String endpoint = NAMED_CREDENTIAL + '/lei-records?filter[lei]=' + EncodingUtil.urlEncode(lei, 'UTF-8');

    // Prepare HTTP request
    Http http = new Http();
    HttpRequest request = new HttpRequest();

    request.setEndpoint(endpoint);
    request.setMethod('GET');
    request.setHeader('Content-Type', 'application/json');
    request.setTimeout(10000); // 10 seconds timeout

    try {
      HttpResponse response = http.send(request);
      Integer statusCode = response.getStatusCode();

      // Handle different response codes
      if (statusCode == 200) {
        return LegalEntityResponseParser.parseResponse(response.getBody());
      } else if (statusCode == 404) {
        throw new CalloutException('Legal Entity not found for LEI: ' + lei);
      } else if (statusCode >= 500) {
        throw new CalloutException('Server Error (' + statusCode + '): ' + response.getBody());
      } else {
        throw new CalloutException('Unexpected HTTP Response (' + statusCode + '): ' + response.getBody());
      }
    } catch (CalloutException e) {
      LogService.createLog('ERROR', CLASS_NAME, 'fetchLegalEntity', e.getTypeName() + ': ' + e.getMessage());
      throw e;
    } catch (Exception e) {
      LogService.createLog('ERROR', CLASS_NAME, 'fetchLegalEntity', e.getTypeName() + ': ' + e.getMessage());
      throw new CalloutException('Unexpected error during API callout: ' + e.getMessage());
    }
  }
}
