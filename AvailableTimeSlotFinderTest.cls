@isTest
private class AvailableTimeSlotFinderTest {
    @TestSetup
    static void makeData(){
        Service__c serviceShort = new Service__c(
            Name = 'Short Service',
            Duration__c = 15
        );

        Service__c serviceMedium = new Service__c(
            Name = 'Medium Service',
            Duration__c = 60
        );

        Service__c serviceLong = new Service__c(
            Name = 'Long Service',
            Duration__c = 120
        );

        Resource__c resource1 = new Resource__c();
        resource1.Name = 'Andrei Popescu';
        resource1.Working_Hours_Start__c = Datetime.newInstance(Date.today(), Time.newInstance(9, 0, 0, 0));
        resource1.Working_Hours_End__c = Datetime.newInstance(Date.today(), Time.newInstance(17, 0, 0, 0));

        Resource__c resource2 = new Resource__c();
        resource2.Name = 'Mihai Mutiu';
        resource2.Working_Hours_Start__c = Datetime.newInstance(Date.today(), Time.newInstance(9, 0, 0, 0));
        resource2.Working_Hours_End__c = Datetime.newInstance(Date.today(), Time.newInstance(17, 0, 0, 0));

        Resource__c resource3 = new Resource__c();
        resource3.Name = 'Cosmin Prestean';
        resource3.Working_Hours_Start__c = Datetime.newInstance(Date.today(), Time.newInstance(9, 0, 0, 0));
        resource3.Working_Hours_End__c = Datetime.newInstance(Date.today(), Time.newInstance(17, 0, 0, 0));

        insert new List<SObject>{serviceShort, serviceMedium, serviceLong, resource1, resource2, resource3};

        // appointment 1 --> resource 1 has appointment from 9:00 to 10:00
        Appointment__c appointment1 = new Appointment__c();
        appointment1.Start_Time__c = Datetime.newInstance(Date.today().addDays(1), Time.newInstance(9, 0, 0, 0));
        appointment1.End_Time__c = Datetime.newInstance(Date.today().addDays(1), Time.newInstance(10, 0, 0, 0));
        appointment1.Resource__c = resource1.Id;
        appointment1.Service__c = serviceMedium.Id;

        // appointment 2 --> resource 1 has appointment from 13:00 to 15:00
        Appointment__c appointment2 = new Appointment__c();
        appointment2.Start_Time__c = Datetime.newInstance(Date.today().addDays(1), Time.newInstance(13, 0, 0, 0));
        appointment2.End_Time__c = Datetime.newInstance(Date.today().addDays(1), Time.newInstance(15, 0, 0, 0));
        appointment2.Resource__c = resource1.Id;
        appointment2.Service__c = serviceLong.Id;

        // appointment 3 --> resource 2 has appointment from 10:00 to 10:15
        Appointment__c appointment3 = new Appointment__c();
        appointment3.Start_Time__c = Datetime.newInstance(Date.today().addDays(1), Time.newInstance(10, 0, 0, 0));
        appointment3.End_Time__c = Datetime.newInstance(Date.today().addDays(1), Time.newInstance(10, 15, 0, 0));
        appointment3.Resource__c = resource2.Id;
        appointment3.Service__c = serviceShort.Id;

        // appointment 4 --> resource 2 has appointment from 14:00 to 15:00
        Appointment__c appointment4 = new Appointment__c();
        appointment4.Start_Time__c = Datetime.newInstance(Date.today().addDays(1), Time.newInstance(14, 0, 0, 0));
        appointment4.End_Time__c = Datetime.newInstance(Date.today().addDays(1), Time.newInstance(15, 0, 0, 0));
        appointment4.Resource__c = resource2.Id;
        appointment4.Service__c = serviceMedium.Id;

        // appointment 5 --> resource 3 has appointment from 15:00 to 17:00
        Appointment__c appointment5 = new Appointment__c();
        appointment5.Start_Time__c = Datetime.newInstance(Date.today().addDays(1), Time.newInstance(15, 0, 0, 0));
        appointment5.End_Time__c = Datetime.newInstance(Date.today().addDays(1), Time.newInstance(17, 0, 0, 0));
        appointment5.Resource__c = resource3.Id;
        appointment5.Service__c = serviceLong.Id;

        insert new List<Appointment__c>{appointment1, appointment2, appointment3, appointment4};
    }

