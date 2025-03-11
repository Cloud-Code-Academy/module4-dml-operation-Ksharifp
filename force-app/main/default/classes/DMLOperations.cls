/**
 * The DMLOperations class serves as a deep dive into Data Manipulation Language (DML) in Apex.
 * It covers fundamental DML operations such as insert, update, upsert, and delete.
 *
 * This class introduces developers to the concept of manipulating Salesforce records in Apex.
 * It discusses how to use DML operations to create, update, and delete records.
 * This class uses standard Salesforce objects like Account, Contact, and Opportunity for demonstration.
 *
 * Topics covered in this class include:
 * - Understanding how to use insert DML operation to create records in Salesforce.
 * - Understanding how to use update and upsert DML operations to update existing records in Salesforce.
 * - Understanding how to use delete DML operation to remove records from Salesforce.
 *
 * Users of this class can expect to gain a strong understanding of DML operations in Apex and
 * be prepared for more advanced topics in Salesforce development.
 *
 * The methods within this class serve as practical examples of different DML operations,
 * allowing developers to learn through practice and examples.
 *
 * @author Kharaam Sharifpour 
 */


public with sharing class DMLOperations {

    /**
     * Question 1
     * Create a new Account object and insert it into the database.
     * The Account will have a random name for uniqueness.
     * @return The Id of the newly created Account.
     */
    public static Id insertNewAccount() {
        // Create a new Account instance
        Account newAcc = new Account();
        // Set some fields on the Account
        newAcc.Name = 'Kharaam-'+ Math.round(Math.random()*1000);
        // Insert the Account into the database
        //insert newAcc;
        // Return the Id of the newly created Account
        //return newAcc.Id;
        insert newAcc;
        return newAcc.Id;
    }

    /**
     * Question 2
     * Create a new Account with the specified name and industry provided.
     * @param name The name of the account to be created.
     * @param industry The industry of the account to be created.
     */
    public static void createAccount(String name, String industry) {
        // Create a new Account and set the fields inline
        Account inlineAcc = new Account(Name = name, Industry = industry);
        // Insert the Account
        insert inlineAcc;
    }

    
    /**
     * Question 3
     * Create a new Contact and link it to the Account id provided then inserts it into the database.
     * @param accountId The Id of the Account to link the Contact to.
     * @return The Id of the newly created Contact.
     */
    public static Id insertNewContact(Id accountId) {
        // Create a new Contact instance

        Contact newContact = new Contact();
        // Set some fields on the Contact
        // Set the AccountId field to the given accountId

        newContact.FirstName = 'Kharaam';
        newContact.LastName = 'Sharifpour';
        newContact.AccountId = accountId;
        // Insert the Contact into the database

        insert newContact;
        // Return the Id of the newly created Contact

        return newContact.Id;
    }

    /**
     * Question 4
     * Update the last name of a Contact in the database.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param contactId The Id of the Contact to update.
     * @param newLastName The new last name for the Contact.
     */
    public static void updateContactLastName(Id contactId, String newLastName) {
        // Retrieve the Contact from the database
        // [SELECT Id FROM Contact WHERE Id = :contactId]

        Contact newContact2 = [SELECT Id, LastName FROM Contact WHERE Id = :contactId LIMIT 1];
        // Update the Contact's last name
        newContact2.LastName = newLastName;
        // Update the Contact in the database
        update newContact2;
    }

    /**
     * Question 5
     * Update the stage of an Opportunity in the database.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param oppId The Id of the Opportunity to update.
     * @param newStage The new stage for the Opportunity.
     */
    public static void updateOpportunityStage(Id oppId, String newStage) {
        // Retrieve the Opportunity from the database
        // [SELECT Id FROM Opportunity WHERE Id = :oppId]
        Opportunity oppoToUpdate = [SELECT Id, StageName FROM Opportunity WHERE Id = :oppId];
        // Update the Opportunity's stage
        oppoToUpdate.StageName = newStage;
        // Update the Opportunity in the database
        update oppoToUpdate;
    }

    /**
     * Question 6
     * Update the Account's Name and Industry given an Account Id.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param accountId The Id of the account to be updated.
     * @param newName The new name for the account.
     * @param newIndustry The new industry for the account.
     */
    public static void updateAccountFields(Id accountId, String newName, String newIndustry) {
        // Query the account
        // [SELECT Id FROM Account WHERE Id = :accountId]
        Account accToUpdate = [SELECT Id, Name, Industry FROM Account WHERE Id = :accountId];
        // Update the Account with the given Id with the new name and industry
        accToUpdate.Name = newName;
        accToUpdate.Industry = newIndustry;
        update accToUpdate; 
    }   


    /**
     * Question 7
     * Create or updates an Opportunities
     * The Opportunity's Stage is set to Qualification.
     * The Opportunity's Close Date is set to 3 months from today.
     * The Opportunity's Amount is set to 50000.
     * @param list of Opportunities to be changed then upserted.
     */
    public static void upsertOpportunityList(List<Opportunity> opportunities) {
        // Loop through each Opportunity in the list
        for ( Opportunity oppoToUpdate : opportunities) {
            // Set the Opportunity's Stage to Qualification
            oppoToUpdate.StageName = 'Qualification';
            // Set the Opportunity's Close Date to 3 months from today
            oppoToUpdate.CloseDate = Date.today().addMonths(3);
            // Set the Opportunity's Amount to 50000
            oppoToUpdate.Amount = 50000;
        }
        upsert opportunities;
        // Upsert the opportunities List so that records are either updated or created
    }

    /**
     * Question 8
     * Insert or update opportunities from list of names.
     * Associate the Opportunities with account that has the name accountName.
     * There should be an Opportunity for each name provided in the list.
     * HINT: The account may or may not exists in the database but is required for opportunity creation. Consider how upsert operation can help with this.
     * HINT: There should not be duplicate opportunites based on the name
     * @param accountName The name of the Account.
     * @param oppNames The list of Opportunity names.
     */
    public static void upsertOpportunities(String accountName, List<String> oppNames) {
        if (oppNames.isEmpty() || accountName == null) {
            System.debug('There are no opportunity names on the list');
        }
        if (!oppNames.isEmpty()) {
            Set<String> oppNamesSet = new Set<String>(oppNames);
            Account oppsAcc = new Account(Name = accountName);
            upsert oppsAcc;
            Integer counter = 0;
            List<Opportunity> oppsToUpsert = new List<Opportunity>();
            // Loop through each Opportunity name

            for (String oppoName : oppNamesSet) {
                Opportunity opp = new Opportunity();
                opp.Name = oppoName;
                opp.CloseDate = Date.today().addMonths(3);
                opp.StageName = 'qualification';
                opp.AccountId = oppsAcc.Id;
                // Add the Opportunity to the list

                oppsToUpsert.add(opp);
            }
            // Create an Opportunity with the given name

            upsert oppsToUpsert;
        }
    
    }
    
    /**
     * Question 9
	 * Upserts an Account with the specified name.
	 * If an Account with the given name already exists, update the description to "Updated Account".
	 * If no such Account exists, it creates a new one and sets the description to "New Account".
	 * @param accountName The name of the Account to be upserted.
	 * @return The Account that was upserted.
	 */
	public static Account upsertAccount(String accountName) {
		// Query for the Account
		List<Account> accounts = [SELECT Id FROM Account WHERE Name = :accountName];
        Account acc = new Account();
		// if the Account exists, update the description
        if ( accounts.isEmpty()) {
            acc.description = 'New Account';
            acc.Name = accountName;
            }
        if (!accounts.isEmpty()) {
            acc = accounts[0];
            acc.description = 'Updated Account';
        } 
		// Upsert the Account
        upsert acc;
		return acc;
	}

    /**
     * Question 10
	 * Manage the association between Contacts and Accounts
	 * Ensure that for each Contact in the provided list, there is a corresponding Account Name that matches the Contact's last name.
	 * If such an Account does not exist, the method creates it; if it does, the method ensures the Contact is associated with it. (Hint: use previous upsertAccount method - this may cause bad practices but for learning purposes it's okay.)
     * Example Contact.LastName = 'Doe' Link to Account.Name = 'Doe' 
     * Example Contact.LastName = 'Jane' Link to Account.Name = 'Jane'
	 * @param contactsToUpsert List of Contacts to be upserted and linked to accounts.
	 */
	public static List<Database.UpsertResult> upsertAccountsWithContacts(List<Contact> contactsToUpsert) {
		// Loop through each Contact
        // I am trying to separate the contacts 
        // There might be three categories of contacts and accounts: 1) Contacts missing Accounts
        // 2) Contacts with Accounts and 3) Contacts that are not associated with an account but the account exists
        // I might end up having to put them together to use the upsert method
        // I rather separate the contacts and accounts and deal with them separately first.
        // Create a list of contacts who are missing Account.Id (there might be a need to create new accounts or find and connect them to the contact)
        // Create a list of contacts who are not missing account.Ids and are associated with a list of existing accounts
        
        // list of contacts that are missing Account.Id and the Account may or may not exist
        List<Contact> conMissingAcc = new List<Contact>([SELECT Id, AccountId, LastName FROM Contact WHERE AccountId = null]);

        // list of contacts that are associated with the correct existing account
        List<Contact> conWithAcc = new List<Contact>([SELECT Id, AccountId, LastName FROM Contact WHERE AccountId != null]);

        // list of contacts that are not connected to an account but the account exists
        List<Contact> conNotAssociatedWithAcc = new List<Contact>();

        // to make sure the Account records are unique, create sets
        //Set<Account> newAcc = new Set<Account>();
        //Set<Account> existingAcc = new Set<Account>();
        
        Account acc = new Account();

        List<Account> newAccS = new List<Account>();
            
            for (Contact con : contactsToUpsert) {
                if (con.AccountId == null) {
                    acc.Name = con.LastName;
                    conMissingAcc.add(con);
                    newAccS.add(acc);
                }
            }
        List<Database.upsertResult> upsertedAcc = Database.upsert(newAccS,false);
        List<Account> upsertedAccountIdNames = [SELECT Id, Name FROM Account WHERE Id =: upsertedAcc];
        Map<String, Id> upsAccNameIdMap = new Map<String, Id>();
            for (Database.UpsertResult upsAcc : upsertedAcc) {
                upsAccNameIdMap.put(   ,upsAcc.getId());
            }

        //Map<String, Id> conLastNameIdMap = new Map<String, Id>();
          //  for (Contact con2 :conMissingAcc) {
          //      conLastNameIdMap.put(con2.LastName, con2.Id);
          //  }
        
            for (Contact con3 : contactsToUpsert) {
                if (upsAccNameIdMap.containsKey(con3.LastName)) {
                    con3.AccountId = upsAccNameIdMap.get(con3.LastName);
                }
            }


        /*List<Contact> conToUpsert = new List<Contact>();
        List<Account> accToUpsert = new List<Account>( [SELECT Id, Name FROM Account WHERE Id =:uniqueAcc]);
        List<Database.upsertResult> upsertedAcc = Database.upsert(accToUpsert,false);
        Map<Id, Account> upsAccM = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Id =:upsertedAcc]);
        Map<Id, String> upsAccIdName = new Map<Id, String>();
            for (Contact con2 : contactsToUpsert) {
                if (upsAccM.containsKey(con2.LastName))
            }
        List<Database.upsertResult> consWithAcc = Database.upsert(conToUpsert,false);
        */
        return upsertedAcc;
    }
        

    /**
     * Question 11
     * Insert a list of Leads and then delete them.
     * @param leadNames The list of Lead names to be inserted.
     */
    public static void insertAndDeleteLeads(List<String> leadNames) {
        List<Lead> leadsToInsert = new List<Lead>();
        // Loop through each Lead name
        for (String ldName : leadNames) {
            Lead myLead = new Lead (LastName = ldName, Company = (ldName +'\'s Company'), Status = 'Open - Not Contacted');
            leadsToInsert.add(myLead);
        }   
        // Insert the Leads
        insert leadsToInsert;
        // Delete the Leads
        delete leadsToInsert;
    }


    /**
     * Question 12
     * Dynamically create the number of cases and relate it to the accountId, then delete them.
     * @param accountId The account for which the cases will be created and then deleted.
     * @param numOfCases The number of cases to create.
     */
    public static void createAndDeleteCases(String accountId, Integer numOfCases) {
        List<Case> casesToInsert = new List<Case>();
        
        for (Integer i = 0; i < numOfCases; i++) {
            Case newCase = new Case(Description = accountId + ' - ' +i, AccountId = accountId);
            casesToInsert.add(newCase);
        }
        // Insert the cases
        insert casesToInsert;

        // Delete the cases
        delete casesToInsert;
    }
}