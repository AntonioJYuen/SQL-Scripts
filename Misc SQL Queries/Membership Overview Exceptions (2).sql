select n.id, join_date, rejoin_date, n.DATE_ADDED, n.PAID_THRU, n.MEMBER_TYPE, n.STATUS
from name n
	inner join Demographics d on n.id = d.id
where (cast(JOIN_DATE as date) >= '2016-1-1' or cast(REJOIN_DATE as date) >= '2016-1-1' or cast(DATE_ADDED as date) >= '2016-1-1')
	and n.COMPANY_RECORD = 0
	and n.status = 'A'
	and n.MEMBER_TYPE not in ('NMI','PROS','BLANK','ST')
	and n.MEMBER_TYPE not like '%O'
	and n.id not in (
select n.ID
from name n
	inner join Demographics d on n.id = d.ID
where n.JOIN_DATE >= cast(cast(year(getdate())-1 as varchar(4)) + '-12-1' as date)
	and n.COMPANY_RECORD = 0
	and n.MEMBER_TYPE not in ('NMI','PROS','BLANK','ST'))
and n.id not in (
select n.ID
from name n
	inner join Demographics d on n.id = d.ID
where d.REJOIN_DATE >= cast(cast(year(getdate())-1 as varchar(4)) + '-12-1' as date)
	and n.COMPANY_RECORD = 0
	and year(isnull(n.JOIN_DATE,'1990-1-1')) <> year(d.REJOIN_DATE)
	and n.MEMBER_TYPE not in ('NMI','PROS','BLANK','ST'))