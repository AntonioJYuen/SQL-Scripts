IF OBJECT_ID('tempdb..##Membership_Overview') IS NOT NULL
	drop table ##Membership_Overview

IF OBJECT_ID('tempdb..##Months') IS NOT NULL
	drop table ##Months

IF OBJECT_ID('tempdb..##Temp_Current_Counts') IS NOT NULL
	drop table ##Temp_Current_Counts

IF OBJECT_ID('tempdb..##Temp_Joins') IS NOT NULL
	drop table ##Temp_Joins

IF OBJECT_ID('tempdb..##Temp_Rejoins') IS NOT NULL
	drop table ##Temp_Rejoins

IF OBJECT_ID('tempdb..##Temp_Suspends') IS NOT NULL
	drop table ##Temp_Suspends

--All months since the beginning of the year

--Inputs here:
DECLARE @StartDate datetime;
DECLARE @EndDate datetime;
SET @StartDate = dateadd(d,-1,cast(cast(year(GETDATE()) as varchar(4)) + '-1-1' as date))
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
create table ##Membership_Overview (Month_Year varchar(15), DateSort varchar(15)
	, LEN_Joins int default 0, LEN_Rejoins int default 0, LEN_Suspends int default 0, LEN_Member_Count int default 0
	, OWN_Joins int default 0, OWN_Rejoins int default 0, OWN_Suspends int default 0, OWN_Member_Count int default 0
	, PUB_Joins int default 0, PUB_Rejoins int default 0, PUB_Suspends int default 0, PUB_Member_Count int default 0
	, ACA_Joins int default 0, ACA_Rejoins int default 0, ACA_Suspends int default 0, ACA_Member_Count int default 0
	, RET_Joins int default 0, RET_Rejoins int default 0, RET_Suspends int default 0, RET_Member_Count int default 0
	, STU_Joins int default 0, STU_Rejoins int default 0, STU_Suspends int default 0, STU_Member_Count int default 0
	, RES_Joins int default 0, RES_Rejoins int default 0, RES_Suspends int default 0, RES_Member_Count int default 0
	, Total_Members int default 0)

