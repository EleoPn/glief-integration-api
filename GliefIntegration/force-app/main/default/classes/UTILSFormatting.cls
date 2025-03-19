/**
 * @description       : 
 * @author            : Eleonore Pean
 * @group             : 
 * @last modified on  : 03-18-2025
 * @last modified by  : Eleonore Pean
**/
public with sharing class UTILSFormatting {

    public static Datetime formatLongStringToDatetime(String datetimeLong) {
        return Datetime.valueOfGMT(datetimeLong.replace('T', ' '));
    }
}