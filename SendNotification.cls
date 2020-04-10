public class SendNotification {
    public class FlowInput{
        @InvocableVariable
        public String messageId;
        
        public FlowInput(){
            
        }
        public FlowInput(String messageId){
            this.messageId = messageId;
        }
    }
    @InvocableMethod(label='Send Notification To User' description='Send Salesforce Notification on Incoming message' category='Message')
    public static void prepareAndSendNotification(List<FlowInput> messageIds){
        List<String> msgIds = new List<String>();
        for(FlowInput messagId:messageIds){
            msgIds.add(messagId.messageId);
        }
        //Send Notification in future
        sendCustomNotification(msgIds);
        
    }
    @future(callout=true)
    public static void sendCustomNotification(List<String> messageId){
        List<heymarket__Message__c> messages = [SELECT Id, heymarket__text__c, heymarket__Sf_Record_Id__c FROM heymarket__Message__c WHERE Id IN :messageId];
        CustomNotificationType cusNotifId= [SELECT Id, DeveloperName FROM CustomNotificationType where DeveloperName = 'IncomingMessage' LIMIT 1];
        Map<Id,Id> contactWithMessage = new Map<Id,Id>();
        Map<Id,Id> leadWithMessage = new Map<Id,Id>();
        Map<Id,Id> accountWithMessage = new Map<Id,Id>();
        for(heymarket__Message__c message : messages){
            if(message.heymarket__Sf_Record_Id__c.startsWith('003')){
                contactWithMessage.put(message.Id,message.heymarket__Sf_Record_Id__c);
            }
            else if(message.heymarket__Sf_Record_Id__c.startsWith('001')){
                accountWithMessage.put(message.Id,message.heymarket__Sf_Record_Id__c);
            }
            else if(message.heymarket__Sf_Record_Id__c.startsWith('00Q')){
                leadWithMessage.put(message.Id,message.heymarket__Sf_Record_Id__c);                
            }
        }
        Map<ID,Contact> contacts = new Map<ID, Contact>([SELECT Id, Name FROM Contact WHERE Id IN :contactWithMessage.values() ]);
        Map<ID,Lead> leads = new Map<ID, Lead>([SELECT Id, Name FROM Lead WHERE Id IN :leadWithMessage.values()]);
        Map<ID,Account> accounts = new Map<ID, Account>([SELECT Id, Name FROM Account WHERE Id IN :accountWithMessage.values()]);
        List<CustomNotificationActionInput> inputs = new List<CustomNotificationActionInput>();
        for(heymarket__Message__c message : messages){
            CustomNotificationActionInput input = new CustomNotificationActionInput();
            input.customNotifTypeId = cusNotifId.Id;
            input.recipientIds = new List<String>{UserInfo.getUserId()};
                
            String title = 'New Incoming Message from ';
            
            if(message.heymarket__Sf_Record_Id__c.startsWith('003')){
                input.targetId = contactWithMessage.get(message.id);
                title += contacts.get(contactWithMessage.get(message.id)).Name;
            }
            else if(message.heymarket__Sf_Record_Id__c.startsWith('001')){
                input.targetId = accountWithMessage.get(message.id);
                title += accounts.get(accountWithMessage.get(message.id)).Name;
            }
            else if(message.heymarket__Sf_Record_Id__c.startsWith('00Q')){
                input.targetId = leadWithMessage.get(message.id);
                title += leads.get(leadWithMessage.get(message.id)).Name;
            }
            
            input.title = title;
            input.body = message.heymarket__Text__c;
            inputs.add(input);
        }
        CustomNotificationAction action = new CustomNotificationAction();
        action.inputs = inputs;
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(Url.getOrgDomainUrl().toExternalForm() + '/services/data/v46.0/actions/standard/customNotificationAction');
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JSON.serialize(action));
        HttpResponse res = h.send(req);
        System.debug(res.getBody());
        
    }
    public class CustomNotificationAction
    {
        public List<CustomNotificationActionInput> inputs { get; set; }
    }
    
    public class CustomNotificationActionInput
    {
        public String customNotifTypeId { get; set; }
        public List<String> recipientIds { get; set; }
        public String title { get; set; }
        public String body { get; set; }
        public String targetId { get; set; }
    }
}