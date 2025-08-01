@isTest
public with sharing class WarehouseSyncScheduleTest {
    // implement scheduled code here
    @isTest static void WarehousescheduleTest(){
        String cronExp = '00 00 01 * * ?';
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        	String jobID=System.schedule('Warehouse Schedule', cronExp, new WarehouseSyncSchedule());
        Test.stopTest();
        //Contains schedule information for a scheduled job. CronTrigger is similar to a cron job on UNIX systems.
        // This object is available in API version 17.0 and later.
        //CronTrigger a=[SELECT Id FROM CronTrigger where NextFireTime > today];
        //System.assertEquals(jobID, a.Id,'Schedule ');     
    }
}