insert into ICSC_Monthly_KPI_Capture_Suspended_Members
select case 
	when n.MEMBER_TYPE like 'PB%' then 'Public Entities (Official and Affiliate)'
	when n.MEMBER_TYPE like 'AC%' then 'Academic (Official and Affiliate)'
	when n.MEMBER_TYPE like 'SM' then 'Students'
	when n.MEMBER_TYPE like 'RMO' then 'Regular Official Members (Lender, Owner/Developer/Mgt/Retailer)'
	when n.MEMBER_TYPE like 'AMO' then 'Associate Official Members (Real Estate Services)'
	when n.MEMBER_TYPE like 'RMU' then 'Regular Unsponsored Members'
	when n.MEMBER_TYPE like 'AMU' then 'Associate Unsponsored Members'
	when n.MEMBER_TYPE like 'RMA' then 'Regular Affiliate Members'
	when n.MEMBER_TYPE like 'AMA' then 'Associate Affiliate Members'
	else 'Other Members' end Member_Type
	, count(n.id) CT
	, cast(DATEADD(DAY, -(DAY(DATEADD(MONTH, 1, d.TERMINATION_DATE))),DATEADD(MONTH, 1, d.TERMINATION_DATE)) as date) Date_Capture
from name n
	inner join Demographics d on n.id = d.id
	left join icsc_PrimaryBusiness p on d.PRIM_BUS_CODE = p.CODE
where d.TERMINATION_DATE >= '2015-1-1'
	and n.COMPANY_RECORD = 0
group by case 
	when n.MEMBER_TYPE like 'PB%' then 'Public Entities (Official and Affiliate)'
	when n.MEMBER_TYPE like 'AC%' then 'Academic (Official and Affiliate)'
	when n.MEMBER_TYPE like 'SM' then 'Students'
	when n.MEMBER_TYPE like 'RMO' then 'Regular Official Members (Lender, Owner/Developer/Mgt/Retailer)'
	when n.MEMBER_TYPE like 'AMO' then 'Associate Official Members (Real Estate Services)'
	when n.MEMBER_TYPE like 'RMU' then 'Regular Unsponsored Members'
	when n.MEMBER_TYPE like 'AMU' then 'Associate Unsponsored Members'
	when n.MEMBER_TYPE like 'RMA' then 'Regular Affiliate Members'
	when n.MEMBER_TYPE like 'AMA' then 'Associate Affiliate Members'
	else 'Other Members' end
	, cast(DATEADD(DAY, -(DAY(DATEADD(MONTH, 1, d.TERMINATION_DATE))),DATEADD(MONTH, 1, d.TERMINATION_DATE)) as date)
order by Date_Capture