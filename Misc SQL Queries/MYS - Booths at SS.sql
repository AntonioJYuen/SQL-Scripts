select o.ST_ID COID, dbo.RemoveBreaks(o.COMPANY) COMPANY
	, o.ADDRESS_1, o.ADDRESS_2, o.CITY, o.STATE_PROVINCE
	, o.ZIP, o.COUNTRY, o.PHONE, o.FAX, o.EMAIL ContactEmail
	, o.FIRST_NAME, o.LAST_NAME, n.EMAIL CompanyEmail
	, o.MEMBER_TYPE, o.STATUS MEMBER_STATUS
	, n2.PAID_THRU, ol.PRODUCT_CODE, ol.DESCRIPTION
	, ol.QUANTITY_ORDERED, ol.UNIT_PRICE, o.TOTAL_PAYMENTS
	, o.BALANCE
from orders o
	inner join order_meet om on o.ORDER_NUMBER = om.ORDER_NUMBER
	left join name n on o.CO_ID = n.id
	inner join name n2 on o.ST_ID = n2.ID
	inner join order_lines ol on o.ORDER_NUMBER = ol.ORDER_NUMBER
where om.MEETING = 'SPREE2016'
	and o.STATUS not like 'C%'