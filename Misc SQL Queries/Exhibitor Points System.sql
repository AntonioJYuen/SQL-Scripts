if OBJECT_ID('tempdb..#TempTable') is not null
drop table #TempTable;

select id, company, Yr into #TempTable
from(

select n.id, dbo.removebreaks(n.company) company, cast(right(om.meeting,4) as int) Yr
from name n
	inner join orders o on n.id = o.ST_ID
	inner join order_meet om on o.ORDER_NUMBER = om.order_number
where om.MEETING like 'PND____'

union

select n.id, dbo.removebreaks(n.company) company, cast(right(product_code,4) as int) Yr
from Activity a
	inner join name n on a.id = n.id
where product_code like 'PND____' 
	and isnumeric(right(product_code,4)) = 1
	and cast(right(product_code,4) as int) >= 2005) a
order by company, Yr

select *
from #TempTable

select id, first_name, last_name, full_name, dbo.removebreaks(COMPANY) Company
from name
where co_id in (select distinct id from #TempTable)
	and status = 'A'
	and member_type not in ('NMI','PROS')
order by CO_ID