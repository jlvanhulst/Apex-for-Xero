global class CreatingInvoicesBatch implements Database.Batchable<sObject>  {  
    
     date InvoiceDate;
     Agency_Billing_Run__c run2;
     date BillingStart;
     date BillingEnd;

     global CreatingInvoicesBatch(string	 rname){
        run2 = [select id, Description__c,Invoice_Date__c, End_date__c, Start_date__c from Agency_billing_run__c where name=:rname];   
     }    
    
     global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator( [select id, Description__c,Invoice_Date__c, End_date__c, Start_date__c  from Agency_billing_run__c where id=:run2.id]);
    }
    
    global void finish(Database.BatchableContext BC)
    {     }
    
    global void execute(Database.BatchableContext BC, List<Agency_Billing_Run__c> run ) {
        BillingStart = run2.Start_date__c ;
        BillingEnd   = run2.End_date__c;
        InvoiceDate  = run2.Invoice_Date__c;  
        
        List<AggregateResult>  accts = [SELECT a.id, COUNT(Number_of_Campaigns__c) FROM Agency_campaign__c c, c.Agency__r a WHERE (billing_date__c >=:BillingStart AND billing_date__c <=:BillingEnd AND Invoiced__c=FALSE ) GROUP by a.id ];
        if (!accts.isEmpty()) { 
           // run = newRun(InvoiceDate); // create the batch hold record - will allow a delete and redo
            
            for (AggregateResult a : accts) {   
                
                Account Agency = [SELECT Name, invoice_per_campaign__c FROM Account WHERE id=:a.id ];
                System.debug('Agency '+Agency.name);
                List<Agency_Campaign__c> cps = [SELECT id,name,SmartSuite__c,Description_for_Invoice__c,Agency__c,Number_of_Campaigns__c,Agency_Rate__c,Weekly_Rate__c, Max_Weeks__c,Weeks__c,Bill_extra_weeks__c  FROM Agency_campaign__c c  WHERE (Agency__c=:a.id AND billing_date__c >=:BillingStart AND billing_date__c <=:BillingEnd AND Invoiced__c=FALSE ) ];
                
                if (Agency.Invoice_Per_Campaign__c) {  
                    
                    for (Agency_Campaign__c c : cps) {
                        
                        Xero_Invoice__c inv = CreateXeroInvoice(Agency.id);
                        Xero_Invoice_line__c line = CreateXeroInvoiceLine( inv,  c );
                        System.debug('Invoice -'+inv.name+' - '+c.name+' '+c.Description_for_Invoice__c+' ' );
                    }  
                } else {
                    Xero_Invoice__c inv = CreateXeroInvoice(Agency.id);
                    for (Agency_Campaign__c c : cps) {
                        Xero_Invoice_line__c line = CreateXeroInvoiceLine( inv,  c );
                        
                        System.debug('Invoice '+inv.name+' - '+c.name+' '+c.Description_for_Invoice__c+' ' );
                    }  
                    
                }
            }
        }
    }
    global Xero_Invoice__c CreateXeroInvoice(string ac) {
        Xero_Invoice__c inv = new Xero_Invoice__c(Agecny__c  = ac, invoice_date__c = InvoiceDate, Agency_Billing_Run__c = run2.id );
        insert inv;
        return inv;
    }
    
    global Xero_Invoice_Line__c CreateXeroInvoiceLine(Xero_Invoice__c inv, Agency_Campaign__c c ) {
      System.debug( c.Agency_Rate__c );
       System.debug(c.Bill_Extra_Weeks__c );
                     System.debug( c.Weekly_Rate__c );
                    
        if (c.Weekly_Rate__c==null) {c.Weekly_Rate__c=0;}
        Xero_Invoice_Line__c l = new Xero_Invoice_Line__c( Account__c   = c.Agency__c, Xero_invoice__c= inv.Id, Agency_Campaign__c=c.Id, Quantity__c = c.Number_of_Campaigns__c, Unit_Amount__c = c.Agency_Rate__c +c.Bill_Extra_Weeks__c*c.Weekly_Rate__c , Description__c= c.Description_for_Invoice__c );
        insert l;
        return l;
    }
    
/**  static Agency_Billing_Run__c newRun(date d) {
        Agency_Billing_Run__c b	= new Agency_Billing_Run__c(End_Date__c = BillingEnd, Start_Date__c = BillingStart);
       insert b;
       return b;

    } 
*/  

}