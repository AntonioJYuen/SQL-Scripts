--Current members based on primary business code

select case when d.PRIM_BUS_CODE = 'LEN' then 'Lender'
		when d.PRIM_BUS_CODE in ('OWN','SCM') then 'Owner/Developer/Manager'
		when d.PRIM_BUS_CODE = 'PBS' then 'Public'
		when d.PRIM_BUS_CODE = 'ACA' then 'Academic'
		when d.PRIM_BUS_CODE = 'RET' then 'Retailer'
		when d.PRIM_BUS_CODE = 'STU' then 'Student'
		else 'Real Estate Services' end BUS_CATEGORY, count(n.id) ct, cast(getdate() as date) Date_Capture
		into ICSC_Monthly_KIA_Capture_Current_Prim_Members
from name n
inner join demographics d on n.id = d.id
left join icsc_PrimaryBusiness p on d.PRIM_BUS_CODE = p.CODE 
where n.status = 'A'
	and n.MEMBER_TYPE not in ('NMI','PROS','BLANK')
	and n.COMPANY_RECORD = 0
group by case when d.PRIM_BUS_CODE = 'LEN' then 'Lender'
		when d.PRIM_BUS_CODE in ('OWN','SCM') then 'Owner/Developer/Manager'
		when d.PRIM_BUS_CODE = 'PBS' then 'Public'
		when d.PRIM_BUS_CODE = 'ACA' then 'Academic'
		when d.PRIM_BUS_CODE = 'RET' then 'Retailer'
		when d.PRIM_BUS_CODE = 'STU' then 'Student'
		else 'Real Estate Services' end