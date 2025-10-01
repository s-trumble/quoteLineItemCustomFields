public with sharing class LineItemSync {
    private static Set<String> sharedCustomFields;
    
    // Private static method to initialize sharedCustomFields - this is fine
    private static void initSharedFields(){
        if(sharedCustomFields != null){
            return;
        }

        Map<String, Schema.SObjectField> qliFields = Schema.SObjectType.QuoteLineItem.fields.getMap();
        Map<String, Schema.SObjectField> oliFields = Schema.SObjectType.OpportunityLineItem.fields.getMap();
        sharedCustomFields = new Set<String>();

        for(String fieldName : qliFields.keySet()){
            // Check for custom fields AND that they exist on OLI
            if(fieldName.endsWith('__c') && oliFields.containsKey(fieldName)){
                sharedCustomFields.add(fieldName);
            }
        }
    }

    public static void syncQLICustomFieldsToOLICustomFields(List<QuoteLineItem> quoteLineItems){
        initSharedFields();
        
        // Handle case where no custom fields are shared
        if (sharedCustomFields.isEmpty()) {
            return;
        }

        Map<Id, QuoteLineItem> qlisWithOli = new Map<Id, QuoteLineItem>();
        Set<Id> oliIds = new Set<Id>();
        for(QuoteLineItem qli : quoteLineItems){
            // Ensure we don't try to sync null IDs (though the handler should prevent this)
            if (qli.OpportunityLineItemId != null) {
                oliIds.add(qli.OpportunityLineItemId);
                qlisWithOli.put(qli.OpportunityLineItemId, qli);
            }
        }
        
        // Dynamically build the SOQL query string
        String fieldsToQuery = String.join(new List<String>(sharedCustomFields), ',');
        String query = 'SELECT Id, ' + fieldsToQuery + ' FROM OpportunityLineItem WHERE Id IN :oliIds';
        
        // Use Database.query to execute the dynamic SOQL
        List<OpportunityLineItem> queriedOlis = Database.query(query);
        Map<Id, OpportunityLineItem> oliMap = new Map<Id, OpportunityLineItem>(queriedOlis);

        List<OpportunityLineItem> olisToUpdate = new List<OpportunityLineItem>();

        for(Id oliId : qlisWithOli.keySet()){
            OpportunityLineItem oli = oliMap.get(oliId);
            QuoteLineItem qli = qlisWithOli.get(oliId);
            
            // Check for existence
            if (oli != null && qli != null) {
                // Typo corrected: consistent variable name `fieldName`
                for (String fieldName : sharedCustomFields){ 
                    // Use SObject.get() and SObject.put() for dynamic access
                    oli.put(fieldName, qli.get(fieldName));
                }
                olisToUpdate.add(oli);
            }
        }
        
        if(!olisToUpdate.isEmpty()){
            // DML operation should be wrapped in a try/catch block for robust error handling
            try {
                update olisToUpdate;
            } catch (DmlException e) {
                // Log the error or handle it as appropriate for your application
                System.debug(LoggingLevel.ERROR, 'Failed to update OLIs: ' + e.getMessage());
                // Consider adding an error to the Quote Line Item for the user to see
            }
        }
    }
}