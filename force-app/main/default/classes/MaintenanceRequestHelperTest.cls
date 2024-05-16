@isTest
public with sharing class MaintenanceRequestHelperTest {
    // implement scheduled code here
    
    @isTest
    private static void testPostive(){
        Vehicle__c v = new Vehicle__C(name = 'SuperTruck');
        insert v;
        
        Product2 e1 = new product2(name = 'SuperEquipment',
                                        lifespan_months__C = 10,
                                        maintenance_cycle__C = 10,
                                        replacement_part__c = true);      
        insert e1;
        
        Case maintainenceReq = new Case();
        maintainenceReq.Type = 'Repair';
        maintainenceReq.Origin = 'Web';
        maintainenceReq.Subject = 'Testing subject';
        maintainenceReq.Vehicle__c = v.Id;
        maintainenceReq.Status = 'New';
        insert maintainenceReq;
        
        Equipment_Maintenance_Item__c  item = new Equipment_Maintenance_Item__c ();
        item.Equipment__c = e1.Id;
        item.Maintenance_Request__c = maintainenceReq.Id;
        insert item; 
        
       	test.startTest();
       		maintainenceReq.status = 'Closed';
       		update maintainenceReq;
       test.stopTest();
       
       /*Assert.isNotNull(item);
       Assert.isNotNull(maintainenceReq.Subject);
       Assert.areEqual(maintainenceReq.Type, 'New');
       Assert.areEqual(maintainenceReq.Vehicle__c, v.Id);
       Assert.areEqual(maintainenceReq.Date_Reported__c, system.today()); */      
    }
    
    private static void testNegative(){
        Vehicle__c v = new Vehicle__C(name = 'SuperTruck');
        insert v;
        
        Product2 e1 = new product2(name = 'SuperEquipment',
                                        lifespan_months__C = 10,
                                        maintenance_cycle__C = 10,
                                        replacement_part__c = true);      
        insert e1;
        
        Case maintainenceReq = new Case();
        maintainenceReq.Type = 'Repair';
        maintainenceReq.Status = 'New';
        maintainenceReq.Origin = 'Web';
        maintainenceReq.Subject = 'Testing subject';
        maintainenceReq.Vehicle__c = v.Id;
        insert maintainenceReq;
        
        Equipment_Maintenance_Item__c  item = new Equipment_Maintenance_Item__c ();
        item.Equipment__c = e1.Id;
        item.Maintenance_Request__c = maintainenceReq.Id;
        insert item; 
        
       	test.startTest();
       		maintainenceReq.status = 'Working';
       		update maintainenceReq;
       test.stopTest();
        
       Case newReq = [SELECT Id, subject, type, Date_Reported__c, Vehicle__c, Date_Due__c
                     FROM Case WHERE status ='New'];
       
       Equipment_Maintenance_Item__c itemPart = [SELECT id FROM Equipment_Maintenance_Item__c WHERE Maintenance_Request__c =:newReq.Id];       
        
		List<case> allRequest = [SELECT id FROM Case];
       
       Equipment_Maintenance_Item__c workPart = [SELECT Id FROM Equipment_Maintenance_Item__c WHERE Maintenance_Request__c = :newReq.Id];
       
       /*Assert.isNotNull(workPart);
       Assert.areEqual(allRequest.size(),1);    */
    }
    
   @istest
   private static void testBulk(){
       List<Vehicle__c> vLst = new List<Vehicle__C>();
       List<Product2> eLst = new List<Product2>();
       List<Equipment_Maintenance_Item__c> itemLst = new List<Equipment_Maintenance_Item__c>();
       List<Case> maintLst = new List<Case>();
       Set<Id> oldCaseIds = new Set<Id>();
       
       for(integer i = 0; i < 300; i++){
          Vehicle__c v = new Vehicle__C(name = 'SuperTruck');
          vLst.add(v);
        	Product2 e = new product2(name = 'SuperEquipment',
                                        lifespan_months__c = 10,
                                        maintenance_cycle__c = 10,
                                        replacement_part__c = true);           
		 eLst.add(e);
       }
       insert vLst;
       insert eLst;
       
       for(integer i = 0; i < 300; i++){
			Case maintainenceReq = new Case();
        	maintainenceReq.Type = 'Repair';
        	maintainenceReq.Origin = 'Web';
        	maintainenceReq.Subject = 'Testing subject';
        	maintainenceReq.Vehicle__c = vLst[i].Id;
           maintainenceReq.Status = 'New';
            maintLst.add(maintainenceReq);
       }
       insert maintLst;
       
       for(integer i = 0; i < 300; i++){
        Equipment_Maintenance_Item__c  item = new Equipment_Maintenance_Item__c ();
        item.Equipment__c = eLst[i].Id;
        item.Maintenance_Request__c = maintLst[i].Id;
        itemLst.add(item);
       }
       insert itemLst;
       
       test.startTest();
           for(case req : maintLst){
               req.Status = 'Closed';
               oldCaseIds.add(req.Id);
           }
           update maintLst;
       test.stopTest();
       
       List<Case> updateMaintLst = [SELECT Id FROM Case WHERE Status = 'New'];
       
       list<Equipment_Maintenance_Item__c> updateItems = [SELECT Id FROM Equipment_Maintenance_Item__c WHERE Maintenance_Request__c IN :oldCaseIds];
       
       //Assert.areEqual(updateMaintLst.size(), 300);
   }
}