# Salesforce DX Project: Next Steps

This project maps values in custom fields on QuoteLineItem to custom fields on OpportunityLineItem when they share the same API name and the parent quote is syncing. 
E.g. QuoteLineItem.My_custom_field__c will map to OpportunityLineItem.My_custom_field__c, but QuoteLineItem.My_custom_field__c will NOT map to OpportunityLineItem.Your_custom_field__c as the field's have different API names. 

It is expected that your custom fields have the same data type or could accept the values from QuoteLineItem field into the OpportunityLineItem field. 
