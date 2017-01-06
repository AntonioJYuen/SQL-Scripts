select *
from name n
	inner join Name_Address na on n.id = na.id and na.preferred_mail = 1
	inner join Demographics d on n.id = d.id
where na.country in (select country
						from Csys_ICSC_Regions_Mem
						where Region_Name = 'ICSC EUROPE')
	and n.status = 'A'
		and n.COMPANY_RECORD = 0

select *
from name n
	inner join Demographics d on n.id = d.id
where d.promo_source like '%memb'
	and COMPANY_RECORD = 0
	and MEMBER_TYPE not in ('NMI','PROS')