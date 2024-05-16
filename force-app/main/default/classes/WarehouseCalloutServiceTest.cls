@IsTest
private class WarehouseCalloutServiceTest {
    // implement your mock callout test here
   @isTest  
   static void testWareHouseCallout(){
       Test.startTest();
       // implement mock callout test here
       Test.setMock(HTTPCalloutMock.class, new WarehouseCalloutServiceMock());
           WarehouseCalloutService wService = new WarehouseCalloutService();
           id apexJobID = system.enqueueJob(wService);
       Test.stopTest();
       
       Assert.areEqual(0, [SELECT count() FROM Product2]);
   }     
}