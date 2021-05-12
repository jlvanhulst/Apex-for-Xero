global class Export2XeroBatch implements Database.Batchable<sObject>, Database.AllowsCallouts
{  
    Agency_Billing_Run__c	 run ;
    list<XeroInvoice> callInvoices;

    global Export2XeroBatch( string	 rname){
        run = [select id, Description__c from Agency_billing_run__c where name=:rname];
        callInvoices   = new List<XeroInvoice>();
        system.debug(callInvoices);
    }
        
    global Database.QueryLocator start(Database.BatchableContext BC)
    {    
        System.debug('- query start batch xero export ');
        return Database.getQueryLocator([SELECT name,Invoice_Date__c,Amount__c,Xero_ID__c, Agecny__r.name, Agecny__r.Xero_Id__c, Agecny__r.Terms__c  FROM Xero_Invoice__c WHERE Xero_ID__c='' AND Agency_Billing_Run__c=:run.Id]);
    }
    
    global void execute(Database.BatchableContext BC, List<Xero_Invoice__c> iList) {
        System.debug('- start exec batch xero export ');
// We'll want to make the parameters system variables not in the code on day. Invoice Status Account code 
        list<XeroInvoice> xiList;
        Integer i = 0;
        System.debug(iList);
        for (Xero_Invoice__c inv  : iList) {
            System.debug(inv.name+'->'+inv.agecny__r.name+' '+inv.Agecny__r.Xero_Id__c);
            if (!(String.isBlank(inv.Agecny__r.Xero_Id__c))) {  /// we need a Xero ID for the account to be allow it to go to Xero
                XeroInvoice xi = new XeroInvoice(inv.Agecny__r.Xero_Id__c); 
                xi.Date_x =dstring( inv.Invoice_Date__c)  ;	 //2019-08-20T00:00:00             
                xi.DueDate=dstring( (inv.Invoice_Date__c +terms(inv.agecny__r.terms__c) )) ; //2019-08-20T00:00:00
                xi.LineAmountTypes = 'Exclusive';
                xi.InvoiceNumber = inv.name;
                xi.status = 'SUBMITTED';
                xi.reference = run.description__c;
                list<Xero_Invoice_Line__c> li = [SELECT Amount__c , Quantity__c, Description__c, Unit_Amount__c  FROM Xero_Invoice_Line__c WHERE Xero_Invoice__c	=:inv.id 	];
                xi.LineItems = new List<XeroInvoice.LineItem>();
                for (Xero_Invoice_line__c ll : li) {
                    XeroInvoice.LineItem lineI = new XeroInvoice.LineItem( );
                    lineI.AccountCode = '41001';
                    lineI.ItemCode = '1022';
                    lineI.Description = ll.Description__c;
                    lineI.Quantity = ll.Quantity__c;
                    lineI.UnitAmount = ll.Unit_Amount__c ;
                    lineI.LineAmount = ll.Amount__c;
                 //   System.debug(LineI);         
                    xi.LineItems.add(lineI  );
                }
              //  System.debug(xi);
				callInvoices.add(xi);
            //    System.debug(xi);            
            }
        }
        callXero();
    }
    
    global void callxero(){
        list<XeroInvoice> returnInvoices;
        returnInvoices = new List<XeroInvoice>();
        System.debug('=talk to xero');
        for (XeroInvoice xi : callInvoices) {
           system.debug(xi);
           returnInvoices.add( XeroAPI.sendInvoice( xi ) );
        }
        System.debug(returnInvoices.size());
        System.debug('=== done talking to xero');
        for (XeroInvoice xr : returnInvoices) {
            Xero_invoice__c inv = [select xero_ID__c from xero_invoice__c where name=:xr.InvoiceNumber ];
            system.debug('boo');
            inv.Xero_ID__c = xr.InvoiceID;
            update inv;          
        }
    }  
    global void finish(Database.BatchableContext BC)
    {     }
 
    public static integer terms(String terms) {
        return Math.max( 30, integer.valueof(terms.right(2))) ;

    }
    public static string dstring(date d) {
        return d.year() + '-' + d.month() + '-' + d.day()+'T00:00:00';
    }  
}