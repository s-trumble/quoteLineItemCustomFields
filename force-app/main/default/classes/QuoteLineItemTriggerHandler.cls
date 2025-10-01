public with sharing class QuoteLineItemTriggerHandler {
    
    public static void identifyQuoteLineItemsToSync(List<QuoteLineItem> newQLIs, Map<Id, QuoteLineItem> oldQLIMap){
        Set<Id> quoteIds = new Set<Id>();
        for(QuoteLineItem qli: newQLIs){
            if(qli.QuoteId != null){
                quoteIds.add(qli.QuoteId);
            }
        }
        
        // Query the parent Quotes to check for IsSyncing
        Map<Id, Quote> quoteMap = new Map<Id, Quote>(
            [SELECT Id, IsSyncing 
            FROM Quote 
            WHERE Id IN :quoteIds]);
        
        
        // --- START: New logic to query all fields for syncing QLIs ---
        List<QuoteLineItem> qlisToRequery = new List<QuoteLineItem>();
        Set<Id> qliIdsToRequery = new Set<Id>();
        
        for(QuoteLineItem qli: newQLIs){
            // Check if the QLI is linked to an OLI AND its parent Quote is syncing
            if(
                qli.OpportunityLineItemId != null &&
                quoteMap.containsKey(qli.QuoteId) &&
                quoteMap.get(qli.QuoteId).IsSyncing == true
                ){
                // We only requery if the field was changed. 
                // Since this is an after-update trigger, we can just grab the ID of the QLI
                // and requery it with all necessary fields.
                qliIdsToRequery.add(qli.Id);
            }
        }
        
        List<QuoteLineItem> quoteLineItemsToSync = new List<QuoteLineItem>();
        
        if (!qliIdsToRequery.isEmpty()) {
             // 1. Get the shared custom fields
            Set<String> customFieldsToQuery = LineItemSync.getSharedCustomFields();
            
            // 2. Add required standard fields
            List<String> fieldsToQueryList = new List<String>{'Id', 'OpportunityLineItemId', 'QuoteId'};
            fieldsToQueryList.addAll(customFieldsToQuery);
            String fieldsToQuery = String.join(fieldsToQueryList, ',');
            
            // 3. Build and execute dynamic SOQL query
            String query = 'SELECT ' + fieldsToQuery + ' FROM QuoteLineItem WHERE Id IN :qliIdsToRequery';
            
            quoteLineItemsToSync = Database.query(query);
        }
        // --- END: New logic ---


        if (!quoteLineItemsToSync.isEmpty()){ 
            LineItemSync.syncQLICustomFieldsToOLICustomFields(quoteLineItemsToSync);
        }
    }
}