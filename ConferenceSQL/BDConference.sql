
------------------------------------------------------TABLES-------------------------------------------------------------------------------

-- Table: Attendee
CREATE TABLE Attendee (
    AttendeeID int IDENTITY(1,1) NOT NULL,
    Name nvarchar(40)  NOT NULL,
    Surname nvarchar(40)  NOT NULL,
    Email nvarchar(40)  NOT NULL,
    Phone nvarchar(20)  NOT NULL,
    City nvarchar(40)  NOT NULL,
    PostalCode nvarchar(20)  NOT NULL,
    Address nvarchar(40)  NOT NULL,
    CONSTRAINT AttendeeID PRIMARY KEY  (AttendeeID)
);

-- Table: Company
CREATE TABLE Company (
    CompanyID int IDENTITY(1,1) NOT NULL,
    CompanyName nvarchar(40)  NOT NULL,
    Address nvarchar(40)  NOT NULL,
    City nvarchar(40)  NOT NULL,
    Email nvarchar(40)  NOT NULL,
    Phone nvarchar(40)  NOT NULL,
    NIP nvarchar(40)  NOT NULL,
    CONSTRAINT Company_pk PRIMARY KEY  (CompanyID)
);

-- Table: Conference
CREATE TABLE Conference (
    ConferenceID int IDENTITY(1,1) NOT NULL,
    Name nvarchar(40)  NOT NULL,
    Description nvarchar(40)  NOT NULL,
    StudentDiscount decimal(3,2)  NOT NULL,
    StartDate date NOT NULL,
    EndDate date NOT NULL,
    CONSTRAINT Conference_pk PRIMARY KEY  (ConferenceID)
);
ALTER TABLE Conference WITH CHECK ADD CONSTRAINT StudentDiscountBetween0and1
    CHECK (StudentDiscount <= 1 AND StudentDiscount >= 0)
ALTER TABLE Conference CHECK CONSTRAINT StudentDiscountBetween0and1
ALTER TABLE Conference WITH CHECK ADD CONSTRAINT NameLengthOver0
    CHECK (LEN(Name) > 0)
ALTER TABLE Conference CHECK CONSTRAINT NameLengthOver0
ALTER TABLE Conference WITH CHECK ADD CONSTRAINT DescriptionLengthOver0
    CHECK (LEN(Description) > 0)
ALTER TABLE Conference CHECK CONSTRAINT DescriptionLengthOver0

-- Table: ConferenceDay
CREATE TABLE ConferenceDay (
    ConferenceDayID int IDENTITY(1,1) NOT NULL,
    ConferenceID int  NOT NULL,
    AttendeesMaxNumber int  NOT NULL,
    Address nvarchar(40)  NOT NULL,
    Date date  NOT NULL,
    CONSTRAINT ConferenceDay_pk PRIMARY KEY  (ConferenceDayID)
);
ALTER TABLE ConferenceDay ADD CONSTRAINT ConferenceDay_Conference
    FOREIGN KEY (ConferenceID)
    REFERENCES Conference (ConferenceID);
ALTER TABLE ConferenceDay WITH CHECK ADD CONSTRAINT AttendeesMaxNumberOver0
    CHECK (AttendeesMaxNumber > 0)
ALTER TABLE ConferenceDay CHECK CONSTRAINT AttendeesMaxNumberOver0

-- Table: ConferenceDayReservation
CREATE TABLE ConferenceDayReservation (
    ConferenceDayReservationID int IDENTITY(1,1) NOT NULL,
    ConferenceDayID int  NOT NULL,
    ReservationID int  NOT NULL,
    Attendees int NOT NULL,
    Students int  NOT NULL,
    isCancelled bit  NOT NULL,
    CONSTRAINT ConferenceDayReservation_pk PRIMARY KEY  (ConferenceDayReservationID)
);
ALTER TABLE ConferenceDayReservation WITH CHECK ADD CONSTRAINT AttendeesOver0
    CHECK (Attendees > 0)
ALTER TABLE ConferenceDayReservation CHECK CONSTRAINT AttendeesOver0
ALTER TABLE ConferenceDayReservation WITH CHECK ADD CONSTRAINT StudentsEqualOrOver0AndLessOrEqualAttendees
    CHECK (Students >= 0 AND  Students <= Attendees)
ALTER TABLE ConferenceDayReservation CHECK CONSTRAINT StudentsEqualOrOver0AndLessOrEqualAttendees
ALTER TABLE ConferenceDayReservation ADD CONSTRAINT ConferenceDayReservation_ConferenceDay
    FOREIGN KEY (ConferenceDayID)
    REFERENCES ConferenceDay (ConferenceDayID);
ALTER TABLE ConferenceDayReservation ADD CONSTRAINT ConferenceDayReservation_Reservation
    FOREIGN KEY (ReservationID)
    REFERENCES Reservation (ReservationID);

-- Table: Customer
CREATE TABLE Customer (
    CustomerID int IDENTITY(1,1) NOT NULL,
    CompanyID int,
    AttendeeID int,
    CONSTRAINT Customer_pk PRIMARY KEY  (CustomerID)
);
ALTER TABLE Customer ADD CONSTRAINT Customer_Attendee
    FOREIGN KEY (AttendeeID)
    REFERENCES Attendee (AttendeeID);
ALTER TABLE Customer ADD CONSTRAINT Customer_Company
    FOREIGN KEY (CompanyID)
    REFERENCES Company (CompanyID);
ALTER TABLE Customer WITH CHECK ADD CONSTRAINT AttendeeIDOrCompanyIDEqualsNULL
    CHECK ((AttendeeID IS NULL OR CompanyID IS NULL ) AND NOT (AttendeeID IS NULL AND CompanyID IS NULL))
ALTER TABLE Customer CHECK CONSTRAINT AttendeeIDOrCompanyIDEqualsNULL

-- Table: PriceThreshold
CREATE TABLE PriceThreshold (
    PriceThresholdID int IDENTITY(1,1) NOT NULL,
    ConferenceDayID int  NOT NULL,
    StartDate date  NOT NULL,
    EndDate date NOT NULL,
    Price money  NOT NULL,
    CONSTRAINT PriceThreshold_pk PRIMARY KEY  (PriceThresholdID)
);
ALTER TABLE PriceThreshold ADD CONSTRAINT PriceThreshold_ConferenceDay
    FOREIGN KEY (ConferenceDayID)
    REFERENCES ConferenceDay (ConferenceDayID);
ALTER TABLE PriceThreshold WITH CHECK ADD CONSTRAINT StartDateBeforeEndDate
    CHECK (EndDate > StartDate)
ALTER TABLE PriceThreshold CHECK CONSTRAINT StartDateBeforeEndDate
ALTER TABLE PriceThreshold WITH CHECK ADD CONSTRAINT PriceNotBelowZero
    CHECK (Price >= 0)
