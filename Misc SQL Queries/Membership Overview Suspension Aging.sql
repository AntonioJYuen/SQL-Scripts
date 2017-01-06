Declare @AsOf date
--set @AsOf = @AsOf
set @AsOf = '2016-7-31'

select case	when DATEDIFF(d,cast(d.TERMINATION_DATE as date),@AsOf) < 30 then '<30'
			when DATEDIFF(d,cast(d.TERMINATION_DATE as date),@AsOf) < 60 then '30-59'
			when DATEDIFF(d,cast(d.TERMINATION_DATE as date),@AsOf) < 90 then '60-89'
			when DATEDIFF(d,cast(d.TERMINATION_DATE as date),@AsOf) <= 180 then '90-180'
			else '>180' end Grouping, count(n.ID) CT, sum(a.Amount_Spent) Total_Spent, sum(a.Amount_Spent) / count(n.id) Amount_Spent_Per_Member
from Demographics d
	inner join name n on d.id = n.ID
	inner join Name_Address na on n.ID = na.ID and PREFERRED_MAIL = 1
	left join (select t.st_id, sum(t.amount*-1) Amount_Spent
					from trans t  
					where t.TRANSACTION_TYPE = 'DIST' and year(t.transaction_date) = year(DATEADD(year,-1,getdate()))
					group by t.st_id) a on n.ID = a.ST_ID
where TERMINATION_DATE >= cast(CAST(year(getdate()) AS varchar(4)) + '-1-1' as date) --DATEADD(d,-365,@AsOf)
	and TERMINATION_DATE <= @AsOf
					and n.COMPANY_RECORD = 0
					and n.MEMBER_TYPE not in ('NMI','PROS','BLANK','ST')
					and na.COUNTRY in ('United States','') --US Filter
 group by case	when DATEDIFF(d,cast(d.TERMINATION_DATE as date),@AsOf) < 30 then '<30'
				when DATEDIFF(d,cast(d.TERMINATION_DATE as date),@AsOf) < 60 then '30-59'
				when DATEDIFF(d,cast(d.TERMINATION_DATE as date),@AsOf) < 90 then '60-89'
				when DATEDIFF(d,cast(d.TERMINATION_DATE as date),@AsOf) <= 180 then '90-180'
				else '>180' end

