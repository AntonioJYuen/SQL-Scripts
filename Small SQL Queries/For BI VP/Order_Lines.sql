select *
from Order_Lines ol
where ol.ORDER_NUMBER in (select o.ORDER_NUMBER from orders o where order_date >= '2016-1-1')