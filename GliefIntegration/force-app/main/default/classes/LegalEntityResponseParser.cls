/**
 * @description       : This class is responsible for parsing JSON responses from the API
 *                      and converting them into Salesforce sObjects.
 * @author            : Eleonore Pean
 * @group             :
 * @last modified on  : 03-19-2025
 * @last modified by  : Eleonore Pean
 **/
public with sharing class LegalEntityResponseParser {
  private final static String CLASS_NAME = LegalEntityResponseParser.class.getName();

  /**
   * @description  Data model representing a Legal Entity extracted from the API response.
   */
  public class LegalEntityData {
    public String lei;
    public String legalName;
    public String category;
    public String jurisdiction;
    public String registrationStatus;
    public Datetime initialRegistrationDate;
    public Datetime lastUpdateDate;
    public Datetime nextRenewalDate;
    public String status;

    // Address fields
    public String legalAddress;
    public String legalCity;
    public String legalCountry;
    public String legalPostalCode;
  }

  /**
   * @description  Parses the given JSON response string and converts it into a LegalEntity__c sObject.
   * @param jsonResponse The raw JSON response received from the external API.
   * @return A populated LegalEntity__c sObject or null if an error occurs.
   */
  public static LegalEntity__c parseResponse(String jsonResponse) {
    LegalEntityData legalEntity = new LegalEntityData();

    try {
      if (String.isBlank(jsonResponse)) {
        throw new JSONException('JSON response is empty or null');
      }

      // Deserialize JSON response into a generic map
      Map<String, Object> parsedJson = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);

      if (!parsedJson.containsKey('data')) {
        throw new JSONException('Missing "data" key in response');
      }

      List<Object> data = (List<Object>) parsedJson.get('data');
      if (data.isEmpty()) {
        throw new JSONException('Empty "data" array in response');
      }

      // Extract entity attributes
      Map<String, Object> entityAttributes = (Map<String, Object>) ((Map<String, Object>) data[0]).get('attributes');
      if (entityAttributes == null) {
        throw new JSONException('Missing "attributes" in response');
      }

      Map<String, Object> entity = (Map<String, Object>) entityAttributes.get('entity');
      if (entity == null) {
        throw new JSONException('Missing "entity" in response');
      }

      // Populate LegalEntityData object
      legalEntity.lei = (String) entityAttributes.get('lei');
      legalEntity.legalName = entity.containsKey('legalName') ? (String) ((Map<String, Object>) entity.get('legalName')).get('name') : null;
      legalEntity.category = (String) entity.get('category');
      legalEntity.jurisdiction = (String) entity.get('jurisdiction');
      legalEntity.registrationStatus = entityAttributes.containsKey('registration') ? (String) ((Map<String, Object>) entityAttributes.get('registration')).get('status') : null;

      try {
        // Convert date strings to Datetime
        legalEntity.initialRegistrationDate = UTILSFormatting.formatLongStringToDatetime(String.valueOf(((Map<String, Object>) entityAttributes.get('registration')).get('initialRegistrationDate')));
        legalEntity.lastUpdateDate = UTILSFormatting.formatLongStringToDatetime(String.valueOf(((Map<String, Object>) entityAttributes.get('registration')).get('lastUpdateDate')));
        legalEntity.nextRenewalDate = UTILSFormatting.formatLongStringToDatetime(String.valueOf(((Map<String, Object>) entityAttributes.get('registration')).get('nextRenewalDate')));
      } catch (Exception e) {
        LogService.createLog('ERROR', CLASS_NAME, 'parseResponse', 'Exception while parsing dates: ' + e.getMessage());
      }

      legalEntity.status = (String) entity.get('status');

      // Extract and store legal address
      if (entity.containsKey('legalAddress')) {
        Map<String, Object> legalAddressMap = (Map<String, Object>) entity.get('legalAddress');
        legalEntity.legalAddress = getAddressLines(legalAddressMap);
        legalEntity.legalCity = (String) legalAddressMap.get('city');
        legalEntity.legalCountry = (String) legalAddressMap.get('country');
        legalEntity.legalPostalCode = (String) legalAddressMap.get('postalCode');
      }
    } catch (JSONException jsonEx) {
      // Log specific JSON parsing errors
      LogService.createLog('ERROR', CLASS_NAME, 'parseResponse', 'JSONException: ' + jsonEx.getMessage());
      return null;
    } catch (Exception ex) {
      // Log any other unexpected errors
      LogService.createLog('ERROR', CLASS_NAME, 'parseResponse', 'Exception: ' + ex.getTypeName() + ': ' + ex.getMessage());
      return null;
    }

    // Convert LegalEntityData object to LegalEntity__c sObject
    return legalEntityToSObject(legalEntity);
  }

  /**
   * @description  Converts a LegalEntityData object into a LegalEntity__c Salesforce sObject.
   * @param legalEntityData The LegalEntityData object containing the parsed data.
   * @return A LegalEntity__c sObject populated with the extracted data.
   */
  public static LegalEntity__c legalEntityToSObject(LegalEntityData legalEntityData) {
    if (legalEntityData == null) {
      return null;
    }

    LegalEntity__c entity = new LegalEntity__c(LEI__c = legalEntityData.lei);

    // Populate sObject fields
    entity.LegalName__c = legalEntityData.legalName;
    entity.Category__c = legalEntityData.category;
    entity.Jurisdiction__c = legalEntityData.jurisdiction;
    entity.RegistrationStatus__c = legalEntityData.registrationStatus;
    entity.InitialRegistrationDate__c = legalEntityData.initialRegistrationDate;
    entity.LastUpdateDate__c = legalEntityData.lastUpdateDate;
    entity.NextRenewalDate__c = legalEntityData.nextRenewalDate;
    entity.Status__c = legalEntityData.status;

    // Populate address fields
    entity.LegalAddress__c = legalEntityData.legalAddress;
    entity.LegalCity__c = legalEntityData.legalCity;
    entity.LegalCountry__c = legalEntityData.legalCountry;
    entity.LegalPostalCode__c = legalEntityData.legalPostalCode;

    return entity;
  }

  /**
   * @description Extracts address lines from an address object.
   * @param addressMap The address object from the JSON.
   * @return A formatted address string.
   */
  private static String getAddressLines(Map<String, Object> addressMap) {
    List<Object> addressLines = (List<Object>) addressMap.get('addressLines');
    return (addressLines != null && !addressLines.isEmpty()) ? String.join(addressLines, ', ') : null;
  }
}
