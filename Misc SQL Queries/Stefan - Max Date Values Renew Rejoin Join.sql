--ALL MEMBERS
select year(MAX_DATE) Year
	, case when month(MAX_DATE) < 4 then 'Q1'
		when month(MAX_DATE) < 7 then 'Q2'
		when month (MAX_DATE) < 10 then 'Q3'
		else 'Q4' end Quarter
	, count(id) CT_Join
from
(
	select n.id,
		case
			when COALESCE(n.JOIN_DATE,'') > COALESCE(d.RENEWED_DATE,'') then n.JOIN_DATE
			when COALESCE(d.RENEWED_DATE,'') > COALESCE(d.REJOIN_DATE,'') then d.RENEWED_DATE
			when COALESCE(d.REJOIN_DATE,'') > COALESCE(n.JOIN_DATE,'') then d.REJOIN_DATE
			else n.JOIN_DATE
		end MAX_DATE
	from name n
		inner join Demographics d on n.id = d.id
) a
where MAX_DATE is not null
group by year(MAX_DATE)
	, case when month(MAX_DATE) < 4 then 'Q1'
		when month(MAX_DATE) < 7 then 'Q2'
		when month (MAX_DATE) < 10 then 'Q3'
		else 'Q4' end
order by year(MAX_DATE)
	, case when month(MAX_DATE) < 4 then 'Q1'
		when month(MAX_DATE) < 7 then 'Q2'
		when month (MAX_DATE) < 10 then 'Q3'
		else 'Q4' end


--ACTIVE MEMBERS
select year(MAX_DATE) Year
	, count(id) CT_Join
from
(
	select n.id,
		case
			when COALESCE(n.JOIN_DATE,'') > COALESCE(d.RENEWED_DATE,'') then n.JOIN_DATE
			when COALESCE(d.RENEWED_DATE,'') > COALESCE(d.REJOIN_DATE,'') then d.RENEWED_DATE
			when COALESCE(d.REJOIN_DATE,'') > COALESCE(n.JOIN_DATE,'') then d.REJOIN_DATE
			else n.JOIN_DATE
		end MAX_DATE
	from name n
		inner join Demographics d on n.id = d.id
	where status = 'A'
		and MEMBER_TYPE not in ('NMI','PROS')
) a
where MAX_DATE is not null
group by year(MAX_DATE)
order by year(MAX_DATE)

--ACTIVE MEMBERS by join date
select year(MAX_DATE) Year
	, count(id) CT_Join
from
(
	select n.id,
		n.join_date MAX_DATE
	from name n
		inner join Demographics d on n.id = d.id
	where status = 'A'
		and MEMBER_TYPE not in ('NMI','PROS')
) a
where MAX_DATE is not null
group by year(MAX_DATE)
order by year(MAX_DATE)