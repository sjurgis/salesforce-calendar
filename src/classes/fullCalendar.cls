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
