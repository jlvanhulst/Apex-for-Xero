trigger Agencey_Billing_Run_Invoice on Agency_Billing_Run__c (after insert) {
    if(TriggerLoopPrevent.firstRun) {
       TriggerLoopPrevent.firstRun = false;
       Agency_Billing_run__c r = Trigger.new[0];  // we'll support only one really, assume from user interface.
       AgencyInvoicing.CreateInvoices( r.Id);
       AgencyInvoicing.CreateBillInvoices( r.Id);

    }
}