public with sharing class AvailableTimeSlotFinder {

    // Input wrapper for the invocable action
    public class InputVariables {
        @InvocableVariable(label='Service ID' required=true)
        public Id serviceId;

        @InvocableVariable(label='Resource ID' required=true)
        public Id resourceId;

        @InvocableVariable(label='Preferred Date' required=true)
        public Date preferredDate;
    }

    // toata problema era ca Collection Choice Set accepta doar record / apex-defined collection, nu String

    @InvocableMethod(label='Find Available Timeslots, If Any')
    public static List<List<TimeSlotItem>> findAvailableTimeSlots(List<InputVariables> inputVariables) {
        if (inputVariables == null || inputVariables.isEmpty()) {
            throw new AuraHandledException('Input variables are required.');
        }
        
        List<List<TimeSlotItem>> output = new List<List<TimeSlotItem>>();

        for (InputVariables inputVar : inputVariables) {
            // NOTE: this has SOQL-in-loop; ok for single-request Screen Flow,
            // but bulkify if you ever pass many requests.
            Service__c service = [
                SELECT Id, Duration__c
                FROM Service__c
                WHERE Id = :inputVar.serviceId
                LIMIT 1
            ];

            Resource__c resource = [
                SELECT Id, Working_Hours_Start__c, Working_Hours_End__c
                FROM Resource__c
                WHERE Id = :inputVar.resourceId
                LIMIT 1
            ];

            Date selectedDate = inputVar.preferredDate;
            Datetime startOfDay = Datetime.newInstance(selectedDate, Time.newInstance(0, 0, 0, 0));
            Datetime endOfDay = startOfDay.addDays(1);

            List<Appointment__c> appointments = [
                SELECT Start_Time__c, End_Time__c
                FROM Appointment__c
                WHERE Resource__c = :resource.Id
                  AND Start_Time__c >= :startOfDay
                  AND Start_Time__c < :endOfDay
                ORDER BY Start_Time__c ASC
            ];

            Time workStart = resource.Working_Hours_Start__c.time();
            Time workEnd   = resource.Working_Hours_End__c.time();
            Time currentTime = workStart;

            List<String> unsplitIntervals = new List<String>();
            List<TimeSlotItem> finalTimeSlots = new List<TimeSlotItem>();

            for (Appointment__c app : appointments) {
                Time appStart = app.Start_Time__c.time();
                if (currentTime < appStart) {
                    unsplitIntervals.add(formatInterval(currentTime, appStart));
                }
                currentTime = app.End_Time__c.time();
            }

            if (currentTime < workEnd) {
                unsplitIntervals.add(formatInterval(currentTime, workEnd));
            }

            Integer durationMin = Integer.valueOf(service.Duration__c);

            for (String unsplitInt : unsplitIntervals) {
                List<Time> startAndEnd = deformatInterval(unsplitInt);
                Time startT = startAndEnd[0];
                Time endT   = startAndEnd[1];

                Integer startMin = startT.hour() * 60 + startT.minute();
                Integer endMin   = endT.hour() * 60 + endT.minute();
                if ((endMin - startMin) < durationMin) {
                    continue;
                }

                Time slotStart = startT;
                while (slotStart < endT) {
                    Time slotEnd = slotStart.addMilliseconds(durationMin * 60000);
                    if (slotEnd > endT) break;

                    String interval = formatInterval(slotStart, slotEnd);
                    TimeSlotItem ts = new TimeSlotItem();
                    ts.timeslot = interval;
                    finalTimeSlots.add(ts);

                    slotStart = slotEnd;
                }
            }

            output.add(finalTimeSlots);
        }
        
        return output;
    }

    public static String formatInterval(Time startInterval, Time endInterval) {
        Datetime startDT = Datetime.newInstance(Date.today(), startInterval);
        Datetime endDT   = Datetime.newInstance(Date.today(), endInterval);
        return startDT.format('HH:mm') + ' - ' + endDT.format('HH:mm');
    }

    public static List<Time> deformatInterval(String interval) {
        String[] parts = interval.split(' - ');
        String[] s = parts[0].split(':');
        String[] e = parts[1].split(':');

        Time startT = Time.newInstance(Integer.valueOf(s[0]), Integer.valueOf(s[1]), 0, 0);
        Time endT   = Time.newInstance(Integer.valueOf(e[0]), Integer.valueOf(e[1]), 0, 0);
        return new List<Time>{ startT, endT };
    }
}
