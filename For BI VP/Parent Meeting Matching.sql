Declare @Start_Date date;
Declare @End_Date date;

set @Start_Date = '2016-1-1'
set @End_Date = '2016-12-31'

select mm2.MEETING_TYPE Parent_Meeting_Type, mm.MEETING, mm.MUF_7 Mapped_Parent
from meet_master mm
	left join Meet_Master mm2 on mm.MUF_7 = mm2.MEETING
where mm.MUF_7 <> ''
	and mm.BEGIN_DATE >= @Start_Date
	and mm.BEGIN_DATE <= @End_Date
order by Parent_Meeting_Type, MEETING