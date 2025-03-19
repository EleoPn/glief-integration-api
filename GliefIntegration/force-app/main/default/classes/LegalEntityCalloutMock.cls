/**
 * @description       : 
 * @author            : Eleonore Pean
 * @group             : 
 * @last modified on  : 03-18-2025
 * @last modified by  : Eleonore Pean
**/
@isTest
global class LegalEntityCalloutMock implements HttpCalloutMock {

    private Integer statusCode;
    private String responseBody;
    
    public LegalEntityCalloutMock(Integer statusCode, String responseBody) {
        this.statusCode = statusCode;
        this.responseBody = responseBody;
    }

    global HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(statusCode);
        response.setBody(responseBody);
        return response;
    }
}