    @isTest
    static void testFindAvailableTimeSlotsResource1ShortService() {
        Resource__c resource1 = [SELECT Id, Name, Working_Hours_Start__c, Working_Hours_End__c FROM Resource__c WHERE Name = 'Andrei Popescu' LIMIT 1];
        Service__c serviceShort = [SELECT Id, Name, Duration__c FROM Service__c WHERE Name = 'Short Service' AND Duration__c = 15 LIMIT 1];
        Date selectedDate = Date.today().addDays(1);

        AvailableTimeSlotFinder.InputVariables inputVars = new AvailableTimeSlotFinder.InputVariables();
        inputVars.resourceId = resource1.Id;
        inputVars.serviceId = serviceShort.Id;
        inputVars.preferredDate = selectedDate;

        List<AvailableTimeSlotFinder.InputVariables> inputVarsList = new List<AvailableTimeSlotFinder.InputVariables>{inputVars};

        Test.startTest();
        List<List<TimeSlotItem>> timeSlotsForAllInputs = AvailableTimeSlotFinder.findAvailableTimeSlots(inputVarsList);
        Test.stopTest();

        Assert.areEqual('10:00', timeSlotsForAllInputs[0][0].timeslot.split(':')[0]);
        Assert.areEqual('10:15', timeSlotsForAllInputs[0][0].timeslot.split(':')[1]);

        Assert.areEqual('10:15', timeSlotsForAllInputs[0][1].timeslot.split(':')[0]);
        Assert.areEqual('10:30', timeSlotsForAllInputs[0][1].timeslot.split(':')[1]);

        Assert.areEqual('10:30', timeSlotsForAllInputs[0][2].timeslot.split(':')[0]);
        Assert.areEqual('10:45', timeSlotsForAllInputs[0][2].timeslot.split(':')[1]);

        Assert.areEqual('10:45', timeSlotsForAllInputs[0][3].timeslot.split(':')[0]);
        Assert.areEqual('11:00', timeSlotsForAllInputs[0][3].timeslot.split(':')[1]);

        Assert.areEqual('11:00', timeSlotsForAllInputs[0][4].timeslot.split(':')[0]);
        Assert.areEqual('11:15', timeSlotsForAllInputs[0][4].timeslot.split(':')[1]);

        Assert.areEqual('11:15', timeSlotsForAllInputs[0][5].timeslot.split(':')[0]);
        Assert.areEqual('11:30', timeSlotsForAllInputs[0][5].timeslot.split(':')[1]);

        Assert.areEqual('11:30', timeSlotsForAllInputs[0][6].timeslot.split(':')[0]);
        Assert.areEqual('11:45', timeSlotsForAllInputs[0][6].timeslot.split(':')[1]);

        Assert.areEqual('11:45', timeSlotsForAllInputs[0][7].timeslot.split(':')[0]);
        Assert.areEqual('12:00', timeSlotsForAllInputs[0][7].timeslot.split(':')[1]);

        Assert.areEqual('12:00', timeSlotsForAllInputs[0][8].timeslot.split(':')[0]);
        Assert.areEqual('12:15', timeSlotsForAllInputs[0][8].timeslot.split(':')[1]);

        Assert.areEqual('12:15', timeSlotsForAllInputs[0][9].timeslot.split(':')[0]);
        Assert.areEqual('12:30', timeSlotsForAllInputs[0][9].timeslot.split(':')[1]);

        Assert.areEqual('12:30', timeSlotsForAllInputs[0][10].timeslot.split(':')[0]);
        Assert.areEqual('12:45', timeSlotsForAllInputs[0][10].timeslot.split(':')[1]);

        Assert.areEqual('12:45', timeSlotsForAllInputs[0][11].timeslot.split(':')[0]);
        Assert.areEqual('13:00', timeSlotsForAllInputs[0][11].timeslot.split(':')[1]);

        Assert.areEqual('13:00', timeSlotsForAllInputs[0][12].timeslot.split(':')[0]);
        Assert.areEqual('13:15', timeSlotsForAllInputs[0][12].timeslot.split(':')[1]);

        Assert.areEqual('13:15', timeSlotsForAllInputs[0][13].timeslot.split(':')[0]);
        Assert.areEqual('13:30', timeSlotsForAllInputs[0][13].timeslot.split(':')[1]);

        Assert.areEqual('13:30', timeSlotsForAllInputs[0][14].timeslot.split(':')[0]);
        Assert.areEqual('13:45', timeSlotsForAllInputs[0][14].timeslot.split(':')[1]);

        Assert.areEqual('13:45', timeSlotsForAllInputs[0][15].timeslot.split(':')[0]);
        Assert.areEqual('14:00', timeSlotsForAllInputs[0][15].timeslot.split(':')[1]);

        Assert.areEqual('14:00', timeSlotsForAllInputs[0][16].timeslot.split(':')[0]);
        Assert.areEqual('14:15', timeSlotsForAllInputs[0][16].timeslot.split(':')[1]);

        Assert.areEqual('14:15', timeSlotsForAllInputs[0][17].timeslot.split(':')[0]);
        Assert.areEqual('14:30', timeSlotsForAllInputs[0][17].timeslot.split(':')[1]);

        Assert.areEqual('14:30', timeSlotsForAllInputs[0][18].timeslot.split(':')[0]);
        Assert.areEqual('14:45', timeSlotsForAllInputs[0][18].timeslot.split(':')[1]);

        Assert.areEqual('14:45', timeSlotsForAllInputs[0][19].timeslot.split(':')[0]);
        Assert.areEqual('15:00', timeSlotsForAllInputs[0][19].timeslot.split(':')[1]);

        Assert.areEqual('15:00', timeSlotsForAllInputs[0][20].timeslot.split(':')[0]);
        Assert.areEqual('15:15', timeSlotsForAllInputs[0][20].timeslot.split(':')[1]);

        Assert.areEqual('15:15', timeSlotsForAllInputs[0][21].timeslot.split(':')[0]);
        Assert.areEqual('15:30', timeSlotsForAllInputs[0][21].timeslot.split(':')[1]);

        Assert.areEqual('15:30', timeSlotsForAllInputs[0][22].timeslot.split(':')[0]);
        Assert.areEqual('15:45', timeSlotsForAllInputs[0][22].timeslot.split(':')[1]);

        Assert.areEqual('15:45', timeSlotsForAllInputs[0][23].timeslot.split(':')[0]);
        Assert.areEqual('16:00', timeSlotsForAllInputs[0][23].timeslot.split(':')[1]);

        Assert.areEqual('16:00', timeSlotsForAllInputs[0][24].timeslot.split(':')[0]);
        Assert.areEqual('16:15', timeSlotsForAllInputs[0][24].timeslot.split(':')[1]);

        Assert.areEqual('16:15', timeSlotsForAllInputs[0][25].timeslot.split(':')[0]);
        Assert.areEqual('16:30', timeSlotsForAllInputs[0][25].timeslot.split(':')[1]);

        Assert.areEqual('16:30', timeSlotsForAllInputs[0][26].timeslot.split(':')[0]);
        Assert.areEqual('16:45', timeSlotsForAllInputs[0][26].timeslot.split(':')[1]);

        Assert.areEqual('16:45', timeSlotsForAllInputs[0][27].timeslot.split(':')[0]);
        Assert.areEqual('17:00', timeSlotsForAllInputs[0][27].timeslot.split(':')[1]);
    }
}
