Declare @Paid_Thru as date
set @Paid_Thru = (dateadd(month, 3, dateadd(month, datediff(MONTH, 0, getdate()), 0)) - 1)

--select dateadd(month, 3, dateadd(month, datediff(MONTH, 0, getdate()), 0)) - 1

------Delete mismatching DUES----

--select n.id, n.MEMBER_TYPE, s.PRODUCT_CODE
--from name n
--	inner join Subscriptions s on n.id = s.id
--where n.status = 'A'
--	and n.MEMBER_TYPE not in ('NMI','PROS')
--	and s.PRODUCT_CODE like 'DUES%'
--	and n.member_type not like '%U'
--	and s.product_code not like '%' + n.MEMBER_TYPE + '%' 
--	and s.PRODUCT_CODE not like n.member_type + '%-3'
--	and datediff(MONTH,n.PAID_THRU,@PAID_THRU) in (0, 2, 3)

--select n.id, n.member_type, s.product_code
--from name n
--	left join Subscriptions s on n.id = s.ID
--where n.id = '1000973'

----begin transaction

----delete from s
----from name n
----	inner join Subscriptions s on n.id = s.id
----where n.status = 'A'
----	and n.MEMBER_TYPE not in ('NMI','PROS')
----	and s.PRODUCT_CODE like 'DUES%'
----	and n.member_type not like '%U'
----	and s.product_code not like '%' + n.MEMBER_TYPE + '%' 
----	and s.PRODUCT_CODE not like n.member_type + '%-3'
----	and datediff(MONTH,n.PAID_THRU,@PAID_THRU) in (0, 2, 3)

------rollback transaction
------commit transaction


------Delete 3 Year Dues----

--select n.id, n.member_type, s.PRODUCT_CODE, s.PAID_THRU
--from name n
--	inner join Subscriptions s on n.id = s.ID
--where n.status = 'A'
--	and n.MEMBER_TYPE not in ('NMI','PROS')
--	and s.PRODUCT_CODE like 'DUES%-3'
--	and s.PAID_THRU < getdate()
--	and datediff(MONTH,n.PAID_THRU,@PAID_THRU) in (0, 2, 3)

--select n.id, n.member_type, s.product_code
--from name n
--	left join Subscriptions s on n.id = s.ID
--where n.id = '1463979'

----begin transaction

----delete from s
----from name n
----	inner join Subscriptions s on n.id = s.id
----where n.status = 'A'
----	and n.MEMBER_TYPE not in ('NMI','PROS')
----	and s.PRODUCT_CODE like 'DUES%-3'
----	and s.PAID_THRU < getdate()
----	and datediff(MONTH,n.PAID_THRU,@PAID_THRU) in (0, 2, 3)

------rollback transaction
------commit transaction

----Insert new records----

insert into Subscriptions (id, bt_id, PRODUCT_CODE, PROD_TYPE, STATUS, BEGIN_DATE, PAID_THRU, COPIES, CONTINUOUS_SINCE, PRIOR_YEARS, FUTURE_COPIES, PREF_MAIL, PREF_BILL, RENEW_MONTHS, PREVIOUS_BALANCE, BILL_DATE, REMINDER_DATE, REMINDER_COUNT, BILL_BEGIN, BILL_THRU, BILL_AMOUNT, BILL_COPIES, PAYMENT_AMOUNT, COPIES_PAID, ADJUSTMENT_AMOUNT, LTD_PAYMENTS, BALANCE, DATE_ADDED, LAST_UPDATED, UPDATED_BY, BILL_TYPE, COMPLIMENTARY, FUTURE_CREDITS, INVOICE_REFERENCE_NUM, INVOICE_LINE_NUM, IS_FR_ITEM, FAIR_MARKET_VALUE)

select n.id, n.id, p.PRODUCT_CODE, 'DUES', 'A', dateadd(day,1,n.paid_thru), dateadd(year,1,n.paid_thru), 1, dateadd(day,1,n.paid_thru), 0, 0, 0, 0, 0, 0, cast(getdate() as date), cast(getdate() as date), 1, dateadd(day,1,n.paid_thru), dateadd(year,1,n.paid_thru), p.PRICE_1, 1, 0, 0, 0, 0, p.PRICE_1, getdate(), getdate(), 'BILLSCRIPT', 'M', 0, 0, 0, 0, 0, 0
from name n
	inner join product p on 'DUES' + n.MEMBER_TYPE = p.PRODUCT_CODE
	inner join Demographics d on n.id = d.id
	left join Subscriptions s on n.id = s.ID and s.PRODUCT_CODE like 'DUES%' and s.PRODUCT_CODE not like 'DUES%-3'
where n.status = 'A' 
	and s.id is null
	and datediff(MONTH,n.PAID_THRU,@PAID_THRU) in (0, 2, 3)
	and d.PROMO_SOURCE not like '%memb'