ALTER TABLE PriceThreshold CHECK CONSTRAINT PriceNotBelowZero

CREATE TABLE RegistrationForConferenceDay (
    RegistrationForConferenceDayID int IDENTITY(1,1) NOT NULL,
    AttendeeID int  NOT NULL,
    ConferenceDayReservationID int  NOT NULL,
    StudentPrice bit NOT NULL,
    CONSTRAINT RegistrationForConferenceDay_pk PRIMARY KEY  (RegistrationForConferenceDayID)
);
ALTER TABLE RegistrationForConferenceDay ADD CONSTRAINT RegistrationForConferenceDay_Attendee
    FOREIGN KEY (AttendeeID)
    REFERENCES Attendee (AttendeeID);
ALTER TABLE RegistrationForConferenceDay ADD CONSTRAINT RegistrationForConferenceDay_ConferenceDayReservation
    FOREIGN KEY (ConferenceDayReservationID)
    REFERENCES ConferenceDayReservation (ConferenceDayReservationID);

-- Table: RegistrationForWorkshop
CREATE TABLE RegistrationForWorkshop (
    RegistrationForWorkshopID int IDENTITY(1,1) NOT NULL,
    WorkshopReservationID int  NOT NULL,
    RegistrationForConferenceDayID int  NOT NULL,
    CONSTRAINT RegistrationForWorkshop_pk PRIMARY KEY  (RegistrationForWorkshopID)
);
ALTER TABLE RegistrationForWorkshop ADD CONSTRAINT RegistrationForWorkshop_RegistrationForConferenceDay
    FOREIGN KEY (RegistrationForConferenceDayID)
    REFERENCES RegistrationForConferenceDay (RegistrationForConferenceDayID);
ALTER TABLE RegistrationForWorkshop ADD CONSTRAINT RegistrationForWorkshop_WorkshopReservation
    FOREIGN KEY (WorkshopReservationID)
    REFERENCES WorkshopReservation (WorkshopReservationID);

-- Table: Reservation
CREATE TABLE Reservation (
    ReservationID int IDENTITY(1,1) NOT NULL,
    CustomerID int  NOT NULL,
    Date datetime  NOT NULL,
    AmountPaid money  NOT NULL,
    isCancelled bit  NOT NULL,
    CONSTRAINT Reservation_pk PRIMARY KEY  (ReservationID)
);
ALTER TABLE Reservation ADD CONSTRAINT Reservation_Customer
    FOREIGN KEY (CustomerID)
    REFERENCES Customer (CustomerID);

-- Table: Workshop
CREATE TABLE Workshop (
    WorkshopID int IDENTITY(1,1) NOT NULL,
    ConferenceDayID int  NOT NULL,
    StartTime datetime  NOT NULL,
    EndTime datetime  NOT NULL,
    Address nvarchar(40)  NOT NULL,
    Price money  NOT NULL,
    Description nvarchar(40)  NOT NULL,
    AttendeesMaxNumber int  NOT NULL,
    Title nvarchar(40) NOT NULL,
    CONSTRAINT Workshop_pk PRIMARY KEY  (WorkshopID)
);
ALTER TABLE Workshop ADD CONSTRAINT Workshop_ConferenceDay
    FOREIGN KEY (ConferenceDayID)
    REFERENCES ConferenceDay (ConferenceDayID);
ALTER TABLE Workshop WITH CHECK ADD CONSTRAINT StartTimeBeforeEndTime
    CHECK (EndTime >= StartTime)
ALTER TABLE Workshop CHECK CONSTRAINT StartTimeBeforeEndTime
ALTER TABLE Workshop WITH CHECK ADD CONSTRAINT PriceNotBelowZero
    CHECK (Price >= 0)
ALTER TABLE Workshop CHECK CONSTRAINT PriceNotBelowZero
ALTER TABLE Workshop WITH CHECK ADD CONSTRAINT AttendeesMaxNumberAboveZero
    CHECK (AttendeesMaxNumber > 0)
ALTER TABLE Workshop CHECK CONSTRAINT AttendeesMaxNumberAboveZero

CREATE TABLE WorkshopReservation (
    WorkshopReservationID int IDENTITY(1,1) NOT NULL,
    WorkshopID int  NOT NULL,
    ConferenceDayReservationID int  NOT NULL,
    Attendees int  NOT NULL,
    isCancelled bit  NOT NULL,
    CONSTRAINT WorkshopReservation_pk PRIMARY KEY  (WorkshopReservationID)
);
ALTER TABLE WorkshopReservation ADD CONSTRAINT WorkshopReservation_ConferenceDayReservation
    FOREIGN KEY (ConferenceDayReservationID)
    REFERENCES ConferenceDayReservation (ConferenceDayReservationID);
ALTER TABLE WorkshopReservation ADD CONSTRAINT WorkshopReservation_Workshop
    FOREIGN KEY (WorkshopID)
    REFERENCES Workshop (WorkshopID);
ALTER TABLE WorkshopReservation WITH CHECK ADD CONSTRAINT AttendeesAboveZero
    CHECK (Attendees > 0)
ALTER TABLE WorkshopReservation CHECK CONSTRAINT AttendeesAboveZero

-------------------------------------------------------FUNCTIONS-------------------------------------------------------------------------------

--return price by id--
create function get_price_by_reservation_id(@ReservationID int)
returns int
begin
   return
    (
    select (sum((cdr.Attendees-cdr.Students)*ptr.price+((cdr.Students)*ptr.price*(c.StudentDiscount*0.01)))) from ConferenceDayReservation cdr
    inner join reservation r on r.ReservationID=@ReservationID
    inner join conferenceday cd on cdr.ConferenceDayID=cd.ConferenceDayID
    inner join conference c on c.ConferenceID=cd.ConferenceID
    inner join PriceThreshold ptr on ptr.ConferenceDayID=cd.ConferenceDayID and r.date between ptr.startdate and ptr.EndDate
    )
end



--return participant by name and surname--
create function get_participant_by_name(@name nvarchar(40),@surname nvarchar(40))
returns @participant table (    AttendeeID int,
    Name nvarchar(40),
    Surname nvarchar(40),
    Email nvarchar(40),
    Phone nvarchar(20),
    City nvarchar(40),
    PostalCode nvarchar(20),
    Address nvarchar(40))
begin
    insert into @participant
    select * from Attendee a
    where name=@name and surname=@surname
    return
end

--return conference days by conferenceID--
create function get_conference_days(@ConferenceID int)
returns @conferencedays table
(conferenceDayID int,
attendeesMaxNumber int,
date datetime)
begin
    insert into @conferencedays select ConferenceDayID,AttendeesMaxNumber,date
    from conferenceday
    where @ConferenceID=ConferenceID
    return
