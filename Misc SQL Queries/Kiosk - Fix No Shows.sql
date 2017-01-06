select o.ST_ID, om.MEETING, k.PRINT_DATE, om.UF_3
	, case when k.PRINT_DATE is null then 1 else 0 end uf_3v2
from orders o	
	inner join order_meet om on o.ORDER_NUMBER = om.ORDER_NUMBER
	left join Kiosk_Order_Badge_Printed k on o.ORDER_NUMBER = k.ORDER_NUMBER
where om.meeting = '2016EOS'
	and k.PRINT_DATE is null
	and o.status not like 'C%'

begin transaction

update om
set om.UF_3 = case when k.PRINT_DATE is null then 1 else 0 end
from orders o	
	inner join order_meet om on o.ORDER_NUMBER = om.ORDER_NUMBER
	left join Kiosk_Order_Badge_Printed k on o.ORDER_NUMBER = k.ORDER_NUMBER
where om.meeting = '2016N1'
	and k.PRINT_DATE is null
	and o.status not like 'C%'

rollback transaction
commit transaction