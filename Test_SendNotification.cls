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
        for(Integer i= 1; i<=50; i++ ){
        messages.add(new Message__c(heymarket__Sf_Record_Id__c = con.Id,
                                    heymarket__text__c='Hello, You there?',
                                    heymarket__Created_On_Heymarket__c = System.now(),
                                    heymarket__External_Id__c = 'test'+i));
        messages.add(new Message__c(heymarket__Sf_Record_Id__c = acc.Id,
                                    heymarket__text__c='Hello, How are you?',
                                    heymarket__Created_On_Heymarket__c = System.now(),
                                    heymarket__External_Id__c = 'test'+(i+50)));
        messages.add(new Message__c(heymarket__Sf_Record_Id__c = ld.Id,
                                    heymarket__text__c='Hello, Whats Up?',
                                    heymarket__Created_On_Heymarket__c = System.now(),
                                    heymarket__External_Id__c = 'test'+(i+100)));
        }
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new NotificationResponseGenerator());
        insert messages;
        Test.stopTest();
        
    }
  
    @isTest 
    static void testContactNotification() {
        List<Message__c> messages = [SELECT Id FROM Message__c];
        List<SendNotification.FlowInput> input = new List<SendNotification.FlowInput>();
        for(Message__c msg: messages)
        	input.add(new SendNotification.FlowInput(msg.Id));
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new NotificationResponseGenerator());
        SendNotification.prepareAndSendNotification(input);
        Test.stopTest();
        
    }
    
}