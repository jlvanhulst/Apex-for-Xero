trigger Billingrun_update on Agency_Billing_Run__c  (after update) {
        Agency_Billing_run__c r = Trigger.new[0];  // we'll support only one really, assume from user interface.
        TriggerLoopPrevent.firstRun = false;
        if (r.Sync_Trigger__c ) {
            database.executeBatch(new Export2XeroBatch(r.Name));    
    }
}