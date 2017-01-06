select left(n.MEMBER_TYPE,2) MEMBER_TYPE
	, case when left(n.MEMBER_TYPE,2) = 'AC' then 'Academic'
		when left(n.MEMBER_TYPE,2) = 'AM' then 'Associate Official (Real Estate Services)'
		when left(n.MEMBER_TYPE,2) = 'MR' then 'Retired Members'
		when left(n.MEMBER_TYPE,2) = 'PB' then 'Public Entities'
		when left(n.MEMBER_TYPE,2) = 'RM' then 'Regular (Lender/Owner/Developer/Mgt/Retailer)'
		when left(n.MEMBER_TYPE,2) = 'SC' then 'Special'
		when left(n.MEMBER_TYPE,2) = 'SM' then 'Student'
		else 'Unknown'
		end Member_Type_Description
	, p.DESCRIPTION
	, count(n.id) CT
from name n
	inner join Demographics d on n.ID = d.ID
	inner join icsc_PrimaryBusiness p on d.PRIM_BUS_CODE = p.CODE
	inner join Member_Types mt on n.MEMBER_TYPE = mt.MEMBER_TYPE 
where n.status = 'A'
	and n.MEMBER_TYPE not in ('NMI','PROS','BLANK','ST','USM')
	and n.COMPANY_RECORD = 0
group by left(n.MEMBER_TYPE,2), p.DESCRIPTION
order by left(n.MEMBER_TYPE,2), p.DESCRIPTION

Declare @StartDate date
Declare @EndDate date

set @StartDate = '2015-1-1'
set @EndDate = '2015-12-21'

select left(n.MEMBER_TYPE,2) MEMBER_TYPE
	, case when left(n.MEMBER_TYPE,2) = 'AC' then 'Academic'
		when left(n.MEMBER_TYPE,2) = 'AM' then 'Associate Official (Real Estate Services)'
		when left(n.MEMBER_TYPE,2) = 'MR' then 'Retired Members'
		when left(n.MEMBER_TYPE,2) = 'PB' then 'Public Entities'
		when left(n.MEMBER_TYPE,2) = 'RM' then 'Regular (Lender/Owner/Developer/Mgt/Retailer)'
		when left(n.MEMBER_TYPE,2) = 'SC' then 'Special'
		when left(n.MEMBER_TYPE,2) = 'SM' then 'Student'
		else 'Unknown'
		end Member_Type_Description
	, p.DESCRIPTION
	, cast(year(n.JOIN_DATE) as varchar(4)) + right('00'+cast(month(n.JOIN_DATE) as varchar(2)),2) YYYYMM
	, count(n.id) CT
from name n
	inner join Demographics d on n.ID = d.ID
	inner join icsc_PrimaryBusiness p on d.PRIM_BUS_CODE = p.CODE
	inner join Member_Types mt on n.MEMBER_TYPE = mt.MEMBER_TYPE 
where n.status = 'A'
	and n.MEMBER_TYPE not in ('NMI','PROS','BLANK','ST','USM')
	and n.COMPANY_RECORD = 0
	and n.JOIN_DATE >= @StartDate
	and n.JOIN_DATE <= @EndDate
group by left(n.MEMBER_TYPE,2), p.DESCRIPTION, cast(year(n.JOIN_DATE) as varchar(4)) + right('00'+cast(month(n.JOIN_DATE) as varchar(2)),2)
order by cast(year(n.JOIN_DATE) as varchar(4)) + right('00'+cast(month(n.JOIN_DATE) as varchar(2)),2), left(n.MEMBER_TYPE,2), p.DESCRIPTION