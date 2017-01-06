--drop table #membertypes
--drop table #monthends

Declare @Start datetime
Declare @End datetime


Select @Start = '20150101'
Select @End = '20160701'

create table #MemberTypes (Member_Type varchar(max))
insert into #MemberTypes 
select 	'Public Entities (Official and Affiliate)'
union
select 	'Academic (Official and Affiliate)'
union
select 	'Students'
union
select 	'Regular Official Members (Lender, Owner/Developer/Mgt/Retailer)'
union
select 	'Associate Official Members (Real Estate Services)'
union
select 	'Regular Unsponsored Members'
union
select 	'Associate Unsponsored Members'
union
select 	'Regular Affiliate Members'
union
select 	'Associate Affiliate Members'
union
select 	'Other Members'

insert into ICSC_Monthly_KPI_Capture_Suspended_Members
select Member_Type, 0, cast(getdate() as date)
from #MemberTypes
where Member_Type not in (select Member_Type from ICSC_Monthly_KPI_Capture_Suspended_Members where Date_Captured = cast(getdate() as date))

;With CTE as
(
Select @Start  as Date,Case When DatePart(mm,@Start)<>DatePart(mm,@Start+1) then 1 else 0 end as [Last]
UNION ALL
Select Date+1,Case When DatePart(mm,Date+1)<>DatePart(mm,Date+2) then 1 else 0 end from CTE
Where Date<@End
)

Select Date into #MonthEnds
from CTE
where [Last]=1   OPTION ( MAXRECURSION 0 )

declare FixKPI cursor
for
select * from #MonthEnds

Declare @MonthEnd date

OPEN FixKPI
FETCH NEXT from FixKPI into @MonthEnd

while @@FETCH_STATUS = 0
BEGIN
	
	insert into ICSC_Monthly_KPI_Capture_Suspended_Members
	select Member_Type, 0, cast(getdate() as date)
	from #MemberTypes
	where Member_Type not in (select Member_Type from ICSC_Monthly_KPI_Capture_Suspended_Members where Date_Captured = cast(@MonthEnd as date))
	
	FETCH NEXT from FixKPI into @MonthEnd
END

	CLOSE FixKPI
	DEALLOCATE FixKPI
