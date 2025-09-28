public with sharing class QuoteLineItemTriggerHandler {
    public static void identifyQuoteLineItemsToSync(List<QuoteLineItem> quoteLineItems){
        List<QuoteLineItem> quoteLineItemsToSync = new List<QuoteLineItem>();
        for(QuoteLineItem qli: quoteLineItems){
            if(qli.OpportunityLineItem != null){
                quoteLineItemsToSync.add(qli);
            }
        }
        if(!isEmpty(quoteLineItemsToSync)){
            QuoteLineItemTriggerUtil.syncQLICustomFieldsToOLICustomFields(quoteLineItemsToSync);
        }
    }
}