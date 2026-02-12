public class TimeSlotItem {
    @AuraEnabled
    @InvocableVariable(label='Timeslot')
    public String timeslot;

    // Default constructor is required for Flow
    public TimeSlotItem() {} 

    public TimeSlotItem(String t) {
        this.timeslot = t;
    }
}
