select distinct n.MEMBER_TYPE, s.PRODUCT_CODE -- delete s
from name n
	inner join Subscriptions s on n.id = s.id and s.PRODUCT_CODE like 'DUES%'
where s.PRODUCT_CODE not like 'DUES' + left(n.MEMBER_TYPE,2) + '%'

select * --delete s
from name n
	inner join Subscriptions s on n.id = s.id and (s.PRODUCT_CODE like 'DUES%' or s.PRODUCT_CODE like 'GST')
where n.MEMBER_TYPE like '%O'

select n.id, s.PRODUCT_CODE, s.PAID_THRU, n.PAID_THRU, s.PAYMENT_AMOUNT --delete from s
from name n
	inner join Subscriptions s on n.id = s.id and s.PRODUCT_CODE like 'DUES%-3'
where s.PAYMENT_AMOUNT = 0

select n.id, s.PRODUCT_CODE, s.PAID_THRU, n.PAID_THRU, s.PAYMENT_AMOUNT --delete from s 
from name n
	inner join Subscriptions s on n.id = s.id and s.PRODUCT_CODE like 'DUES%'--%-3'
where n.id in (
			select n.ID
			from name n
				inner join Subscriptions s on n.id = s.id and s.PRODUCT_CODE like 'DUES%'
				group by n.id
			having count(n.id) > 1)
	and n.PAID_THRU >= s.PAID_THRU and s.PAYMENT_AMOUNT = 0--and s.PAID_THRU <= getdate() 