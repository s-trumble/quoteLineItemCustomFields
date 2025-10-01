public with sharing class QuoteLineItemTriggerHandler {
    
    public static void identifyQuoteLineItemsToSync(List<QuoteLineItem> newQLIs, Map<Id, QuoteLineItem> oldQLIMap){
        List<QuoteLineItem> quoteLineItemsToSync = new List<QuoteLineItem>();
        Set<Id> quoteIds = new Set<Id>();

        for(QuoteLineItem qli: newQLIs){
            if(qli.QuoteId != null){
                quoteIds.add(qli.QuoteId);
            }
        }

        Map<Id, Quote> quoteMap = new Map<Id, Quote>(
            [SELECT Id, QuoteId, IsSyncing 
            FROM Quote 
            WHERE Id IN :quoteIds]);
        
        for(QuoteLineItem qli: newQLIs){
            if(
                qli.OpportunityLineItemId != null &&
                quoteMap.containsKey(qli.QuoteId) &&
                quoteMap.get(qli.QuoteId).IsSyncing == true
                ){
                quoteLineItemsToSync.add(qli);
            }
        }
        if (!quoteLineItemsToSync.isEmpty()){ 
            QuoteLineItemTriggerUtil.syncQLICustomFieldsToOLICustomFields(quoteLineItemsToSync);
        }
    }
}