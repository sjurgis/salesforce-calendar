# salesforce-calendar     [![Deploy to Salesforce](https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png)](https://githubsfdeploy.herokuapp.com?owner=sjurgis&repo=salesforce-calendar)
Custom calendar built on FullCalendar JavaScript framework. Easily to customize to work with custom objects.
This is an adaptation of Cody Sechelski's [Create a Calendar View in Salesforce.com](http://www.codebycody.com/2013/06/create-calendar-view-in-salesforcecom.html).



The main problem with his implementation was that it wasn't handling more than 2000 records. This was due to a Apex workaround, as it is reserves *start* and *end* variables, Cody made a repeat table and parsed that into JavaScript object. My solution creates JSON string in Apex and then uses string function to replace all startString and endString instances.
A more sensible solution would involve recreating the object in JavaScript or simply editing the FullCalendar library to look for different variable names.

I have also simplified the code a bit so you can start working towards your personal implementation. As this is using JavaScript remoting, I hope this gives you a framework to work towards more advanced features like editing or optimizing request sizes (executing a request on next month load).

The page
```html
<apex:page showHeader="false" standardStylesheets="false" controller="fullCalendar" >
    <script src="//cdnjs.cloudflare.com/ajax/libs/jquery/2.1.4/jquery.min.js"/>
    <script src="//cdnjs.cloudflare.com/ajax/libs/moment.js/2.10.3/moment.min.js"/>
    <script src="//cdnjs.cloudflare.com/ajax/libs/fullcalendar/2.3.1/fullcalendar.min.js"/>
    <link href="//cdnjs.cloudflare.com/ajax/libs/fullcalendar/2.3.1/fullcalendar.min.css" rel="stylesheet" />
    <link href="//cdnjs.cloudflare.com/ajax/libs/fullcalendar/2.3.1/fullcalendar.print.css" rel="stylesheet" media="print"  />
    <body>             
   <script type="text/javascript"> 
      function getEventData() {                         // records are retrieved from soql database
        Visualforce.remoting.Manager.invokeAction(
            '{!$RemoteAction.fullCalendar.eventdata}',  // controller and method names
            function(result, event){
                if (event.status) {
                    evt =  JSON.parse(result);
                    $('#calendar').fullCalendar({       // html element and library name
                        events: evt                     
                    }) 
                } else if (event.type === 'exception') { 
                    console.log(event.message);
                } else {
                    console.log(event.message);
                }
            }, 
            {escape: false}
        );
    }
    $(document).ready(function() {
        getEventData();
    });
    </script>
    <div id="calendar"></div>
    </body>
</apex:page>
```

The class
```apex
public class fullCalendar {
    public string eventsJSON {get;set;}
    
    //The calendar plugin is expecting dates is a certain format. We can use this string to get it formated correctly
    static String dtFormat = 'EEE, d MMM yyyy HH:mm:ss z';

    @RemoteAction
    public static string eventdata(){
        calEvent[] events = new calEvent[]{};
        for(Event evnt: [select Id, Subject, isAllDayEvent, StartDateTime, EndDateTime from Event]){
            DateTime startDT = evnt.StartDateTime;
            DateTime endDT = evnt.EndDateTime;
            
            calEvent myEvent = new calEvent();
            myEvent.title = evnt.Subject;
            myEvent.allDay = evnt.isAllDayEvent;
            myEvent.startString = startDT.format(dtFormat);
            myEvent.endString = endDT.format(dtFormat);
            myEvent.url = '/' + evnt.Id;
            myEvent.className = 'event-personal';
            events.add(myEvent);
        }
        
        string jsonEvents = JSON.serialize(events);
        jsonEvents = jsonEvents.replace('startString','start');
        jsonEvents = jsonEvents.replace('endString','end');
        
        return jsonEvents;
    }

    // Class to hold calendar event data
    public class calEvent {
        public String title {get;set;}
        public Boolean allDay {get;set;}
        public String startString {get;set;}
        public String endString {get;set;}
        public String url {get;set;}
        public String className {get;set;}
    }
}
```
Tested to 10'000 records with this execute anonymous
```apex
event[] bulklist= new event[]{};
for (integer i = 0; i < 100000; i++)
{
    string srnd = string.valueOf(math.random());
    blob rnd = Blob.valueOf(srnd);
    bulklist.add(new event (
        subject=encodingUtil.base64Encode(rnd),
        startDateTime=system.now().addDays(-10+ (math.random() * 10 ).intValue()),
        isAllDayEvent=true     
    ) );
}
insert bulklist;
```

*To do*: test with natural distribution graph.
