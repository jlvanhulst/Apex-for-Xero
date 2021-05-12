public class ExportInvoice2Xero {
      public static void wait(Integer Seconds) {
        Long startingTime = System.now().getTime(); // Num milliseconds since Jan 1 1970
        Integer delayInMilliseconds = 1000*Seconds; // One-second delay
        while (System.now().getTime() - startingTime < delayInMilliseconds)  {
            // Do nothing until desired delay has passed
        }
    }  
    
  public static void Export() {
        List<Xero_Invoice__c> iList = [SELECT name,Invoice_Date__c,Amount__c,Xero_ID__c, Agecny__r.name, Agecny__r.Xero_Id__c FROM Xero_Invoice__c WHERE Xero_ID__c=''];
        list<XeroInvoice> xiList;
        Integer i = 0;
        for (Xero_Invoice__c inv  : iList) {
            System.debug(inv.name+'->'+inv.Agecny__r.Xero_Id__c);
            if (!(String.isBlank(inv.Agecny__r.Xero_Id__c))) {
                XeroInvoice xi = new XeroInvoice(inv.Agecny__r.Xero_Id__c); 
                xi.Date_x =dstring( inv.Invoice_Date__c)  ;	 //2019-08-20T00:00:00             
                xi.DueDate=dstring( (inv.Invoice_Date__c +30) ) ; //2019-08-20T00:00:00
                xi.LineAmountTypes = 'Exclusive';
                xi.InvoiceNumber = inv.name;
                xi.status = 'AUTHORISED';
                list<Xero_Invoice_Line__c> li = [SELECT Amount__c , Quantity__c, Description__c, Unit_Amount__c  FROM Xero_Invoice_Line__c WHERE Xero_Invoice__c	=:inv.id 	];
                xi.LineItems = new List<XeroInvoice.LineItem>();
                for (Xero_Invoice_line__c ll : li) {
                    XeroInvoice.LineItem lineI = new XeroInvoice.LineItem( );
                    lineI.AccountCode = '41001';
                    lineI.Description = ll.Description__c;
                    lineI.Quantity = ll.Quantity__c;
                    lineI.LineAmount = ll.Amount__c;
                    System.debug(LineI);         
                    xi.LineItems.add(lineI  );
                }
                XeroInvoice rt;
                if (test.isRunningTest()) {
                    rt = xi;
                } else {
                    rt = XeroAPI.sendInvoice( xi ); 
                }
                System.debug(xi);
                inv.Xero_ID__c = rt.InvoiceID;
                update inv;
                Wait(1);

            }
        }
    }
    
    public static string dstring(date d) {
        return d.year() + '-' + d.month() + '-' + d.day()+'T00:00:00';
    }
    
}