end

--return conference day attendees--
create function get_conference_day_attendees(@ConferenceDayID int)
returns @attendee table
(name nvarchar(40),
surname varchar(40),
phone varchar(40),
attendeeID int)
as begin
    insert into @attendee
    select a.name,a.surname,a.phone,a.attendeeID
    from attendee a
    inner join RegistrationForConferenceDay rfcd on rfcd.AttendeeID=a.AttendeeID
    inner join ConferenceDayReservation cdr on cdr.ConferenceDayReservationID=rfcd.ConferenceDayReservationID
    inner join ConferenceDay cd on cd.ConferenceDayID=cdr.ConferenceDayID
    where cd.ConferenceDayID=@ConferenceDayID
    return
end

--return number of free places on conference day--
create function get_conference_day_free_places_number(@ConferenceDayID int)
returns int
as
    begin
return
(select cd.AttendeesMaxNumber-sum(attendees)  from ConferenceDay cd
    left join conferencedayreservation cdr on cd.ConferenceDayID=cdr.ConferenceDayID
    and cdr.isCancelled=0
    where cd.ConferenceDayID=@ConferenceDayID
    group by cd.ConferenceDayID,cd.AttendeesMaxNumber
    )
end


--return number of free places on workshop--
create function get_workshop_free_places_number(@WorkshopID int)
returns int
as
    begin
        return(select w.AttendeesMaxNumber-sum(wr.attendees) from Workshop w
            left join WorkshopReservation wr on wr.WorkshopID=w.WorkshopID
            and isCancelled=0
            where w.WorkshopID=@WorkshopID
            group by w.WorkshopID,w.AttendeesMaxNumber)
    end

--**return conferences by attendeeID--
create function get_conferences_by_AttendeeID(@AttendeeID int)
returns @conferences table ( ConferenceName nvarchar(40),
Description nvarchar(40)
)
begin
    insert into @conferences
    select c.name,c.description from conference c
    inner join conferenceday cd on cd.ConferenceID=c.ConferenceID
    inner join conferencedayreservation cdr on cdr.ConferenceDayID=cd.ConferenceDayID
    inner join RegistrationForConferenceDay rfcd on rfcd.ConferenceDayReservationID=cdr.ConferenceDayReservationID
    where rfcd.AttendeeID=@AttendeeID
    return
end

--**return all reservation by CustomerID
create function get_reservations_customerID(@CustomerID int)
returns @reservations table(
    Name nvarchar(40),
    Phone nvarchar(40),
    Address nvarchar(40),
    isCompany nvarchar(40),
    ReservationID int ,
    CustomerID int  ,
    Date datetime ,
    AmountPaid money ,
    isCancelled bit
)
begin
    insert into @reservations select c.companyname,c.phone,c.address,'Yes' isCompany,r.reservationID,r.customerId,r.date,r.amountpaid,r.iscancelled from Reservation r
            inner join customer cu on cu.customerID=@customerID
            inner join Company c on c.CompanyID=cu.CompanyID
           union
        select a.name+''+a.surname as Name,a.phone,a.address,'No' isCompany,r.reservationID,r.customerID,r.date,r.amountpaid,r.iscancelled from Reservation r
        inner join customer cu on cu.customerID=@CustomerID
        inner join attendee a on a.AttendeeID=cu.AttendeeID
    return
end

--**return attendees by workshopID
create function get_attendees_by_workshopID(@WorkshopID int)
returns @attendee table (
    Title nvarchar(40),
    Name nvarchar(40),
    Surname nvarchar(40),
    Email nvarchar(40) ,
    Phone nvarchar(20) ,
    City nvarchar(40) ,
    PostalCode nvarchar(20),
    Address nvarchar(40)
              )
begin
    insert into @attendee select distinct wr.title,a.name,a.surname,a.email,a.phone,a.city,a.postalcode,a.address from Workshop wr
    inner join WorkshopReservation WR2 on wr.WorkshopID = @WorkshopID
    inner join RegistrationForWorkshop RFW on WR2.WorkshopReservationID = RFW.WorkshopReservationID
    inner join RegistrationForConferenceDay  rfcd on rfcd.RegistrationForConferenceDayID=rfw.RegistrationForConferenceDayID
    inner join Attendee A on rfcd.AttendeeID = A.AttendeeID
     return
end

create function are_workshops_overlapping(@WorkshopID1 int, @WorkshopID2 int)
returns bit

    begin
        if (@WorkshopID2 = @WorkshopID1)
            begin
                return 0
            end
        if exists(select * from Workshop
            where WorkshopID = @WorkshopID1 and (StartTime between (select StartTime from Workshop where WorkshopID = @WorkshopID2)
                and (select EndTime from Workshop where WorkshopID = @WorkshopID2) or EndTime between (select StartTime from Workshop where WorkshopID = @WorkshopID2)
                and (select EndTime from Workshop where WorkshopID = @WorkshopID2)))
        begin
            return 1
        end
        return 0
    end


create function are_conferences_overlapping(@ConferenceID1 int, @ConferenceID2 int)
returns bit
as
    begin
        if (@ConferenceID2 = @ConferenceID1)
            begin
                return 0
            end
        if EXISTS(select * from Conference
            where ConferenceID = @ConferenceID1 and (StartDate between (select StartDate from Conference where ConferenceID = @ConferenceID2) and
                (select EndDate from Conference where ConferenceID = @ConferenceID2) or EndDate between (select StartDate from Conference where ConferenceID = @ConferenceID2) and
                (select EndDate from Conference where ConferenceID = @ConferenceID2)))
        begin
            return 1
        end
        return 0
    end


create function get_attendees_by_conferencedayid(@ConferenceDayID int)
returns @attendees table
    (AttendeeID int,
    Name nvarchar(40),
    Surname nvarchar(40),
    Email nvarchar(40),
    Phone nvarchar(20),
    City nvarchar(40),
    PostalCode nvarchar(20),
    Address nvarchar(40))
begin
    insert into @attendees select distinct A.AttendeeID, A.Name, A.Surname, A.Email, A.Phone, A.City, A.PostalCode, A.Address
            from ConferenceDay CD2
            inner join ConferenceDayReservation CDR2 on CD2.ConferenceDayID = CDR2.ConferenceDayID
            inner join RegistrationForConferenceDay RFCD2 on CDR2.ConferenceDayReservationID = RFCD2.ConferenceDayReservationID
            inner join Attendee A on RFCD2.AttendeeID = A.AttendeeID
            where CD2.ConferenceDayID = @ConferenceDayID
    return
end

