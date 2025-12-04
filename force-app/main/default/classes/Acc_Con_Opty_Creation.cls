public class Acc_Con_Opty_Creation {
    public Account createAccount(String n, String e) {
        
        Account a = new Account();
        a.Name = n;
        a.Email__c = e;
        insert a;

        Contact c = new Contact();
        c.LastName = 'Satti Reddy';
        c.AccountId = a.Id;
        insert c;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        Date d = Date.newInstance(2012, 2, 17);
        opp.CloseDate = d;
        opp.StageName = 'Closed Lost';
        opp.AccountId = a.Id;
        insert opp;

        return a;
    }
}