//This is Account trigger helper
public class AccountTriggerHelper {
    public static void addPrefixAsMr(List<Account> triggerNew, Map<Id, Account> triggerNewMap, List<Account> triggerOld, Map<Id, Account> triggerOldMap){
        for(Account acc : triggerNew){
            if(!acc.Name.startsWith('Mr.')){
                acc.Name = 'Mr.' + acc.Name;
            }
        }
    }
    
    public static void createContactByAccount(List<Account> triggerNew, Map<Id,Account> triggerNewMap, List<Account> triggerOld, Map<Id, Account> triggerOldMap){
        Set<Id> accountIds = new Set<Id>();
        List<Contact> contactListToInsert = new List<Contact>();
        for(Account a : triggerNew){
            accountIds.add(a.Id);
        }
        List<Account> accList = [SELECT Id, Name FROM Account WHERE Id IN : accountIds];
        if(accList != Null){
            for(Account acc : accList){
                Contact con = new Contact(LastName = 'ContactByAccount', AccountId = acc.Id);
                contactListToInsert.add(con);
            }
            if(!contactListToInsert.isEmpty()){
                insert contactListToInsert;
            }
        }
    }
    
    public static void accountDuplicate(List<Account> triggerNew, Map<Id, Account> triggerNewMap, List<Account> triggerOld, Map<Id, Account> triggerOldMap){
        Set<String> names = new Set<String>();
        for(Account a : triggerNew){
            names.add(a.Name);
        }
        Map<String, Account> dup = new Map<String, Account>([SELECT Id, Name FROM Account WHERE Name IN :names]);
        for(Account a : triggerNew){
            if(dup.containsKey(a.Name) && dup.get(a.Name).Id != a.Id){
                a.Name.addError('You cannot create duplicate Accounts');
            }
        }
    }
    
    public static void helloWorld(List<Account> triggerNew, Map<Id, Account> triggerNewMap, List<Account> triggerOld, Map<Id, Account> triggerOldMap){
        List<Account> acc = triggerNew;
        for(Account a : acc){
            if(a.Hello__c != 'World'){
                a.Hello__c = 'World';
            }
        }
    }
    public static void deleteAccount(List<Account> triggerNew, Map<Id, Account> triggerNewMap, List<Account> triggerOld, Map<Id, Account> triggerOldMap){
        if(UserInfo.getProfileId() != [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id){
            for(Account acc : triggerOld){
                acc.addError('You cannot delete Account records');
            }
        }
    }
    
    public static void contactCreationbyLocation(List<Account> triggerNew, Map<Id, Account> triggerNewMap, List<Account> triggerOld, Map<Id, Account> triggerOldMap){
        List<Contact> listCon = new List<Contact>();
        Map<Id, Decimal> mapAcc = new Map<Id, Decimal>();
        for(Account acc : triggerNew){
            if(acc.Number_of_Locations__c != null){
                mapAcc.put(acc.Id, acc.Number_of_Locations__c);    
            }
        }
        if(mapAcc.size() > 0){
            for(Id accId : mapAcc.keySet()){
                for(Integer i = 0; i < mapAcc.get(accId); i++){
                    Contact newCon = new Contact();
                    newCon.AccountId = accId;
                    newCon.LastName = 'Contact' + i;
                    listCon.add(newCon);
                }
            }
        }
        if(listCon.size() > 0){
            insert listCon;
        }
    }
    
    public static void updateSalesRep(List<Account> triggerNew, Map<Id, Account> triggerNewMap, List<Account> triggerOld, Map<Id, Account> triggerOldMap){
        Set<Id> accOwner = new Set<Id>();
        for(Account acc: triggerNew){
            accOwner.add(acc.OwnerId);
        }
        Map<Id,User> userMap = new Map<Id,User>([Select Name From User Where Id IN: accOwner]);
        for(Account Acc: triggerNew){
            User u = userMap.get(acc.OwnerId);
            acc.Sales_Rep__c = u.Name;
        }
    }
    
    public static void preventAccountDeletion(List<Account> triggerNew, Map<Id, Account> triggerNewMap, List<Account> triggerOld, Map<Id, Account> triggerOldMap){
        Set<ID> accId = new Set<Id>();
        for(Account acc: triggerOld){
            accId.add(acc.Id);
        }
        List<Opportunity> opp = [Select Id From Opportunity Where AccountId IN: accId];
        if(!opp.isEmpty()){
            for(Account acc: triggerOld){
                acc.addError('Cannot delete an account with related opportunities.');
            }
        }
    }
    
    public static void updateAddressOnAccount(List<Account> triggerNew, Map<Id, Account> triggerNewMap, List<Account> triggerOld, Map<Id, Account> triggerOldMap){
        for(Account a : triggerNew){
            if(a.Copy_Billing_To_Shipping__c == true){
                //a.ShippingCountry = a.BillingCountry;
                a.ShippingStreet = a.BillingStreet;
                a.ShippingCity = a.BillingCity;
                //a.ShippingState = a.BillingState;
                a.ShippingPostalCode = a.BillingPostalCode;
                a.ShippingCountryCode = a.BillingCountryCode;
                a.ShippingStateCode = a.BillingStateCode;
            }
        }
    }
    
    public static void emailOnAccountUpdate(List<Account> triggerNew, Map<Id, Account> triggerNewMap, List<Account> triggerOld, Map<Id, Account> triggerOldMap){
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        
        for (Account acc : triggerNew) {
            Account oldAcc = triggerOldMap.get(acc.Id);
            List<Contact> modifiedContacts = [SELECT Id, Name FROM Contact WHERE AccountId = :acc.Id AND LastModifiedDate > :oldAcc.LastModifiedDate];
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String emailSubject;
            String emailBody;
            
            if (!modifiedContacts.isEmpty()) {
                List<String> contactNames = new List<String>();
                for (Contact contact : modifiedContacts) {
                    contactNames.add(contact.Name);
                }
                
                emailSubject = 'Account Updated with New Contacts';
                emailBody = 'An account has been updated with the following contacts.\n';
                emailBody += 'Account Name : ' + acc.Name + '\n';
                emailBody += 'Account Id : ' + acc.Id + '\n';
                emailBody += 'Contacts : ' + String.join(contactNames, ', ');
                
            } else {
                emailSubject = 'Account Updated';
                emailBody = 'An account has been updated.\n';
                emailBody += 'Account Name : ' + acc.Name + '\n';
                emailBody += 'Account Id : ' + acc.Id + '\n';
            }
            
            mail.setToAddresses(new List<String>{acc.Owner.Email});
            mail.setSubject(emailSubject);
            mail.setPlainTextBody(emailBody);
            emailsToSend.add(mail);
        }
        
        if (!emailsToSend.isEmpty()) {
            Messaging.sendEmail(emailsToSend);
        }
    }
}