create function get_attendees_by_conferenceid(@ConferenceID int)
returns @attendees table
    (AttendeeID int,
    Name nvarchar(40),
    Surname nvarchar(40),
    Email nvarchar(40),
    Phone nvarchar(20),
    City nvarchar(40),
    PostalCode nvarchar(20),
    Address nvarchar(40))
begin
    insert into @attendees select [dbo].get_attendees_by_conferencedayid(CD3.ConferenceDayID)
        from Conference C inner join ConferenceDay CD3 on C.ConferenceID = CD3.ConferenceID
        where C.ConferenceID = @ConferenceID
    return
end
-------------------------------------------------------------------VIEW-----------------------------------------------------------------------

--most popular conferences--
create view MostPopularConferences
as
    select top 10
    c.ConferenceID, c.name,sum(cdr.Attendees) as [Attendees Number] from Conference c
inner join ConferenceDay cd on cd.ConferenceID=c.ConferenceID
inner join ConferenceDayReservation cdr on cdr.ConferenceDayID=cd.ConferenceDayID
group by c.ConferenceID, c.name
order by sum(cdr.Attendees) desc

--most popular workshops--s
create view MostPopularWorkshops
as
    select top 10
    w.WorkshopID, w.title ,sum(wr.Attendees) [Attendees Number] from Workshop w
inner join WorkshopReservation wr on wr.WorkshopID=w.WorkshopID
group by w.title, w.WorkshopID
order by sum(wr.Attendees) desc

--future conferences--
create view FutureConferences
as
    select c.ConferenceID, c.name,c.startdate ,c.Description
from Conference c
where c.StartDate>GETDATE()

--**reservations with price--
create view dbo.ReservationsWithPrices
as
select c.name,r.reservationid,r.date,[dbo].get_price_by_reservation_id(r.ReservationID) as [Amount to Pay],r.isCancelled from Reservation r
left join ConferenceDayReservation cdr on cdr.reservationID=r.ReservationID
left join ConferenceDay cd on cdr.ConferenceDayID=cd.ConferenceDayID
left join Conference c on cd.ConferenceID=c.ConferenceID

--reservations without full data--
create view CompaniesWithReservationsWithoutFullData
as
    select co.CompanyID,co.CompanyName,co.Phone,co.Email,r.date as [Reservation Date],r.ReservationID as [Reservation ID] from company co
inner join customer cu on cu.CompanyID=co.CompanyID
inner join reservation r on r.CustomerID=cu.CustomerID
inner join ConferenceDayReservation cdr on cdr.ReservationID=r.ReservationID
inner join RegistrationForConferenceDay rfcd on rfcd.ConferenceDayReservationID=cdr.ConferenceDayReservationID
inner join WorkshopReservation WR on cdr.ConferenceDayReservationID = WR.ConferenceDayReservationID
inner join RegistrationForWorkshop rfw on rfw.WorkshopReservationID=wr.WorkshopReservationID

where ((select sum(cdr2.attendees) from ConferenceDayReservation cdr2 where cdr2.ReservationID=r.ReservationID)
    >(select count(rfcd2.RegistrationForConferenceDayID)  from RegistrationForConferenceDay rfcd2
        inner join ConferenceDayReservation cdr2 on rfcd2.ConferenceDayReservationID = cdr2.ConferenceDayReservationID
        inner join Reservation r2 on cdr2.ReservationID = r2.ReservationID
        where cu.CustomerID=r2.CustomerID and r2.ReservationID = r.ReservationID)
    )
or ((select sum(wsr.attendees) from WorkshopReservation wsr
    inner join ConferenceDayReservation cdr3 on wsr.ConferenceDayReservationID=cdr3.ConferenceDayReservationID
    where cdr3.ReservationID=r.ReservationID)
        > (select count(rfw2.RegistrationForWorkshopID) from RegistrationForWorkshop rfw2
            inner join WorkshopReservation W2 on rfw2.WorkshopReservationID = W2.WorkshopReservationID
            inner join ConferenceDayReservation C on W2.Attendees = C.Attendees
            inner join Reservation R3 on C.ReservationID = R3.ReservationID
            where R3.CustomerID=cu.CustomerID and r.ReservationID = r3.ReservationID
        ))



--reservations for conferences that starts in two weeks without full data--
create view ReservationsForConferencesThatStartInTwoWeeksWithoutFullData
as
    select CompanyID, CompanyName, Phone, Email, [Reservation Date], [Reservation ID] from CompaniesWithReservationsWithoutFullData r
inner join ConferenceDayReservation cdr on cdr.ReservationID=r.[Reservation ID]
inner join ConferenceDay cd on cd.ConferenceDayID=cdr.ConferenceDayID
inner join Conference c on c.ConferenceID=cd.ConferenceID
where dateadd(week,+2,GETDATE())>c.StartDate and c.StartDate > GETDATE()


--most active clients--
create view MostActiveCustomers
as
    select top 10
co.companyname,(select count (*) from Attendee a2 where a2.AttendeeID in (select AttendeeID from
                Customer c2 inner join
                Reservation R2 on c2.CustomerID = R2.CustomerID
                inner join ConferenceDayReservation CDR on R2.ReservationID = CDR.ReservationID
                inner join RegistrationForConferenceDay RFCD on CDR.ConferenceDayReservationID = RFCD.ConferenceDayReservationID
                inner join Attendee A3 on RFCD.AttendeeID = A3.AttendeeID
                where c2.customerid = c.CustomerID )) as [Attendee Number]
from company co
inner join customer c on c.CompanyID=co.CompanyID
inner join Attendee a on a.AttendeeID=c.AttendeeID
group by co.companyname, c.CustomerID
order by [Attendee Number] desc

--month income--
create view MonthIncome
as
    select month(r.date) as Month,r.AmountPaid
from reservation r
group by month(r.date),r.amountpaid

create view FutureConferencesAttendees
as
    select distinct A.AttendeeID, A.Name, A.Surname, A.Email, A.Phone, A.City, A.PostalCode, A.Address
        from Conference C inner join ConferenceDay CD on C.ConferenceID = CD.ConferenceID
        inner join ConferenceDayReservation CDR on CD.ConferenceDayID = CDR.ConferenceDayID
        inner join RegistrationForConferenceDay RFCD on CDR.ConferenceDayReservationID = RFCD.ConferenceDayReservationID
        inner join Attendee A on RFCD.AttendeeID = A.AttendeeID
        where C.StartDate >= GETDATE()

create view OverlappingWorkshops
as
    select W1.WorkshopID as FirstWorkshopID, W1.Title as FirstWorkshopTitle, W1.StartTime as FirstWorkshopStartTime, W1.EndTime as FirstWorkshopEndTime, W2.WorkshopID, W2.Title, W2.StartTime, W2.EndTime
    from Workshop W1 cross join Workshop W2
    where [dbo].are_workshops_overlapping(W1.WorkshopID, W2.WorkshopID) = 1

