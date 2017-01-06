declare @StartDate date
declare @EndDate date

set @StartDate = '2015-1-1'
set @EndDate = '2015-12-31'

select TRANSACTION_DATE, TRANSACTION_TYPE, ST_ID, PRODUCT_CODE, AMOUNT*-1 Amount
from Trans
where product_code like '%credit'
	and TRANSACTION_DATE >= @StartDate
	and TRANSACTION_DATE <= @EndDate