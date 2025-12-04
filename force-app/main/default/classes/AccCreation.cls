public class AccCreation {
    public List<Account> createAccount(String name, String phone, String Email, Integer n){
        List<Account> accList = new List<Account>();
        for(Integer i=0; i<n; i++){
            Account acc = new Account();
            acc.name = name + ' ' + i;
            acc.phone = phone;
            acc.Email__c = email;
            accList.add(acc);
        }
        insert accList;
        return accList;
    }
}