create view OverlappingConferenceDays
as
    select C1.ConferenceDayID as C1ConferenceDayID, C1.Date as C1Date, C1.Address as C1Address, C1.AttendeesMaxNumber as C1AttendeesMaxNumber, C2.ConferenceDayID, C2.Date, C2.Address, C2.AttendeesMaxNumber
    from ConferenceDay C1 cross join ConferenceDay C2
    where C1.Date = C2.Date
    and C1.ConferenceDayID != C2.ConferenceDayID

create view OverlappingConferences
as
    select C1.ConferenceID as C1ConferenceID, C1.Name as C1Name, C1.StartDate as C1StartDate, C1.EndDate as C1EndDate,C2.ConferenceID, C2.Name, C2.StartDate, C2.EndDate
    from Conference C1 cross join Conference C2
    where [dbo].are_conferences_overlapping(C1.ConferenceID, C2.ConferenceID) = 1

create view UndergoingConferences
as
    select ConferenceID, Name, StartDate, EndDate
    from Conference
    where Conference.StartDate <= GETDATE() and Conference.EndDate >= GETDATE()

create view CancelledReservationsWithCustomerInfo
as
    select ReservationID, R.CustomerID, Date, AmountPaid, CompanyName, Address, City, Email, Phone
    from Reservation R inner join Customer C on R.CustomerID = C.CustomerID
    inner join Company C2 on C.CompanyID = C2.CompanyID
    where R.isCancelled = 1
    union
    select ReservationID, R.CustomerID, Date, AmountPaid, Name + Surname as name, Address, City, Email, Phone
    from Reservation R inner join Customer C3 on R.CustomerID = C3.CustomerID
    inner join Attendee A on C3.AttendeeID = A.AttendeeID
    where R.isCancelled = 1

create view FutureWorkshopsWithFreePlaces
as
    select WorkshopID, StartTime, EndTime, Address, Price, Title, AttendeesMaxNumber - (select count(*) from dbo.get_attendees_by_workshopid(WorkshopID)) as [Free places]
    from Workshop
    where AttendeesMaxNumber > (select count(*) from get_attendees_by_workshopid(WorkshopID))

create view FutureConferenceDaysWithFreePlaces
as
    select ConferenceDayID, ConferenceID, Address, Date, AttendeesMaxNumber - (select count(*) from  dbo.get_attendees_by_conferencedayid(ConferenceDayID)) as [Free places]
    from ConferenceDay
    where AttendeesMaxNumber > (select count(*) from  dbo.get_attendees_by_conferencedayid(ConferenceDayID))

---------------------------------------------------------PROCEDURES--------------------------------------------------------------------------

--adding conference--
create procedure add_conference
 @name nvarchar(40),
 @description nvarchar(40),
 @StudentDiscount decimal(3,2),
 @StartDate date,
 @EndDate date
 as begin try
    insert into conference
     (Name, Description, StudentDiscount, StartDate, EndDate)
     values (@name,@description,@StudentDiscount,@StartDate,@EndDate)
end try
begin catch
    declare @errorMessage nvarchar(2048)
    set @errorMessage = 'Error occurred when adding conference: \n'
    +ERROR_MESSAGE();
    THROW 52000, @errormessage,1
end catch

--adding conference day--
 create procedure add_conference_day
 @conferenceID int,
 @attendanceMaxNumber int,
 @address nvarchar(40),
 @date datetime
  as begin try
     if not exists
      (select * from conference
         where conferenceid=@conferenceID)
      begin
          throw 52000, 'Conference with provided id does not exist.',1
      end
      if exists
          (select * from ConferenceDay
          where ConferenceID=@conferenceID and date=@date)
      begin
          throw 52000,'Conference day with provided date already exists.',1
      end
      insert into ConferenceDay(conferenceid, attendeesmaxnumber, address, date)
      values(@conferenceID, @attendanceMaxNumber,@address,@date)
 end try
 begin catch
     declare @errorMessage nvarchar(2048)
         set @errorMessage = 'Error occurred when adding conference day: \n' +ERROR_MESSAGE();
    THROW 52000, @errormessage,1
 end catch

--adding workshop--
create procedure add_workshop
@conferenceDayID int,
@startTime datetime,
@endTime datetime,
@address nvarchar(40),
@price money,
@description nvarchar(40),
@attendanceMaxNumber int,
@title nvarchar(40)
as
    begin try
        if not exists(
            select * from ConferenceDayReservation
            where ConferenceDayID=@conferenceDayID
            )
        begin
            throw 52000,'Conference day does not exist' ,1
        end
        insert into Workshop
        (conferencedayid, starttime, endtime, address, price, description, attendeesmaxnumber, title)
        values(@conferenceDayID,@startTime,@endTime,@address,@price,@description,@attendanceMaxNumber,@title)
    end try
    begin catch
          declare @errorMessage nvarchar(2048)
         set @errorMessage = 'Error occurred when adding workshop: \n' +ERROR_MESSAGE();
    THROW 52000, @errormessage,1
    end catch

--add price threshold--
create procedure add_price_threshold
        @StartDate datetime,
        @EndDate datetime,
        @price money,
        @conferenceDayID int
as
    begin try
        if not exists(select * from ConferenceDay where ConferenceDayID=@conferenceDayID)
        begin
            throw 52000, 'Conference day does not exists',1
        end
        insert into PriceThreshold
        (ConferenceDayID, StartDate, EndDate, Price)
        Values(@conferenceDayID,@StartDate,@EndDate,@price)
    end try
    begin catch
        declare @errorMessage nvarchar(2048)
         set @errorMessage = 'Error occurred when adding price threshold: \n' +ERROR_MESSAGE();
    THROW 52000, @errormessage,1
    end catch

--add reservation for conference--
create procedure add_reservation_for_conference
    @ConferenceID int,
    @CustomerID int,
    @Date datetime
as
    begin try
        if not exists (select * from Conference where conferenceID=@ConferenceID)
        begin throw 52000 , 'Conference does not exists .' ,1
        end
        if not exists(select * from Customer  where CustomerID=@CustomerID)
        begin throw 52000 , 'Customer does not exists .' ,1
        end
        insert into Reservation
        (CustomerID, Date, AmountPaid, isCancelled)
        Values (@CustomerID,@date, 0, 0)
    end try
    begin catch
        declare @errorMessage nvarchar(2048)
         set @errorMessage = 'Error occurred when adding conference: \n' +ERROR_MESSAGE();
    THROW 52000, @errormessage,1
    end catch

