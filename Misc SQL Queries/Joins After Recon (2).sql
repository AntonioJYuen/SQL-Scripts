select n.id, n.MEMBER_TYPE, n.STATUS, a.MEMBER_TYPE, a.STATUS, t.SOURCE_CODE--, s.SOURCE_CODE
from name n
	inner join (select st_id, MEMBER_TYPE, STATUS
				from orders o
					inner join order_meet om on o.ORDER_NUMBER = om.ORDER_NUMBER
				where om.MEETING = '2016RECON'
					and (o.MEMBER_TYPE = 'NMI' or o.STATUS = 'S' or om.REGISTRANT_CLASS = 'NM')
					and o.STATUS not like 'C%') a on n.ID = a.ST_ID
	inner join Trans t on n.ID = t.ST_ID and t.PRODUCT_CODE like 'Due%' and t.TRANSACTION_DATE >= '2016-6-23'
where n.status = 'A' and n.member_type not in ('NMI','PROS')
	and COMPANY_RECORD = 0