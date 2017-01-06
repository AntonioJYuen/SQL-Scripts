select a.DESCRIPTION, year(a.EFFECTIVE_DATE) StartYear, year(a.THRU_DATE) EndYear, n.FULL_NAME, n.FIRST_NAME, n.LAST_NAME, dbo.RemoveBreaks(n.COMPANY) Company, na.ADDRESS_1, na.ADDRESS_2, na.ADDRESS_3, na.CITY, na.STATE_PROVINCE, na.ZIP, na.COUNTRY
from name n
	inner join Name_Address na on n.id = na.id and na.PREFERRED_MAIL = 1
	inner join Activity a on n.id = a.ID
where a.PRODUCT_CODE in ('COMMITTEE/FD Canada Bod')
	and THRU_DATE >= '2016-1-1'

union

select a.DESCRIPTION, year(a.EFFECTIVE_DATE) StartYear, year(a.THRU_DATE) EndYear, n.FULL_NAME, n.FIRST_NAME, n.LAST_NAME, dbo.RemoveBreaks(n.COMPANY) Company, na.ADDRESS_1, na.ADDRESS_2, na.ADDRESS_3, na.CITY, na.STATE_PROVINCE, na.ZIP, na.COUNTRY
from name n
	inner join Name_Address na on n.id = na.id and na.PREFERRED_MAIL = 1
	inner join Activity a on n.id = a.ID
where a.PRODUCT_CODE in ('COMMITTEE/FD Bd Directors')
	and THRU_DATE >= '2015-1-1'

union

select a.DESCRIPTION, year(a.EFFECTIVE_DATE) StartYear, year(a.THRU_DATE) EndYear, n.FULL_NAME, n.FIRST_NAME, n.LAST_NAME, dbo.RemoveBreaks(n.COMPANY) Company, na.ADDRESS_1, na.ADDRESS_2, na.ADDRESS_3, na.CITY, na.STATE_PROVINCE, na.ZIP, na.COUNTRY
from name n
	inner join Name_Address na on n.id = na.id and na.PREFERRED_MAIL = 1
	inner join Activity a on n.id = a.ID
where a.PRODUCT_CODE in ('COMMITTEE/FD Comm Support','COMMITTEE/FD Development','COMMITTEE/FD Eisenberg','COMMITTEE/FD JTR Recip','COMMITTEE/FD GAP','COMMITTEE/FD Fiala','COMMITTEE/FD Grossman'
						,'COMMITTEE/FD Jll','COMMITTEE/FD Menino','COMMITTEE/FD Scholarshio','COMMITTEE/FD Schurgin','COMMITTEE/FD Undergrad')
	and THRU_DATE <= '2016-12-31'
	and THRU_DATE >= '2015-1-1'

union

select mm.TITLE, year(mm.BEGIN_DATE) StartYear, year(mm.END_DATE) EndYear, n.FULL_NAME, n.FIRST_NAME, n.LAST_NAME, dbo.RemoveBreaks(n.COMPANY) Company, na.ADDRESS_1, na.ADDRESS_2, na.ADDRESS_3, na.CITY, na.STATE_PROVINCE, na.ZIP, na.COUNTRY
from Meet_Master mm
	inner join Order_Meet om on mm.MEETING = om.MEETING
	inner join orders o on om.ORDER_NUMBER = o.ORDER_NUMBER
	inner join name n on o.ST_ID = n.ID
	inner join Name_Address na on n.ID = na.ID and na.PREFERRED_MAIL = 1
where mm.MEETING in ('2015drs','2015fdlv')
	and o.STATUS not like 'C%'