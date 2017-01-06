select convert(varchar(6), n.join_date, 112), count(n.id)
from name n
	inner join Demographics d on n.id = d.ID and n.JOIN_DATE <> isnull(d.REJOIN_DATE,'1990-1-1')
where n.JOIN_DATE >= '2013-1-1'
	and n.JOIN_DATE <= '2015-12-31'
	and n.COUNTRY in ('United States')
group by convert(varchar(6), n.join_date, 112)
order by convert(varchar(6), n.join_date, 112)