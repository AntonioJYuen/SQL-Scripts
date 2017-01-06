select SOURCE_SYSTEM, case when CHECK_NUMBER like 'C%' then 'Company Check'
		when CHECK_NUMBER like 'P%' then 'Personal Check'
		else 'Other' end Check_Type, count(TRANS_NUMBER) CT
from trans
where (replace(CHECK_NUMBER,' ','') like 'C[0-9]%'
	or replace(CHECK_NUMBER,' ','') like 'P[0-9]%')
	and TRANSACTION_DATE >= '2015-1-1'
	and TRANSACTION_DATE <= '2015-12-31'
group by SOURCE_SYSTEM, case when CHECK_NUMBER like 'C%' then 'Company Check'
		when CHECK_NUMBER like 'P%' then 'Personal Check'
		else 'Other' end 

select dbo.RemoveBreaks(n.COMPANY) Company, count(t.TRANS_NUMBER) Count_Payments, sum(t.amount) Total_Payments
from trans t
	inner join name n on t.BT_ID = n.ID
	--left join name c on n.CO_ID = n.ID
where (replace(CHECK_NUMBER,' ','') like 'C[0-9]%'
	or replace(CHECK_NUMBER,' ','') like 'P[0-9]%')
	and TRANSACTION_DATE >= '2015-1-1'
	and TRANSACTION_DATE <= '2015-12-31'
group by dbo.RemoveBreaks(n.COMPANY)