select p.DESCRIPTION, count(p.DESCRIPTION) Cnt
from name n
	inner join Name_Address na on n.id = na.ID and na.PREFERRED_MAIL = 1
	inner join Demographics d on n.id = d.ID
	inner join icsc_PrimaryBusiness p on d.PRIM_BUS_CODE = p.CODE
where na.STATE_PROVINCE = 'AZ'
	and n.MEMBER_TYPE not in ('NMI','NM','PROS','PROC')
	and n.STATUS = 'A'
group by p.DESCRIPTION