begin transaction

delete s
from Subscriptions s
	inner join product p on s.PRODUCT_CODE = p.PRODUCT_CODE
where s.BILL_AMOUNT <> p.PRICE_1
	and s.PRODUCT_CODE like 'DUES%'

commit transaction