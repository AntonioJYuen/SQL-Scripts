--Year by Year

select MEETING, SUM(Total_Attendees) Total_Attendees, sum(case when Returning_Attendees > 0 then 1 else 0 end) Returning_Attendees
	, SUM(Total_Attendees) - sum(case when Attended_Before > 0 then 1 else 0 end) First_Time_Attendees
from(
	select o.ST_ID, mm.MEETING, count(a.ST_ID) Returning_Attendees, count(distinct o.st_id) as Total_Attendees, count(b.ST_ID) Attended_Before
	from meet_master mm
		inner join Order_Meet om on mm.MEETING = om.MEETING
		inner join Orders o on om.ORDER_NUMBER = o.ORDER_NUMBER and o.STATUS not like 'C%'
		inner join Order_Lines ol on o.ORDER_NUMBER = ol.ORDER_NUMBER and ol.QUANTITY_ORDERED > 0 and ol.PRODUCT_CODE like '%OA/FP%'
		left join (select distinct o2.ST_ID, mm2.MEETING, mm2.BEGIN_DATE
				from meet_master mm2
				inner join Order_Meet om2 on mm2.MEETING = om2.MEETING
				inner join Orders o2 on om2.ORDER_NUMBER = o2.ORDER_NUMBER and o2.STATUS not like 'C%'
				inner join Order_Lines ol2 on o2.ORDER_NUMBER = ol2.ORDER_NUMBER and ol2.QUANTITY_ORDERED > 0 and ol2.PRODUCT_CODE like '%OA/FP%'
				where mm2.MEETING like '%[0-9]OA'
				) a on o.ST_ID = a.ST_ID and year(mm.BEGIN_DATE) - 1 = year(a.BEGIN_DATE)
		left join (select distinct o3.ST_ID, mm3.MEETING, mm3.BEGIN_DATE
				from meet_master mm3
				inner join Order_Meet om3 on mm3.MEETING = om3.MEETING
				inner join Orders o3 on om3.ORDER_NUMBER = o3.ORDER_NUMBER and o3.STATUS not like 'C%'
				inner join Order_Lines ol3 on o3.ORDER_NUMBER = ol3.ORDER_NUMBER and ol3.QUANTITY_ORDERED > 0 and ol3.PRODUCT_CODE like '%OA/FP%'
				where mm3.MEETING like '%[0-9]OA'
				) b on o.ST_ID = b.ST_ID and year(mm.BEGIN_DATE) > year(b.BEGIN_DATE)
	where mm.MEETING like '%[0-9]OA'
	group by o.ST_ID, mm.MEETING
) b
group by MEETING
order by cast(left(MEETING,4) as int) desc