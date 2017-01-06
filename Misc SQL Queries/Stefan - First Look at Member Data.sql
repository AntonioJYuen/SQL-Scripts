	--or n.id in (select distinct st_Id from trans where transaction_date >= @StartDate and TRANSACTION_DATE <= @EndDate)
	--or n.id in (select distinct id from Activity a where a.TRANSACTION_DATE >= @StartDate and a.TRANSACTION_DATE <= @EndDate)
	--or n.id in (select distinct st_id from orders o inner join order_meet om on o.ORDER_NUMBER = om.ORDER_NUMBER inner join Meet_Master mm on om.MEETING = mm.MEETING where BEGIN_DATE >= @StartDate and BEGIN_DATE <= @EndDate and TOTAL_PAYMENTS > 0)
drop table ##TempIDs

Declare @StartDate as date
Declare @EndDate as date

set @StartDate = '2016-01-01'
set @EndDate = '2016-06-30'

create table ##TempIDs (ST_ID varchar(12))

insert into ##TempIDs
select distinct st_Id 
from trans 
where transaction_date >= @StartDate and TRANSACTION_DATE <= @EndDate

insert into ##TempIDs
select distinct id from Activity a 
where a.TRANSACTION_DATE >= @StartDate 
	and a.TRANSACTION_DATE <= @EndDate
	and id not in (select ST_ID from ##TempIDs)
	
insert into ##TempIDs
select distinct st_id 
from orders o 
	inner join order_meet om on o.ORDER_NUMBER = om.ORDER_NUMBER 
	inner join Meet_Master mm on om.MEETING = mm.MEETING 
where BEGIN_DATE >= @StartDate 
	and BEGIN_DATE <= @EndDate 
	and TOTAL_PAYMENTS > 0
	and st_id not in (select ST_ID from ##TempIDs)

--select *
--from ##TempIDs
--2016FDLV?
select n.id, n.co_id, case when n.COMPANY_RECORD = 1 then 'Yes' else 'No' end Is_Company, dbo.removebreaks(n.COMPANY) COMPANY
	, n.MEMBER_TYPE, n.STATUS, p.DESCRIPTION Prim_Bus_Codes
	, na.CITY, na.STATE_PROVINCE, na.COUNTRY, cr.Region_Name, cu.ICSC_USA_REGION,n.join_date, n.paid_thru
	, n.GENDER, n.BIRTH_DATE
	, d.RENEWED_DATE, d.REJOIN_DATE, d.TERMINATION_DATE
	, m.Meet_Ct
	, (select sum(amount * -1) Payment_Amt from trans t where TRANSACTION_DATE >= @StartDate and TRANSACTION_DATE <= @EndDate and n.id = st_id and transaction_type ='DIST' and SOURCE_SYSTEM = 'DUES') CY_YTD_DUE_Pmnt
	, (select sum(amount * -1) Payment_Amt
		from trans t 
			inner join product p on t.product_code = p.product_code
			inner join Meet_Master mm on p.product_major = mm.MEETING
		where mm.BEGIN_DATE >= @StartDate
			and mm.BEGIN_DATE <= @EndDate
			and t.transaction_type ='DIST' 
			and t.SOURCE_SYSTEM = 'MEETING'
			and n.id = t.st_id) CY_YTD_MEET_Pmnt
	, (select sum(amount * -1) Payment_Amt
		from trans t 
			inner join product p on t.product_code = p.product_code
			inner join Meet_Master mm on p.product_major = mm.MEETING
		where mm.BEGIN_DATE >= @StartDate
			and mm.BEGIN_DATE <= @EndDate
			and t.transaction_type ='DIST' 
			and t.SOURCE_SYSTEM = 'EXPO'
			and n.id = t.st_id) CY_YTD_EXPO_Pmnt
	, (select sum(amount * -1) Payment_Amt
		from trans t 
			inner join product p on t.product_code = p.product_code
			inner join Meet_Master mm on p.product_major = mm.MEETING
		where mm.BEGIN_DATE >= @StartDate
			and mm.BEGIN_DATE <= @EndDate
			and t.transaction_type ='DIST' 
			and t.SOURCE_SYSTEM = 'SC'
			and n.id = t.st_id) CY_YTD_SPON_Pmnt
	, (select sum(amount * -1) Payment_Amt from trans t where TRANSACTION_DATE >= @StartDate and TRANSACTION_DATE <= @EndDate and n.id = st_id and transaction_type ='DIST' and SOURCE_SYSTEM = 'FR') CY_YTD_FUND_Pmnt
	, (select sum(amount * -1) Payment_Amt from trans t where TRANSACTION_DATE >= @StartDate and TRANSACTION_DATE <= @EndDate and n.id = st_id and transaction_type ='DIST' and SOURCE_SYSTEM = 'AR') CY_YTD_MISC_Pmnt
	, (select sum(amount * -1) Payment_Amt from trans t where year(TRANSACTION_DATE) = year(@StartDate) and n.id = st_id and transaction_type ='DIST' and SOURCE_SYSTEM = 'DUES') CY_Full_Year_DUE_Pmnt
	, (select sum(amount * -1) Payment_Amt
		from trans t 
			inner join product p on t.product_code = p.product_code
			inner join Meet_Master mm on p.product_major = mm.MEETING
		where year(mm.BEGIN_DATE) = year(@StartDate)
			and t.transaction_type ='DIST' 
			and t.SOURCE_SYSTEM = 'MEETING'
			and n.id = t.st_id) CY_Full_Year_MEET_Pmnt
	, (select sum(amount * -1) Payment_Amt
		from trans t 
			inner join product p on t.product_code = p.product_code
			inner join Meet_Master mm on p.product_major = mm.MEETING
		where year(mm.BEGIN_DATE) = year(@StartDate)
			and t.transaction_type ='DIST' 
			and t.SOURCE_SYSTEM = 'EXPO'
			and n.id = t.st_id) CY_Full_Year_EXPO_Pmnt
	, (select sum(amount * -1) Payment_Amt
		from trans t 
			inner join product p on t.product_code = p.product_code
			inner join Meet_Master mm on p.product_major = mm.MEETING
		where year(mm.BEGIN_DATE) = year(@StartDate)
			and t.transaction_type ='DIST' 
			and t.SOURCE_SYSTEM = 'SC'
			and n.id = t.st_id) CY_Full_Year_SPON_Pmnt
	, (select sum(amount * -1) Payment_Amt from trans t where year(TRANSACTION_DATE) = year(@StartDate) and n.id = st_id and transaction_type ='DIST' and SOURCE_SYSTEM = 'FR') CY_Full_Year_FUND_Pmnt
	, (select sum(amount * -1) Payment_Amt from trans t where year(TRANSACTION_DATE) = year(@StartDate) and n.id = st_id and transaction_type ='DIST' and SOURCE_SYSTEM = 'AR') CY_Full_Year_MISC_Pmnt

	
	, (select sum(amount * -1) Payment_Amt from trans t where TRANSACTION_DATE >= dateadd(y,-1,@StartDate) and TRANSACTION_DATE <= dateadd(y,-1,@EndDate) and n.id = st_id and transaction_type ='DIST' and SOURCE_SYSTEM = 'DUES') LY_YTD_DUE_Pmnt
	, (select sum(amount * -1) Payment_Amt
		from trans t 
			inner join product p on t.product_code = p.product_code
			inner join Meet_Master mm on p.product_major = mm.MEETING
		where mm.BEGIN_DATE >= dateadd(y,-1,@StartDate)
			and mm.BEGIN_DATE <= dateadd(y,-1,@EndDate)
			and t.transaction_type ='DIST' 
			and t.SOURCE_SYSTEM = 'MEETING'
			and n.id = t.st_id) LY_YTD_MEET_Pmnt
	, (select sum(amount * -1) Payment_Amt
		from trans t 
			inner join product p on t.product_code = p.product_code
			inner join Meet_Master mm on p.product_major = mm.MEETING
		where mm.BEGIN_DATE >= dateadd(y,-1,@StartDate)
			and mm.BEGIN_DATE <= dateadd(y,-1,@EndDate)
			and t.transaction_type ='DIST' 
			and t.SOURCE_SYSTEM = 'EXPO'
			and n.id = t.st_id) LY_YTD_EXPO_Pmnt
	, (select sum(amount * -1) Payment_Amt
		from trans t 
			inner join product p on t.product_code = p.product_code
			inner join Meet_Master mm on p.product_major = mm.MEETING
		where mm.BEGIN_DATE >= dateadd(y,-1,@StartDate)
			and mm.BEGIN_DATE <= dateadd(y,-1,@EndDate)
			and t.transaction_type ='DIST' 
			and t.SOURCE_SYSTEM = 'SC'
			and n.id = t.st_id) LY_YTD_SPON_Pmnt
	, (select sum(amount * -1) Payment_Amt from trans t where TRANSACTION_DATE >= dateadd(y,-1,@StartDate) and TRANSACTION_DATE <= dateadd(y,-1,@EndDate) and n.id = st_id and transaction_type ='DIST' and SOURCE_SYSTEM = 'FR') LY_YTD_FUND_Pmnt
	, (select sum(amount * -1) Payment_Amt from trans t where TRANSACTION_DATE >= dateadd(y,-1,@StartDate) and TRANSACTION_DATE <= dateadd(y,-1,@EndDate) and n.id = st_id and transaction_type ='DIST' and SOURCE_SYSTEM = 'AR') LY_YTD_MISC_Pmnt
	, (select sum(amount * -1) Payment_Amt from trans t where year(TRANSACTION_DATE) = year(dateadd(y,-1,@StartDate)) and n.id = st_id and transaction_type ='DIST' and SOURCE_SYSTEM = 'DUES') LY_Full_Year_DUE_Pmnt
	, (select sum(amount * -1) Payment_Amt
		from trans t 
			inner join product p on t.product_code = p.product_code
			inner join Meet_Master mm on p.product_major = mm.MEETING
		where year(mm.BEGIN_DATE) = year(dateadd(y,-1,@StartDate))
			and t.transaction_type ='DIST' 
			and t.SOURCE_SYSTEM = 'MEETING'
			and n.id = t.st_id) LY_Full_Year_MEET_Pmnt
	, (select sum(amount * -1) Payment_Amt
		from trans t 
			inner join product p on t.product_code = p.product_code
			inner join Meet_Master mm on p.product_major = mm.MEETING
		where year(mm.BEGIN_DATE) = year(dateadd(y,-1,@StartDate))
			and t.transaction_type ='DIST' 
			and t.SOURCE_SYSTEM = 'EXPO'
			and n.id = t.st_id) LY_Full_Year_EXPO_Pmnt
	, (select sum(amount * -1) Payment_Amt
		from trans t 
			inner join product p on t.product_code = p.product_code
			inner join Meet_Master mm on p.product_major = mm.MEETING
		where year(mm.BEGIN_DATE) = year(dateadd(y,-1,@StartDate))
			and t.transaction_type ='DIST' 
			and t.SOURCE_SYSTEM = 'SC'
			and n.id = t.st_id) LY_Full_Year_SPON_Pmnt
	, (select sum(amount * -1) Payment_Amt from trans t where year(TRANSACTION_DATE) = year(dateadd(y,-1,@StartDate)) and n.id = st_id and transaction_type ='DIST' and SOURCE_SYSTEM = 'FR') LY_Full_Year_FUND_Pmnt
	, (select sum(amount * -1) Payment_Amt from trans t where year(TRANSACTION_DATE) = year(dateadd(y,-1,@StartDate)) and n.id = st_id and transaction_type ='DIST' and SOURCE_SYSTEM = 'AR') LY_Full_Year_MISC_Pmnt
	,case 
		when n.MEMBER_TYPE like 'PB%' then 'Public Entities (Official and Affiliate)'
		when n.MEMBER_TYPE like 'AC%' then 'Academic (Official and Affiliate)'
		when n.MEMBER_TYPE like 'SM' then 'Students'
		when n.MEMBER_TYPE like 'RMO' then 'Regular Official Members (Lender, Owner/Developer/Mgt/Retailer)'
		when n.MEMBER_TYPE like 'AMO' then 'Associate Official Members (Real Estate Services)'
		when n.MEMBER_TYPE like 'RMU' then 'Regular Unsponsored Members'
		when n.MEMBER_TYPE like 'AMU' then 'Associate Unsponsored Members'
		when n.MEMBER_TYPE like 'RMA' then 'Regular Affiliate Members'
		when n.MEMBER_TYPE like 'AMA' then 'Associate Affiliate Members'
		else 'Other Members' end Member_Types_2
	, case when d.PRIM_BUS_CODE = 'LEN' then 'Lender'
		when d.PRIM_BUS_CODE in ('OWN','SCM') then 'Owner/Developer/Manager'
		when d.PRIM_BUS_CODE = 'PBS' then 'Public'
		when d.PRIM_BUS_CODE = 'ACA' then 'Academic'
		when d.PRIM_BUS_CODE = 'RET' then 'Retailer'
		when d.PRIM_BUS_CODE = 'STU' then 'Student'
		else 'Real Estate Services' end Prim_Bus_Codes_2
from name n
	inner join Demographics d on n.ID = d.ID
	inner join name_address na on n.id = na.id and na.preferred_mail = 1
	left join icsc_PrimaryBusiness p on d.PRIM_BUS_CODE = p.CODE
	left join Member_Types mt on n.MEMBER_TYPE = mt.MEMBER_TYPE 
	left join Csys_ICSC_Regions_Mem cr on na.COUNTRY = cr.Country
	left join csys_ICSC_USA_regions cu on na.STATE_PROVINCE = cu.STATE_CODE
	left join (select st_id, count(st_id) Meet_Ct from orders o inner join order_meet om on o.ORDER_NUMBER = om.ORDER_NUMBER inner join Meet_Master mm on om.MEETING = mm.MEETING where BEGIN_DATE >= @StartDate and BEGIN_DATE <= '2016-6-30' and o.STATUS not like 'C%' group by o.ST_ID) m on n.ID = m.ST_ID
	--left join (select st_id, source_system, sum(amount) Payment_Amt from trans t where TRANSACTION_DATE >= @StartDate and TRANSACTION_DATE <= @EndDate group by st_id, SOURCE_SYSTEM) t on n.ID = t.ST_ID
--where n.id = '1664634'
where (n.status = 'A'
	and n.MEMBER_TYPE not in ('NMI', 'NM','PROS','PROC','BLANK','ST')
	and cast(n.join_date as date) <= '2016-6-30')
	or n.id in (select st_id from ##TempIDs)
	or year(d.TERMINATION_DATE) = 2016
	or year(d.REJOIN_DATE) = 2016
	or year(n.JOIN_DATE) = 2016
	or year(d.RENEWED_DATE) = 2016