insert into ##Membership_Overview (Month_Year, DateSort)
select DATENAME(month, Row#) + ', ' + cast(year(Row#) as varchar), cast(year(Row#) as varchar) + right('0' + cast(month(Row#) as varchar),2) from ##Months

--Current member base
select DATENAME(month, getdate()) + ', ' + cast(year(getdate()) as varchar) Month_Year
					, case when d.PRIM_BUS_CODE = 'LEN' then 'Lender'
						when d.PRIM_BUS_CODE in ('OWN','SCM') then 'Owner/Developer/Manager'
						when d.PRIM_BUS_CODE = 'PBS' then 'Public'
						when d.PRIM_BUS_CODE = 'ACA' then 'Academic'
						when d.PRIM_BUS_CODE = 'RET' then 'Retailer'
						when d.PRIM_BUS_CODE = 'STU' then 'Student'
						else 'Real Estate Services' end Prim_Business
					, count(n.id) ct into ##Temp_Current_Counts
				from name n
					inner join Demographics d on n.ID = d.ID
				where status = 'A'
					and n.MEMBER_TYPE not in ('NMI','PROS','BLANK','ST')
					and n.COMPANY_RECORD = 0
				group by case when d.PRIM_BUS_CODE = 'LEN' then 'Lender'
						when d.PRIM_BUS_CODE in ('OWN','SCM') then 'Owner/Developer/Manager'
						when d.PRIM_BUS_CODE = 'PBS' then 'Public'
						when d.PRIM_BUS_CODE = 'ACA' then 'Academic'
						when d.PRIM_BUS_CODE = 'RET' then 'Retailer'
						when d.PRIM_BUS_CODE = 'STU' then 'Student'
						else 'Real Estate Services' end

update m
set	m.LEN_Member_Count = isnull((select ct from ##Temp_Current_Counts o where m.Month_Year = o.Month_Year and o.Prim_Business = 'Lender'),0)
	, m.OWN_Member_Count = isnull((select ct from ##Temp_Current_Counts o where m.Month_Year = o.Month_Year and o.Prim_Business = 'Owner/Developer/Manager'),0)
	, m.PUB_Member_Count = isnull((select ct from ##Temp_Current_Counts o where m.Month_Year = o.Month_Year and o.Prim_Business = 'Public'),0)
	, m.ACA_Member_Count = isnull((select ct from ##Temp_Current_Counts o where m.Month_Year = o.Month_Year and o.Prim_Business = 'Academic'),0)
	, m.RET_Member_Count = isnull((select ct from ##Temp_Current_Counts o where m.Month_Year = o.Month_Year and o.Prim_Business = 'Retailer'),0)
	, m.STU_Member_Count = isnull((select ct from ##Temp_Current_Counts o where m.Month_Year = o.Month_Year and o.Prim_Business = 'Student'),0)
	, m.RES_Member_Count = isnull((select ct from ##Temp_Current_Counts o where m.Month_Year = o.Month_Year and o.Prim_Business = 'Real Estate Services'),0)
	, m.Total_Members = isnull((select sum(ct) from ##Temp_Current_Counts o where m.Month_Year = o.Month_Year),0)
from ##Membership_Overview m
where m.Month_Year in (select Month_Year from ##Temp_Current_Counts)

--Joins
select DATENAME(month, n.JOIN_DATE) + ', ' + cast(year(n.JOIN_DATE) as varchar) Month_Year
	, case when d.PRIM_BUS_CODE = 'LEN' then 'Lender'
		when d.PRIM_BUS_CODE in ('OWN','SCM') then 'Owner/Developer/Manager'
		when d.PRIM_BUS_CODE = 'PBS' then 'Public'
		when d.PRIM_BUS_CODE = 'ACA' then 'Academic'
		when d.PRIM_BUS_CODE = 'RET' then 'Retailer'
		when d.PRIM_BUS_CODE = 'STU' then 'Student'
		else 'Real Estate Services' end Prim_Business
	, count(n.id) ct into ##Temp_Joins
from name n
	inner join Demographics d on n.id = d.ID
where n.JOIN_DATE >= cast(cast(year(getdate())-1 as varchar(4)) + '-12-1' as date)
	and n.COMPANY_RECORD = 0
	and n.MEMBER_TYPE not in ('NMI','PROS','BLANK','ST')
group by DATENAME(month, n.JOIN_DATE) + ', ' + cast(year(n.JOIN_DATE) as varchar), year(n.JOIN_DATE), month(n.JOIN_DATE)
	, case when d.PRIM_BUS_CODE = 'LEN' then 'Lender'
		when d.PRIM_BUS_CODE in ('OWN','SCM') then 'Owner/Developer/Manager'
		when d.PRIM_BUS_CODE = 'PBS' then 'Public'
		when d.PRIM_BUS_CODE = 'ACA' then 'Academic'
		when d.PRIM_BUS_CODE = 'RET' then 'Retailer'
		when d.PRIM_BUS_CODE = 'STU' then 'Student'
		else 'Real Estate Services' end

update m
set	m.LEN_Joins = isnull((select ct from ##Temp_Joins o where m.Month_Year = o.Month_Year and o.Prim_Business = 'Lender'),0)
	, m.OWN_Joins = isnull((select ct from ##Temp_Joins o where m.Month_Year = o.Month_Year and o.Prim_Business = 'Owner/Developer/Manager'),0)
	, m.PUB_Joins = isnull((select ct from ##Temp_Joins o where m.Month_Year = o.Month_Year and o.Prim_Business = 'Public'),0)
	, m.ACA_Joins = isnull((select ct from ##Temp_Joins o where m.Month_Year = o.Month_Year and o.Prim_Business = 'Academic'),0)
	, m.RET_Joins = isnull((select ct from ##Temp_Joins o where m.Month_Year = o.Month_Year and o.Prim_Business = 'Retailer'),0)
	, m.STU_Joins = isnull((select ct from ##Temp_Joins o where m.Month_Year = o.Month_Year and o.Prim_Business = 'Student'),0)
	, m.RES_Joins = isnull((select ct from ##Temp_Joins o where m.Month_Year = o.Month_Year and o.Prim_Business = 'Real Estate Services'),0)
from ##Membership_Overview m
where m.Month_Year in (select Month_Year from ##Temp_Joins)

--Rejoins
select DATENAME(month, d.REJOIN_DATE) + ', ' + cast(year(d.REJOIN_DATE) as varchar) Month_Year
	, case when d.PRIM_BUS_CODE = 'LEN' then 'Lender'
		when d.PRIM_BUS_CODE in ('OWN','SCM') then 'Owner/Developer/Manager'
		when d.PRIM_BUS_CODE = 'PBS' then 'Public'
		when d.PRIM_BUS_CODE = 'ACA' then 'Academic'
		when d.PRIM_BUS_CODE = 'RET' then 'Retailer'
		when d.PRIM_BUS_CODE = 'STU' then 'Student'
		else 'Real Estate Services' end Prim_Business
	, count(n.id) ct into ##Temp_Rejoins
from name n
	inner join Demographics d on n.id = d.ID
where d.REJOIN_DATE >= cast(cast(year(getdate())-1 as varchar(4)) + '-12-1' as date)
	and n.COMPANY_RECORD = 0
	and year(isnull(n.JOIN_DATE,'1990-1-1')) <> year(d.REJOIN_DATE)
	and n.MEMBER_TYPE not in ('NMI','PROS','BLANK','ST')
group by DATENAME(month, d.REJOIN_DATE) + ', ' + cast(year(d.REJOIN_DATE) as varchar), year(d.REJOIN_DATE), month(d.REJOIN_DATE)
	, case when d.PRIM_BUS_CODE = 'LEN' then 'Lender'
		when d.PRIM_BUS_CODE in ('OWN','SCM') then 'Owner/Developer/Manager'
		when d.PRIM_BUS_CODE = 'PBS' then 'Public'
		when d.PRIM_BUS_CODE = 'ACA' then 'Academic'
		when d.PRIM_BUS_CODE = 'RET' then 'Retailer'
		when d.PRIM_BUS_CODE = 'STU' then 'Student'
		else 'Real Estate Services' end
		
update m
set	m.LEN_Rejoins = isnull((select ct from ##Temp_Rejoins o where m.Month_Year = o.Month_Year and o.Prim_Business = 'Lender'),0)
	, m.OWN_Rejoins = isnull((select ct from ##Temp_Rejoins o where m.Month_Year = o.Month_Year and o.Prim_Business = 'Owner/Developer/Manager'),0)
	, m.PUB_Rejoins = isnull((select ct from ##Temp_Rejoins o where m.Month_Year = o.Month_Year and o.Prim_Business = 'Public'),0)
	, m.ACA_Rejoins = isnull((select ct from ##Temp_Rejoins o where m.Month_Year = o.Month_Year and o.Prim_Business = 'Academic'),0)
	, m.RET_Rejoins = isnull((select ct from ##Temp_Rejoins o where m.Month_Year = o.Month_Year and o.Prim_Business = 'Retailer'),0)
	, m.STU_Rejoins = isnull((select ct from ##Temp_Rejoins o where m.Month_Year = o.Month_Year and o.Prim_Business = 'Student'),0)
	, m.RES_Rejoins = isnull((select ct from ##Temp_Rejoins o where m.Month_Year = o.Month_Year and o.Prim_Business = 'Real Estate Services'),0)
from ##Membership_Overview m
where m.Month_Year in (select Month_Year from ##Temp_Rejoins)

--Suspends
select  DATENAME(month, d.TERMINATION_DATE) + ', ' + cast(year(d.TERMINATION_DATE) as varchar) Month_Year
	, case when d.PRIM_BUS_CODE = 'LEN' then 'Lender'
		when d.PRIM_BUS_CODE in ('OWN','SCM') then 'Owner/Developer/Manager'
		when d.PRIM_BUS_CODE = 'PBS' then 'Public'
		when d.PRIM_BUS_CODE = 'ACA' then 'Academic'
		when d.PRIM_BUS_CODE = 'RET' then 'Retailer'
		when d.PRIM_BUS_CODE = 'STU' then 'Student'
		else 'Real Estate Services' end Prim_Business
	, count(n.id) ct into ##Temp_Suspends
from name n
	inner join Demographics d on n.id = d.ID
where d.TERMINATION_DATE >= cast(cast(year(getdate())-1 as varchar(4)) + '-12-1' as date)
	and n.COMPANY_RECORD = 0
	and n.MEMBER_TYPE not in ('NMI','PROS','BLANK','ST')
group by DATENAME(month, d.TERMINATION_DATE) + ', ' + cast(year(d.TERMINATION_DATE) as varchar), year(d.TERMINATION_DATE), month(d.TERMINATION_DATE)
	, case when d.PRIM_BUS_CODE = 'LEN' then 'Lender'
		when d.PRIM_BUS_CODE in ('OWN','SCM') then 'Owner/Developer/Manager'
		when d.PRIM_BUS_CODE = 'PBS' then 'Public'
		when d.PRIM_BUS_CODE = 'ACA' then 'Academic'
		when d.PRIM_BUS_CODE = 'RET' then 'Retailer'
		when d.PRIM_BUS_CODE = 'STU' then 'Student'
		else 'Real Estate Services' end
		
update m
set	m.LEN_Suspends = isnull((select ct from ##Temp_Suspends o where m.Month_Year = o.Month_Year and o.Prim_Business = 'Lender'),0)
	, m.OWN_Suspends = isnull((select ct from ##Temp_Suspends o where m.Month_Year = o.Month_Year and o.Prim_Business = 'Owner/Developer/Manager'),0)
	, m.PUB_Suspends = isnull((select ct from ##Temp_Suspends o where m.Month_Year = o.Month_Year and o.Prim_Business = 'Public'),0)
	, m.ACA_Suspends = isnull((select ct from ##Temp_Suspends o where m.Month_Year = o.Month_Year and o.Prim_Business = 'Academic'),0)
	, m.RET_Suspends = isnull((select ct from ##Temp_Suspends o where m.Month_Year = o.Month_Year and o.Prim_Business = 'Retailer'),0)
	, m.STU_Suspends = isnull((select ct from ##Temp_Suspends o where m.Month_Year = o.Month_Year and o.Prim_Business = 'Student'),0)
	, m.RES_Suspends = isnull((select ct from ##Temp_Suspends o where m.Month_Year = o.Month_Year and o.Prim_Business = 'Real Estate Services'),0)
from ##Membership_Overview m
where m.Month_Year in (select Month_Year from ##Temp_Suspends)

Declare @DateSort int

Declare @LEN_Joins int
Declare @LEN_Rejoins int
Declare @LEN_Suspends int
Declare @LEN_Member_Count int
Declare @Tmp_LEN_Member_Count int

Declare @OWN_Joins int
Declare @OWN_Rejoins int
Declare @OWN_Suspends int
Declare @OWN_Member_Count int
Declare @Tmp_OWN_Member_Count int

Declare @PUB_Joins int
Declare @PUB_Rejoins int
Declare @PUB_Suspends int
Declare @PUB_Member_Count int
Declare @Tmp_PUB_Member_Count int

Declare @ACA_Joins int
Declare @ACA_Rejoins int
Declare @ACA_Suspends int
Declare @ACA_Member_Count int
Declare @Tmp_ACA_Member_Count int

Declare @RET_Joins int
Declare @RET_Rejoins int
Declare @RET_Suspends int
Declare @RET_Member_Count int
Declare @Tmp_RET_Member_Count int

Declare @STU_Joins int
Declare @STU_Rejoins int
Declare @STU_Suspends int
Declare @STU_Member_Count int
Declare @Tmp_STU_Member_Count int

Declare @RES_Joins int
Declare @RES_Rejoins int
Declare @RES_Suspends int
Declare @RES_Member_Count int
Declare @Tmp_RES_Member_Count int

Declare @Trigger int
Set @Trigger = 0

DECLARE db_cursor cursor fast_forward for
select m1.DateSort
	, m2.LEN_Joins, m2.LEN_Rejoins, m2.LEN_Suspends, m2.LEN_Member_Count
	, m2.OWN_Joins, m2.OWN_Rejoins, m2.OWN_Suspends, m2.OWN_Member_Count
	, m2.PUB_Joins, m2.PUB_Rejoins, m2.PUB_Suspends, m2.PUB_Member_Count
	, m2.ACA_Joins, m2.ACA_Rejoins, m2.ACA_Suspends, m2.ACA_Member_Count
	, m2.RET_Joins, m2.RET_Rejoins, m2.RET_Suspends, m2.RET_Member_Count
	, m2.STU_Joins, m2.STU_Rejoins, m2.STU_Suspends, m2.STU_Member_Count
	, m2.RES_Joins, m2.RES_Rejoins, m2.RES_Suspends, m2.RES_Member_Count
from ##Membership_Overview m1
	left join ##Membership_Overview m2 on (m1.DateSort = m2.DateSort - 1) or (m1.DateSort = m2.DateSort - 89)
where m2.LEN_Joins is not null
order by DateSort desc

OPEN db_cursor
FETCH NEXT from db_cursor into @DateSort
	, @LEN_Joins, @LEN_Rejoins, @LEN_Suspends, @LEN_Member_Count
	, @OWN_Joins, @OWN_Rejoins, @OWN_Suspends, @OWN_Member_Count
	, @PUB_Joins, @PUB_Rejoins, @PUB_Suspends, @PUB_Member_Count
	, @ACA_Joins, @ACA_Rejoins, @ACA_Suspends, @ACA_Member_Count
	, @RET_Joins, @RET_Rejoins, @RET_Suspends, @RET_Member_Count
	, @STU_Joins, @STU_Rejoins, @STU_Suspends, @STU_Member_Count
	, @RES_Joins, @RES_Rejoins, @RES_Suspends, @RES_Member_Count

while @@FETCH_STATUS = 0
BEGIN

	if @Trigger = 0
	BEGIN
		Set @Tmp_LEN_Member_Count = @LEN_Member_Count
		Set @Tmp_OWN_Member_Count = @OWN_Member_Count
		Set @Tmp_PUB_Member_Count = @PUB_Member_Count
		Set @Tmp_ACA_Member_Count = @ACA_Member_Count
		Set @Tmp_RET_Member_Count = @RET_Member_Count
		Set @Tmp_STU_Member_Count = @STU_Member_Count
		Set @Tmp_RES_Member_Count = @RES_Member_Count
	END
	

	update ##Membership_Overview
	set LEN_Member_Count = @Tmp_LEN_Member_Count - @Len_Joins - @LEN_Rejoins + @LEN_Suspends
		, OWN_Member_Count = @Tmp_OWN_Member_Count - @OWN_Joins - @OWN_Rejoins + @OWN_Suspends
		, PUB_Member_Count = @Tmp_PUB_Member_Count - @PUB_Joins - @PUB_Rejoins + @PUB_Suspends
		, ACA_Member_Count = @Tmp_ACA_Member_Count - @ACA_Joins - @ACA_Rejoins + @ACA_Suspends
		, RET_Member_Count = @Tmp_RET_Member_Count - @RET_Joins - @RET_Rejoins + @RET_Suspends
		, STU_Member_Count = @Tmp_STU_Member_Count - @STU_Joins - @STU_Rejoins + @STU_Suspends
		, RES_Member_Count = @Tmp_RES_Member_Count - @RES_Joins - @RES_Rejoins + @RES_Suspends
	where DateSort = @DateSort

	select @Tmp_Len_Member_Count = Len_Member_Count 
		, @Tmp_OWN_Member_Count = OWN_Member_Count 
		, @Tmp_PUB_Member_Count = PUB_Member_Count 
		, @Tmp_ACA_Member_Count = ACA_Member_Count 
		, @Tmp_RET_Member_Count = RET_Member_Count 
		, @Tmp_STU_Member_Count = STU_Member_Count 
		, @Tmp_RES_Member_Count = RES_Member_Count 
	from ##Membership_Overview 
	where DateSort = @DateSort

	update ##Membership_Overview
	set Total_Members = LEN_Member_Count + OWN_Member_Count + PUB_Member_Count + ACA_Member_Count + RET_Member_Count + STU_Member_Count + RES_Member_Count


	set @Trigger = 1

	FETCH NEXT from db_cursor into @DateSort
	, @LEN_Joins, @LEN_Rejoins, @LEN_Suspends, @LEN_Member_Count
	, @OWN_Joins, @OWN_Rejoins, @OWN_Suspends, @OWN_Member_Count
	, @PUB_Joins, @PUB_Rejoins, @PUB_Suspends, @PUB_Member_Count
	, @ACA_Joins, @ACA_Rejoins, @ACA_Suspends, @ACA_Member_Count
	, @RET_Joins, @RET_Rejoins, @RET_Suspends, @RET_Member_Count
	, @STU_Joins, @STU_Rejoins, @STU_Suspends, @STU_Member_Count
	, @RES_Joins, @RES_Rejoins, @RES_Suspends, @RES_Member_Count

END

	CLOSE db_cursor
	DEALLOCATE db_cursor

select *
from ##Membership_Overview