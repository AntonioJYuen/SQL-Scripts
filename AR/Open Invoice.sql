Declare @DateTime as Date;
set @DateTime = '2016-12-31'

if OBJECT_ID('tempdb..##Open_Invoices_All') is not null
	drop table ##Open_Invoices_All;

if OBJECT_ID('tempdb..##Open_Invoices_All_Pymts') is not null
	drop table ##Open_Invoices_All_Pymts;

--Invoices ALL
select distinct i.bt_id, n.FULL_NAME, n.COMPANY, i.DESCRIPTION, i.INVOICE_DATE, i.CHARGES, i.BALANCE, i.INVOICE_NUM, i.SOURCE_SYSTEM, i.BATCH_NUM, i.REFERENCE_NUM into ##Open_Invoices_All
from Invoice i
	inner join name n on i.BT_ID = n.id
where i.INVOICE_DATE <= @DateTime
	and not(i.SOURCE_SYSTEM = 'CERTIFY' and i.INVOICE_TYPE = 'PP')
	and i.AR_ACCOUNT <> '1413-0000-00-3'
order by i.BT_ID, i.DESCRIPTION, i.INVOICE_DATE

--Invoices ALL Fix Payments
select sum(t.AMOUNT) SumOfAMOUNT, t.BT_ID, t.INVOICE_REFERENCE_NUM into ##Open_Invoices_All_Pymts
from trans t
	inner join ##Open_Invoices_All o on t.INVOICE_REFERENCE_NUM = o.REFERENCE_NUM
where t.TRANSACTION_TYPE = 'AR' 
	and t.TRANSACTION_DATE > @DateTime 
	and t.INVOICE_CREDITS <> 0
group by t.BT_ID, t.INVOICE_REFERENCE_NUM
having sum(t.amount) <> 0 and t.INVOICE_REFERENCE_NUM <> 0
order by t.INVOICE_REFERENCE_NUM

--Invoices ALL Update for payments
UPDATE a
set a.BALANCE = a.BALANCE - p.SumOfAmount
from ##Open_Invoices_All a
	INNER JOIN ##Open_Invoices_All_Pymts p on a.REFERENCE_NUM = p.INVOICE_REFERENCE_NUM and a.BT_ID = p.BT_ID

--Open Invoices ALL by Invoice Number
select a.BT_ID, a.FULL_NAME, a.COMPANY, a.DESCRIPTION, a.CHARGES, a.BALANCE, DATEDIFF(d,a.INVOICE_DATE, @DateTime) Days_Outstanding
	, case when DATEDIFF(d,a.INVOICE_DATE, @DateTime) < 31 then BALANCE else 0 end as [Current]
	, case when DATEDIFF(d,a.INVOICE_DATE, @DateTime) BETWEEN 31 and 60 then BALANCE else 0 end as [31-60]
	, case when DATEDIFF(d,a.INVOICE_DATE, @DateTime) BETWEEN 61 and 90 then BALANCE else 0 end as [61-90]
	, case when DATEDIFF(d,a.INVOICE_DATE, @DateTime) > 90 then BALANCE else 0 end as [91 & OVER]
	, a.INVOICE_NUM
	, a.SOURCE_SYSTEM
	, a.BATCH_NUM
	, a.REFERENCE_NUM
	, a.INVOICE_DATE
from ##Open_Invoices_All a
where a.BALANCE <> 0