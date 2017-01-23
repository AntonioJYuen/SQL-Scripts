--Regions group by meet master
select mm.meeting_type, mt.DESCRIPTION, isnull(isnull(ur.ICSC_USA_REGION,rm.Region_Name),'N/A'), count(mm.meeting) Number_Meetings, sum(a.Number_Attendees) Number_Attendees
from meet_master mm
	left join csys_ICSC_USA_regions ur on mm.STATE_PROVINCE = ur.STATE_CODE
	left join Csys_ICSC_Regions_Mem rm on mm.COUNTRY = rm.Country
	inner join Meeting_Types mt on mm.MEETING_TYPE = mt.CODE
	left join (select om.MEETING, count(o.st_id) Number_Attendees from Orders o inner join Order_Meet om on o.ORDER_NUMBER = om.ORDER_NUMBER where o.STATUS not like 'C%' and o.MEMBER_TYPE not in ('ST') group by om.MEETING) a on mm.MEETING = a.MEETING
where mm.MEETING_TYPE in ('RECON','NY','NSPC','IDEA','DEAL','LNG','LP3R','LSP')
	and mm.BEGIN_DATE >= '2016-1-1'
	and mm.BEGIN_DATE <= '2016-12-31'
	and mm.status = 'A'
group by mm.MEETING_TYPE, mt.DESCRIPTION, isnull(isnull(ur.ICSC_USA_REGION,rm.Region_Name),'N/A')

--Regions grouped by order
select mm.meeting_type, mt.DESCRIPTION, isnull(isnull(ur.ICSC_USA_REGION,rm.Region_Name),'N/A'), count(mm.meeting) Number_Meetings, sum(a.Number_Attendees) Number_Attendees
from meet_master mm
	inner join Meeting_Types mt on mm.MEETING_TYPE = mt.CODE
	left join (select om.MEETING, o.STATE_PROVINCE, o.COUNTRY, count(o.st_id) Number_Attendees from Orders o inner join Order_Meet om on o.ORDER_NUMBER = om.ORDER_NUMBER where o.STATUS not like 'C%' and o.MEMBER_TYPE not in ('ST') group by om.MEETING, o.STATE_PROVINCE, o.COUNTRY) a on mm.MEETING = a.MEETING
	left join csys_ICSC_USA_regions ur on a.STATE_PROVINCE = ur.STATE_CODE
	left join Csys_ICSC_Regions_Mem rm on a.COUNTRY = rm.Country
where mm.MEETING_TYPE in ('RECON','NY','NSPC','IDEA','DEAL','LNG','LP3R','LSP')
	and mm.BEGIN_DATE >= '2016-1-1'
	and mm.BEGIN_DATE <= '2016-12-31'
	and mm.status = 'A'
group by mm.MEETING_TYPE, mt.DESCRIPTION, isnull(isnull(ur.ICSC_USA_REGION,rm.Region_Name),'N/A')