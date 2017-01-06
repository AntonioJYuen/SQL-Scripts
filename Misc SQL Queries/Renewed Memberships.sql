select cast(year(transaction_date) as varchar(4)) + right( '0' + cast(month(transaction_date) as varchar(2)),2) Period
	, case when PRODUCT_CODE like '%-3' then '3 Year Dues' else '1 Year Dues' end Product_Code
	, count(n.ID) CT
from Csys_ICSC_Regions_Mem m
	inner join Name_Address na on na.COUNTRY = m.Country
	inner join Name n on na.id = n.ID
	inner join Demographics d on n.id = d.ID
	left join icsc_PrimaryBusiness p on d.PRIM_BUS_CODE = p.CODE
	left join (select a2.id, a2.PRODUCT_CODE, a2.DESCRIPTION, a2.transaction_date
				from(
					select a.*, ROW_NUMBER() over (partition by a.id order by a.transaction_date) as rn 
					from activity a 
					where a.ACTIVITY_TYPE = 'DUES' 
						and a.PRODUCT_CODE like 'DUES%'
						and a.transaction_date >= '2012-1-1'
				) a2
				where a2.rn = 1) a3 on case when n.member_type like '%o' then n.CO_ID else n.ID end = a3.ID
where n.COMPANY_RECORD = 0
	and n.MEMBER_TYPE not in ('NMI','PROS','BLANK','ST')
	--and n.STATUS = 'A'
	and m.Region_Name = 'ICSC EUROPE'
	and a3.transaction_date is not null
	and (abs(datediff(m,ISNULL(d.REJOIN_DATE, '1900-1-1'),a3.transaction_date))>3  or abs(datediff(m,ISNULL(n.JOIN_DATE, '1900-1-1'),a3.transaction_date))>3)
	--and a3.product_code not like '%-3'
	and d.PROMO_SOURCE not like '%MEMB'
group by cast(year(transaction_date) as varchar(4)) + right( '0' + cast(month(transaction_date) as varchar(2)),2)
	, case when PRODUCT_CODE like '%-3' then '3 Year Dues' else '1 Year Dues' end