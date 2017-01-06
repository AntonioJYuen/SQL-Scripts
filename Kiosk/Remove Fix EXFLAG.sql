--Delete EXFLAG
begin transaction

delete
from Order_Lines
where PRODUCT_CODE like '%EXFLAG'

commit transaction

--Fix number lines on Orders
select o.ORDER_NUMBER, o.NUMBER_LINES, a.line_number
from orders o
	inner join (select o.ORDER_NUMBER, o.NUMBER_LINES, max(ol.line_number) line_number
				from orders o
					inner join order_lines ol on o.order_number = ol.ORDER_NUMBER
				group by o.ORDER_NUMBER, o.NUMBER_LINES
				having o.NUMBER_LINES <> max(ol.line_number)
					and max(ol.line_number) < 10
				) a on o.ORDER_NUMBER = a.ORDER_NUMBER

begin transaction

update o
set o.NUMBER_LINES = a.line_number
from orders o
	inner join (select o.ORDER_NUMBER, o.NUMBER_LINES, max(ol.line_number) line_number
				from orders o
					inner join order_lines ol on o.order_number = ol.ORDER_NUMBER
				group by o.ORDER_NUMBER, o.NUMBER_LINES
				having o.NUMBER_LINES <> max(ol.line_number)
					and max(ol.line_number) < 10
				) a on o.ORDER_NUMBER = a.ORDER_NUMBER

commit transaction