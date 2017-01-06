begin transaction

declare @MeetingCode as varchar(10)
declare @ExpoCode as varchar(10)

set @MeetingCode = '2016TX'
set @ExpoCode = 'TX2016'

if OBJECT_ID('tempdb..##Meet_Order_Nums') is not null 
	drop table ##Meet_Order_Nums

--Load IDs into a temp table
SELECT distinct o.ORDER_NUMBER into ##Meet_Order_Nums
FROM      Orders AS O INNER JOIN
				Order_Meet AS OM ON O.ORDER_NUMBER = OM.ORDER_NUMBER INNER JOIN
				Order_Lines AS OL ON O.ORDER_NUMBER = OL.ORDER_NUMBER
WHERE     (NOT (O.STATUS LIKE 'C%')) AND (OL.PRODUCT_CODE IN (@MeetingCode + '/FP',@MeetingCode + '/EX')) AND (OL.QUANTITY_ORDERED > 0) AND (OM.MEETING = @MeetingCode) AND O.CO_ID in

(SELECT     O.ST_ID as COID
FROM       Orders as O INNER JOIN
					Order_Meet as OM ON O.ORDER_NUMBER = OM.ORDER_NUMBER
WHERE     (OM.MEETING = @ExpoCode) AND (NOT (O.STATUS LIKE 'c%'))
UNION
SELECT     O.CO_ID as COID
FROM        Orders as O INNER JOIN
					Order_Meet as OM ON O.ORDER_NUMBER = OM.ORDER_NUMBER INNER JOIN
					Order_Lines as OL ON O.ORDER_NUMBER = OL.ORDER_NUMBER
WHERE     (OL.PRODUCT_CODE = @MeetingCode + '/RTROW' AND OL.QUANTITY_ORDERED > 0) AND (NOT (O.STATUS LIKE 'c%')))
and OM.REGISTRANT_CLASS <> 'ST'

--Insert the EXFLAG function into orders
insert into order_lines (order_number, LINE_NUMBER, product_code, description, quantity_ordered, NOTE)

select ORDER_NUMBER, max(LINE_NUMBER) + 1, @MeetingCode + '/EXFLAG', 'Flag for Exhibitors for Security Purpose', 1, ''
from Order_Lines
where ORDER_NUMBER in (
		select ORDER_NUMBER from ##Meet_Order_Nums
)
and ORDER_NUMBER not in (select ORDER_NUMBER from Order_Lines where PRODUCT_CODE = @MeetingCode + '/EXFLAG')
group by ORDER_NUMBER

--Update the number_lines on the order table
update o
set o.NUMBER_LINES = ol.Line_Number
from orders o
	inner join order_meet om on o.ORDER_NUMBER = om.ORDER_NUMBER
	inner join (select order_number, max(LINE_NUMBER) Line_Number from Order_Lines group by ORDER_NUMBER) ol on o.ORDER_NUMBER = ol.ORDER_NUMBER
where o.ORDER_NUMBER in (select ORDER_NUMBER from ##Meet_Order_Nums)

select o.NUMBER_LINES, ol.*
from orders o
	inner join Order_Lines ol on o.ORDER_NUMBER = ol.ORDER_NUMBER
where ol.PRODUCT_CODE = @MeetingCode + '/EXFLAG'

commit transaction

select o.ORDER_NUMBER
from orders o
	inner join order_meet om on o.ORDER_NUMBER = om.ORDER_NUMBER
	inner join (select order_number, max(LINE_NUMBER) Line_Number from Order_Lines group by ORDER_NUMBER) ol on o.ORDER_NUMBER = ol.ORDER_NUMBER
where o.ORDER_NUMBER in (select ORDER_NUMBER from ##Meet_Order_Nums)

select o.ORDER_NUMBER
from orders o
	inner join Order_Lines ol on o.ORDER_NUMBER = ol.ORDER_NUMBER
	inner join order_meet om on o.ORDER_NUMBER = om.ORDER_NUMBER
where om.MEETING = @MeetingCode
group by o.ORDER_NUMBER ,o.NUMBER_LINES
having o.NUMBER_LINES <> max(ol.line_number)