public with sharing class WarehouseCalloutService implements Queueable {

    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';
    private static final Integer HTTP_OK = 200;
    
    @future(callout=true)
    public static void syncWarehouseEquipment(){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        request.setEndpoint(WAREHOUSE_URL);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        
        List<Product2> warehouseEquipLst = new List<Product2>();
        
        if (response.getStatusCode() == HTTP_OK){
            List<Object> jsonResponse = (List<Object>)JSON.deserializeUntyped(response.getBody());
            System.debug(response.getBody());
            
            //Your class maps the following fields:
            //Replacement part (always true)
            //Cost, Current inventory, Lifespan,
            //Maintenance cycle,Warehouse SKU
            for (Object eq : jsonResponse){
                Map<String,Object> jsonObj = (Map<String,Object>)eq;
                Product2 newEq = new Product2();
                newEq.Replacement_Part__c = (Boolean) jsonObj.get('replacement');
                newEq.Name = (String) jsonObj.get('name');
                newEq.Maintenance_Cycle__c = (Integer) jsonObj.get('maintenanceperiod');
                newEq.Lifespan_Months__c = (Integer) jsonObj.get('lifespan');
                newEq.Cost__c = (Integer) jsonObj.get('cost');
                newEq.Warehouse_SKU__c = (String) jsonObj.get('sku');
                newEq.Current_Inventory__c = (Double) jsonObj.get('quantity');
                newEq.ProductCode = (String) jsonObj.get('_id');
                warehouseEquipLst.add(newEq);
            }
            
            if (warehouseEquipLst.size() > 0){
                upsert warehouseEquipLst;
            }
        }
    }
    
    public static void execute (QueueableContext context){
        syncWarehouseEquipment();
    }    
}