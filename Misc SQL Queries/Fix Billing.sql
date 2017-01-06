
-Sawida runs the billing on fixed date based on the calender published in advance.

-She sends PDFs for billing records that need correction. Listed below are the queries to fix those billings records with incorrect amounts

-Please also run the bill to company query as well.It is set up as a job so on NJSQLIMIS152 so that we dont lose the qurey: Membill companies update (job name)

-Here is the query:

Update nf
set nf.BT_ID = n.CO_ID
from Name_Fin nf inner join Name n on nf.ID = n.ID
where n.CO_ID in 
(

Select distinct n.CO_ID from
Name n inner join Activity o 
on n.ID = o.ID
where o.OTHER_CODE = 'membill'
and o.thru_date > GETDATE()


)

and n.member_type not in ('pros','proc','nmi','nm','blank','org','usm')


*************PLEASE REMEMBER TO CHANGE THE PAID THRU DATE BELOW TO CORRECT BILLING RECORDS FOR THE MONTHS THEY ARE INCORRECT*************

-----------------------------------------------------------------------------------------------------------------

--Fix billing
--------------------------------------------------------------------------------------------------------------------

Declare @Month date;
set @Month = '8/31/2015';

select n.ID
	, s.PRODUCT_CODE
	, s.BILL_AMOUNT
	, s.PAYMENT_AMOUNT
	, s.BALANCE
	, p.PRICE_1
	, s.BILL_DATE
	, s.PAID_THRU
	,case when n.PAID_THRU >= s.PAID_THRU then 0 else s.PAYMENT_AMOUNT end
	, dateadd(year,1,n.PAID_THRU)
from Subscriptions s
	inner join name n on s.id = n.id
	inner join Product p on s.PRODUCT_CODE = p.PRODUCT_CODE and (s.PRODUCT_CODE = 'DUES' + replace(n.MEMBER_TYPE,'O','') /*or s.PRODUCT_CODE = 'DUES' + replace(n.MEMBER_TYPE,'O','') + '-3'*/)
where n.PAID_THRU = @Month
	--and (s.PRODUCT_CODE = 'DUES' + replace(n.MEMBER_TYPE,'O','') or s.PRODUCT_CODE = 'DUES' + replace(n.MEMBER_TYPE,'O','') + '-3')
	and (not (s.BALANCE + case when n.PAID_THRU >= s.PAID_THRU then 0 else s.PAYMENT_AMOUNT end = p.PRICE_1)  --case when DATEDIFF(month, s.BILL_DATE, n.PAID_THRU) <= 6 then s.PAYMENT_AMOUNT else 0 end = p.PRICE_1) 
		or n.PAID_THRU >= s.PAID_THRU --DATEDIFF(month, s.BILL_DATE, n.PAID_THRU) > 6
		or s.BILL_AMOUNT <> p.PRICE_1)

update s
set s.BILL_AMOUNT = p.PRICE_1
	, s.PAYMENT_AMOUNT = case when n.PAID_THRU >= s.PAID_THRU then 0 else s.PAYMENT_AMOUNT end --case when DATEDIFF(month, s.BILL_DATE, n.PAID_THRU) <= 6 then s.PAYMENT_AMOUNT else 0 end
	, s.BALANCE = p.PRICE_1 - case when n.PAID_THRU >= s.PAID_THRU then 0 else s.PAYMENT_AMOUNT end --case when DATEDIFF(month, s.BILL_DATE, n.PAID_THRU) <= 6 then s.PAYMENT_AMOUNT else 0 end
	, s.BILL_DATE = getdate()
	, s.PAID_THRU = dateadd(year,1,n.PAID_THRU)
from Subscriptions s
	inner join name n on s.id = n.id
	inner join Product p on s.PRODUCT_CODE = p.PRODUCT_CODE and (s.PRODUCT_CODE = 'DUES' + replace(n.MEMBER_TYPE,'O','') /*or s.PRODUCT_CODE = 'DUES' + replace(n.MEMBER_TYPE,'O','') + '-3'*/)
where n.PAID_THRU = @Month
	--and (s.PRODUCT_CODE = 'DUES' + replace(n.MEMBER_TYPE,'O','') or s.PRODUCT_CODE = 'DUES' + replace(n.MEMBER_TYPE,'O','') + '-3')
	and (not (s.BALANCE + case when n.PAID_THRU >= s.PAID_THRU then 0 else s.PAYMENT_AMOUNT end = p.PRICE_1)  --case when DATEDIFF(month, s.BILL_DATE, n.PAID_THRU) <= 6 then s.PAYMENT_AMOUNT else 0 end = p.PRICE_1) 
		or n.PAID_THRU >= s.PAID_THRU --DATEDIFF(month, s.BILL_DATE, n.PAID_THRU) > 6
		or s.BILL_AMOUNT <> p.PRICE_1)