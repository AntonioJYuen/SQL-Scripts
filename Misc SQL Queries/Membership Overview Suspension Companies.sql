--Total Spend
select count(id) Num_Companies, sum(Total_Spend) Total_Spent, sum(Total_Spend)/count(id) Spent_Per_Company
from (
	select n.id, dbo.removebreaks(n.COMPANY) COMPANY, max(isnull(Company_Spend,0)) Company_Spend, sum(isnull(Employee_Spend,0)) Employee_Spend, max(isnull(t.Company_Spend,0)) + sum(isnull(t2.Employee_Spend,0)) Total_Spend
	from name n
		inner join Name_Address na on n.ID = na.ID and na.PREFERRED_MAIL = 1
		inner join Demographics d on n.ID = d.ID
		left join (select t.ST_ID, sum(t.amount * -1) Company_Spend from trans t where t.TRANSACTION_TYPE = 'DIST' and t.TRANSACTION_DATE >= '2015-1-1' and t.TRANSACTION_DATE < '2016-1-1' group by t.ST_ID) t on n.ID = t.ST_ID 
		--inner join name n2 on n.ID = n2.CO_ID
		left join (select n2.CO_ID, t2.ST_ID, sum(t2.amount * -1) Employee_Spend from name n2 inner join trans t2 on n2.id = t2.ST_ID where t2.TRANSACTION_TYPE = 'DIST' and t2.TRANSACTION_DATE >= '2015-1-1' and t2.TRANSACTION_DATE < '2016-1-1' group by n2.CO_ID, t2.ST_ID) t2 on n.ID = t2.CO_ID
	where n.COMPANY_RECORD = 1
		and d.TERMINATION_DATE >= '2016-1-1'
		and d.TERMINATION_DATE <= '2016-7-31'
		and (n.STATUS <> 'A' or n.MEMBER_TYPE = 'NM')
		and n.MEMBER_TYPE <> 'PROC'
		--and na.COUNTRY in ('United States','')
	group by n.id, dbo.removebreaks(n.COMPANY)
) a

--Total Spend 
select n.id, dbo.removebreaks(n.COMPANY) COMPANY, max(isnull(n2.Num_Employees,0)) Num_Employees, max(isnull(Company_Spend,0)) Company_Spend, sum(isnull(Employee_Spend,0)) Employee_Spend, max(isnull(t.Company_Spend,0)) + sum(isnull(t2.Employee_Spend,0)) Total_Spend
from name n
	inner join Name_Address na on n.ID = na.ID and na.PREFERRED_MAIL = 1
	inner join Demographics d on n.ID = d.ID
	left join (select co_id, count(id) Num_Employees from name where PAID_THRU >= '2015-1-1' group by CO_ID) n2 on n.ID = n2.CO_ID
	left join (select t.ST_ID, sum(t.amount * -1) Company_Spend from trans t where t.TRANSACTION_TYPE = 'DIST' and t.TRANSACTION_DATE >= '2015-1-1' and t.TRANSACTION_DATE < '2016-1-1' group by t.ST_ID) t on n.ID = t.ST_ID 
	--inner join name n2 on n.ID = n2.CO_ID
	left join (select n2.CO_ID, t2.ST_ID, sum(t2.amount * -1) Employee_Spend from name n2 inner join trans t2 on n2.id = t2.ST_ID where t2.TRANSACTION_TYPE = 'DIST' and t2.TRANSACTION_DATE >= '2015-1-1' and t2.TRANSACTION_DATE < '2016-1-1' group by n2.CO_ID, t2.ST_ID) t2 on n.ID = t2.CO_ID
where n.COMPANY_RECORD = 1
	and d.TERMINATION_DATE >= '2016-1-1'
	and d.TERMINATION_DATE <= '2016-7-31'
	and (n.STATUS <> 'A' or n.MEMBER_TYPE = 'NM')
	and n.MEMBER_TYPE <> 'PROC'
	--and na.COUNTRY in ('United States','')
group by n.id, dbo.removebreaks(n.COMPANY)
order by max(isnull(t.Company_Spend,0)) + sum(isnull(t2.Employee_Spend,0)) desc