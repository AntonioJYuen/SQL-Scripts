begin transaction

update mm
set mm.MUF_7 = mm2.MEETING
from Meet_Master mm
	inner join Meet_Master mm2 on right(mm.meeting,4) + left(mm.meeting,len(mm.meeting)-4) = mm2.MEETING
where mm.BEGIN_DATE >= '2016-1-1'
	and mm.MEETING_TYPE = 'EXPO'
	and mm.muf_7 = ''

select mm.meeting EXPO_MEETING, mm.TITLE EXPO_TITLE, mm.MUF_7
	--, right(mm.meeting,4) + left(mm.meeting,len(mm.meeting)-4)
	, mm2.MEETING PARENT_MEETING, mm2.TITLE PARENT_TITLE
from Meet_Master mm
	inner join Meet_Master mm2 on right(mm.meeting,4) + left(mm.meeting,len(mm.meeting)-4) = mm2.MEETING
where mm.BEGIN_DATE >= '2016-1-1'
	and mm.MEETING_TYPE = 'EXPO'

commit transaction

select mm.meeting EXPO_MEETING, mm.TITLE EXPO_TITLE, mm.MUF_7
	--, right(mm.meeting,4) + left(mm.meeting,len(mm.meeting)-4)
	, mm2.MEETING PARENT_MEETING, mm2.TITLE PARENT_TITLE
from Meet_Master mm
	left join Meet_Master mm2 on right(mm.meeting,4) + left(mm.meeting,len(mm.meeting)-4) = mm2.MEETING
where mm.BEGIN_DATE >= '2016-1-1'
	and mm.MEETING_TYPE = 'EXPO'
	and mm.MUF_7 = ''

select mm.meeting EXPO_MEETING, mm.TITLE EXPO_TITLE, mm.MUF_7
	--, right(mm.meeting,4) + left(mm.meeting,len(mm.meeting)-4)
	, mm2.MEETING PARENT_MEETING, mm2.TITLE PARENT_TITLE
from Meet_Master mm
	left join Meet_Master mm2 on mm.MUF_7 = mm2.MEETING
where mm.BEGIN_DATE >= '2016-1-1'
	and mm.MEETING_TYPE = 'EXPO'
	and mm2.MEETING is null