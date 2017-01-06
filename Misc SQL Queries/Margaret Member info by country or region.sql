--Individuals
select case when na.COUNTRY = '' then 'United States' else na.COUNTRY end COUNTRY, count(n.ID) CT
from name n
	inner join name_address na on n.ID = na.ID and na.PREFERRED_MAIL = 1
where n.MEMBER_TYPE not in ('NMI','PROS')
	and n.status = 'A'
	and n.COMPANY_RECORD = 0
group by case when na.COUNTRY = '' then 'United States' else na.COUNTRY end
order by count(n.ID) desc

--Companies
select case when na.COUNTRY = '' then 'United States' else na.COUNTRY end COUNTRY, count(n.ID) CT
from name n
	inner join name_address na on n.ID = na.ID and na.PREFERRED_MAIL = 1
where n.MEMBER_TYPE not in ('NMI','PROS')
	and n.status = 'A'
	and n.COMPANY_RECORD = 1
group by case when na.COUNTRY = '' then 'United States' else na.COUNTRY end
order by count(n.ID) desc

--Individual
select m.Region_Name, count(n.ID) CT
from name n
	inner join name_address na on n.ID = na.ID and na.PREFERRED_MAIL = 1
	left join Csys_ICSC_Regions_Mem m on case when na.COUNTRY = '' then 'United States' else na.COUNTRY end = m.Country
where n.MEMBER_TYPE not in ('NMI','PROS')
	and n.status = 'A'
	and n.COMPANY_RECORD = 0
group by m.Region_Name
order by count(n.ID) desc

--Companies
select m.Region_Name, count(n.ID) CT
from name n
	inner join name_address na on n.ID = na.ID and na.PREFERRED_MAIL = 1
	left join Csys_ICSC_Regions_Mem m on case when na.COUNTRY = '' then 'United States' else na.COUNTRY end = m.Country
where n.MEMBER_TYPE not in ('NMI','PROS')
	and n.status = 'A'
	and n.COMPANY_RECORD = 1
group by m.Region_Name
order by count(n.ID) desc

--Non Member - Individual Transactions
select COUNTRY, count(ID) CT
from (
select distinct n.ID, case when na.COUNTRY = '' then 'United States' else na.COUNTRY end COUNTRY
from trans t
	inner join name n on t.ST_ID = n.ID
	inner join Name_Address na on n.ID = na.ID and na.PREFERRED_MAIL = 1
where n.MEMBER_TYPE in ('NMI','PROS')
	and t.TRANSACTION_DATE >= '2016-1-1'
)a
group by COUNTRY
order by count(ID) desc

--Non Member - Company Transactions
select COUNTRY, count(ID) CT
from (
select distinct n.ID, case when na.COUNTRY = '' then 'United States' else na.COUNTRY end COUNTRY
from trans t
	inner join name n on t.ST_ID = n.ID
	inner join Name_Address na on n.ID = na.ID and na.PREFERRED_MAIL = 1
where n.MEMBER_TYPE in ('NM','PROC')
	and t.TRANSACTION_DATE >= '2016-1-1'
)a
group by COUNTRY
order by count(ID) desc