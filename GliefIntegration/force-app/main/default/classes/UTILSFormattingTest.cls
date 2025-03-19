/**
 * @description       : 
 * @author            : Eleonore Pean
 * @group             : 
 * @last modified on  : 03-18-2025
 * @last modified by  : Eleonore Pean
**/
@isTest
private class UTILSFormattingTest {
    @isTest
    static void testFormatLongStringToDatetime_Valid() {
        // Test with a valid date in the expected format
        String validDatetime = '2024-03-18T15:30:00';
        Datetime expectedDatetime = Datetime.newInstanceGmt(2024, 3, 18, 15, 30, 0);
        
        Datetime result = UTILSFormatting.formatLongStringToDatetime(validDatetime);
        Assert.areEqual(expectedDatetime, result, 'The conversion should be correct.');
    }

    @isTest
    static void testFormatLongStringToDatetime_Invalid() {
        // Test with an incorrectly formatted date
        String invalidDatetime = '2024/03/18 15:30:00';
        try {
            Datetime result = UTILSFormatting.formatLongStringToDatetime(invalidDatetime);
            Assert.fail('An exception should have been thrown for an invalid format.');
        } catch (Exception e) {
            Assert.isNotNull(e, 'An exception must be thrown.');
        }
    }

    @isTest
    static void testFormatLongStringToDatetime_NullOrEmpty() {
        // Test with null input
        try {
            Datetime result = UTILSFormatting.formatLongStringToDatetime(null);
            Assert.fail('An exception should have been thrown for a null input.');
        } catch (Exception e) {
            Assert.isNotNull(e, 'An exception must be thrown.');
        }

        // Test with an empty string
        try {
            Datetime result = UTILSFormatting.formatLongStringToDatetime('');
            Assert.fail('An exception should have been thrown for an empty string.');
        } catch (Exception e) {
            Assert.isNotNull(e, 'An exception must be thrown.');
        }
    }
}