--add conference day reservation--
create procedure add_conference_day_reservation
@ConferenceDayID int,
@ReservationID int,
@Students int,
@Attendees int
as
begin try
    if not exists(select * from conferenceDay where conferenceDayID=@ConferenceDayID)
    begin throw 52000,'Conference day does not exists .' ,1
    end
    if not exists(select * from reservation where ReservationID=@ReservationID)
    begin throw 52000,'Reservation does not exists .',1
    end
   if not exists(select c.companyID from customer c
    inner join Reservation r on r.CustomerID=c.CustomerID
        where r.ReservationID = @ReservationID and CompanyID is not null)
    and @Attendees > 1
    begin
    ;throw 52000,'Individual client can book only single place in a day',1
    end
    insert into ConferenceDayReservation(conferencedayid, reservationid, attendees, students,isCancelled)
    values(@ConferenceDayID,@ReservationID,@Attendees,@Students, 0)
end try
begin catch
    declare @errorMessage nvarchar(2048)
         set @errorMessage = 'Error occurred when adding conference day reservation: \n' +ERROR_MESSAGE();
    THROW 52000, @errormessage,1
end catch

--add workshop reservation--
    create procedure add_workshop_reservation
@WorkshopID int,
@attendees int,
@conferenceDayReservationID int
as
        begin try
            if not exists (select * from workshop wr where wr.WorkshopID=@WorkshopID)
            begin throw 52000,'Workshop does not exists',1
                end
            if not exists (select * from ConferenceDayReservation where ConferenceDayReservationID=@conferenceDayReservationID)
            begin throw 52000,'Reservation does not exists',1
                end
            if exists (select isCancelled from ConferenceDayReservation where ConferenceDayReservationID=@conferenceDayReservationID
                and ConferenceDayReservation.isCancelled = 1)
                begin throw 52000,'Reservation for this day of conference is already cancelled',1
                end
            declare @possibleAttendees int =
            (select Attendees from ConferenceDayReservation where @conferenceDayReservationID=ConferenceDayReservationID)
            if @possibleAttendees < @attendees
            begin throw 52000,'Not enough place for all',1
                end
            insert into WorkshopReservation
            ( WorkshopID, ConferenceDayReservationID, Attendees, isCancelled)
            Values (@WorkshopID,@conferenceDayReservationID,@attendees, 0)
        end try
        begin catch
               declare @errorMessage nvarchar(2048)
         set @errorMessage = 'Error occurred when adding reservation workshop: \n' +ERROR_MESSAGE();
    THROW 52000, @errormessage,1
        end catch

--add Company--
create procedure add_company
@CompanyName nvarchar(40),
@CompanyAddress nvarchar(40),
@City nvarchar(40),
@email nvarchar(40),
@phone nvarchar(40),
@NIP nvarchar(40)
as
begin try
    declare @companyID int
   select @companyID=co.companyID from customer
    inner join company co on co.CompanyID=customer.CompanyID
    where @email=co.Email and @nip=co.NIP
    if @companyId is not NULL
        begin throw 52000,'Company already exists',1
    end
    insert into Company
    (CompanyName, Address, City, Email, Phone, NIP)
    values(@companyname,@CompanyAddress,@City,@email,@phone,@nip)
end try
begin catch
    declare @errorMessage nvarchar(2048)
         set @errorMessage = 'Error occurred when adding company: \n' +ERROR_MESSAGE();
    THROW 52000, @errormessage,1
end catch

--adding customer--
create procedure add_customer
@CompanyID int,
@AttendeeID int
as
    begin try
        if ((@AttendeeID is null and @CompanyID is null) or (@AttendeeID is not null and @CompanyID is not null))
        begin throw 52000,'Customer is private person or a company, those groups are exclusive ',1
            end
        declare @customerID int
        select @customerID=customerid from Customer
        where @AttendeeID=AttendeeID and @CompanyID=CompanyID

        if @customerID is not null
        begin throw 52000,'Customer already exists',1
        end
insert into customer (CompanyID, AttendeeID)
values(@CompanyID,@AttendeeID)
    end try
    begin catch
        declare @errorMessage nvarchar(2048)
         set @errorMessage = 'Error occurred when adding customer: \n' +ERROR_MESSAGE();
    THROW 52000, @errormessage,1
    end catch

--add attendee--
create procedure add_attendee
@Name nvarchar(40),
@Surname nvarchar(40),
@Email nvarchar(40),
@Phone nvarchar(20),
@City nvarchar(40),
@PostalCode nvarchar(40),
@Address nvarchar(40)
as
    begin try
        declare @attendeeID int
        select @attendeeID=attendeeID
        from Attendee
        where @name=name and @surname=surname and @phone=phone
        if @attendeeID is not null begin throw 52000,'Attendee already exists',1
        end
        insert into Attendee (Name, Surname, Email, Phone, City, PostalCode, Address)
        values(@name,@surname,@email,@phone,@city,@postalcode,@address)
    end try
    begin catch
         declare @errorMessage nvarchar(2048)
         set @errorMessage = 'Error occurred when adding attendee: \n' +ERROR_MESSAGE();
    THROW 52000, @errormessage,1
    end catch

--registration for conference day--
create procedure add_conference_day_registration
@conferenceDayReservationID int,
@AttendeeID int,
@studentPrice bit
as
    begin try
        if not exists(select * from ConferenceDayReservation  where ConferenceDayReservationID=@conferenceDayReservationID)
        begin throw 52000,'No reservation for that time.',1
        end
        if not exists(select * from Attendee where AttendeeID=@AttendeeID)
        begin throw 52000,'Attendee does not exist',1
            end
        insert into
            RegistrationForConferenceDay(AttendeeID, ConferenceDayReservationID, StudentPrice)
            values(@AttendeeID,@conferenceDayReservationID,@studentPrice)
    end try
    begin catch
          declare @errorMessage nvarchar(2048)
         set @errorMessage = 'Error occurred when doing registration for conference day: \n' +ERROR_MESSAGE();
    THROW 52000, @errormessage,1
    end catch


--registration for workshop--
        create procedure add_workshop_registration
@WorkshopReservationID int,
@registrationForConferenceDayID int
as
            begin try
                if not exists (select * from WorkshopReservation where WorkshopReservationID=@WorkshopReservationID)
                begin throw 52000,'No reservation for that workshop',1
                end
                if not exists (select * from RegistrationForConferenceDay where @registrationForConferenceDayID=RegistrationForConferenceDayID)
                begin throw 52000,'No day registration for that time',1
                end
                insert into RegistrationForWorkshop(workshopreservationid, registrationforconferencedayid)
                values(@WorkshopReservationID,@registrationForConferenceDayID)
            end try
            begin catch
                 declare @errorMessage nvarchar(2048)
         set @errorMessage = 'Error occurred when doing registration for workshop: \n' +ERROR_MESSAGE();
    THROW 52000, @errormessage,1
            end catch

