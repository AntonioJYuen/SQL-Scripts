select year(JOIN_DATE)
	, case when month(join_date) < 4 then 'Q1'
		when month(join_date) < 7 then 'Q2'
		when month (join_date) < 10 then 'Q3'
		else 'Q4' end Quarter
	, count(id) CT_Join
from name
where JOIN_DATE is not null
	and status not like 'D' 
group by year(JOIN_DATE)
	, case when month(join_date) < 4 then 'Q1'
		when month(join_date) < 7 then 'Q2'
		when month (join_date) < 10 then 'Q3'
		else 'Q4' end