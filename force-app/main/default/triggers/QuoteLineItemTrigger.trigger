trigger QuoteLineItemTrigger on QuoteLineItem (after update) {
    if(isUpdate() && isAfter()){
        QuoteLineItemTriggerHandler.syncCustomFields(Trigger.New);
    }

}