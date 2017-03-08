IF OBJECT_ID('tempdb..##Membership_Overview') IS NOT NULL
	drop table ##Membership_Overview

IF OBJECT_ID('tempdb..##Months') IS NOT NULL
	drop table ##Months

--All months since the beginning of the year

--Inputs here:
DECLARE @StartDate datetime;
DECLARE @EndDate datetime;
SET @StartDate = dateadd(d,-1,cast(cast(year(GETDATE())-1 as varchar(4)) + '-1-1' as date))
SET @EndDate = GETDATE();

--Procedure here:
  WITH RecursiveRowGenerator (Row#, Iteration) AS (
       SELECT 1, 1
        UNION ALL
       SELECT Row# + Iteration, Iteration * 2
         FROM RecursiveRowGenerator
        WHERE Iteration * 2 < CEILING(SQRT(DATEDIFF(MONTH, @StartDate, @EndDate)+1))
        UNION ALL
       SELECT Row# + (Iteration * 2), Iteration * 2
         FROM RecursiveRowGenerator
        WHERE Iteration * 2 < CEILING(SQRT(DATEDIFF(MONTH, @StartDate, @EndDate)+1))
     )
     , SqrtNRows AS (
       SELECT *
         FROM RecursiveRowGenerator
        UNION ALL
       SELECT 0, 0
     )

