select dbo.RemoveBreaks(n.COMPANY) Company, year(o.ORDER_DATE) Order_Date, mm.MEETING_TYPE, sum(o.TOTAL_PAYMENTS) Total_Payments
from orders o
	inner join order_meet om on o.ORDER_NUMBER = om.ORDER_NUMBER
	inner join Meet_Master mm on om.MEETING = mm.MEETING
	inner join name n on o.ST_ID = n.ID
	left join name nc on n.CO_ID = nc.ID	
where mm.MEETING_TYPE in ('SPON','EXPO')
	and o.STATUS not like 'C%'
	and (
			isnull(nc.STATE_PROVINCE,n.STATE_PROVINCE) in ('AK','AZ','CA','CO','HI','ID','MT','NV','NM','OR','UT','WA','WY')
			or (isnull(nc.COUNTRY,n.COUNTRY) = 'CANADA' and isnull(nc.STATE_PROVINCE,n.STATE_PROVINCE) in ('AB','BC','NT','SK','YT'))
		)
	and o.ORDER_DATE >= '2014-1-1'
group by n.COMPANY, year(o.ORDER_DATE), mm.MEETING_TYPE
order by year(o.ORDER_DATE), mm.MEETING_TYPE, sum(o.TOTAL_PAYMENTS) desc