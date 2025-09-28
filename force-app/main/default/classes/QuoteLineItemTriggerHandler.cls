public with sharing class QuoteLineItemTriggerHandler {
    
    public static void identifyQuoteLineItemsToSync(List<QuoteLineItem> newQLIs, Map<Id, QuoteLineItem> oldQLIMap){
        List<QuoteLineItem> quoteLineItemsToSync = new List<QuoteLineItem>();
        
        for(QuoteLineItem qli: newQLIs){
            if(qli.OpportunityLineItemId != null){
                quoteLineItemsToSync.add(qli);
            }
        }
        if (!quoteLineItemsToSync.isEmpty()){ 
            QuoteLineItemTriggerUtil.syncQLICustomFieldsToOLICustomFields(quoteLineItemsToSync);
        }
    }
}