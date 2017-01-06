--Joins
select cast(year(n.join_date) as varchar(4)) + right('0'+cast(month(n.join_date) as varchar(2)),2) Period, p.DESCRIPTION,count(n.id) CT
from Csys_ICSC_Regions_Mem m
	inner join Name_Address na on na.COUNTRY = m.Country
	inner join Name n on na.id = n.ID
	inner join Demographics d on n.id = d.ID
	left join icsc_PrimaryBusiness p on d.PRIM_BUS_CODE = p.CODE
where n.COMPANY_RECORD = 0
	and n.MEMBER_TYPE not in ('NMI','PROS','BLANK','ST')
	and m.Region_Name = 'ICSC EUROPE'
	and n.JOIN_DATE >= '2012-1-1'
	and d.PROMO_SOURCE not like '%memb%' --Councils
group by cast(year(n.join_date) as varchar(4)) + right('0'+cast(month(n.join_date) as varchar(2)),2), p.DESCRIPTION
order by cast(year(n.join_date) as varchar(4)) + right('0'+cast(month(n.join_date) as varchar(2)),2), p.DESCRIPTION

--rejoins
select cast(year(d.REJOIN_DATE) as varchar(4)) + right('0'+cast(month(d.REJOIN_DATE) as varchar(2)),2) Period, p.DESCRIPTION,count(n.id) CT
from Csys_ICSC_Regions_Mem m
	inner join Name_Address na on na.COUNTRY = m.Country
	inner join Name n on na.id = n.ID
	inner join Demographics d on n.id = d.ID
	left join icsc_PrimaryBusiness p on d.PRIM_BUS_CODE = p.CODE
where n.COMPANY_RECORD = 0
	and n.MEMBER_TYPE not in ('NMI','PROS','BLANK','ST')
	and m.Region_Name = 'ICSC EUROPE'
	and d.REJOIN_DATE >= '2012-1-1'
	and d.PROMO_SOURCE not like '%memb%' --Councils
group by cast(year(d.REJOIN_DATE) as varchar(4)) + right('0'+cast(month(d.REJOIN_DATE) as varchar(2)),2), p.DESCRIPTION
order by cast(year(d.REJOIN_DATE) as varchar(4)) + right('0'+cast(month(d.REJOIN_DATE) as varchar(2)),2), p.DESCRIPTION