declare @ShowAll as int

set @ShowAll = 0

select n.id
	, n.FIRST_NAME
	, n.LAST_NAME
	, n.FULL_NAME
	, n.EMAIL
	, cast(cast(year(getdate())-2 as varchar) + '-1-1' as date) Begin_Date
	, cast(GETDATE() as date) as Today
	, sum(c.UNITS) Total_CE_Credits
from icsc_Cert_meetingsCEU c
	inner join name n on c.ID = n.ID
where c.UNITS > 0
	and n.COMPANY_RECORD = 0
	and c.ID in (select distinct STUDENT_ID
				from Cert_Register
				where GOOD_THRU_DATE > getdate())
group by n.id, n.FIRST_NAME, n.LAST_NAME, n.FULL_NAME, n.EMAIL
having sum(c.units) >= case when @ShowAll = 0 then 10 else 0 end
order by sum(c.units) desc