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

        Map<Id, QuoteLineItem> qliMap = new Map<Id, QuoteLineItem>(
            [SELECT Id, OpportunityLineItemId, QuoteId
            FROM QuoteLineItem
            WHERE QuoteId IN :quoteIds]
        );

        quoteLineItemsToSync.addAll(qliMap.values());
    
        if (!quoteLineItemsToSync.isEmpty()){ 
            LineItemSync.syncQLICustomFieldsToOLICustomFields(quoteLineItemsToSync);
        }
    }

    
}