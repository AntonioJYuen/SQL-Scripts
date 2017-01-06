select case when n.COMPANY_RECORD = 1 then n.id else n.CO_ID end COMPANY_ID, o.ST_ID
	, n.COMPANY
	, (select sum(ol.QUANTITY_ORDERED * pf.EXPECTED_ATTENDANCE)
		from order_lines ol
			inner join Product_Function pf on ol.PRODUCT_CODE = pf.PRODUCT_CODE
		where o.order_number = ol.order_number) Sq_Ft
	, o.TOTAL_PAYMENTS
	, (select count(n2.ID)
		from name n2
			inner join orders o2 on n2.ID = o2.ST_ID
			inner join order_meet om2 on o2.ORDER_NUMBER = om2.ORDER_NUMBER
			inner join meet_master mm2 on om2.MEETING = mm2.MEETING
		where mm2.meeting = '2015EDM'
			and o2.STATUS not like 'C%'
			and n2.co_id = case when n.COMPANY_RECORD = 1 then n.id else n.CO_ID end
			and o2.TOTAL_PAYMENTS > 0) Paid_Attendees
	, (select count(n2.ID)
		from name n2
			inner join orders o2 on n2.ID = o2.ST_ID
			inner join order_meet om2 on o2.ORDER_NUMBER = om2.ORDER_NUMBER
			inner join meet_master mm2 on om2.MEETING = mm2.MEETING
		where mm2.meeting = '2015EDM'
			and o2.STATUS not like 'C%'
			and n2.co_id = case when n.COMPANY_RECORD = 1 then n.id else n.CO_ID end
			and o2.TOTAL_PAYMENTS = 0) Unpaid_Attendees
	, (select isnull(sum(o2.TOTAL_PAYMENTS),0)
		from name n2
			inner join orders o2 on n2.ID = o2.ST_ID
			inner join order_meet om2 on o2.ORDER_NUMBER = om2.ORDER_NUMBER
			inner join meet_master mm2 on om2.MEETING = mm2.MEETING
		where mm2.meeting = '2015EDM'
			and o2.STATUS not like 'C%'
			and n2.co_id = case when n.COMPANY_RECORD = 1 then n.id else n.CO_ID end
			and o2.TOTAL_PAYMENTS > 0) Attendee_Payments
from name n
	inner join orders o on n.ID = o.ST_ID
	inner join order_meet om on o.ORDER_NUMBER = om.ORDER_NUMBER
	inner join meet_master mm on om.MEETING = mm.MEETING
where mm.meeting = 'EDM2015'
	and o.STATUS not like 'C%'


--select count(n.ID)
--from name n
--	inner join orders o on n.ID = o.ST_ID
--	inner join order_meet om on o.ORDER_NUMBER = om.ORDER_NUMBER
--	inner join meet_master mm on om.MEETING = mm.MEETING
--where mm.meeting = '2015EDM'
--	and o.STATUS not like 'C%'
--	and n.co_id in (select distinct case when n.COMPANY_RECORD = 1 then n.id else n.CO_ID end COMPANY_ID
--				from name n
--					inner join orders o on n.ID = o.ST_ID
--					inner join order_meet om on o.ORDER_NUMBER = om.ORDER_NUMBER
--					inner join meet_master mm on om.MEETING = mm.MEETING
--				where mm.meeting = 'EDM2015'
--					and o.STATUS not like 'C%')

--1.	List of companies who exhibited
--2.	Size of their booth and amount paid
--3.	Number of registrants under the exhibiting companies
--a.	Paid + amount paid
--b.	Non paid
