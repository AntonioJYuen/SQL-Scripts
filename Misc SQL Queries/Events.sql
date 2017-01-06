select TITLE
	, MEETING
	, BEGIN_DATE
	, END_DATE
	, MEETING_TYPE
	, STATUS
from Meet_Master mm
where mm.meeting like '[0-9][0-9][0-9][0-9][a-Z]%'
	and meeting not like '[0-9][0-9][0-9][0-9]WB%'
	and meeting not like '%S'