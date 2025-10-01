public with sharing class QuoteTriggerHandler {
    public QuoteTriggerHandler() {

    }
    public static void identifyQuoteLineItemsToSync(List<Quote> newQuotes, Map<Id, Quote> oldQuoteMap){
        List<QuoteLineItem> quoteLineItemsToSync = new List<QuoteLineItem>();
        Set<Id> quoteIds = new Set<Id>();

        for(Quote q : newQuotes){
            if(
                q.IsSyncing == true &&
                oldQuoteMap.get(q.Id).IsSyncing == false
                ){
                quoteIds.add(q.Id);
                }
        }
        
        // --- FIX START: Query the custom fields dynamically ---
        if (quoteIds.isEmpty()) {
            return;
        }

        // 1. Get the shared custom fields
        Set<String> customFieldsToQuery = LineItemSync.getSharedCustomFields();
        
        // 2. Add required standard fields
        List<String> fieldsToQueryList = new List<String>{'Id', 'OpportunityLineItemId', 'QuoteId'};
        fieldsToQueryList.addAll(customFieldsToQuery);
        String fieldsToQuery = String.join(fieldsToQueryList, ',');
        
        // 3. Build and execute dynamic SOQL query
        String query = 'SELECT ' + fieldsToQuery + ' FROM QuoteLineItem WHERE QuoteId IN :quoteIds';
        
        List<QuoteLineItem> queriedQlis = Database.query(query);

        Map<Id, QuoteLineItem> qliMap = new Map<Id, QuoteLineItem>(queriedQlis);
        // --- FIX END ---

        quoteLineItemsToSync.addAll(qliMap.values());
    
        if (!quoteLineItemsToSync.isEmpty()){ 
            LineItemSync.syncQLICustomFieldsToOLICustomFields(quoteLineItemsToSync);
        }
    }

    
}