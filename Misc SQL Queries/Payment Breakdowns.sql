--select *
--from trans
--where GL_ACCOUNT = '1026-0000-00-0'
--	and PSEUDO_ACCOUNT like 'ICSC-DUES-PAY'
--	and TRANSACTION_DATE >= '2015-1-1'

--select year(transaction_Date) Year, 'Check' Payment_Type, 'Backend' Payment_Method, 'Euro' Currency, count(TRANS_NUMBER) Num_Transactions, sum(amount) Total_Paid
--from trans
--where GL_ACCOUNT in ('1030-0000-00-0','1026-0000-00-0')
--	and PSEUDO_ACCOUNT like 'ICSC-DUES-PAY'
--	and TRANSACTION_DATE >= '2015-1-1'
--	and amount > 0
--group by year(transaction_Date)

select year(transaction_date) Year
	, case when CHECK_NUMBER like '%WT%' then 'Wire Transfer' when cc_number like '*****%' or CHECK_NUMBER like 'EUROCC%' then 'Credit Card' else 'Check' end Payment_Type
	, case when t.SOURCE_CODE like 'W_%' then 'Web' else 'Backend' end Payment_Method
	, case when GL_ACCOUNT in ('1030-0000-00-0','1026-0000-00-0') then 'Euro'
		when check_number like '%EURO%' then 'Euro'
		else 'USD' end Currency, count(t.st_id) Num_Transactions, sum(amount) Total_Paid
from name n
	inner join trans t on n.id = t.st_id
	--inner join trans t on case when n.MEMBER_TYPE like '%O' then n.CO_ID else n.id end = t.ST_ID
	inner join Name_Address na on n.id = na.id and na.PREFERRED_MAIL = 1
	inner join Csys_ICSC_Regions_Mem m on na.COUNTRY = m.Country
where m.Region_Name = 'ICSC EUROPE'
	and PSEUDO_ACCOUNT = 'ICSC-DUES-PAY'
	and t.TRANSACTION_DATE >= '2012-1-1'
group by year(transaction_date)
	, case when CHECK_NUMBER like '%WT%' then 'Wire Transfer' when cc_number like '*****%' or CHECK_NUMBER like 'EUROCC%' then 'Credit Card' else 'Check' end 
	, case when t.SOURCE_CODE like 'W_%' then 'Web' else 'Backend' end 
	, case when GL_ACCOUNT in ('1030-0000-00-0','1026-0000-00-0') then 'Euro'
		when check_number like '%EURO%' then 'Euro'
		else 'USD' end 
order by year(transaction_date), case when GL_ACCOUNT in ('1030-0000-00-0','1026-0000-00-0') then 'Euro'
		when check_number like '%EURO%' then 'Euro'	else 'USD' end 
		, case when CHECK_NUMBER like '%WT%' then 'Wire Transfer' when cc_number like '*****%' or CHECK_NUMBER like 'EUROCC%' then 'Credit Card' else 'Check' end 