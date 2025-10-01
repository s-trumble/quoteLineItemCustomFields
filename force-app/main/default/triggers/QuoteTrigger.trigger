trigger QuoteTrigger on Quote (after update) {
     if(Trigger.isUpdate && Trigger.isAfter){
        QuoteTriggerHandler.identifyQuoteLineItemsToSync(Trigger.New, Trigger.OldMap);
    }

}