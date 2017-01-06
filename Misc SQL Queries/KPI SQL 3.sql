--Suspended members

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
	, cast(getdate() as date) Date_Captured-- into ICSC_Monthly_KIA_Capture_Suspended_Members
from name n
	inner join Demographics d on n.ID = d.ID
	left join icsc_PrimaryBusiness p on d.PRIM_BUS_CODE = p.CODE
	left join Member_Types mt on n.MEMBER_TYPE = mt.MEMBER_TYPE 
where n.status = 'S'
	and n.MEMBER_TYPE not in ('NMI','PROS','BLANK')
	and n.COMPANY_RECORD = 0
	and month(n.PAID_THRU) = month(getdate())
	and year(n.PAID_THRU) = year(getdate())
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