select cast(year(paid_thru) as varchar) + right('00' + cast(month(paid_thru) as varchar),2) PAID_THRU
	, cast(year(dateadd(m,2,paid_thru)) as varchar) + right('00' + cast(month(dateadd(m,2,paid_thru)) as varchar),2) TERMINATION_DATE
	, count(id) NUMBER_TERMINATED
from name
where dateadd(m,2,paid_thru) between '2013-1-1' and getdate()	
	and status = 'S'
	and COMPANY_RECORD = 0
	and MEMBER_TYPE not in ('NMI','ST','BLANK','PROS')
	and country in ('United States','')
group by cast(year(paid_thru) as varchar) + right('00' + cast(month(paid_thru) as varchar),2)
	, cast(year(dateadd(m,2,paid_thru)) as varchar) + right('00' + cast(month(dateadd(m,2,paid_thru)) as varchar),2)
order by cast(cast(year(paid_thru) as varchar) + right('00' + cast(month(paid_thru) as varchar),2) as int)