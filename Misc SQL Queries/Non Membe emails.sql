select distinct o.EMAIL
from Orders o	
	inner join order_meet om on o.ORDER_NUMBER = om.ORDER_NUMBER
	left join name n on n.ID = o.ST_ID
where 
	--o.order_date >= '2015-1-1'
	--and o.ORDER_DATE <= '2015-12-31'
	om.MEETING = '2016MA'
	and o.MEMBER_TYPE = 'NMI'
	and o.email <> ''
	and o.TOTAL_PAYMENTS > 0

--non members not linked to a company
--suspended members who are not linked to a company or a suspended company
--suspended members who are linked to a active company

--no retailers

--write into the activity that an email reminder was sent to them

--2 weeks after the event is over - send out emails to NMI