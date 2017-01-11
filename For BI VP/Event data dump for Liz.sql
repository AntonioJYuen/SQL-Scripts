select n.ID, replace(n.FIRST_NAME, ',', '') FIRST_NAME, replace(n.LAST_NAME, ',', '') LAST_NAME, replace(n.FULL_NAME, ',', '') Full_Name, replace(dbo.removeBreaks(n.COMPANY), ',', '') Company, n.COMPANY_RECORD, n.JOIN_DATE, n.STATUS, n.MEMBER_TYPE, case when nu.ICSC_USA_REGION is not null then nu.ICSC_USA_REGION when nr.ICSC_REGION is not null then nr.ICSC_REGION else '~Missing Region Data' end Member_Region
	, d.prim_bus_code, o.ORDER_DATE
	, mm.MEETING, case when u.ICSC_USA_REGION is not null then u.ICSC_USA_REGION when r.ICSC_REGION is not null then r.ICSC_REGION else '~Missing Region Data' end Meeting_Region, mm.BEGIN_DATE Meeting_Date
	, mm.MEETING_TYPE
	, case when a.Meeting_Text is null then 1 else 0 end First_Time
	, o.TOTAL_PAYMENTS
from name n
	inner join Demographics d on n.id = d.id
	inner join orders o on n.id = o.st_Id
	inner join Order_Meet om on o.ORDER_NUMBER = om.ORDER_NUMBER
	inner join Meet_Master mm on om.MEETING = mm.MEETING
	left join csys_ICSC_regions r on mm.country = r.COUNTRY_NAME
	left join csys_ICSC_USA_regions u on mm.STATE_PROVINCE = u.STATE_CODE
	left join csys_ICSC_regions nr on n.country = nr.COUNTRY_NAME
	left join csys_ICSC_USA_regions nu on n.STATE_PROVINCE = nu.STATE_CODE
	left join (select st_id, Left(SubString(MEETING, PatIndex('%[0-9.-]%', MEETING), 8000), PatIndex('%[^0-9.-]%', SubString(MEETING, PatIndex('%[0-9.-]%', MEETING), 8000) + 'X')-1) Year_Attended, dbo.RemoveNonAlphaCharacters(MEETING) Meeting_Text from orders o inner join order_meet om on o.ORDER_NUMBER = om.ORDER_NUMBER) a 
		on n.id = a.ST_ID and Left(SubString(mm.MEETING, PatIndex('%[0-9.-]%', mm.MEETING), 8000), PatIndex('%[^0-9.-]%', SubString(mm.MEETING, PatIndex('%[0-9.-]%', mm.MEETING), 8000) + 'X')-1) > a.Year_Attended
			and dbo.RemoveNonAlphaCharacters(mm.MEETING)= a.Meeting_Text
where o.STATUS not in ('CT','C')
	and (o.ORDER_DATE >= '2014-1-1'	and o.ORDER_DATE < '2017-1-1') or (mm.BEGIN_DATE >= '2014-1-1' and mm.BEGIN_DATE < '2017-1-1')