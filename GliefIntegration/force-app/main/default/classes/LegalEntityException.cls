/**
 * @description       : 
 * @author            : Eleonore Pean
 * @group             : 
 * @last modified on  : 03-18-2025
 * @last modified by  : Eleonore Pean
**/
public abstract class LegalEntityException extends Exception {
    
    public class CalloutException extends LegalEntityException {}
    
    public class ParsingException extends LegalEntityException {
    }
}