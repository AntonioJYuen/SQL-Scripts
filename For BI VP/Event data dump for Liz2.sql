if OBJECT_ID('tempdb..##TEMP_TABLE_FOR_LIZ') is not null
	drop table ##TEMP_TABLE_FOR_LIZ

select o.ST_ID, replace(o.FIRST_NAME, ',', '') FIRST_NAME, replace(o.LAST_NAME, ',', '') LAST_NAME, replace(o.FULL_NAME, ',', '') Full_Name, replace(dbo.removeBreaks(o.COMPANY), ',', '') Company, n.COMPANY_RECORD, n.JOIN_DATE, n.STATUS, n.MEMBER_TYPE, case when nu.ICSC_USA_REGION is not null then nu.ICSC_USA_REGION when nr.ICSC_REGION is not null then nr.ICSC_REGION else '~Missing Region Data' end Member_Region
	, d.prim_bus_code, o.ORDER_DATE
	, mm.MEETING, case when u.ICSC_USA_REGION is not null then u.ICSC_USA_REGION when r.ICSC_REGION is not null then r.ICSC_REGION else '~Missing Region Data' end Meeting_Region, mm.BEGIN_DATE Meeting_Date
	, mm.MEETING_TYPE
	, case when max(a.Meeting_Text) is null then 1 else 0 end First_Time
	, o.TOTAL_PAYMENTS, mm.MUF_5 Budgeted_Attendance, mm.MUF_10 Budgeted_Revenue 
	, o.CO_ID, case when o.status in ('CT','C') then 1 else 0 end Canceled
	, mm.TITLE into ##TEMP_TABLE_FOR_LIZ
from orders o
	inner join Order_Meet om on o.ORDER_NUMBER = om.ORDER_NUMBER
	inner join Meet_Master mm on om.MEETING = mm.MEETING
	left join name n on o.st_id = n.ID
	left join Demographics d on n.id = d.id
	left join csys_ICSC_regions r on mm.country = r.COUNTRY_NAME
	left join csys_ICSC_USA_regions u on mm.STATE_PROVINCE = u.STATE_CODE
	left join csys_ICSC_regions nr on n.country = nr.COUNTRY_NAME
	left join csys_ICSC_USA_regions nu on n.STATE_PROVINCE = nu.STATE_CODE
	left join (select st_id, Left(SubString(MEETING, PatIndex('%[0-9.-]%', MEETING), 8000), PatIndex('%[^0-9.-]%', SubString(MEETING, PatIndex('%[0-9.-]%', MEETING), 8000) + 'X')-1) Year_Attended, dbo.RemoveNonAlphaCharacters(MEETING) Meeting_Text from orders o inner join order_meet om on o.ORDER_NUMBER = om.ORDER_NUMBER) a 
		on n.id = a.ST_ID and Left(SubString(mm.MEETING, PatIndex('%[0-9.-]%', mm.MEETING), 8000), PatIndex('%[^0-9.-]%', SubString(mm.MEETING, PatIndex('%[0-9.-]%', mm.MEETING), 8000) + 'X')-1) > a.Year_Attended
			and dbo.RemoveNonAlphaCharacters(mm.MEETING)= a.Meeting_Text
where o.STATUS not in ('CT','C')
	and ((o.ORDER_DATE >= '2014-1-1' and o.ORDER_DATE < '2017-1-1') or (mm.BEGIN_DATE >= '2014-1-1' and mm.BEGIN_DATE < '2017-1-1'))
group by o.ST_ID, replace(o.FIRST_NAME, ',', ''), replace(o.LAST_NAME, ',', ''), replace(o.FULL_NAME, ',', ''), replace(dbo.removeBreaks(o.COMPANY), ',', ''), n.COMPANY_RECORD, n.JOIN_DATE, n.STATUS, n.MEMBER_TYPE, case when nu.ICSC_USA_REGION is not null then nu.ICSC_USA_REGION when nr.ICSC_REGION is not null then nr.ICSC_REGION else '~Missing Region Data' end
	, d.prim_bus_code, o.ORDER_DATE
	, mm.MEETING, case when u.ICSC_USA_REGION is not null then u.ICSC_USA_REGION when r.ICSC_REGION is not null then r.ICSC_REGION else '~Missing Region Data' end, mm.BEGIN_DATE
	, mm.MEETING_TYPE
	, o.TOTAL_PAYMENTS, mm.MUF_5, mm.MUF_10
	, o.CO_ID, case when o.status in ('CT','C') then 1 else 0 end
	, mm.TITLE

select *
from ##TEMP_TABLE_FOR_LIZ
where Meeting_Region like '~m%'