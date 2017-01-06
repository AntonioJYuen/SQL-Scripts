----Each one of the updates contains a begin transaction and commit transaction. If a mistake is made, please execute the command "rollback transaction"
----If the command is successful, be sure to execute the command "commit transaction"

--Data dump to be viewed before correcting reg class
declare @Meeting varchar(max)
Set @Meeting = '2016CC'

select n.id, om.REGISTRANT_CLASS, n.MEMBER_TYPE, ol.PRODUCT_CODE
	, case when ol.PRODUCT_CODE in (@Meeting + '/EX') then 'EX'
		when ol.PRODUCT_CODE in (@Meeting + '/RT',@Meeting + '/RETO') then 'RT'
		when o.TOTAL_PAYMENTS = 0 then 'CP'
		when n.MEMBER_TYPE not in ('NMI','PROS') and n.status = 'A' then 'M'
		else 'NM' end Corrected_Reg_Class
from orders o 
	inner join Order_Meet om on o.ORDER_NUMBER = om.ORDER_NUMBER
	inner join Order_Lines ol on o.ORDER_NUMBER = ol.ORDER_NUMBER
	inner join name n on o.ST_ID = n.ID
	inner join Product p on ol.PRODUCT_CODE = p.PRODUCT_CODE
where meeting = @Meeting
	and om.REGISTRANT_CLASS not in (select REGISTRANT_CLASS from Meet_Reg_Class)
	and o.STATUS not like 'C%'
	--and n.id in (select id from ##temp)


--Update Reg Class

begin transaction

declare @Meeting varchar(max)
Set @Meeting = '2016CC'

update om
set REGISTRANT_CLASS = case when ol.PRODUCT_CODE in (@Meeting + '/EX') then 'EX'
						when ol.PRODUCT_CODE in (@Meeting + '/RT',@Meeting + '/RETO') then 'RT'
						when o.TOTAL_PAYMENTS = 0 then 'CP'
						when n.MEMBER_TYPE not in ('NMI','PROS') and n.status = 'A' then 'M'
						else 'NM' end 
from orders o 
	inner join Order_Meet om on o.ORDER_NUMBER = om.ORDER_NUMBER
	inner join Order_Lines ol on o.ORDER_NUMBER = ol.ORDER_NUMBER
	inner join name n on o.ST_ID = n.ID
	inner join Product p on ol.PRODUCT_CODE = p.PRODUCT_CODE
where meeting = @Meeting
	and om.REGISTRANT_CLASS not in (select REGISTRANT_CLASS from Meet_Reg_Class)
	and o.STATUS not like 'C%'

--commit transaction

-----------Correct Source Code
begin transaction

declare @Meeting varchar(max)
Set @Meeting = '2016CC'

update o
set o.SOURCE_CODE = 'KIOSK'
from orders o
	inner join order_meet om on o.ORDER_NUMBER = om.ORDER_NUMBER
	inner join name n on o.ST_ID = n.ID
where meeting = @Meeting
	and o.SOURCE_CODE not in (select code from Gen_Tables where TABLE_NAME like 'SOURCE_CODE')
	and o.SOURCE_CODE <> ''

--commit transaction
