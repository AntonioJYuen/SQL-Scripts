Declare @TimeAdjust int
Declare @MeetingCode varchar(10)

set @MeetingCode = '2016MA'
set @TimeAdjust = 0

--Onsites
select cast(dateadd(hour,-3,k.PRINT_DATE) as date) Date_Printed
	,  replace(case when cast(convert(char(2), dateadd(hour,@TimeAdjust,k.PRINT_DATE), 108) as int)/12 < 1 then convert(char(2), dateadd(hour,@TimeAdjust,k.PRINT_DATE), 108) + 'AM' else convert(char(2), dateadd(hour,@TimeAdjust-12,k.PRINT_DATE), 108) + 'PM' end,'00','12') Hour_Printed
	, count(st_id) Num_Printed
from orders o
       inner join Order_Meet om on o.ORDER_NUMBER = om.ORDER_NUMBER
       inner join Meet_Master mm on om.MEETING = mm.MEETING
       inner join Kiosk_Order_Badge_Printed k on o.ORDER_NUMBER = k.ORDER_NUMBER
where o.STATUS not like 'C%'
       and om.MEETING = @MeetingCode
       and o.MEMBER_TYPE not in ('ST','FA')
	   and o.CO_ID <> '1037339'
       --and o.ORDER_DATE >= mm.BEGIN_DATE
group by cast(dateadd(hour,-3,k.PRINT_DATE) as date), replace(case when cast(convert(char(2), dateadd(hour,@TimeAdjust,k.PRINT_DATE), 108) as int)/12 < 1 then convert(char(2), dateadd(hour,@TimeAdjust,k.PRINT_DATE), 108) + 'AM' else convert(char(2), dateadd(hour,@TimeAdjust-12,k.PRINT_DATE), 108) + 'PM' end,'00','12')
order by cast(dateadd(hour,-3,k.PRINT_DATE) as date) desc
	, right(replace(case when cast(convert(char(2), dateadd(hour,@TimeAdjust,k.PRINT_DATE), 108) as int)/12 < 1 then convert(char(2), dateadd(hour,@TimeAdjust,k.PRINT_DATE), 108) + 'AM' else convert(char(2), dateadd(hour,@TimeAdjust-12,k.PRINT_DATE), 108) + 'PM' end,'00','12'),2) desc
	, cast(left(replace(replace(case when cast(convert(char(2), dateadd(hour,@TimeAdjust,k.PRINT_DATE), 108) as int)/12 < 1 then convert(char(2), dateadd(hour,@TimeAdjust,k.PRINT_DATE), 108) + 'AM' else convert(char(2), dateadd(hour,@TimeAdjust-12,k.PRINT_DATE), 108) + 'PM' end,'00','12'),'12','00'),2) as int) desc
