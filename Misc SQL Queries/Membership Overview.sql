--JOIN
select month(n.JOIN_DATE), year(n.JOIN_DATE), count(n.id) CT
from name n
	inner join Demographics d on n.id = d.ID
where n.JOIN_DATE >= '2016-1-1'
	and n.JOIN_DATE <= '2016-6-30'
	and n.JOIN_DATE <> d.REJOIN_DATE
	and n.COMPANY_RECORD = 0
	and n.MEMBER_TYPE not in ('NMI','PROS','BLANK','ST')
group by month(n.JOIN_DATE), year(n.JOIN_DATE)
order by month(n.JOIN_DATE)

--Rejoins
select month(d.REJOIN_DATE), year(d.REJOIN_DATE), count(n.id) CT
from name n
	inner join Demographics d on n.id = d.ID
where d.REJOIN_DATE >= '2016-1-1'
	and n.COMPANY_RECORD = 0
	and n.JOIN_DATE <> d.REJOIN_DATE
	and n.MEMBER_TYPE not in ('NMI','PROS','BLANK','ST')
group by month(d.REJOIN_DATE), year(d.REJOIN_DATE)
order by month(d.REJOIN_DATE), year(d.REJOIN_DATE)

--Suspends
select month(d.TERMINATION_DATE), year(d.TERMINATION_DATE), count(n.id) CT
from name n
	inner join Demographics d on n.id = d.ID
where d.TERMINATION_DATE >= '2016-1-1'
	and n.COMPANY_RECORD = 0
	and n.MEMBER_TYPE not in ('NMI','PROS','BLANK','ST')
group by month(d.TERMINATION_DATE), year(d.TERMINATION_DATE)
order by month(d.TERMINATION_DATE), year(d.TERMINATION_DATE)

--Current member base
select count(id)
from name n
where status = 'A'
	and n.MEMBER_TYPE not in ('NMI','PROS','BLANK','ST')
	and n.COMPANY_RECORD = 0

--Joins this month
select count(n.id) CT
from name n
	inner join Demographics d on n.id = d.ID
where n.JOIN_DATE >= cast(getdate() - DAY(getdate()) + 1 as date)
	and n.JOIN_DATE <> d.REJOIN_DATE
	and n.COMPANY_RECORD = 0
	and n.MEMBER_TYPE not in ('NMI','PROS','BLANK','ST')

--Rejoins this month
select count(n.id) CT
from name n
	inner join Demographics d on n.id = d.ID
where d.REJOIN_DATE >= cast(getdate() - DAY(getdate()) + 1 as date)
	and n.COMPANY_RECORD = 0
	and n.JOIN_DATE <> d.REJOIN_DATE
	and n.MEMBER_TYPE not in ('NMI','PROS','BLANK','ST')

--Suspends this month
select month(d.TERMINATION_DATE), year(d.TERMINATION_DATE), count(n.id) CT
from name n
	inner join Demographics d on n.id = d.ID
where d.TERMINATION_DATE >= cast(getdate() - DAY(getdate()) + 1 as date)
	and n.COMPANY_RECORD = 0
	and n.MEMBER_TYPE not in ('NMI','PROS','BLANK','ST')
group by month(d.TERMINATION_DATE), year(d.TERMINATION_DATE)
order by month(d.TERMINATION_DATE), year(d.TERMINATION_DATE)