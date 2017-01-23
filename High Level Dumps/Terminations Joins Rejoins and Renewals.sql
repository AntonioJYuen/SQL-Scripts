--Terminations
select cast(year(period_date) as varchar(4)) + right('00' + cast(month(period_date) as varchar(2)),2) Period, count(id) Ct
from (
	select distinct d.TERMINATION_DATE period_date, n.ID
	from name n
		inner join Demographics d on n.id = d.id
	where d.TERMINATION_DATE >= '2016-1-1'
		and n.COMPANY_RECORD = 0
) a
group by cast(year(period_date) as varchar(4)) + right('00' + cast(month(period_date) as varchar(2)),2)
order by cast(cast(year(period_date) as varchar(4)) + right('00' + cast(month(period_date) as varchar(2)),2) as int)

--Renews
select cast(year(period_date) as varchar(4)) + right('00' + cast(month(period_date) as varchar(2)),2) Period, count(id) Ct
from (
	select max(t.TRANSACTION_DATE) period_date, n.id
	from name n
		inner join Demographics d on n.id = d.id
		inner join trans t on n.id = t.ST_ID and t.source_system = 'DUES' 
										and t.TRANSACTION_TYPE = 'DIST' and t.TRANSACTION_DATE >= '2016-1-1' and t.TRANSACTION_DATE < '2018-1-1'
										and year(n.JOIN_DATE) <> year(t.TRANSACTION_DATE) and year(d.REJOIN_DATE) <> year(t.TRANSACTION_DATE)
	group by n.id
) a
group by cast(year(period_date) as varchar(4)) + right('00' + cast(month(period_date) as varchar(2)),2)
order by cast(cast(year(period_date) as varchar(4)) + right('00' + cast(month(period_date) as varchar(2)),2) as int)

--Joins
select cast(year(period_date) as varchar(4)) + right('00' + cast(month(period_date) as varchar(2)),2) Period, count(id) Ct
from (
	select distinct n.JOIN_DATE period_date, n.ID
	from name n
		inner join Demographics d on n.id = d.id
	where n.JOIN_DATE >= '2016-1-1'
		and n.COMPANY_RECORD = 0
) a
group by cast(year(period_date) as varchar(4)) + right('00' + cast(month(period_date) as varchar(2)),2)
order by cast(cast(year(period_date) as varchar(4)) + right('00' + cast(month(period_date) as varchar(2)),2) as int)

select cast(year(period_date) as varchar(4)) + right('00' + cast(month(period_date) as varchar(2)),2) Period, count(id) Ct
from (
	select distinct n.JOIN_DATE period_date, n.ID
	from name n
		inner join Demographics d on n.id = d.id
		inner join trans t on n.id = t.ST_ID and t.source_system = 'DUES' 
										and t.TRANSACTION_TYPE = 'DIST' and t.TRANSACTION_DATE >= '2016-1-1' and t.TRANSACTION_DATE < '2018-1-1'
										and year(n.JOIN_DATE) = year(t.TRANSACTION_DATE)
	where n.JOIN_DATE >= '2016-1-1'
		and n.COMPANY_RECORD = 0
) a
group by cast(year(period_date) as varchar(4)) + right('00' + cast(month(period_date) as varchar(2)),2)
order by cast(cast(year(period_date) as varchar(4)) + right('00' + cast(month(period_date) as varchar(2)),2) as int)

--Rejoins
select cast(year(period_date) as varchar(4)) + right('00' + cast(month(period_date) as varchar(2)),2) Period, count(id) Ct
from (
	select distinct d.REJOIN_DATE period_date, n.ID
	from name n
		inner join Demographics d on n.id = d.id
	where d.REJOIN_DATE >= '2016-1-1'
		and year(n.join_date) <> year(d.rejoin_date)
		and n.COMPANY_RECORD = 0
) a
group by cast(year(period_date) as varchar(4)) + right('00' + cast(month(period_date) as varchar(2)),2)
order by cast(cast(year(period_date) as varchar(4)) + right('00' + cast(month(period_date) as varchar(2)),2) as int)

select cast(year(period_date) as varchar(4)) + right('00' + cast(month(period_date) as varchar(2)),2) Period, count(id) Ct
from (
	select distinct d.REJOIN_DATE period_date, n.ID
	from name n
		inner join Demographics d on n.id = d.id
		inner join trans t on n.id = t.ST_ID and t.source_system = 'DUES' 
										and t.TRANSACTION_TYPE = 'DIST' and t.TRANSACTION_DATE >= '2016-1-1' and t.TRANSACTION_DATE < '2018-1-1'
										and year(d.REJOIN_DATE) = year(t.TRANSACTION_DATE) and year(d.REJOIN_DATE) <> year(n.JOIN_DATE)
	where d.REJOIN_DATE >= '2016-1-1'
) a
group by cast(year(period_date) as varchar(4)) + right('00' + cast(month(period_date) as varchar(2)),2)
order by cast(cast(year(period_date) as varchar(4)) + right('00' + cast(month(period_date) as varchar(2)),2) as int)