--**remove conference day reservation--
create procedure remove_conference_day_reservation
@ConferenceDayReservationID int
as
    begin
        begin
            try
            if not exists (select * from ConferenceDayReservation as cdr where cdr.ConferenceDayReservationID=@ConferenceDayReservationID)
            begin throw 52001,'Reservation for conference day  does not exist',1
                end
            delete from ConferenceDayReservation where ConferenceDayReservationID=@ConferenceDayReservationID
        end try
        begin catch
            declare @errorMessage nvarchar(2048)
         set @errorMessage = 'Error occurred when doing  conference day reservation removement : \n' +ERROR_MESSAGE();
    THROW 52000, @errormessage,1
        end catch
end


--**remove workshop reservation--
create procedure remove_workshop_reservation
@WorkshopReservationID int
as
    begin
        begin
            try
            if not exists (select * from WorkshopReservation as wr where wr.WorkshopReservationID=@WorkshopReservationID)
            begin throw 52001,'Reservation for workshop does not exist',1
        end
            delete from WorkshopReservation where WorkshopReservationID=@WorkshopReservationID
            end try
        begin catch
            declare @errorMessage nvarchar(2048)
         set @errorMessage = 'Error occurred when doing workshop reservation removement: \n' +ERROR_MESSAGE();
    THROW 52000, @errormessage,1
        end catch
    end

--**remove reservation--
create procedure remove_reservation
@ReservationID int
as
    begin
        begin try
            if not exists (select * from Reservation r where r.ReservationID=@ReservationID)
            begin throw 52001,'Reservation does not exist',1
            end
            delete from  Reservation where ReservationID=@ReservationID
            end try
          begin catch
            declare @errorMessage nvarchar(2048)
         set @errorMessage = 'Error occurred when doing reservation removement: \n' +ERROR_MESSAGE();
    THROW 52000, @errormessage,1
        end catch

    end

--**remove registration for conference day--
create procedure remove_registration_for_conference_day
@RegistrationForConferenceDayID int
as
    begin
        begin try
            if not exists (select * from RegistrationForConferenceDay where RegistrationForConferenceDayID=@RegistrationForConferenceDayID)
            begin throw 52001,'Registration for conference day does not exist',1
            end
            delete from RegistrationForConferenceDay where RegistrationForConferenceDayID=@RegistrationForConferenceDayID
            end try
         begin catch
            declare @errorMessage nvarchar(2048)
         set @errorMessage = 'Error occurred when doing registration conference day removement: \n' +ERROR_MESSAGE();
    THROW 52000, @errormessage,1
             end catch
    end

--**remove registration for workshop--
create procedure remove_registration_for_workshop
@RegistrationForWorkshopID int
as
begin
    begin try
        if not exists (select * from RegistrationForWorkshop where RegistrationForWorkshopID=@RegistrationForWorkshopID)
        begin throw 52001,'Registration for workshop does not exist',1
            end
        delete from RegistrationForWorkshop where RegistrationForWorkshopID=@RegistrationForWorkshopID
    end try
    begin catch
        declare @errorMessage nvarchar(2048)
         set @errorMessage = 'Error occurred when doing registration for workshop  removement: \n' +ERROR_MESSAGE();
    THROW 52000, @errormessage,1
    end catch
end

--**Payment realisation--
create procedure payment_realisation
@PaymentAmount int,
@ReservationID int
as
    begin
        begin try
            if not exists (select * from Reservation where ReservationID=@ReservationID)
            begin throw 52001,'Reservation does not exist',1
                end
            if @PaymentAmount < 0
            begin throw 52001,'Payment amount can not be below zero',1
            end
            update reservation set AmountPaid=AmountPaid+@PaymentAmount where ReservationID=@ReservationID
            end try
        begin catch
            declare @errorMessage nvarchar(2048)
         set @errorMessage = 'Error occurred when doing payment realisation: \n' +ERROR_MESSAGE();
    THROW 52000, @errormessage,1
        end catch
    end

--**unpaid reservation cancellation--
create procedure unpaid_reservation_cancellation
as
    update Reservation
    set reservation.isCancelled=1
    from Reservation join ReservationsWithPrices on Reservation.ReservationID=ReservationsWithPrices.reservationid
    where not
        exists(
            select * from reservation r  where datediff(d,r.date,GETDATE()) <=7
            and ReservationsWithPrices.[Amount to Pay]=0
            )
------------------------------------------------------TRIGGERS-----------------------------------------------------------------------------------------------

--reservation cancelling--
create trigger reservation_cancelled
    on reservation
    after update
as begin
    update cdr
    set cdr.isCancelled=i.isCancelled
    from ConferenceDayReservation cdr
    inner join inserted i on i.ReservationID = cdr.ReservationID
    update wr
    set wr.isCancelled=i.isCancelled
    from WorkshopReservation wr
    inner join ConferenceDayReservation CDR2 on wr.ConferenceDayReservationID = CDR2.ConferenceDayReservationID
    inner join inserted i on i.ReservationID = CDR2.ReservationID
    end

--**number of attendees to reserve is less or equal the number of free places on the conference day--
create trigger too_few_places_conference_day
  on ConferenceDay
   after update
as
    begin
if  exists(select * from inserted i where dbo.get_conference_day_free_places_number(i.ConferenceDayID)<0)
        begin
            rollback transaction;
            throw 52001,'Too few places to reserve this many conference day attendees.',1
    end
end

--**number of attendees to reserve is less or equal the number of free places on the workshop--
create trigger too_few_places_workshop
    on Workshop
   after update
as
    begin
if exists(select * from inserted i where dbo.get_workshop_free_places_number (i.WorkshopID)<0)
begin
    rollback transaction;
    throw 52001,'Too few places to reserve this many workshop attendees',1
    end
end

--**conference day belongs to conference--
create trigger conference_day_belongs_conference
    on ConferenceDay
    after insert
as
    begin
        if exists(select * from inserted i inner join conference c on c.ConferenceID=i.ConferenceID
            where i.date not between c.startdate and c.enddate)

        begin
        rollback transaction;
        throw 52001,'Conference day must belong to conference',1
            end
    end

--**Workshop belongs to conference--
create trigger workshop_belongs_conference
    on Workshop
    after insert
as
    begin
        if exists(select * from inserted i inner join conferenceday cd on cd.ConferenceDayID=i.ConferenceDayID
            and convert(date,i.starttime)!=cd.date)
        begin
            rollback transaction;
            throw 52002,'Workshop must belong to conference',1
            end
    end

--**Price threshold are connected--
create trigger start_of_one_threshold_is_end_plus_one_of_another
    on PriceThreshold
    after insert
