select distinct TITLE
from name
where (title like 'Chief%'
	or title like '%CEO%'
	or (title like '%CIO%' and TITLE not like '%acion%' and TITLE not like '%ccion%' and TITLE not like '%icio%' and TITLE not like '%sócio%' and TITLE not like '%socio%')
	or (title like '%CTO%' and TITLE not like '%Direct%' and TITLE not like '%Instructor%' and TITLE not like '%ecto%')
	or title like '%CMO%'
	or (title like '%CCO%' and TITLE not like '%Acco%')
	or title like '%CDO%'
	or (title like '%COO%' and TITLE not like '%Coord%')
	or title like '%CPO%'
	or title like '%CRO%'
	or title like '%CXO%')
	and TITLE not like '%Assistant%'
	and TITLE not like '%Asisten%'
	and TITLE not like '%Associate%'
	and TITLE not like '%Contractor%'
	and TITLE not like '%Actor%'