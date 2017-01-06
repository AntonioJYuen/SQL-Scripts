select p.TITLE [Committee Title], p.PRODUCT_MINOR [Committee Code], c.TITLE [Committee Title], p.GROUP_3, a.PRODUCT_CODE, n.id, n.COMPANY, n.LAST_NAME, n.FIRST_NAME, n.FULL_NAME, a.OTHER_CODE, a.THRU_DATE
from Activity a
	inner join name n on a.ID = n.ID
	left join Committee_Position c on a.ACTION_CODES = c.POSITION_CODE
	left join Product p on a.PRODUCT_CODE = p.PRODUCT_CODE
where a.ACTIVITY_TYPE = 'COMMITTEE'
	and a.THRU_DATE >= cast(getdate() as date)
	and year(a.THRU_DATE) <> 2099
order by a.PRODUCT_CODE, n.LAST_FIRST

--name effective date and term date for ambassadors
select n.FIRST_NAME, n.LAST_NAME, n.FULL_NAME, n.TITLE, na.STATE_PROVINCE, a.EFFECTIVE_DATE, a.THRU_DATE
	, round(cast(DATEDIFF(d,a.EFFECTIVE_DATE, a.THRU_DATE) as float)/cast(365 as float)*12,0) Months_Active
	, n.HOME_PHONE, n.WORK_PHONE
from Activity a
	inner join name n on a.id = n.id
	inner join Name_Address na on n.id = na.id and na.PREFERRED_MAIL = 1
where activity_type = 'committee'
	and product_code = 'COMMITTEE/AMBASSADORS'
	and a.THRU_DATE > getdate()

--2.	A list of all Non Member Event Attendees (NMEA) from 1/1/15 to 12/31/15.
select n.id, n.FIRST_NAME, n.LAST_NAME, n.MEMBER_TYPE, dbo.removeBreaks(n.COMPANY) Company, n.STATUS, count(o.st_id) Num_Meetings_Attended, sum(o.TOTAL_PAYMENTS) Total_Paid
	,STUFF
		(
			(
				SELECT ',' + om.MEETING
				FROM Orders o2
					inner join order_meet om on o2.ORDER_NUMBER = om.ORDER_NUMBER
				WHERE n.id = o2.ST_ID and year(o2.ORDER_DATE) = 2015
				ORDER BY om.MEETING
				FOR XML PATH('')
			), 1, 1, ''
		) AS Meetings
from name n
	inner join orders o on n.id = o.st_Id
	inner join order_meet om on o.ORDER_NUMBER = om.ORDER_NUMBER
where o.ORDER_DATE >= '2015-1-1' and o.ORDER_DATE <= '2015-12-31'
	and (om.REGISTRANT_CLASS = 'NM')
	and (n.STATUS = 'S' or n.MEMBER_TYPE = 'NMI')
	--and ((n.MEMBER_TYPE = 'NMI' and n.STATUS in ('A','S'))	or (n.MEMBER_TYPE not in ('NM','NMI','PROS','PROC') and n.STATUS = 'S'))
	and n.COMPANY_RECORD = 0
	and n.MEMBER_TYPE <> 'ST'
	--and o.TOTAL_PAYMENTS > 0
group by n.id, n.FIRST_NAME, n.LAST_NAME, n.MEMBER_TYPE, n.STATUS, n.COMPANY
order by n.MEMBER_TYPE

--all retailers who left since 2013
select n.id, n.FIRST_NAME, n.LAST_NAME, n.COMPANY, year(n.PAID_THRU) PTD_Year, d.PRIM_BUS_CODE
	, (select sum(o.total_payments) from orders o where year(o.ORDER_DATE) = year(n.paid_thru) and o.st_Id = n.id) Total_Payments
from name n
	inner join demographics d on n.id = d.id
where d.PRIM_BUS_CODE = 'ret'
	and year(n.PAID_THRU) in (2015,2014,2013)
	and n.COMPANY_RECORD = 0
order by year(n.PAID_THRU), n.FULL_NAME