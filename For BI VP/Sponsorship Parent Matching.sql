begin transaction

update mm
set mm.MUF_7 = mm2.MEETING
from Meet_Master mm
	inner join Meet_Master mm2 on left(mm.MEETING,len(mm.meeting)-1) = mm2.MEETING
where mm.BEGIN_DATE >= '2016-1-1'
	and mm.MEETING_TYPE = 'SPON'
	and mm.muf_7 = ''

select mm.meeting SPON_MEETING, mm.TITLE SPON_TITLE, mm.MUF_7, mm2.MEETING PARENT_MEETING, mm2.TITLE PARENT_TITLE
from Meet_Master mm
	inner join Meet_Master mm2 on left(mm.MEETING,len(mm.meeting)-1) = mm2.MEETING
where mm.BEGIN_DATE >= '2016-1-1'
	and mm.MEETING_TYPE = 'SPON'

commit transaction

select mm.meeting SPON_MEETING, mm.TITLE SPON_TITLE, mm.MUF_7, mm2.MEETING PARENT_MEETING, mm2.TITLE PARENT_TITLE
from Meet_Master mm
	left join Meet_Master mm2 on left(mm.MEETING,len(mm.meeting)-1) = mm2.MEETING
where mm.BEGIN_DATE >= '2016-1-1'
	and mm.MEETING_TYPE = 'SPON'
	and mm.MUF_7 = ''

select mm.meeting SPON_MEETING, mm.TITLE SPON_TITLE, mm.MUF_7, mm2.MEETING PARENT_MEETING, mm2.TITLE PARENT_TITLE
from Meet_Master mm
	left join Meet_Master mm2 on mm.MUF_7 = mm2.MEETING
where mm.BEGIN_DATE >= '2016-1-1'
	and mm.MEETING_TYPE = 'SPON'
	and mm2.MEETING is null