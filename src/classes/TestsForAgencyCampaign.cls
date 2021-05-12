@istest
public class TestsForAgencyCampaign {
    @isTest static void TestInsertTrigger() {
        Test.startTest();
        
        // Test data setup
        // Create an account with an opportunity, and then try to delete it
        id r = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency/Platform').getRecordTypeId();
        Account a = new Account(name='----Agency Test Account',RecordTypeId =r, Rate__c=2500,Weekly_rate__c	=250, Max_Length__c=6 );
        insert a;
        Agency_Campaign__c ac = new Agency_Campaign__c(Name='---test---test--', Start_Date__c=Date.today(), Agency__c=a.id, Number_of_Campaigns__c =1 );
        // Perform test
        insert ac;
        Test.stopTest();
        Agency_Campaign__c check = [SELECT billing_date__c FROM Agency_Campaign__c WHERE id = :ac.id];
        System.debug( check.billing_date__c );
        System.assert(check.billing_date__c==eom(Date.today()));
    }
    private static date eom(date d) {   
        return   Date.newInstance(d.year(), d.month(), Date.daysInMonth(d.year(), d.month()));  
    }
    
    @isTest Static void createInvoice() {
        Test.startTest();
        
        id r = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency/Platform').getRecordTypeId();
        Account a1 = new Account(name='----Agency Test Account Invoice Separate',RecordTypeId =r, Invoice_Per_Campaign__c=true);
        insert a1;
        Account a2 = new Account(name='----Agency Test Account Combo',RecordTypeId =r,Invoice_Per_Campaign__c=false);
        insert a2;
      //  Account a3 = new Account(name='----Agency Test Bill As Account',RecordTypeId =r,Invoice_Per_Campaign__c=false, AccountNumber='123' );
      //  insert a3;
        
        Agency_Campaign__c ac1 = new Agency_Campaign__c(SmartSuite__c='#1',Name='---test---test--1', Number_of_Campaigns__c =1,Start_Date__c=Date.today(), Agency__c=a1.id );
        Agency_Campaign__c ac2 = new Agency_Campaign__c(SmartSuite__c='#2',Name='---test---test--2', Number_of_Campaigns__c =1,Start_Date__c=Date.today(), Agency__c=a2.id );
        Agency_Campaign__c ac3 = new Agency_Campaign__c(Billing_Account__c=a1.id, SmartSuite__c='#3',Name='---test---test--3', Number_of_Campaigns__c =1,Start_Date__c=Date.today(), Agency__c=a2.id );

        insert ac1;
        insert ac2;
        insert ac3;

        Agency_Billing_run__c run = new Agency_Billing_run__c(Invoice_Date__c = eom(Date.today()), End_date__c=eom(Date.today()), Start_date__c=Date.today() );
        insert run;
        //AgencyInvoicing.CreateInvoices(run.id);
        run.Sync_Trigger__c = true;
        update run; // now test the update trigger.
        Test.stopTest();
        
    }
}