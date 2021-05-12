trigger InsertBillingDateForAgencyCampaigns on Agency_Campaign__c (before insert) {
    for (Agency_Campaign__C a : Trigger.new ) {
        Date d = a.Start_Date__c;
        if (!(d==null) && a.Billing_date__c==null) {
            a.Billing_Date__c = Date.newInstance(d.year(), d.month(), Date.daysInMonth(d.year(), d.month()));
            // System.debug(Date.newInstance(d.year(), d.month(), Date.daysInMonth(d.year(), d.month())) );
        }
        if (a.Rate__c==null) {
           a.Rate__c = a.Agency_Rate__c;
        }
        if (a.Max_Weeks__c ==null) {
           a.Max_Weeks__c  = a.Agency_weeks__c;
        }
        if (a.Weekly_rate__c==null && !(a.Agency_week_rate__c==null) ) {
           a.Weekly_rate__c = a.Agency_week_rate__c;
        }
        else // if there is a weekly rate we don't do # of campaigns based on weeks!
        {
           if (!(a.Weeks__c==null || a.Agency_weeks__c==null)  ) {
            a.Number_of_Campaigns__c = Math.round( a.Weeks__c / a.Agency_weeks__c)	;
           } 
        }
    }
    
}