SELECT TOP(DATEDIFF(MONTH, @StartDate, @EndDate)+1) 
DATEADD(month, DATEDIFF(month, 0, @StartDate) + A.Row# * POWER(2,CEILING(LOG(SQRT(DATEDIFF(MONTH, @StartDate, @EndDate)+1))/LOG(2))) + B.Row#, 0)  Row# into ##Months
  FROM SqrtNRows A, SqrtNRows B
 ORDER BY A.Row#, B.Row#;

--Populating the months into the temp Membership Table
create table ##Membership_Overview (Month_Year varchar(15), DateSort varchar(15), Joins int default 0, Rejoins int default 0, Suspends int default 0, Suspends_Rejoins int default 0, Suspends_Non_Rejoin int default 0, Member_Count int default 0)

insert into ##Membership_Overview (Month_Year, DateSort)
select DATENAME(month, Row#) + ', ' + cast(year(Row#) as varchar), cast(year(Row#) as varchar) + right('0' + cast(month(Row#) as varchar),2) from ##Months

--Current member base
update m
set m.Member_Count = a.ct
from ##Membership_Overview m
	INNER JOIN (select DATENAME(month, getdate()) + ', ' + cast(year(getdate()) as varchar) Month_Year, count(id) ct
				from name n
				where status = 'A'
					and n.MEMBER_TYPE not in ('NMI','PROS','BLANK','ST')
					and n.COMPANY_RECORD = 0) a on m.Month_Year = a.Month_Year

--Joins
update m
set m.Joins = a.ct
from ##Membership_Overview m
	INNER JOIN(select DATENAME(month, n.JOIN_DATE) + ', ' + cast(year(n.JOIN_DATE) as varchar) Month_Year, count(n.id) ct
				from name n
					inner join Demographics d on n.id = d.ID
				where n.JOIN_DATE >= cast(cast(year(@StartDate)-1 as varchar(4)) + '-12-1' as date)
					and n.COMPANY_RECORD = 0
					and n.MEMBER_TYPE not in ('NMI','PROS','BLANK','ST')
					and n.STATUS = 'A'
				group by DATENAME(month, n.JOIN_DATE) + ', ' + cast(year(n.JOIN_DATE) as varchar), year(n.JOIN_DATE), month(n.JOIN_DATE)) a on m.Month_Year = a.Month_Year

--Rejoins
update m
set m.Rejoins = a.ct
from ##Membership_Overview m
	INNER JOIN(select DATENAME(month, d.REJOIN_DATE) + ', ' + cast(year(d.REJOIN_DATE) as varchar) Month_Year, count(n.id) ct
				from name n
					inner join Demographics d on n.id = d.ID
				where d.REJOIN_DATE >= cast(cast(year(@StartDate)-1 as varchar(4)) + '-12-1' as date)
					and n.COMPANY_RECORD = 0
					and year(isnull(n.JOIN_DATE,'1990-1-1')) <> year(d.REJOIN_DATE)
					and n.MEMBER_TYPE not in ('NMI','PROS','BLANK','ST')
					and n.STATUS = 'A'
				group by DATENAME(month, d.REJOIN_DATE) + ', ' + cast(year(d.REJOIN_DATE) as varchar), year(d.REJOIN_DATE), month(d.REJOIN_DATE)) a on m.Month_Year = a.Month_Year


--Suspends this month
update m
set m.Suspends = a.ct
from ##Membership_Overview m
	INNER JOIN(select  DATENAME(month, d.TERMINATION_DATE) + ', ' + cast(year(d.TERMINATION_DATE) as varchar) Month_Year, count(n.id) ct
				from name n
					inner join Demographics d on n.id = d.ID
				where d.TERMINATION_DATE >= cast(cast(year(@StartDate)-1 as varchar(4)) + '-12-1' as date)
					and n.COMPANY_RECORD = 0
					and n.MEMBER_TYPE not in ('NMI','PROS','BLANK','ST')
				group by DATENAME(month, d.TERMINATION_DATE) + ', ' + cast(year(d.TERMINATION_DATE) as varchar), year(d.TERMINATION_DATE), month(d.TERMINATION_DATE)) a on m.Month_Year = a.Month_Year


--Suspends this month
update m
set m.Suspends_Rejoins = a.ct
from ##Membership_Overview m
	INNER JOIN(select  DATENAME(month, d.TERMINATION_DATE) + ', ' + cast(year(d.TERMINATION_DATE) as varchar) Month_Year, count(n.id) ct
				from name n
					inner join Demographics d on n.id = d.ID
				where d.TERMINATION_DATE >= cast(cast(year(@StartDate)-1 as varchar(4)) + '-12-1' as date)
					and n.COMPANY_RECORD = 0
					and n.MEMBER_TYPE not in ('NMI','PROS','BLANK','ST')
					and n.STATUS = 'A'
				group by DATENAME(month, d.TERMINATION_DATE) + ', ' + cast(year(d.TERMINATION_DATE) as varchar), year(d.TERMINATION_DATE), month(d.TERMINATION_DATE)) a on m.Month_Year = a.Month_Year


--Suspends this month
update m
set m.Suspends_Non_Rejoin = a.ct
from ##Membership_Overview m
	INNER JOIN(select  DATENAME(month, d.TERMINATION_DATE) + ', ' + cast(year(d.TERMINATION_DATE) as varchar) Month_Year, count(n.id) ct
				from name n
					inner join Demographics d on n.id = d.ID
				where d.TERMINATION_DATE >= cast(cast(year(@StartDate)-1 as varchar(4)) + '-12-1' as date)
					and n.COMPANY_RECORD = 0
					and n.MEMBER_TYPE not in ('NMI','PROS','BLANK','ST')
					and n.STATUS <> 'A'
				group by DATENAME(month, d.TERMINATION_DATE) + ', ' + cast(year(d.TERMINATION_DATE) as varchar), year(d.TERMINATION_DATE), month(d.TERMINATION_DATE)) a on m.Month_Year = a.Month_Year


Declare @DateSort int
Declare @Joins int
Declare @Rejoins int
Declare @Suspends int
Declare @Member_Count int
Declare @Tmp_Member_Count int

Declare @Trigger int
Set @Trigger = 0

DECLARE db_cursor cursor fast_forward for
select m1.DateSort, m2.Joins, m2.Rejoins, m2.Suspends, m2.Member_Count
from ##Membership_Overview m1
	left join ##Membership_Overview m2 on (m1.DateSort = m2.DateSort - 1) or (m1.DateSort = m2.DateSort - 89)
where m2.Member_Count is not null
order by DateSort desc

OPEN db_cursor
FETCH NEXT from db_cursor into @DateSort, @Joins, @Rejoins, @Suspends, @Member_Count

while @@FETCH_STATUS = 0
BEGIN

	if @Trigger = 0
		Set @Tmp_Member_Count = @Member_Count

	update ##Membership_Overview
	set Member_Count = @Tmp_Member_Count - @Joins - @Rejoins + @Suspends
	where DateSort = @DateSort

	select @Tmp_Member_Count = Member_Count from ##Membership_Overview where DateSort = @DateSort

	set @Trigger = 1

	FETCH NEXT from db_cursor into @DateSort, @Joins, @Rejoins, @Suspends, @Member_Count

END

	CLOSE db_cursor
	DEALLOCATE db_cursor

select *
from ##Membership_Overview