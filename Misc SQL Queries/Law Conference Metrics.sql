select o.product_code, case when n.country = '' then 'United States' else n.country end Country, 
	case when product_code = '2008LC1' then 2007 else isnull(year(o.TRANSACTION_DATE),1997) end EventYear
	, count(n.id)
FROM        dbo.Activity AS o WITH (NOLOCK) 
			INNER JOIN dbo.Name AS n WITH (NOLOCK) on o.ID = n.ID
			JOIN icsc_Member_Export me WITH (NOLOCK) ON o.ID = me.ID 
			LEFT JOIN State_Codes sc WITH (NOLOCK) ON sc.STATE_PROVINCE = me.STATE_PROVINCE 
			LEFT JOIN Gen_Tables gt WITH (NOLOCK) ON me.PRIM_BUS_CODE = gt.CODE AND TABLE_NAME = 'PRIMARY'
WHERE     ACTIVITY_TYPE IN ('MEETING', 'EXPO','SPON')
			and (o.PRODUCT_CODE like '%LC' or o.PRODUCT_CODE like '%LC1')
			and o.PRODUCT_CODE not like '%CLC'
			and o.PRODUCT_CODE not like '%SLC'
			and o.PRODUCT_CODE not like '%TLC'
			and o.PRODUCT_CODE not like '%DLC'
			and o.PRODUCT_CODE not like '%LNLC'
group by o.product_code, case when n.country = '' then 'United States' else n.country end, isnull(year(o.TRANSACTION_DATE),1997)

UNION

select mm.meeting, case when o.country = '' then 'United States' else o.country end Country, year(mm.BEGIN_DATE) EventYear, count(o.st_id)
FROM        meet_master as mm 
			left join dbo.Order_Meet AS om WITH (NOLOCK) ON mm.meeting = om.MEETING
			left join dbo.Orders AS o WITH (NOLOCK) on om.order_number = o.ORDER_NUMBER
			--JOIN icsc_Member_Export me WITH (NOLOCK) ON o.ST_ID = me.ID 
			--LEFT JOIN State_Codes sc WITH (NOLOCK) ON sc.STATE_PROVINCE = me.STATE_PROVINCE 
			--LEFT JOIN Gen_Tables gt WITH (NOLOCK) ON me.PRIM_BUS_CODE = gt.CODE AND TABLE_NAME = 'PRIMARY'
where mm.MEETING like '%LC'
			and mm.MEETING not like '%CLC'
			and mm.MEETING not like '%RLC'
			and mm.MEETING not like '%NLC'
			and mm.MEETING not like '%S'
			and o.status not like 'C%'
group by mm.meeting, case when o.country = '' then 'United States' else o.country end, year(mm.BEGIN_DATE)

order by eventyear desc