as
    begin
        if exists(select * from inserted i where i.startdate !=
            dateadd(day, +1 ,(select top 1 PriceThreshold.EndDate from PriceThreshold where PriceThreshold.ConferenceDayID = i.ConferenceDayID
            order by EndDate desc)) or i.enddate>(select cd.date from ConferenceDay cd where i.ConferenceDayID=cd.ConferenceDayID))
        begin
            rollback transaction;
            throw 52002,'Not valid date of threshold',1
        end
    end

--*Eliminate conference days for deleted reservation--
create trigger delete_conference_days_for_deleted_reservation
    on Reservation
   after delete
as
  begin
      delete from ConferenceDayReservation  where ConferenceDayReservation.ReservationID in (select ReservationID from deleted)
  end

--*Eliminate Workshop reservation for deleted conference day reservation--
create trigger delete_workshop_reservation_for_deleted_conference_day_reservation
    on ConferenceDayReservation
    after delete
as
    begin
        delete from WorkshopReservation where ConferenceDayReservationID in (select ConferenceDayReservationID from deleted)
    end

--*Eliminate registration for conference day for deleted conference day reservation--
create trigger delete_registration_conference_day_for_deleted_conference_day_reservation
    on ConferenceDayReservation
    after delete
as
    begin
        delete from RegistrationForConferenceDay where ConferenceDayReservationID in (select ConferenceDayReservationID from deleted)
    end

--*Eliminate registration for workshop for deleted workshop reservation--
create trigger delete_registration_workshop_for_deleted_workshop_reservation
    on WorkshopReservation
    after delete
as
    begin
        delete from RegistrationForWorkshop where WorkshopReservationID in (select WorkshopReservationID from deleted)
    end

    --all reserved student places for conference day have their registration - cannot add another registration for this reservation

create trigger cannot_add_new_student_registration_for_conference_day
        on RegistrationForConferenceDay
        after insert
as
    begin
        if exists(select ConferenceDayReservationID from ConferenceDayReservation cdr
            where cdr.ConferenceDayReservationID in (select ConferenceDayReservationID from inserted) and cdr.Students < (select count(RegistrationForConferenceDayID)
                from RegistrationForConferenceDay where RegistrationForConferenceDay.ConferenceDayReservationID = cdr.ConferenceDayReservationID
                and StudentPrice = 1
                group by RegistrationForConferenceDay.ConferenceDayReservationID))
        begin
            ROLLBACK TRANSACTION;
            THROW 50001,'Too few free places for students to add registrations ',1
        end
    end

--all reserved places for conference day have their registration - cannot add another registration for this reservation

create trigger cannot_add_new_registration_for_conference_day
    on RegistrationForConferenceDay
    after insert
as
    begin
        if exists(select ConferenceDayReservationID from ConferenceDayReservation cdr
            where cdr.ConferenceDayReservationID in (select ConferenceDayReservationID from inserted) and cdr.Attendees < (select count(RegistrationForConferenceDayID)
                from RegistrationForConferenceDay where RegistrationForConferenceDay.ConferenceDayReservationID = cdr.ConferenceDayReservationID
                group by RegistrationForConferenceDay.ConferenceDayReservationID))
        begin
            ROLLBACK TRANSACTION;
            THROW 50001,'Too few free places to add registrations ',1
        end
end

--all reserved places for workshop have their registration - cannot add another registration for this reservation

create trigger cannot_add_new_registration_for_workshop
    on RegistrationForWorkshop
    after insert
as
    begin
            if exists(select WorkshopReservationID from WorkshopReservation wr
            where wr.WorkshopReservationID in (select WorkshopReservationID from inserted) and wr.Attendees < (select count(RegistrationForWorkshopID)
                from RegistrationForWorkshop where RegistrationForWorkshop.WorkshopReservationID = wr.WorkshopReservationID
                group by RegistrationForWorkshop.WorkshopReservationID))
        begin
            ROLLBACK TRANSACTION;
            THROW 50001,'Too few free places to add registrations ',1
        end
    end


--delete all registrations for workshop connected with deleted registration for conference day

create trigger delete_workshop_registrations
    on RegistrationForConferenceDay
    after delete
as
    begin
        delete from RegistrationForWorkshop
        where RegistrationForConferenceDayID in (select RegistrationForConferenceDayID from deleted)
    end

--attempt of registration for two or more overlapping workshops

create trigger cannot_register_for_overlapping_workshops
    on RegistrationForWorkshop
    after insert
as
    begin
        if (exists(select A2.AttendeeID from inserted i inner join RegistrationForConferenceDay R
            on R.RegistrationForConferenceDayID = i.RegistrationForConferenceDayID
            inner join Attendee A2 on R.AttendeeID = A2.AttendeeID
            inner join WorkshopReservation WR3 on i.WorkshopReservationID = WR3.WorkshopReservationID
            where exists(select wr2.WorkshopID from Workshop inner join WorkshopReservation WR2 on Workshop.WorkshopID = WR2.WorkshopID
                inner join RegistrationForWorkshop RFW on WR2.WorkshopReservationID = RFW.WorkshopReservationID
                inner join RegistrationForConferenceDay D on RFW.RegistrationForConferenceDayID = D.RegistrationForConferenceDayID
                inner join Attendee A3 on D.AttendeeID = A3.AttendeeID
                where A3.AttendeeID = A2.AttendeeID and dbo.are_workshops_overlapping(WR3.WorkshopID, Workshop.WorkshopID) = 1)
            ))
        begin
            ROLLBACK TRANSACTION;
            THROW 50001, 'Cannot register for overlapping workshops', 1
        end
    end

----------------------------------------------------------------GENERATOR-------------------------------------------------------------------------------

declare @i int=0
declare @j int =0
while @i<(select count(*) from dbo.Conference)
begin set @i=@i+1
    set @j=0
    while @j<
          (select datediff(day,(select startdate from dbo.Conference where conferenceId=@i),(select EndDate from dbo.conference where conferenceID=@i))
              as datediff)
    begin
        insert into dbo.ConferenceDay values(@i,rand()*(250)+1,'Kossaki Street',dateadd(day,@j,(select startdate from dbo.conference where conferenceID=@i)))
        set @j=@j+1
    end
end

declare @i int =0
declare @j int =0
while @i<(select count(*) from dbo.ConferenceDay)
begin set @i=@i+1
    set @j=0
    while @j<(select datediff(day,(select c.startdate from dbo.conferenceday cd inner join dbo.conference c on c.ConferenceID=cd.ConferenceID where cd.ConferenceDayID=@i),
        (select c.enddate from dbo.conferenceday cd inner join dbo.conference c on c.conferenceID=cd.conferenceid where cd.ConferenceDayID=@i)) as datediff)
    begin
        insert into dbo.workshop values(@i,dateadd(day,@j,))
    end
