SET NOCOUNT ON

if OBJECT_ID('tempdb..#sp_ICSC_Meetings_Overview') is not null
	drop table #sp_ICSC_Meetings_Overview

Declare @YearCompare as int;
Declare @Start_Date date;
Declare @End_Date date;

set @YearCompare = 2017
set @Start_Date = cast(@YearCompare - 1 as varchar) + '-1-1'
set @End_Date = cast(@YearCompare as varchar) + '-12-31'

select year(b.BEGIN_DATE) Meet_Year
	, b.MEETING
	, b.TITLE
	, b.MEETING_TYPE
	, mt.DESCRIPTION
	, b.Prior_Year_Code
	, count(distinct b.MEETING) Mtg_Count
	, sum(Distinct_All_Attendees) Distinct_All_Attendees
	, sum(Distinct_Paid_Attendees) Distinct_Paid_Attendees
	, sum(Distinct_Comp_Attendees) Distinct_Comp_Attendees
	, sum(Distinct_Owed_Attendees) Distinct_Owed_Attendees
	, sum(Distinct_All_Companies) Distinct_All_Companies
	, sum(Distinct_Paid_Companies) Distinct_Paid_Companies
	, sum(Distinct_Comp_Companies) Distinct_Comp_Companies
	, sum(Distinct_Owed_Companies) Distinct_Owed_Companies
	, sum(Full_Year_Revenue) Full_Year_Revenue
	, sum(YTD_Distinct_All_Attendees) YTD_Distinct_All_Attendees
	, sum(YTD_Distinct_Paid_Attendees) YTD_Distinct_Paid_Attendees
	, sum(YTD_Distinct_Comp_Attendees) YTD_Distinct_Comp_Attendees
	, sum(YTD_Distinct_Owed_Attendees) YTD_Distinct_Owed_Attendees
	, sum(YTD_Distinct_All_Companies) YTD_Distinct_All_Companies
	, sum(YTD_Distinct_Paid_Companies) YTD_Distinct_Paid_Companies
	, sum(YTD_Distinct_Comp_Companies) YTD_Distinct_Comp_Companies
	, sum(YTD_Distinct_Owed_Companies) YTD_Distinct_Owed_Companies
	, sum(YTD_Revenue) YTD_Revenue into #sp_ICSC_Meetings_Overview

