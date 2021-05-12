public without sharing class AgencyInvoicing {
    /**
* @description Class to handle creating invoices for Agency Campaigns
* @return Nothing (Creates records in Xero Invoice and Invoice Line and one Billing Run record)
*/
    private static date InvoiceDate;
    private static Agency_Billing_Run__c run;
    private static date BillingStart;
    private static date BillingEnd;
/*    
    private static date LastDayofMonth(date d) {
        Return Date.newInstance(d.year(), d.month(), Date.daysInMonth(d.year(), d.month()));
    }
    private static date FirstDayofMonth(date d) {
        Return Date.newInstance(d.year(), d.month(), 1);
    } 
*/
       public static void CreateBillInvoices(string rId) {
        run = [Select Invoice_Date__c, End_date__c, Start_date__c FROM Agency_billing_run__c WHERE id = :rId] ;
        BillingStart = run.Start_date__c ;
        BillingEnd   = run.End_date__c;
        InvoiceDate  = run.Invoice_Date__c;  
        
        List<AggregateResult>  accts = [SELECT a.id, a.Invoice_per_campaign__c ipc, COUNT(Number_of_Campaigns__c) FROM Agency_campaign__c c, c.Billing_Account__r a WHERE (billing_date__c >=:BillingStart AND billing_date__c <=:BillingEnd AND Invoiced__c=FALSE AND Billing_Account__c!=null ) GROUP by a.id, a.Invoice_per_campaign__c  ];
        if (!accts.isEmpty()) { 
           // run = newRun(InvoiceDate); // create the batch hold record - will allow a delete and redo
            List<Xero_Invoice_Line__c> lines;
          //  List<Xero_Invoice__c> invs;
            lines = new List<Xero_Invoice_Line__c>(); 
         //   invs  = new List<Xero_invoice__c>();
            for (AggregateResult a : accts) {   
                
                //Account Agency = [SELECT Name, invoice_per_campaign__c FROM Account WHERE id=:a.id ];
                //System.debug('Agency '+a.Name);
                List<Agency_Campaign__c> cps = [SELECT id,name,SmartSuite__c,Description_for_Invoice__c,Agency__c,Number_of_Campaigns__c,Agency_Rate__c,Weekly_Rate__c, Max_Weeks__c,Weeks__c,Bill_extra_weeks__c FROM Agency_campaign__c c  WHERE ( Billing_Account__c=:a.id AND billing_date__c >=:BillingStart AND billing_date__c <=:BillingEnd AND Invoiced__c=FALSE  ) ];
                if ( (Boolean)a.get('ipc')) {  
                    
                    for (Agency_Campaign__c c : cps) {
                        
                        Xero_Invoice__c inv =  CreateXeroInvoice(a.id);
                      //  invs.add( inv );
                        lines.add(  CreateXeroInvoiceLine( inv,  c ) );
                        System.debug('Billto ipc Invoice -'+inv.name+' - '+c.name+' '+c.Description_for_Invoice__c+' ' );
                    }  
                } else {
                    Xero_Invoice__c inv = CreateXeroInvoice(a.id);
                   // invs.add( inv );
                    for (Agency_Campaign__c c : cps) {
                        lines.add(  CreateXeroInvoiceLine( inv,  c ) );
                        System.debug('Billto combined Invoice '+inv.name+' - '+c.name+' '+c.Description_for_Invoice__c+' ' );
                    }  
                    
                }
            }
         //   insert invs;
            Insert lines;
        }
    }
    public static void CreateInvoices(string rId) {
        run = [Select Invoice_Date__c, End_date__c, Start_date__c FROM Agency_billing_run__c WHERE id = :rId] ;
        BillingStart = run.Start_date__c ;
        BillingEnd   = run.End_date__c;
        InvoiceDate  = run.Invoice_Date__c;  
        
        List<AggregateResult>  accts = [SELECT a.id,  a.Invoice_per_campaign__c ipc, COUNT(Number_of_Campaigns__c) FROM Agency_campaign__c c, c.Agency__r a WHERE (billing_date__c >=:BillingStart AND billing_date__c <=:BillingEnd AND Invoiced__c=FALSE AND Billing_Account__c=null ) GROUP by a.id, a.Invoice_per_campaign__c  ];
        if (!accts.isEmpty()) { 
           // run = newRun(InvoiceDate); // create the batch hold record - will allow a delete and redo
            List<Xero_Invoice_Line__c> lines;
          //  List<Xero_Invoice__c> invs;
            lines = new List<Xero_Invoice_Line__c>(); 
         //   invs  = new List<Xero_invoice__c>();
            for (AggregateResult a : accts) {   
                
                //Account Agency = [SELECT Name, invoice_per_campaign__c FROM Account WHERE id=:a.id ];
                System.debug('Agency '+a.id);
                List<Agency_Campaign__c> cps = [SELECT id,name,SmartSuite__c,Description_for_Invoice__c,Agency__c,Number_of_Campaigns__c,Agency_Rate__c,Weekly_Rate__c, Max_Weeks__c,Weeks__c,Bill_extra_weeks__c FROM Agency_campaign__c c  WHERE (Agency__c=:a.id AND billing_date__c >=:BillingStart AND billing_date__c <=:BillingEnd AND Invoiced__c=FALSE AND Billing_Account__c=null	 ) ];
                if ( (Boolean)a.get('ipc')) {  
                    
                    for (Agency_Campaign__c c : cps) {
                        
                        Xero_Invoice__c inv =  CreateXeroInvoice(a.id);
                      //  invs.add( inv );
                        lines.add(  CreateXeroInvoiceLine( inv,  c ) );
                        	System.debug('Invoice -'+inv.name+' - '+c.name+' '+c.Description_for_Invoice__c+' ' );
                    }  
                } else {
                    Xero_Invoice__c inv = CreateXeroInvoice(a.id);
                   // invs.add( inv );
                    for (Agency_Campaign__c c : cps) {
                        lines.add(  CreateXeroInvoiceLine( inv,  c ) );
                        System.debug('Invoice '+inv.name+' - '+c.name+' '+c.Description_for_Invoice__c+' ' );
                    }  
                    
                }
            }
         //   insert invs;
            Insert lines;
        }
    }
    static Xero_Invoice__c CreateXeroInvoice(string ac) {
        Xero_Invoice__c inv = new Xero_Invoice__c(Agecny__c  = ac, invoice_date__c = InvoiceDate, Agency_Billing_Run__c = run.id );
        insert inv;
        return inv;
    }
    
    static Xero_Invoice_Line__c CreateXeroInvoiceLine(Xero_Invoice__c inv, Agency_Campaign__c c ) {
      System.debug( c.Agency_Rate__c );
       System.debug(c.Bill_Extra_Weeks__c );
                     System.debug( c.Weekly_Rate__c );
                    
        if (c.Weekly_Rate__c==null) {c.Weekly_Rate__c=0;}
        Xero_Invoice_Line__c l = new Xero_Invoice_Line__c( Account__c   = c.Agency__c, Xero_invoice__c= inv.Id, Agency_Campaign__c=c.Id, Quantity__c = c.Number_of_Campaigns__c, Unit_Amount__c = c.Agency_Rate__c +c.Bill_Extra_Weeks__c*c.Weekly_Rate__c , Description__c= c.Description_for_Invoice__c );
     //   insert l;
        return l;
    }
    
/**  static Agency_Billing_Run__c newRun(date d) {
        Agency_Billing_Run__c b	= new Agency_Billing_Run__c(End_Date__c = BillingEnd, Start_Date__c = BillingStart);
       insert b;
       return b;

    } 
*/  
}