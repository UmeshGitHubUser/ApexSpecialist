public with sharing class MaintenanceRequestHelper {
    
    public static void updateWorkOrders(List<Case> caseLst, Map<Id,Case> oldCaseMap) {
        // TODO: Complete the method to update workorders
        Set<Id> caseIds = new Set<Id>();
        
        for(Case c:caseLst){
            //if current status of the case is Closed
            if(oldCaseMap.get(c.Id).Status != 'Closed' && c.Status == 'Closed'){
                if(c.Type == 'Repair' || c.Type == 'Routine Maintenance'){
                    caseIds.add(c.Id);
                }
            }
        }
        
        if(caseIds.size() > 0){
            List<Case> newCaseLst = new List<Case>();
            Map<Id,Case> closedCasesMap = new Map<Id,Case>([SELECT Id, Vehicle__c,(SELECT Id,Equipment__c,Quantity__c FROM Equipment_Maintenance_Items__r) 
                                                             FROM Case WHERE Id IN :caseIds]);
            Map<Id,Decimal> mntCycleMap = new Map<ID,Decimal>();
            List<AggregateResult> results = [SELECT Maintenance_Request__c, MIN(Equipment__r.Maintenance_Cycle__c) cycle FROM Equipment_Maintenance_Item__c WHERE Maintenance_Request__c IN :caseIds GROUP BY Maintenance_Request__c];
            
            for (AggregateResult ar : results){ 
                mntCycleMap.put((Id) ar.get('Maintenance_Request__c'), (Decimal) ar.get('cycle'));
            }
            
            for(Case c: closedCasesMap.values() ){
                Case nCase = new Case();
                nCase.ParentId = c.Id;
                nCase.Status = 'New';
				nCase.Subject = 'Routine Maintenance';
				nCase.Type = 'Routine Maintenance';
				nCase.Vehicle__c = c.Vehicle__c;
				nCase.Origin = 'Web';
				nCase.Date_Reported__c = Date.Today();
                
                if (mntCycleMap.containskey(c.Id)){
                    nCase.Date_Due__c = Date.today().addDays((Integer) mntCycleMap.get(c.Id));
                }
                
                newCaseLst.add(nCase);
            }
            
            insert newCaseLst;
            
           List<Equipment_Maintenance_Item__c> emiLst = new List<Equipment_Maintenance_Item__c>();
           for (Case nc : newCaseLst){
                for (Equipment_Maintenance_Item__c emi : closedCasesMap.get(nc.ParentId).Equipment_Maintenance_Items__r){
                    Equipment_Maintenance_Item__c emiClone = emi.clone();
                    emiClone.Maintenance_Request__c = nc.Id;
                    emiLst.add(emiClone);                  
                }
            }
            insert emiLst;
        }
    }       
}