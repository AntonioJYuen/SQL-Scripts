select n.id, n.FIRST_NAME, n.LAST_NAME, dbo.RemoveBreaks(n.COMPANY) Company, n.MEMBER_TYPE, n.STATUS, d.PRIM_BUS_CODE, d.SECONDARY_CODE, n.TITLE, n.CITY, n.STATE_PROVINCE, n.COUNTRY, n.GENDER, n.BIRTH_DATE, datediff(year,n.DATE_ADDED,getdate()) Years_In_Database, datediff(year,n.JOIN_DATE,getdate()) Years_Member_ICSC, sum(case when om.meeting like '%RECON%' then 1 else 0 end) Only_Recon
	, (select sum(amount*-1) from trans t where t.ST_ID = n.id and TRANSACTION_TYPE = 'DIST') Life_Time_Value
from name n
	inner join Demographics d on n.ID = d.ID
	inner join orders o on n.ID = o.ST_ID
	inner join order_meet om on o.ORDER_NUMBER = om.ORDER_NUMBER
where n.STATUS = 'A'
	and n.MEMBER_TYPE not in ('NMI','PROS')
	and COMPANY_RECORD = 0
group by n.ID, datediff(year,n.JOIN_DATE,getdate()), n.FIRST_NAME, n.LAST_NAME, dbo.RemoveBreaks(n.COMPANY), n.MEMBER_TYPE, n.STATUS, d.PRIM_BUS_CODE, d.SECONDARY_CODE, n.TITLE, n.CITY, n.STATE_PROVINCE, n.COUNTRY, n.GENDER, n.BIRTH_DATE, datediff(year,n.DATE_ADDED,getdate())
having sum(case when o.STATUS in ('CT','C') then 0 else 1 end) = 1