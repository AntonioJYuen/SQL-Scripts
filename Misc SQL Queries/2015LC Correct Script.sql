select n.id into ##temp3
from orders o 
	inner join Order_Meet om on o.ORDER_NUMBER = om.ORDER_NUMBER
	inner join Order_Lines ol on o.ORDER_NUMBER = ol.ORDER_NUMBER
	inner join name n on o.ST_ID = n.ID
	inner join Product p on ol.PRODUCT_CODE = p.PRODUCT_CODE
where meeting = '2015LC'
	and om.REGISTRANT_CLASS not in (select REGISTRANT_CLASS from Meet_Reg_Class)
	and o.STATUS not like 'C%'

select n.id, om.REGISTRANT_CLASS, n.MEMBER_TYPE, ol.PRODUCT_CODE
	, case when n.MEMBER_TYPE not in ('PROS','NMI') and n.STATUS = 'A' then 'M'
		else 'NM' end Corrected_Reg_Class
from orders o 
	inner join Order_Meet om on o.ORDER_NUMBER = om.ORDER_NUMBER
	inner join Order_Lines ol on o.ORDER_NUMBER = ol.ORDER_NUMBER
	inner join name n on o.ST_ID = n.ID
	inner join Product p on ol.PRODUCT_CODE = p.PRODUCT_CODE
where meeting = '2015LC'
	--and om.REGISTRANT_CLASS not in (select REGISTRANT_CLASS from Meet_Reg_Class)
	and o.STATUS not like 'C%'
	and n.id in (select id from ##temp3)

begin transaction

update om
set REGISTRANT_CLASS = case when n.MEMBER_TYPE not in ('PROS','NMI') and n.STATUS = 'A' then 'M'
		else 'NM' end
from orders o 
	inner join Order_Meet om on o.ORDER_NUMBER = om.ORDER_NUMBER
	inner join Order_Lines ol on o.ORDER_NUMBER = ol.ORDER_NUMBER
	inner join name n on o.ST_ID = n.ID
	inner join Product p on ol.PRODUCT_CODE = p.PRODUCT_CODE
where meeting = '2015LC'
	and om.REGISTRANT_CLASS not in (select REGISTRANT_CLASS from Meet_Reg_Class)
	and o.STATUS not like 'C%'

--commit transaction

---------Correct Source Code
begin transaction

update o
set o.SOURCE_CODE = 'KIOSK'
from orders o
	inner join order_meet om on o.ORDER_NUMBER = om.ORDER_NUMBER
	inner join name n on o.ST_ID = n.ID
where meeting = '2015LC'
	and o.SOURCE_CODE not in (select code from Gen_Tables where TABLE_NAME like 'SOURCE_CODE')
	and o.SOURCE_CODE <> ''

--commit transaction

select n.id into ##temp4
from orders o
	inner join order_meet om on o.ORDER_NUMBER = om.ORDER_NUMBER
	inner join name n on o.ST_ID = n.ID
where meeting = '2015LC'
	and o.SOURCE_CODE not in (select code from Gen_Tables where TABLE_NAME like 'SOURCE_CODE')
	and o.SOURCE_CODE <> ''

select id, o.SOURCE_CODE
from orders o
	inner join order_meet om on o.ORDER_NUMBER = om.ORDER_NUMBER
	inner join name n on o.ST_ID = n.ID
where meeting = '2015LC'
	--and o.SOURCE_CODE not in (select code from Gen_Tables where TABLE_NAME like 'SOURCE_CODE')
	and o.SOURCE_CODE <> ''
	and n.id in (select id from ##temp4)