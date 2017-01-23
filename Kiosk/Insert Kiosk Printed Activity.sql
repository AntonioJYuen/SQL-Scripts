
begin transaction

insert into Kiosk_Order_Badge_Printed(ORDER_NUMBER,BADGE_NUMBER,PRINTED, PRINT_DATE, NEW_FUNCTIONS_EXIST)
select o.ORDER_NUMBER, 1, 1, getdate(), 0
from orders o
	inner join order_meet om on o.order_number = om.order_number
where om.MEETING = '2017BC'
	and o.CO_ID in (1003319,1267608,1650225,1018152,1051399,1365261,1044094,1000970,1364214,1134843,1263891,1423374,1017895,1223185,1023335,1005971,1023986)
	and o.STATUS not like 'C%'

select *
from Kiosk_Order_Badge_Printed
where ORDER_NUMBER in (select o.ORDER_NUMBER
			from orders o
				inner join order_meet om on o.order_number = om.order_number
			where om.MEETING = '2017BC'
				and o.CO_ID in (1003319,1267608,1650225,1018152,1051399,1365261,1044094,1000970,1364214,1134843,1263891,1423374,1017895,1223185,1023335,1005971,1023986)
				and o.STATUS not like 'C%')

commit transaction