select year(mm.BEGIN_DATE) Meet_Year
	, sum(case when o.SOURCE_CODE = 'W_Meetings' then 1 else 0 end) Web_Reg
	, sum(case when o.SOURCE_CODE = 'W_Meetings' then 1 else 0 end)/cast(count(o.SOURCE_CODE) as decimal) Web_Percent
	, sum(case when o.SOURCE_CODE = 'Kiosk' then 1 else 0 end) Kiosk_Reg
	, sum(case when o.SOURCE_CODE = 'Kiosk' then 1 else 0 end)/cast(count(o.SOURCE_CODE) as decimal) Kiosk_Percent
	, sum(case when o.ORDER_DATE < mm.BEGIN_DATE and o.SOURCE_CODE not in ('W_Meetings','Kiosk') then 1 else 0 end) Backend_Reg
	, sum(case when o.ORDER_DATE < mm.BEGIN_DATE and o.SOURCE_CODE not in ('W_Meetings','Kiosk') then 1 else 0 end)/cast(count(o.SOURCE_CODE) as decimal) Backend_Percent
	, sum(case when o.ORDER_DATE >= mm.BEGIN_DATE and o.SOURCE_CODE not in ('W_Meetings','Kiosk') then 1 else 0 end) Onsite_Reg
	, sum(case when o.ORDER_DATE >= mm.BEGIN_DATE and o.SOURCE_CODE not in ('W_Meetings','Kiosk') then 1 else 0 end)/cast(count(o.SOURCE_CODE) as decimal) Onsite_Percent
	, count(o.SOURCE_CODE) Total
from orders o
	inner join order_meet om on o.ORDER_NUMBER = om.ORDER_NUMBER
	inner join Meet_Master mm on om.meeting = mm.meeting
where om.meeting in (
				select meeting
				from meet_master mm
				where mm.MEETING_TYPE not in ('SPON','EXPO','COMM')
					and mm.BEGIN_DATE >= '2000-1-1'
					and mm.BEGIN_DATE <= '2016-12-31')
	and o.status not like 'C%'
group by year(mm.begin_date)
order by year(mm.begin_date)