public with sharing class QuoteLineItemTriggerUtil {
    
    private static Set<String> sharedCustomFields;
    private static void initSharedFields(){
        if(sharedCustomFields != null){
            return;
        }

        Map<String, Schema.SObjectField> qliFields = Schema.SObjectType.QuoteLineItem.fields.getMap();
        Map<String, Schema.SObjectField> oliFields = Schema.SObjectType.OpportunityLineItem.fields.getMap();
        sharedCustomFields = new Set<String>();

        for(String fieldName : qliFields.keySet()){
            if(fieldName.endsWith('__c') && oliFields.containsKey(fieldName)){
                sharedCustomFields.add(fieldName);
            }
        }
    }

    public static void syncQLICustomFieldsToOLICustomFields(List<QuoteLineItem> quoteLineItems){
        initSharedFields();

        Map<Id, QuoteLineItem> qlisWithOli = new Map<Id, QuoteLineItem>();
        for(QuoteLineItem qli : quoteLineItems){
            qlisWithOli.put(qli.OpportunityLineItemId, qli);
        }
        Map<Id, OpportunityLineItem> oliMap = new Map<Id, OpportunityLineItem>(
            [SELECT Id 
            FROM OpportunityLineItem 
            WHERE Id IN :quoteLineItems]);

    }
}