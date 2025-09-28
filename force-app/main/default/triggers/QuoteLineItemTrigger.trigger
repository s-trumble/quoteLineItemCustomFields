trigger QuoteLineItemTrigger on QuoteLineItem (after update) {
    if(Trigger.isUpdate && Trigger.isAfter){
        QuoteLineItemTriggerHandler.identifyQuoteLineItemsToSync(Trigger.New, Trigger.OldMap);
    }
}