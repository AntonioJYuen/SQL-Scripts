select top 50 o.CO_ID, dbo.RemoveBreaks(n.COMPANY), count(o.ORDER_NUMBER)
from orders o
	inner join order_meet om on o.order_number = om.order_number
	inner join meet_master mm on om.meeting = mm.meeting
	inner join name n on o.CO_ID = n.ID
where mm.begin_date >= '2016-1-1'
	and mm.BEGIN_DATE <= '2016-12-31'
	and o.status not like 'C%'
	and mm.MEETING_TYPE not in ('EXPO','SPON')
	and o.CO_ID <> ''
	and n.MEMBER_TYPE <> 'ORG'
group by o.CO_ID, dbo.RemoveBreaks(n.COMPANY)
order by count(o.ST_ID) desc