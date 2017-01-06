select id, REGISTRANT_CLASS, MEMBER_TYPE, Corrected_Reg_Class, count(id) Num
from (
	select n.id, om.REGISTRANT_CLASS, n.MEMBER_TYPE
		, case when ol.PRODUCT_CODE in ('2015CC/OP8','2015CC/OP9','2015CC/OP10','2015CC/RETO') then 'EX'
			when ol.PRODUCT_CODE in ('2015CC/RT') then 'CP'
			--when sum(ol.UNIT_PRICE) = 0 then 'CP'
			when n.MEMBER_TYPE not in ('NMI','PROS') then 'M'
			else 'NM' end Corrected_Reg_Class
	from orders o 
		inner join Order_Meet om on o.ORDER_NUMBER = om.ORDER_NUMBER
		inner join Order_Lines ol on o.ORDER_NUMBER = ol.ORDER_NUMBER
		inner join name n on o.ST_ID = n.ID
		inner join Product p on ol.PRODUCT_CODE = p.PRODUCT_CODE
	where meeting = '2015CC'
		and om.REGISTRANT_CLASS not in (select REGISTRANT_CLASS from Meet_Reg_Class)
	--group by n.id, om.REGISTRANT_CLASS, n.MEMBER_TYPE, ol.PRODUCT_CODE, p.PRODUCT_CODE
) a
group by id, REGISTRANT_CLASS, MEMBER_TYPE, Corrected_Reg_Class
order by count(id) desc