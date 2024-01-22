--SQL_PROJECT FINAL

--General info

--You are employee in IT department of commercial bank that has offices in different countries. 
--You receive request to design database for Salary management for the employees across the globe.
--You will need to prepare database that will be used to store and manage basic information 
--about the employee and additionally manage monthly salary for each employee. 
--Following information should exists in your database:

--Kreirame nova baza


use SQL_Project

--Kreirame Seniority Level tabela soglasno postavenata zadacata

drop table if exists [dbo].[SeniorityLevel]
go 

CREATE TABLE [dbo].[SeniorityLevel]
(
	[ID] [int] IDENTITY(1,1) PRIMARY KEY NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
)

insert into [dbo].[SeniorityLevel] (Name)
values
		('Junior'),
		('Intermediate'),
		('Senior'),
		('Lead'),
		('Project Manager'),
		('Division Manager'),
		('Office Manager'),
		('CEO'),
		('CTO'),
		('CIO')

select * from [dbo].[SeniorityLevel]

--Kreirame Location tabela soglasno postavenata zadacata i 
--potrebnite podatoci od 190 reda od (Application.Countries) gi zimame od veke kreiranata baza na WideWorldImporters

drop table if exists [dbo].[Location]
go 

create table [dbo].[Location]
(
   [ID] [int] IDENTITY(1,1) PRIMARY KEY NOT NULL,
   [CountryName] [nvarchar](100),
   [Continent] [nvarchar](100),
   [Region] [nvarchar](100),
)

insert into [dbo].[Location] (CountryName, Continent, Region)
select [CountryName],[Continent],[Region]
from [Wide World Importers].[Application].[Countries]

select * from [dbo].[Location]

--Kreirame Department tabela soglasno postavenata zadacata

drop table if exists [dbo].[Department]
go 

CREATE TABLE [dbo].[Department]
(
	[ID] [int] IDENTITY(1,1) PRIMARY KEY NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
)

insert into [dbo].[Department] (Name)
values
		('Personal Banking & Operations'),
		('Digital Banking Department'),
		('Retail Banking & Marketing Department'),
		('Wealth Management & Third Party Products'),
		('International Banking Division & DFB'),
		('Treasury'),
		('Information Technology'),
		('Corporate Communications'),
		('Support Services & Branch Expansion'),
		('Human Resources')

select * from [dbo].[Department]

--Kreirame Employee tabela soglasno postavenata zadacata i 
--potrebnite podatoci od 1111 reda od (Application.People) gi zimame od veke kreiranata baza na WideWorldImporters 
--i istite tie podatoci ke gi procistime i napravime na ovoj nachin : 

--Seniority level:
--We have 10 different seniority levels, so all employees should be divided in almost equal groups 
--and ~10% of employees should have ‘Junior’ seniority, 10% “Intermediate” and so on.

--Departments:
--We have 10 different departments, so all employees should be divided in almost equal groups
--and ~10% of employees should belong to ‘Personal Banking & Operations’ department, 
--~10% “Treasury” department and and so on.

--Location:
--We have 190 different departments, so all employees should be divided in almost equal groups 
--and we need to have approx. 5-6 employees on each location.
--Example: Employee 1,2,3,4,5,6 should be on location 1, Employees 7,8,9,10,11,12 should be on location 2 etc.

drop table if exists [dbo].[Employee]
go 

CREATE TABLE [dbo].[Employee]
(
	[ID] [int] IDENTITY(1,1) PRIMARY KEY NOT NULL,
	[FirstName] [nvarchar](100) NOT NULL,
	[LastName] [nvarchar](100) NOT NULL,
	[LocationID] [int] NOT NULL,
	[SeniorityLevelID] [int] NOT NULL,
	[DepartmentID] [int] NOT NULL
)

select* from [Wide World Importers].[Application].[People]

--tuka so substring,charindex gi odvoivme FirstName i LastName od WWI (App.People) tabelata, (kade bea spoeni-FullName)
--naredno so f-jata ntile gi podredivme po personid za da dobieme 10% seniority level od employee, 
--10% department od employee i 190 department (5-6) employee po location.
--i na kraj povrzavme so join, za da si gi prevzememe od site id-njata.

