IF OBJECT_ID('tempdb..##temp_table') IS NOT NULL
	 DROP TABLE ##temp_table

select n.ID, n.CO_ID, case when n.COMPANY_RECORD = 1 then 'YES' else 'NO' end Is_Company
	, n.FIRST_NAME, n.LAST_NAME, dbo.removebreaks(n.COMPANY) Company, n.TITLE, n.FUNCTIONAL_TITLE, n.MEMBER_TYPE, n.STATUS
	, n.GENDER
	, n.CITY, n.STATE_PROVINCE, n.COUNTRY
	, n.BIRTH_DATE, n.DATE_ADDED, n.JOIN_DATE
	, d.PRIM_BUS_CODE, d.SECONDARY_CODE, d.DEPARTMENT
	, sum(case when TRANSACTION_TYPE = 'DIST' then amount * -1 else 0 end) Full_Time_Value
	, sum(case when TRANSACTION_TYPE = 'DIST' and t.SOURCE_SYSTEM = 'FR' then amount * -1 else 0 end) Fundraising_Value
	, sum(case when PRODUCT_CODE like '%PAC%' and TRANSACTION_TYPE = 'DIST' then amount * -1 else 0 end) PAC_Value
	, sum(case when PRODUCT_CODE like '%SIC%' and TRANSACTION_TYPE = 'DIST' then amount * -1 else 0 end) SIC_Value into ##temp_table
from name n
	inner join Demographics d on n.ID = d.ID
	left join trans t on n.id = t.st_id
group by n.ID, n.CO_ID, case when n.COMPANY_RECORD = 1 then 'YES' else 'NO' end
		, n.FIRST_NAME, n.LAST_NAME, dbo.removebreaks(n.COMPANY), n.TITLE, n.FUNCTIONAL_TITLE, n.MEMBER_TYPE, n.STATUS
		, n.GENDER
		, n.CITY, n.STATE_PROVINCE, n.COUNTRY
		, n.BIRTH_DATE, n.DATE_ADDED, n.JOIN_DATE
		, d.PRIM_BUS_CODE, d.SECONDARY_CODE, d.DEPARTMENT

select t.ID, t.CO_ID, t.Is_Company
	, t.FIRST_NAME, t.LAST_NAME, t.Company, t.TITLE, t.FUNCTIONAL_TITLE, t.MEMBER_TYPE, t.STATUS
	, t.GENDER
	, t.CITY, t.STATE_PROVINCE, t.COUNTRY
	, t.BIRTH_DATE, t.DATE_ADDED, t.JOIN_DATE
	, t.PRIM_BUS_CODE, t.SECONDARY_CODE, t.DEPARTMENT
	, t.Full_Time_Value
	, t.Full_Time_Value + sum(u.Full_Time_Value) Full_Time_Value_with_Affilates
	, t.Fundraising_Value + sum(u.Fundraising_Value) Fundraising_Value_With_Affiliates
	, t.PAC_Value + sum(u.PAC_Value) PAC_Value_With_Affiliates
	, t.SIC_Value + sum(u.SIC_Value) SIC_Value_With_Affiliates
from ##temp_table t
	left join (select CO_ID, Full_Time_Value, Fundraising_Value, PAC_Value, SIC_Value from ##temp_table) u on t.ID = u.CO_ID
where t.MEMBER_TYPE not in ('NM','NMI','PROS','PROC','USM','','BLANK','ORG','ST')
		and t.STATUS = 'A'
group by t.ID, t.CO_ID, t.Is_Company
	, t.FIRST_NAME, t.LAST_NAME, t.Company, t.TITLE, t.FUNCTIONAL_TITLE, t.MEMBER_TYPE, t.STATUS
	, t.GENDER
	, t.CITY, t.STATE_PROVINCE, t.COUNTRY
	, t.BIRTH_DATE, t.DATE_ADDED, t.JOIN_DATE
	, t.PRIM_BUS_CODE, t.SECONDARY_CODE, t.DEPARTMENT
	, t.Full_Time_Value
	, t.Fundraising_Value
	, t.PAC_Value
	, t.SIC_Value