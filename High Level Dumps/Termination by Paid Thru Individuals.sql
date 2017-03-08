alter view vw_ICSC_PAID_THRU_TERMINATIONS
as 

with CTEList as (
select distinct a.id
from name n 
	inner join (
				select id, first_name + LAST_NAME + STATE_PROVINCE + replace(CITY,' ','') COMPARE, JOIN_DATE
				from name n
				where dateadd(m,2,n.paid_thru) between '2015-1-1' and '2016-12-31'
					and n.status = 'S'
					and n.COMPANY_RECORD = 0
					and n.MEMBER_TYPE not in ('NMI','ST','BLANK','PROS')
					and n.country in ('United States','')
				) a on n.ID <> a.ID and first_name + LAST_NAME + STATE_PROVINCE + replace(CITY,' ','') = a.COMPARE and a.JOIN_DATE < n.JOIN_DATE
where FIRST_NAME <> ''
	and LAST_NAME <> ''
	and STATE_PROVINCE <> ''
	and CITY <> ''
)

select cast(year(n.paid_thru) as varchar) + right('00' + cast(month(n.paid_thru) as varchar),2) PAID_THRU_YYYYMM
	, cast(year(dateadd(m,2,n.paid_thru)) as varchar) + right('00' + cast(month(dateadd(m,2,n.paid_thru)) as varchar),2) TERMINATION_DATE_YYYYMM
	, n.ID, n.PAID_THRU, mt.DESCRIPTION Member_Type, n.FULL_NAME, n.STATUS, n.COMPANY, n.CO_ID, case when n2.STATUS like 'A' then 'Active Company' else '' end Active_Company
	, pb.DESCRIPTION Primary_Business
	, DATEDIFF(year, n2.JOIN_DATE, getdate()) Company_Years_In_IMIS
	, (select count(n3.id) from name n3 where n3.CO_ID = n2.ID and n3.MEMBER_TYPE not in ('NMI','PROS','BLANK','ST')) Company_Size
	, (select count(n3.id) from name n3 where n3.CO_ID = n2.ID and n3.MEMBER_TYPE not in ('NMI','PROS','BLANK','ST') and n3.STATUS = 'A') Company_Active_Size
	--, case when n.ID in (select * from CTEList) then 1 else 0 end Possible_Dupe
	, case when sum(case when cl.ID is not null then 1 else 0 end) > 1 then 1 else 0 end Possible_Dupe
	, sum(case when o.ORDER_DATE <= dateadd(m,2,n.paid_thru) then 1 else 0 end)	ORDERS_BEFORE_TERM
	, sum(case when o.ORDER_DATE > dateadd(m,2,n.paid_thru) then 1 else 0 end)	ORDERS_AFTER_TERM
from name n
	left join name n2 on n.CO_ID = n2.ID
	left join orders o on n.ID = o.ST_ID and o.status not like 'C%'
	inner join Demographics d on n.id = d.id
	left join Member_Types mt on n.MEMBER_TYPE = mt.MEMBER_TYPE
	left join icsc_PrimaryBusiness pb on d.PRIM_BUS_CODE = pb.CODE
	left join CTEList cl on n.ID = cl.ID
where dateadd(m,2,n.paid_thru) between '2015-1-1' and '2016-12-31'
	and n.status = 'S'
	and n.COMPANY_RECORD = 0
	and n.MEMBER_TYPE not in ('NMI','ST','BLANK','PROS')
	and n.country in ('United States','')
group by cast(year(n.paid_thru) as varchar) + right('00' + cast(month(n.paid_thru) as varchar),2) 
	, cast(year(dateadd(m,2,n.paid_thru)) as varchar) + right('00' + cast(month(dateadd(m,2,n.paid_thru)) as varchar),2) 
	, n.ID, n.PAID_THRU, mt.DESCRIPTION, n.FULL_NAME, n.STATUS, n.COMPANY, n.CO_ID, case when n2.STATUS like 'A' then 'Active Company' else '' end 
	, pb.DESCRIPTION, n2.ID
	, DATEDIFF(year, n2.JOIN_DATE, getdate()) 
--order by cast(cast(year(n.paid_thru) as varchar) + right('00' + cast(month(n.paid_thru) as varchar),2) as int)