;with cte as
(
select
trim(substring([FullName],1,charindex(' ',[FullName])-1)) as FirstName,
trim(substring([FullName],charindex(' ',[FullName]),len([FullName])-charindex(' ',[FullName])+1)) as LastName,
                       NTILE(190) OVER (ORDER BY PersonID) as LocationID, 
                       NTILE(10) OVER (ORDER BY PersonID) as SeniorityLevelID,
                       NTILE(10) OVER (ORDER BY PersonID) as DepartmentID
from [Wide World Importers].[Application].[People]
)
insert into [dbo].[Employee] (FirstName, LastName, LocationID, SeniorityLevelID, DepartmentID)
select FirstName,LastName, LocationID, SeniorityLevelID, DepartmentID
from cte as ct
inner join [Location] as l on ct.LocationID= l.id
inner join SeniorityLevel as sl on ct.SeniorityLevelID=sl.id
inner join Department as d on ct.DepartmentID=d.id

select * from [dbo].[Employee]

--Kreirame Salary tabela soglasno postavenata zadacata i si ja povikuvame 
--procedurata za Data od predthodnata baza, (bidejki tuka ke ni e potrebana istata)

--Salary data for the past 20 years, starting from 01.2001 to 12.2020
--Gross amount should be random data between 30.000 and 60.000 
--Net amount should be 90% of the gross amount
--RegularWorkAmount sould be 80% of the total Net amount for all employees and months
--Bonus amount should be the difference between the NetAmount and RegularWorkAmount for every Odd month (January,March,..)
--OvertimeAmount  should be the difference between the NetAmount and RegularWorkAmount for every Even month (February,April,…)
--All employees use 10 vacation days in July and 10 Vacation days in December
--Additionally random vacation days and sickLeaveDays should be generated with the following script:

drop table if exists [dbo].[Salary]
go 

CREATE TABLE [dbo].[Salary]
(
   [ID] [bigint] IDENTITY(1,1) PRIMARY KEY NOT NULL,
   [EmployeeID] [int] NOT NULL,
   [Month] [smallint] NOT NULL,
   [Year] [smallint] NOT NULL,
   [GrossAmount] [decimal](18,2) NOT NULL,
   [NetAmount] [decimal](18,2) NOT NULL,
   [RegularWorkAmount] [decimal](18,2) NOT NULL,
   [BonusAmount] [decimal](18,2) NOT NULL,
   [OvertimeAmount] [decimal](18,2) NOT NULL,
   [VacationDays] [smallint] NOT NULL,
   [SickLeaveDays] [smallint] NOT NULL
)

--kreiranje tabela Data

drop table if exists [dbo].[Data]
go 