from (
--Distinct ID count of attendee w/ IDs
	select a.MEETING_TYPE, a.MEETING, a.BEGIN_DATE, a.Prior_Year_Code, a.TITLE
		, COUNT(distinct case when not(len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST')) then a.ST_ID else null end) Distinct_All_Attendees
		, COUNT(distinct case when not(len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST')) and a.TOTAL_PAYMENTS > 0 then a.ST_ID else null end) Distinct_Paid_Attendees
		, COUNT(distinct case when not(len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST')) and a.TOTAL_PAYMENTS = 0 then a.ST_ID else null end) Distinct_Comp_Attendees
		, COUNT(distinct case when not(len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST')) and a.TOTAL_PAYMENTS < 0 then a.ST_ID else null end) Distinct_Owed_Attendees
		, COUNT(distinct case when len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST') then a.ST_ID else null end) Distinct_All_Companies
		, COUNT(distinct case when len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST') and a.TOTAL_PAYMENTS > 0 then a.ST_ID else null end) Distinct_Paid_Companies
		, COUNT(distinct case when len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST') and a.TOTAL_PAYMENTS = 0 then a.ST_ID else null end) Distinct_Comp_Companies
		, COUNT(distinct case when len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST') and a.TOTAL_PAYMENTS < 0 then a.ST_ID else null end) Distinct_Owed_Companies
		, SUM(a.TOTAL_PAYMENTS) Full_Year_Revenue
		, SUM(case when a.ORDER_DATE <= cast(year(a.BEGIN_DATE) as varchar) + '-' + cast(month(getdate()) as varchar) + '-' + cast(day(getdate()) as varchar) then a.TOTAL_PAYMENTS else 0 end) YTD_Revenue
		, COUNT(distinct case when a.ORDER_DATE <= cast(year(a.BEGIN_DATE) as varchar) + '-' + cast(month(getdate()) as varchar) + '-' + cast(day(getdate()) as varchar) and not(len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST')) then a.ST_ID else null end) YTD_Distinct_All_Attendees
		, COUNT(distinct case when a.ORDER_DATE <= cast(year(a.BEGIN_DATE) as varchar) + '-' + cast(month(getdate()) as varchar) + '-' + cast(day(getdate()) as varchar) and not(len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST')) and a.TOTAL_PAYMENTS > 0 then a.ST_ID else null end) YTD_Distinct_Paid_Attendees
		, COUNT(distinct case when a.ORDER_DATE <= cast(year(a.BEGIN_DATE) as varchar) + '-' + cast(month(getdate()) as varchar) + '-' + cast(day(getdate()) as varchar) and not(len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST')) and a.TOTAL_PAYMENTS = 0 then a.ST_ID else null end) YTD_Distinct_Comp_Attendees
		, COUNT(distinct case when a.ORDER_DATE <= cast(year(a.BEGIN_DATE) as varchar) + '-' + cast(month(getdate()) as varchar) + '-' + cast(day(getdate()) as varchar) and not(len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST')) and a.TOTAL_PAYMENTS < 0 then a.ST_ID else null end) YTD_Distinct_Owed_Attendees
		, COUNT(distinct case when a.ORDER_DATE <= cast(year(a.BEGIN_DATE) as varchar) + '-' + cast(month(getdate()) as varchar) + '-' + cast(day(getdate()) as varchar) and len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST') then a.ST_ID else null end) YTD_Distinct_All_Companies
		, COUNT(distinct case when a.ORDER_DATE <= cast(year(a.BEGIN_DATE) as varchar) + '-' + cast(month(getdate()) as varchar) + '-' + cast(day(getdate()) as varchar) and len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST') and a.TOTAL_PAYMENTS > 0 then a.ST_ID else null end) YTD_Distinct_Paid_Companies
		, COUNT(distinct case when a.ORDER_DATE <= cast(year(a.BEGIN_DATE) as varchar) + '-' + cast(month(getdate()) as varchar) + '-' + cast(day(getdate()) as varchar) and len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST') and a.TOTAL_PAYMENTS = 0 then a.ST_ID else null end) YTD_Distinct_Comp_Companies
		, COUNT(distinct case when a.ORDER_DATE <= cast(year(a.BEGIN_DATE) as varchar) + '-' + cast(month(getdate()) as varchar) + '-' + cast(day(getdate()) as varchar) and len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST') and a.TOTAL_PAYMENTS < 0 then a.ST_ID else null end) YTD_Distinct_Owed_Companies

	from (
		--Dump of main meeting - regular members
		select mm.MUF_7, mm.MEETING_TYPE, o.MEMBER_TYPE, o.ST_ID, o.TOTAL_PAYMENTS, mm.MEETING, mm.BEGIN_DATE, o.ORDER_DATE, mm.MUF_1 Prior_Year_Code, mm.TITLE
		from orders o
			inner join order_meet om on o.ORDER_NUMBER = om.ORDER_NUMBER
			inner join meet_master mm on om.MEETING = mm.MEETING
		where o.STATUS not like 'C%'
			and BEGIN_DATE >= @Start_Date
			and BEGIN_DATE <= @End_Date
			and ST_ID <> ''
			and mm.MUF_7 = ''

		union all

		--Dump of child meeting - regular members
		select mm.MUF_7, mm2.MEETING_TYPE, o.MEMBER_TYPE, o.ST_ID, o.TOTAL_PAYMENTS, mm2.MEETING, mm.BEGIN_DATE, o.ORDER_DATE, mm2.MUF_1 Prior_Year_Code, mm2.TITLE
		from orders o
			inner join order_meet om on o.ORDER_NUMBER = om.ORDER_NUMBER
			inner join meet_master mm on om.MEETING = mm.MEETING
			left join Meet_Master mm2 on mm.MUF_7 = mm2.MEETING
		where o.STATUS not like 'C%'
			and mm.BEGIN_DATE >= @Start_Date
			and mm.BEGIN_DATE <= @End_Date
			and ST_ID <> ''
			and mm.MUF_7 <> ''
	) a
	group by a.MEETING_TYPE, a.MEETING, a.BEGIN_DATE, a.Prior_Year_Code, a.TITLE


	union all

	--Count of attendees w/ no ID
	select a.MEETING_TYPE, a.MEETING, a.BEGIN_DATE, a.Prior_Year_Code, a.TITLE
		, COUNT(case when not(len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST')) then a.ST_ID else null end) Distinct_All_Attendees
		, COUNT(case when not(len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST')) and a.TOTAL_PAYMENTS > 0 then a.ST_ID else null end) Distinct_Paid_Attendees
		, COUNT(case when not(len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST')) and a.TOTAL_PAYMENTS = 0 then a.ST_ID else null end) Distinct_Comp_Attendees
		, COUNT(case when not(len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST')) and a.TOTAL_PAYMENTS < 0 then a.ST_ID else null end) Distinct_Owed_Attendees
		, COUNT(case when len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST') then a.ST_ID else null end) Distinct_All_Companies
		, COUNT(case when len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST') and a.TOTAL_PAYMENTS > 0 then a.ST_ID else null end) Distinct_Paid_Companies
		, COUNT(case when len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST') and a.TOTAL_PAYMENTS = 0 then a.ST_ID else null end) Distinct_Comp_Companies
		, COUNT(case when len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST') and a.TOTAL_PAYMENTS < 0 then a.ST_ID else null end) Distinct_Owed_Companies
		, SUM(a.TOTAL_PAYMENTS) Full_Year_Revenue
		, SUM(case when a.ORDER_DATE <= cast(year(a.BEGIN_DATE) as varchar) + '-' + cast(month(getdate()) as varchar) + '-' + cast(day(getdate()) as varchar) then a.TOTAL_PAYMENTS else 0 end) YTD_Revenue
		, COUNT(case when a.ORDER_DATE <= cast(year(a.BEGIN_DATE) as varchar) + '-' + cast(month(getdate()) as varchar) + '-' + cast(day(getdate()) as varchar) and not(len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST')) then a.ST_ID else null end) YTD_Distinct_All_Attendees
		, COUNT(case when a.ORDER_DATE <= cast(year(a.BEGIN_DATE) as varchar) + '-' + cast(month(getdate()) as varchar) + '-' + cast(day(getdate()) as varchar) and not(len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST')) and a.TOTAL_PAYMENTS > 0 then a.ST_ID else null end) YTD_Distinct_Paid_Attendees
		, COUNT(case when a.ORDER_DATE <= cast(year(a.BEGIN_DATE) as varchar) + '-' + cast(month(getdate()) as varchar) + '-' + cast(day(getdate()) as varchar) and not(len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST')) and a.TOTAL_PAYMENTS = 0 then a.ST_ID else null end) YTD_Distinct_Comp_Attendees
		, COUNT(case when a.ORDER_DATE <= cast(year(a.BEGIN_DATE) as varchar) + '-' + cast(month(getdate()) as varchar) + '-' + cast(day(getdate()) as varchar) and not(len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST')) and a.TOTAL_PAYMENTS < 0 then a.ST_ID else null end) YTD_Distinct_Owed_Attendees
		, COUNT(case when a.ORDER_DATE <= cast(year(a.BEGIN_DATE) as varchar) + '-' + cast(month(getdate()) as varchar) + '-' + cast(day(getdate()) as varchar) and len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST') then a.ST_ID else null end) YTD_Distinct_All_Companies
		, COUNT(case when a.ORDER_DATE <= cast(year(a.BEGIN_DATE) as varchar) + '-' + cast(month(getdate()) as varchar) + '-' + cast(day(getdate()) as varchar) and len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST') and a.TOTAL_PAYMENTS > 0 then a.ST_ID else null end) YTD_Distinct_Paid_Companies
		, COUNT(case when a.ORDER_DATE <= cast(year(a.BEGIN_DATE) as varchar) + '-' + cast(month(getdate()) as varchar) + '-' + cast(day(getdate()) as varchar) and len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST') and a.TOTAL_PAYMENTS = 0 then a.ST_ID else null end) YTD_Distinct_Comp_Companies
		, COUNT(case when a.ORDER_DATE <= cast(year(a.BEGIN_DATE) as varchar) + '-' + cast(month(getdate()) as varchar) + '-' + cast(day(getdate()) as varchar) and len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST') and a.TOTAL_PAYMENTS < 0 then a.ST_ID else null end) YTD_Distinct_Owed_Companies

	from (
		--Dump of main meeting - no ID
		select mm.MUF_7, mm.MEETING_TYPE, o.MEMBER_TYPE, o.ST_ID, o.TOTAL_PAYMENTS, mm.MEETING, mm.BEGIN_DATE, o.ORDER_DATE, mm.MUF_1 Prior_Year_Code, mm.TITLE
		from orders o
			inner join order_meet om on o.ORDER_NUMBER = om.ORDER_NUMBER
			inner join meet_master mm on om.MEETING = mm.MEETING
		where o.STATUS not like 'C%'
			and BEGIN_DATE >= @Start_Date
			and BEGIN_DATE <= @End_Date
			and ST_ID = ''
			and mm.MUF_7 = ''

		union all
		
		--Dump of child meetings - no ID
		select mm.MUF_7, mm2.MEETING_TYPE, o.MEMBER_TYPE, o.ST_ID, o.TOTAL_PAYMENTS, mm2.MEETING, mm.BEGIN_DATE, o.ORDER_DATE, mm2.MUF_1 Prior_Year_Code, mm2.TITLE
		from orders o
			inner join order_meet om on o.ORDER_NUMBER = om.ORDER_NUMBER
			inner join meet_master mm on om.MEETING = mm.MEETING
			left join Meet_Master mm2 on mm.MUF_7 = mm2.MEETING
		where o.STATUS not like 'C%'
			and mm.BEGIN_DATE >= @Start_Date
			and mm.BEGIN_DATE <= @End_Date
			and ST_ID = ''
			and mm.MUF_7 <> ''
	) a
	group by a.MEETING_TYPE, a.MEETING, a.BEGIN_DATE, a.Prior_Year_Code, a.TITLE
) b
left join Meeting_Types mt on b.MEETING_TYPE = left(mt.CODE,5)
group by year(b.BEGIN_DATE), b.MEETING, b.MEETING_TYPE, mt.DESCRIPTION, b.Prior_Year_Code, b.TITLE
order by year(b.BEGIN_DATE), b.MEETING_TYPE

select cy.Meet_Year						CY_Meet_Year
	, cy.MEETING						CY_MEETING
	, cy.TITLE							CY_TITLE
	, cy.MEETING_TYPE					CY_MEETING_TYPE
	, cy.DESCRIPTION					CY_DESCRIPTION
	, cy.Prior_Year_Code				CY_Prior_Year_Code
	, cy.Mtg_Count						CY_Mtg_Count
	, cy.Distinct_All_Attendees			CY_Distinct_All_Attendees
	, cy.Distinct_Paid_Attendees		CY_Distinct_Paid_Attendees
	, cy.Distinct_Comp_Attendees		CY_Distinct_Comp_Attendees
	, cy.Distinct_Owed_Attendees		CY_Distinct_Owed_Attendees
	, cy.Distinct_All_Companies			CY_Distinct_All_Companies
	, cy.Distinct_Paid_Companies		CY_Distinct_Paid_Companies
	, cy.Distinct_Comp_Companies		CY_Distinct_Comp_Companies
	, cy.Distinct_Owed_Companies		CY_Distinct_Owed_Companies
	, cy.Full_Year_Revenue				CY_Full_Year_Revenue
	, cy.YTD_Distinct_All_Attendees		CY_YTD_Distinct_All_Attendees
	, cy.YTD_Distinct_Paid_Attendees	CY_YTD_Distinct_Paid_Attendees
	, cy.YTD_Distinct_Comp_Attendees	CY_YTD_Distinct_Comp_Attendees
	, cy.YTD_Distinct_Owed_Attendees	CY_YTD_Distinct_Owed_Attendees
	, cy.YTD_Distinct_All_Companies		CY_YTD_Distinct_All_Companies
	, cy.YTD_Distinct_Paid_Companies	CY_YTD_Distinct_Paid_Companies
	, cy.YTD_Distinct_Comp_Companies	CY_YTD_Distinct_Comp_Companies
	, cy.YTD_Distinct_Owed_Companies	CY_YTD_Distinct_Owed_Companies
	, cy.YTD_Revenue					CY_YTD_Revenue

	, ly.Meet_Year						LY_Meet_Year
	, ly.MEETING						LY_MEETING
	, ly.TITLE							LY_TITLE
	, ly.MEETING_TYPE					LY_MEETING_TYPE
	, ly.DESCRIPTION					LY_DESCRIPTION
	, ly.Prior_Year_Code				LY_Prior_Year_Code
	, ly.Mtg_Count						LY_Mtg_Count
	, ly.Distinct_All_Attendees			LY_Distinct_All_Attendees
	, ly.Distinct_Paid_Attendees		LY_Distinct_Paid_Attendees
	, ly.Distinct_Comp_Attendees		LY_Distinct_Comp_Attendees
	, ly.Distinct_Owed_Attendees		LY_Distinct_Owed_Attendees
	, ly.Distinct_All_Companies			LY_Distinct_All_Companies
	, ly.Distinct_Paid_Companies		LY_Distinct_Paid_Companies
	, ly.Distinct_Comp_Companies		LY_Distinct_Comp_Companies
	, ly.Distinct_Owed_Companies		LY_Distinct_Owed_Companies
	, ly.Full_Year_Revenue				LY_Full_Year_Revenue
	, ly.YTD_Distinct_All_Attendees		LY_YTD_Distinct_All_Attendees
	, ly.YTD_Distinct_Paid_Attendees	LY_YTD_Distinct_Paid_Attendees
	, ly.YTD_Distinct_Comp_Attendees	LY_YTD_Distinct_Comp_Attendees
	, ly.YTD_Distinct_Owed_Attendees	LY_YTD_Distinct_Owed_Attendees
	, ly.YTD_Distinct_All_Companies		LY_YTD_Distinct_All_Companies
	, ly.YTD_Distinct_Paid_Companies	LY_YTD_Distinct_Paid_Companies
	, ly.YTD_Distinct_Comp_Companies	LY_YTD_Distinct_Comp_Companies
	, ly.YTD_Distinct_Owed_Companies	LY_YTD_Distinct_Owed_Companies
	, ly.YTD_Revenue					LY_YTD_Revenue

from #sp_ICSC_Meetings_Overview cy
	left join #sp_ICSC_Meetings_Overview ly on cy.Prior_Year_Code = ly.MEETING
where cy.Meet_Year = @YearCompare