@isTest
public class Test_SendNotification {
    
    @testSetup
    static void setUp(){
        
        Contact con = new Contact(FirstName = 'Test', LastName = 'Contact');
        insert con;
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        Lead ld = new Lead(FirstName = 'Test', LastName = 'Account');
        insert ld;
        List<Message__c> messages = new List<Message__c>();
        messages.add(new Message__c(heymarket__Sf_Record_Id__c = con.Id,
                                    heymarket__text__c='Hello, You there?',
                                    heymarket__Created_On_Heymarket__c = System.now(),
                                    heymarket__External_Id__c = 'test1'));
        messages.add(new Message__c(heymarket__Sf_Record_Id__c = acc.Id,
                                    heymarket__text__c='Hello, How are you?',
                                    heymarket__Created_On_Heymarket__c = System.now(),
                                    heymarket__External_Id__c = 'test2'));
        messages.add(new Message__c(heymarket__Sf_Record_Id__c = ld.Id,
                                    heymarket__text__c='Hello, Whats Up?',
                                    heymarket__Created_On_Heymarket__c = System.now(),
                                    heymarket__External_Id__c = 'test3'));
        insert messages;
    }
    
    @isTest 
    static void testContactNotification() {
        List<Message__c> message = [SELECT Id FROM Message__c];
        List<SendNotification.FlowInput> input = new List<SendNotification.FlowInput>();
        input.add(new SendNotification.FlowInput(message[0].Id));
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new NotificationResponseGenerator());
        SendNotification.prepareNotification(input);
        Test.stopTest();
        
    }
    @isTest 
    static void testAccountNotification() {
        List<Message__c> message = [SELECT Id FROM Message__c];
        List<SendNotification.FlowInput> input = new List<SendNotification.FlowInput>();
        input.add(new SendNotification.FlowInput(message[1].Id));
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new NotificationResponseGenerator());
        SendNotification.prepareNotification(input);
        Test.stopTest();
        
    }
    @isTest 
    static void testLeadNotification() {
        List<Message__c> message = [SELECT Id FROM Message__c];
        List<SendNotification.FlowInput> input = new List<SendNotification.FlowInput>();
        input.add(new SendNotification.FlowInput(message[2].Id));
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new NotificationResponseGenerator());
        SendNotification.prepareNotification(input);
        Test.stopTest();
        
    }
}