CREATE TABLE [dbo].[Date](
	[DateKey] [int] NOT NULL,
	[Date] [date] NOT NULL,
	[Day] [tinyint] NOT NULL,
	[DaySuffix] [char](2) NOT NULL,
	[Weekday] [tinyint] NOT NULL,
	[WeekDayName] [varchar](10) NOT NULL,
	[IsWeekend] [bit] NOT NULL,
	[IsHoliday] [bit] NOT NULL,
	[HolidayText] [varchar](64) SPARSE  NULL,
	[DOWInMonth] [tinyint] NOT NULL,
	[DayOfYear] [smallint] NOT NULL,
	[WeekOfMonth] [tinyint] NOT NULL,
	[WeekOfYear] [tinyint] NOT NULL,
	[ISOWeekOfYear] [tinyint] NOT NULL,
	[Month] [tinyint] NOT NULL,
	[MonthName] [varchar](10) NOT NULL,
	[Quarter] [tinyint] NOT NULL,
	[QuarterName] [varchar](6) NOT NULL,
	[Year] [int] NOT NULL,
	[MMYYYY] [char](6) NOT NULL,
	[MonthYear] [char](7) NOT NULL,
	[FirstDayOfMonth] [date] NOT NULL,
	[LastDayOfMonth] [date] NOT NULL,
	[FirstDayOfQuarter] [date] NOT NULL,
	[LastDayOfQuarter] [date] NOT NULL,
	[FirstDayOfYear] [date] NOT NULL,
	[LastDayOfYear] [date] NOT NULL,
	[FirstDayOfNextMonth] [date] NOT NULL,
	[FirstDayOfNextYear] [date] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[DateKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

alter table dbo.[Date]
add ValidFrom date,
    ValidTo date,
	ModifieDate datetime

ALTER TABLE [dbo].[Date] ADD CONSTRAINT [DF_dboDate_ValidFrom] DEFAULT (getdate()) FOR [ValidFrom]
ALTER TABLE [dbo].[Date] ADD CONSTRAINT [DF_dboDate_ValidTo] DEFAULT ('1900-01-01') FOR [ValidTo]

select *from dbo.Date

--Kreiranje na procedura Date

;CREATE or alter PROCEDURE [dbo].[GenerateDate]
	-- Add the parameters for the stored procedure here
	@StartDate date,
	@NumberOfYears int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		DECLARE
		@CutoffDate DATE = (select DATEADD(YEAR, @NumberOfYears, @StartDate))

	-- prevent set or regional settings from interfering with 
	-- interpretation of dates / literals
	SET DATEFIRST 7;
	SET DATEFORMAT mdy;
	SET LANGUAGE US_ENGLISH;

	-- this is just a holding table for intermediate calculations:
	CREATE TABLE #dim
	(
		[Date]       DATE        NOT NULL, 
		[day]        AS DATEPART(DAY,      [date]),
		[month]      AS DATEPART(MONTH,    [date]),
		FirstOfMonth AS CONVERT(DATE, DATEADD(MONTH, DATEDIFF(MONTH, 0, [date]), 0)),
		[MonthName]  AS DATENAME(MONTH,    [date]),
		[week]       AS DATEPART(WEEK,     [date]),
		[ISOweek]    AS DATEPART(ISO_WEEK, [date]),
		[DayOfWeek]  AS DATEPART(WEEKDAY,  [date]),
		[quarter]    AS DATEPART(QUARTER,  [date]),
		[year]       AS DATEPART(YEAR,     [date]),
		FirstOfYear  AS CONVERT(DATE, DATEADD(YEAR,  DATEDIFF(YEAR,  0, [date]), 0)),
		Style112     AS CONVERT(CHAR(8),   [date], 112),
		Style101     AS CONVERT(CHAR(10),  [date], 101)
	);

	-- use the catalog views to generate as many rows as we need
	INSERT INTO #dim ([date]) 
	SELECT
		DATEADD(DAY, rn - 1, @StartDate) as [date]
	FROM 
	(
		SELECT TOP (DATEDIFF(DAY, @StartDate, @CutoffDate)) 
			rn = ROW_NUMBER() OVER (ORDER BY s1.[object_id])
		FROM
			-- on my system this would support > 5 million days
			sys.all_objects AS s1
			CROSS JOIN sys.all_objects AS s2
		ORDER BY
			s1.[object_id]
	) AS x;
	-- select * from #dim

	truncate table dbo.[Date]

	INSERT dbo.[Date] ([DateKey], [Date], [Day], [DaySuffix], [Weekday], [WeekDayName], [IsWeekend], [IsHoliday], [HolidayText], [DOWInMonth], [DayOfYear], [WeekOfMonth], [WeekOfYear], [ISOWeekOfYear], [Month], [MonthName], [Quarter], [QuarterName], [Year], [MMYYYY], [MonthYear], [FirstDayOfMonth], [LastDayOfMonth], [FirstDayOfQuarter], [LastDayOfQuarter], [FirstDayOfYear], [LastDayOfYear], [FirstDayOfNextMonth], [FirstDayOfNextYear])
	SELECT
		DateKey       = convert(int, convert(varchar(4),year([date])) + right('0' + convert(varchar(2),month([date])),2) + right('0' + convert(varchar(2),day([date])),2)),
		[Date]        = [date],
		[Day]         = CONVERT(TINYINT, [day]),
		DaySuffix     = CONVERT(CHAR(2), CASE WHEN [day] / 10 = 1 THEN 'th' ELSE 
						CASE RIGHT([day], 1) WHEN '1' THEN 'st' WHEN '2' THEN 'nd' 
						WHEN '3' THEN 'rd' ELSE 'th' END END),
		[Weekday]     = CONVERT(TINYINT, [DayOfWeek]),
		[WeekDayName] = CONVERT(VARCHAR(10), DATENAME(WEEKDAY, [date])),
		[IsWeekend]   = CONVERT(BIT, CASE WHEN [DayOfWeek] IN (1,7) THEN 1 ELSE 0 END),
		[IsHoliday]   = CONVERT(BIT, 0),
		HolidayText   = CONVERT(VARCHAR(64), NULL),
		[DOWInMonth]  = CONVERT(TINYINT, ROW_NUMBER() OVER 
						(PARTITION BY FirstOfMonth, [DayOfWeek] ORDER BY [date])),
		[DayOfYear]   = CONVERT(SMALLINT, DATEPART(DAYOFYEAR, [date])),
		WeekOfMonth   = CONVERT(TINYINT, DENSE_RANK() OVER 
						(PARTITION BY [year], [month] ORDER BY [week])),
		WeekOfYear    = CONVERT(TINYINT, [week]),
		ISOWeekOfYear = CONVERT(TINYINT, ISOWeek),
		[Month]       = CONVERT(TINYINT, [month]),
		[MonthName]   = CONVERT(VARCHAR(10), [MonthName]),
		[Quarter]     = CONVERT(TINYINT, [quarter]),
		QuarterName   = CONVERT(VARCHAR(6), CASE [quarter] WHEN 1 THEN 'First' 
						WHEN 2 THEN 'Second' WHEN 3 THEN 'Third' WHEN 4 THEN 'Fourth' END), 
		[Year]        = [year],
		MMYYYY        = CONVERT(CHAR(6), LEFT(Style101, 2)    + LEFT(Style112, 4)),
		MonthYear     = CONVERT(CHAR(7), LEFT([MonthName], 3) + LEFT(Style112, 4)),
		FirstDayOfMonth     = FirstOfMonth,
		LastDayOfMonth      = MAX([date]) OVER (PARTITION BY [year], [month]),
		FirstDayOfQuarter   = MIN([date]) OVER (PARTITION BY [year], [quarter]),
		LastDayOfQuarter    = MAX([date]) OVER (PARTITION BY [year], [quarter]),
		FirstDayOfYear      = FirstOfYear,
		LastDayOfYear       = MAX([date]) OVER (PARTITION BY [year]),
		FirstDayOfNextMonth = DATEADD(MONTH, 1, FirstOfMonth),
		FirstDayOfNextYear  = DATEADD(YEAR,  1, FirstOfYear)
	FROM #dim
END
GO

--proverka 

exec dbo.GenerateDate @StartDate='2000-01-01', @NumberOfYears = 35

select *from dbo.Date

--Salary data for the past 20 years, starting from 01.2001 to 12.2020
--Gross amount should be random data between 30.000 and 60.000 
--Net amount should be 90% of the gross amount
--RegularWorkAmount sould be 80% of the total Net amount for all employees and months
--Bonus amount should be the difference between the NetAmount and RegularWorkAmount for every Odd month (January,March,..)
--OvertimeAmount  should be the difference between the NetAmount and RegularWorkAmount for every Even month (February,April,…)
--All employees use 10 vacation days in July and 10 Vacation days in December
--Additionally random vacation days and sickLeaveDays should be generated with the following script:

;with cte as
(
select e.ID,d.[Month],d.[Year],
convert (decimal (18,2),ABS (CHECKSUM (NewID())) %45000+ 45001) as GrossAmount
from Employee as e
cross join dbo.Date as d
where d.[Year] between '2001' and '2020'
group by e.ID,d.[Month],d.[Year]
)
insert into [dbo].[Salary] (EmployeeID, [Month], [Year], GrossAmount, NetAmount, 
RegularWorkAmount, BonusAmount, OvertimeAmount, VacationDays, SickLeaveDays)
select *,
GrossAmount *0.9 as NetAmount,
(GrossAmount *0.9)*0.8 as RegularWorkAmount,
case 
when (Month %2)<>0
then GrossAmount *0.9 -( GrossAmount *0.9)*0.8
else 0
end as BonusAmount,
case 
when (Month %2)=0
then GrossAmount *0.9-(GrossAmount *0.9)*0.8
else 0
end as OvertimeAmount,
case
when (Month) in (7,12)
then 10 
else 0
end as VacationDays,
0 as SickLeaveDays
from cte as c
order by [Year],[Month]

select* from [dbo].[Salary] 

--Additionally random vacation days and sickLeaveDays should be generated with the following script:
-- ova e istoto od postavenata zadaca 

update dbo.Salary set vacationDays = vacationDays + (EmployeeId % 2)
where  (employeeId + MONTH+ year)%5 = 1
GO
update dbo.Salary set SickLeaveDays = EmployeeId%8, vacationDays = vacationDays + (EmployeeId % 3)
where  (employeeId + MONTH+ year)%5 = 2
GO

--If everything is done as expected the following query should return 0 rows:
--tuka mi dava prazna tebela od 0 redovi

select * from dbo.Salary 
where NetAmount <> (regularWorkAmount + BonusAmount + OverTimeAmount)

--Additionally, vacation days should be between 20 and 30

select EmployeeID,[Month],[Year], sum (VacationDays) as VacationDays
from dbo.Salary
group by EmployeeID,[Month],[Year]
having sum (VacationDays) between 20 and 30
order by EmployeeID,[Month],[Year] desc




