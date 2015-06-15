@isTest public class fullCalendar_Test {
    static testMethod void fullCalendar_Test(){
        datetime dtStart = system.now();
        datetime dtEnd = dtStart.addHours(1);
        event testEvent = new event(Subject = 'Lisp4life', isAllDayEvent = false, StartDateTime = dtStart, EndDateTime = dtEnd);
        insert testEvent;

        PageReference upPage = Page.fullCalendar;
        Test.setCurrentPageReference(upPage);
        fullCalendar FC = new fullCalendar();
        string jsonS = fullCalendar.eventdata();
        String dtFormat = 'EEE, d MMM yyyy HH:mm:ss z';
        string expectedResult = '[{"url":"/'+ testEvent.id + '","title":"Lisp4life","start":"' + dtStart.format(dtFormat) + '","end":"' + dtEnd.format(dtFormat) + '","className":"event-personal","allDay":false}]' ;
    	system.assertEquals(expectedResult, jsonS);
    }
}
