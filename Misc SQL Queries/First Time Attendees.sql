declare @meetingCode varchar(4)
declare @yearStart int

set @meetingCode = 'OA'
set @yearStart = 2011

select n.id, n.first_name, n.last_name, n.full_name, dbo.removebreaks(n.COMPANY) Company, n.MEMBER_TYPE, isnull(p.DESCRIPTION,'') Primary_Business
	, isnull(f.DESCRIPTION,'') Functional_Title
	, max(case when om.meeting = '2011OA' then 1 else 0 end) [2011OA]
	, max(case when om.meeting = '2012OA' then 1 else 0 end) [2012OA]
	, max(case when om.meeting = '2013OA' then 1 else 0 end) [2013OA]
	, max(case when om.meeting = '2014OA' then 1 else 0 end) [2014OA]
	, max(case when om.meeting = '2015OA' then 1 else 0 end) [2015OA]
	, max(case when om.meeting = '2016OA' then 1 else 0 end) [2016OA]
from orders o
	inner join order_meet om on o.order_number = om.order_number
	inner join name n on o.ST_ID = n.ID
	inner join Demographics d on n.id = d.id
	left join icsc_PrimaryBusiness p on d.PRIM_BUS_CODE = p.CODE --Primary Business View
	left join icsc_FunctionalTitle f on n.FUNCTIONAL_TITLE = f.CODE --Functional Title View
	left join (select o2.st_id, om2.meeting
				from orders o2
				inner join order_meet om2 on o2.ORDER_NUMBER = om2.ORDER_NUMBER
				where om2.MEETING like '____' + @meetingCode) a on o.ST_ID = a.ST_ID and cast(left(om.meeting,4) as int) > cast(left(a.meeting,4) as int) --All OAC that the attendee attended in the past
where om.meeting like '____' + @meetingCode
	and cast(left(om.meeting,4) as int) >= @yearStart --All OAC attendees after 2011
	and a.MEETING is null --Remove all individuals who attended an OAC
group by n.id, n.first_name, n.last_name, n.full_name, dbo.removebreaks(n.COMPANY), n.MEMBER_TYPE, isnull(p.DESCRIPTION,''), isnull(f.DESCRIPTION,'')