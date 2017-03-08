select mm.MEETING, p.INCOME_ACCOUNT, SUBSTRING(p.INCOME_ACCOUNT,6,4)
from Meet_Master mm
	inner join Product p on mm.MEETING = p.PRODUCT_MAJOR
	--inner join Product_Function pf on p.PRODUCT_CODE = pf.PRODUCT_CODE
where p.INCOME_ACCOUNT <> ''

select mm.MEETING, STUFF(
		(
		select distinct ',' + SUBSTRING(p.INCOME_ACCOUNT,6,4)
		from Product p
		where p.PRODUCT_MAJOR = mm.MEETING and p.INCOME_ACCOUNT <> '' and SUBSTRING(p.INCOME_ACCOUNT,6,4) <> '0000'
		for XML Path(''), type
		).value('.', 'nvarchar(max)'), 1, 1, '')
from Meet_Master mm
where mm.BEGIN_DATE between '2016-1-1' and '2016-12-31'
	and mm.MEETING = '2016RECON'

select *
from Gen_Tables
where TABLE_NAME like 'gl_account'
	and code like '%9951%'