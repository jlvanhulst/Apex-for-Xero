@istest
public class TestExportInvoice2Xero {
    @isTest Static void ExportInvoice() {
        Test.startTest();
     
        id r = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency/Platform').getRecordTypeId();
        Account a1 = new Account(name='----Agency Test Account Invoice Separate',RecordTypeId =r, Invoice_Per_Campaign__c=true, Xero_Id__c='fa3cccca-d919-405c-acae-123e7ae2fed9');
        insert a1;
        Agency_Billing_run__c run = new Agency_Billing_run__c(Invoice_date__c =Date.today(),Start_date__c=Date.today(), End_date__c=Date.today() );
        insert run;
        Agency_Campaign__c ac = new Agency_Campaign__c(Name='---test---test--', Start_Date__c=Date.today(), Agency__c=a1.id,  Number_of_Campaigns__c =1 );
        insert ac;
        Xero_Invoice__c i = new  Xero_Invoice__c(Invoice_Date__c=Date.today(),Agecny__c=a1.id, Agency_Billing_run__c=run.id);
        insert i;
        Xero_invoice_Line__c il = new Xero_invoice_line__c(Account__c=a1.id,Agency_Campaign__c=ac.id,Xero_Invoice__c=i.id,Unit_amount__c=100, Quantity__c=1,Description__c='Test description');
        insert il;
 //       List<Xero_Invoice__c> iList = [SELECT name,Invoice_Date__c,Amount__c,Xero_ID__c, Agecny__r.name, Agecny__r.Xero_Id__c FROM Xero_Invoice__c WHERE Xero_ID__c=''];
//                list<Xero_Invoice_Line__c> li = [SELECT Amount__c , Quantity__c, Description__c, Unit_Amount__c  FROM Xero_Invoice_Line__c WHERE Xero_Invoice__c	=:inv.id 	];

        ExportInvoice2Xero.Export();
        Test.stopTest();
 
    }
    
}