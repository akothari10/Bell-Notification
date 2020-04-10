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
    public static void prepareNotification(List<FlowInput> messageIds){
        
        Message__c message = [SELECT Id, heymarket__text__c, heymarket__Sf_Record_Id__c FROM Message__c WHERE Id = :messageIds[0].messageId][0];
        CustomNotificationType cusNotifId= [SELECT Id, DeveloperName FROM CustomNotificationType where DeveloperName = 'IncomingMessage' LIMIT 1];
        CustomNotificationActionInput input = new CustomNotificationActionInput();
        input.customNotifTypeId = cusNotifId.Id;
        input.recipientIds = new List<String>{UserInfo.getUserId()};
        
        String title = 'New Incoming Message from ';
        
        if(message.heymarket__Sf_Record_Id__c.startsWith('003')){
             Contact recipient = [SELECT Id, Name FROM Contact WHERE Id =: message.heymarket__Sf_Record_Id__c LIMIT 1][0];
             input.targetId = recipient.Id;
             title += recipient.Name;
        }
        else if(message.heymarket__Sf_Record_Id__c.startsWith('001')){
            Account recipient = [SELECT Id, Name FROM Account WHERE Id =: message.heymarket__Sf_Record_Id__c LIMIT 1][0];
            input.targetId = recipient.Id;
            title += recipient.Name;
        }
        else{
            Lead recipient = [SELECT Id, Name FROM Lead WHERE Id =: message.heymarket__Sf_Record_Id__c LIMIT 1][0];
            input.targetId = recipient.Id;
            title += recipient.Name;
        }
        
        input.title = title;
        input.body = message.heymarket__Text__c;
        
        CustomNotificationAction action = new CustomNotificationAction();
        action.inputs = new List<CustomNotificationActionInput>{input};
        sendCustomNotification(action);
        
    }

    public static void sendCustomNotification(CustomNotificationAction action){
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