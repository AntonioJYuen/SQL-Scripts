USE [PRODIMIS]
GO
/****** Object:  StoredProcedure [dbo].[sp_ICSC_Meetings_Overview]    Script Date: 3/8/2017 3:43:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[sp_ICSC_Meetings_Overview] 
	@YearCompare as int
as

SET NOCOUNT ON

if OBJECT_ID('tempdb..##sp_ICSC_Meetings_Overview') is not null	
	drop table ##sp_ICSC_Meetings_Overview

if OBJECT_ID('tempdb..##sp_ICSC_Meetings_Overview_1') is not null	
	drop table ##sp_ICSC_Meetings_Overview_1

if OBJECT_ID('tempdb..##sp_ICSC_Meetings_Overview_2') is not null	
	drop table ##sp_ICSC_Meetings_Overview_2

--Declare @YearCompare as int;
--set @YearCompare = 2017

Declare @Start_Date date;
Declare @End_Date date;

set @Start_Date = cast(@YearCompare - 1 as varchar) + '-1-1'
set @End_Date = cast(@YearCompare as varchar) + '-12-31'

select isnull(mm.MUF_7,mm2.MUF_7) MUF_7, isnull(mm2.MEETING_TYPE, mm.MEETING_TYPE) MEETING_TYPE, o.MEMBER_TYPE, o.ST_ID, o.TOTAL_PAYMENTS, isnull(mm2.MEETING,mm.MEETING) MEETING, isnull(mm2.BEGIN_DATE, mm.BEGIN_DATE) BEGIN_DATE, o.ORDER_DATE, isnull(mm2.MUF_1, mm.MUF_1) Prior_Year_Code, isnull(mm2.TITLE, mm.TITLE) TITLE
	, isnull(mm2.COUNTRY,mm.COUNTRY) COUNTRY, isnull(mm2.STATE_PROVINCE,mm.STATE_PROVINCE) STATE_PROVINCE
	, isnull(ur.ICSC_USA_REGION,rm.Region_Name) Region, case when datediff(d, GETDATE(),isnull(mm2.BEGIN_DATE, mm.BEGIN_DATE)) > 0 then datediff(d, GETDATE(),isnull(mm2.BEGIN_DATE, mm.BEGIN_DATE)) else 0 end Days_Out
into ##sp_ICSC_Meetings_Overview_1
from orders o
	inner join order_meet om on o.ORDER_NUMBER = om.ORDER_NUMBER
	inner join meet_master mm on om.MEETING = mm.MEETING
	left join Meet_Master mm2 on mm.MUF_7 = mm2.MEETING
	left join Csys_ICSC_Regions_Mem rm on isnull(mm2.COUNTRY,mm.COUNTRY) = rm.Country
	left join csys_ICSC_USA_regions ur on isnull(mm2.STATE_PROVINCE,mm.STATE_PROVINCE) = ur.STATE_CODE
where o.STATUS not like 'C%'
	and mm.BEGIN_DATE >= @Start_Date
	and mm.BEGIN_DATE <= @End_Date
	and o.ST_ID <> ''

update ly
set Days_Out = isnull((select max(Days_Out) from ##sp_ICSC_Meetings_Overview_1 cy where ly.MEETING = cy.Prior_Year_Code), Days_Out)
from ##sp_ICSC_Meetings_Overview_1 ly
			
select isnull(mm.MUF_7,mm2.MUF_7) MUF_7, isnull(mm2.MEETING_TYPE, mm.MEETING_TYPE) MEETING_TYPE, o.MEMBER_TYPE, o.ST_ID, o.TOTAL_PAYMENTS, isnull(mm2.MEETING,mm.MEETING) MEETING, isnull(mm2.BEGIN_DATE, mm.BEGIN_DATE) BEGIN_DATE, o.ORDER_DATE, isnull(mm2.MUF_1, mm.MUF_1) Prior_Year_Code, isnull(mm2.TITLE, mm.TITLE) TITLE
	, isnull(mm2.COUNTRY,mm.COUNTRY) COUNTRY, isnull(mm2.STATE_PROVINCE,mm.STATE_PROVINCE) STATE_PROVINCE
	, isnull(ur.ICSC_USA_REGION,rm.Region_Name) Region, case when datediff(d, GETDATE(),isnull(mm2.BEGIN_DATE, mm.BEGIN_DATE)) > 0 then datediff(d, GETDATE(),isnull(mm2.BEGIN_DATE, mm.BEGIN_DATE)) else 0 end Days_Out
into ##sp_ICSC_Meetings_Overview_2
from orders o
	inner join order_meet om on o.ORDER_NUMBER = om.ORDER_NUMBER
	inner join meet_master mm on om.MEETING = mm.MEETING
	left join Meet_Master mm2 on mm.MUF_7 = mm2.MEETING
	left join Csys_ICSC_Regions_Mem rm on isnull(mm2.COUNTRY,mm.COUNTRY) = rm.Country
	left join csys_ICSC_USA_regions ur on isnull(mm2.STATE_PROVINCE,mm.STATE_PROVINCE) = ur.STATE_CODE
where o.STATUS not like 'C%'
	and mm.BEGIN_DATE >= @Start_Date
	and mm.BEGIN_DATE <= @End_Date
	and o.ST_ID = ''

update ly
set Days_Out = isnull(isnull((select max(Days_Out) from ##sp_ICSC_Meetings_Overview_2 cy where ly.MEETING = cy.Prior_Year_Code),(select max(Days_Out) from ##sp_ICSC_Meetings_Overview_1 cy where ly.MEETING = cy.Prior_Year_Code)), Days_Out)
from ##sp_ICSC_Meetings_Overview_2 ly

select year(b.BEGIN_DATE) Meet_Year
	, b.MEETING
	, b.BEGIN_DATE
	, b.TITLE
	, b.MEETING_TYPE
	, mt.DESCRIPTION
	, b.Prior_Year_Code
	, max(b.COUNTRY) COUNTRY
	, max(b.STATE_PROVINCE) STATE_PROVINCE
	, max(b.Region) Region
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
	, sum(YTD_Revenue) YTD_Revenue 
	into ##sp_ICSC_Meetings_Overview

from (
--Distinct ID count of attendee w/ IDs
	select a.MEETING_TYPE, a.MEETING, a.BEGIN_DATE, a.Prior_Year_Code, a.TITLE, a.COUNTRY, a.STATE_PROVINCE, a.Region
		, COUNT(distinct case when not(len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST')) then a.ST_ID else null end) Distinct_All_Attendees
		, COUNT(distinct case when not(len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST')) and a.TOTAL_PAYMENTS > 0 then a.ST_ID else null end) Distinct_Paid_Attendees
		, COUNT(distinct case when not(len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST')) and a.TOTAL_PAYMENTS = 0 then a.ST_ID else null end) Distinct_Comp_Attendees
		, COUNT(distinct case when not(len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST')) and a.TOTAL_PAYMENTS < 0 then a.ST_ID else null end) Distinct_Owed_Attendees
		, COUNT(distinct case when len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST') then a.ST_ID else null end) Distinct_All_Companies
		, COUNT(distinct case when len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST') and a.TOTAL_PAYMENTS > 0 then a.ST_ID else null end) Distinct_Paid_Companies
		, COUNT(distinct case when len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST') and a.TOTAL_PAYMENTS = 0 then a.ST_ID else null end) Distinct_Comp_Companies
		, COUNT(distinct case when len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST') and a.TOTAL_PAYMENTS < 0 then a.ST_ID else null end) Distinct_Owed_Companies
		, SUM(a.TOTAL_PAYMENTS) Full_Year_Revenue
		, SUM(case when DATEDIFF(d,ORDER_DATE,BEGIN_DATE) >= Days_Out then a.TOTAL_PAYMENTS else 0 end) YTD_Revenue
		, COUNT(distinct case when DATEDIFF(d,ORDER_DATE,BEGIN_DATE) >= Days_Out and not(len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST')) then a.ST_ID else null end) YTD_Distinct_All_Attendees
		, COUNT(distinct case when DATEDIFF(d,ORDER_DATE,BEGIN_DATE) >= Days_Out and not(len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST')) and a.TOTAL_PAYMENTS > 0 then a.ST_ID else null end) YTD_Distinct_Paid_Attendees
		, COUNT(distinct case when DATEDIFF(d,ORDER_DATE,BEGIN_DATE) >= Days_Out and not(len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST')) and a.TOTAL_PAYMENTS = 0 then a.ST_ID else null end) YTD_Distinct_Comp_Attendees
		, COUNT(distinct case when DATEDIFF(d,ORDER_DATE,BEGIN_DATE) >= Days_Out and not(len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST')) and a.TOTAL_PAYMENTS < 0 then a.ST_ID else null end) YTD_Distinct_Owed_Attendees
		, COUNT(distinct case when DATEDIFF(d,ORDER_DATE,BEGIN_DATE) >= Days_Out and len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST') then a.ST_ID else null end) YTD_Distinct_All_Companies
		, COUNT(distinct case when DATEDIFF(d,ORDER_DATE,BEGIN_DATE) >= Days_Out and len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST') and a.TOTAL_PAYMENTS > 0 then a.ST_ID else null end) YTD_Distinct_Paid_Companies
		, COUNT(distinct case when DATEDIFF(d,ORDER_DATE,BEGIN_DATE) >= Days_Out and len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST') and a.TOTAL_PAYMENTS = 0 then a.ST_ID else null end) YTD_Distinct_Comp_Companies
		, COUNT(distinct case when DATEDIFF(d,ORDER_DATE,BEGIN_DATE) >= Days_Out and len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST') and a.TOTAL_PAYMENTS < 0 then a.ST_ID else null end) YTD_Distinct_Owed_Companies

	from (
		--Dump of meeting - regular members
			select * from ##sp_ICSC_Meetings_Overview_1
	) a
	group by a.MEETING_TYPE, a.MEETING, a.BEGIN_DATE, a.Prior_Year_Code, a.TITLE, a.COUNTRY, a.STATE_PROVINCE, a.Region


	union all

	--Count of attendees w/ no ID
	select a.MEETING_TYPE, a.MEETING, a.BEGIN_DATE, a.Prior_Year_Code, a.TITLE, a.COUNTRY, a.STATE_PROVINCE, a.Region
		, COUNT(case when not(len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST')) then a.ST_ID else null end) Distinct_All_Attendees
		, COUNT(case when not(len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST')) and a.TOTAL_PAYMENTS > 0 then a.ST_ID else null end) Distinct_Paid_Attendees
		, COUNT(case when not(len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST')) and a.TOTAL_PAYMENTS = 0 then a.ST_ID else null end) Distinct_Comp_Attendees
		, COUNT(case when not(len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST')) and a.TOTAL_PAYMENTS < 0 then a.ST_ID else null end) Distinct_Owed_Attendees
		, COUNT(case when len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST') then a.ST_ID else null end) Distinct_All_Companies
		, COUNT(case when len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST') and a.TOTAL_PAYMENTS > 0 then a.ST_ID else null end) Distinct_Paid_Companies
		, COUNT(case when len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST') and a.TOTAL_PAYMENTS = 0 then a.ST_ID else null end) Distinct_Comp_Companies
		, COUNT(case when len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST') and a.TOTAL_PAYMENTS < 0 then a.ST_ID else null end) Distinct_Owed_Companies
		, SUM(a.TOTAL_PAYMENTS) Full_Year_Revenue
		, SUM(case when DATEDIFF(d,ORDER_DATE,BEGIN_DATE) >= Days_Out then a.TOTAL_PAYMENTS else 0 end) YTD_Revenue
		, COUNT(case when DATEDIFF(d,ORDER_DATE,BEGIN_DATE) >= Days_Out and not(len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST')) then a.ST_ID else null end) YTD_Distinct_All_Attendees
		, COUNT(case when DATEDIFF(d,ORDER_DATE,BEGIN_DATE) >= Days_Out and not(len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST')) and a.TOTAL_PAYMENTS > 0 then a.ST_ID else null end) YTD_Distinct_Paid_Attendees
		, COUNT(case when DATEDIFF(d,ORDER_DATE,BEGIN_DATE) >= Days_Out and not(len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST')) and a.TOTAL_PAYMENTS = 0 then a.ST_ID else null end) YTD_Distinct_Comp_Attendees
		, COUNT(case when DATEDIFF(d,ORDER_DATE,BEGIN_DATE) >= Days_Out and not(len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST')) and a.TOTAL_PAYMENTS < 0 then a.ST_ID else null end) YTD_Distinct_Owed_Attendees
		, COUNT(case when DATEDIFF(d,ORDER_DATE,BEGIN_DATE) >= Days_Out and len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST') then a.ST_ID else null end) YTD_Distinct_All_Companies
		, COUNT(case when DATEDIFF(d,ORDER_DATE,BEGIN_DATE) >= Days_Out and len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST') and a.TOTAL_PAYMENTS > 0 then a.ST_ID else null end) YTD_Distinct_Paid_Companies
		, COUNT(case when DATEDIFF(d,ORDER_DATE,BEGIN_DATE) >= Days_Out and len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST') and a.TOTAL_PAYMENTS = 0 then a.ST_ID else null end) YTD_Distinct_Comp_Companies
		, COUNT(case when DATEDIFF(d,ORDER_DATE,BEGIN_DATE) >= Days_Out and len(a.MEMBER_TYPE) = 2 and a.MEMBER_TYPE not in ('MR','SC','SM','ST') and a.TOTAL_PAYMENTS < 0 then a.ST_ID else null end) YTD_Distinct_Owed_Companies

	from (
		--Dump of meetings - no ID
			select * from ##sp_ICSC_Meetings_Overview_2
	) a
	group by a.MEETING_TYPE, a.MEETING, a.BEGIN_DATE, a.Prior_Year_Code, a.TITLE, a.COUNTRY, a.STATE_PROVINCE, a.Region
) b
left join Meeting_Types mt on b.MEETING_TYPE = left(mt.CODE,5)
group by year(b.BEGIN_DATE), b.BEGIN_DATE, b.MEETING, b.MEETING_TYPE, mt.DESCRIPTION, b.Prior_Year_Code, b.TITLE
order by year(b.BEGIN_DATE), b.MEETING_TYPE

select isnull(cy.COUNTRY,ly.COUNTRY)				Country
	, isnull(cy.STATE_PROVINCE,ly.STATE_PROVINCE)	STATE_PROVINCE
	, isnull(cy.Region,LY.Region)					Region
	, cy.Meet_Year									CY_Meet_Year
	, cy.MEETING									CY_MEETING
	, cy.BEGIN_DATE									CY_BEGIN_DATE
	, cy.TITLE										CY_TITLE
	, cy.MEETING_TYPE								CY_MEETING_TYPE
	, cy.DESCRIPTION								CY_DESCRIPTION
	, cy.Prior_Year_Code							CY_Prior_Year_Code
	, cy.Mtg_Count									CY_Mtg_Count
	, cy.Distinct_All_Attendees						CY_Distinct_All_Attendees
	, cy.Distinct_Paid_Attendees					CY_Distinct_Paid_Attendees
	, cy.Distinct_Comp_Attendees					CY_Distinct_Comp_Attendees
	, cy.Distinct_Owed_Attendees					CY_Distinct_Owed_Attendees
	, cy.Distinct_All_Companies						CY_Distinct_All_Companies
	, cy.Distinct_Paid_Companies					CY_Distinct_Paid_Companies
	, cy.Distinct_Comp_Companies					CY_Distinct_Comp_Companies
	, cy.Distinct_Owed_Companies					CY_Distinct_Owed_Companies
	, cy.Full_Year_Revenue							CY_Full_Year_Revenue
	, cy.YTD_Distinct_All_Attendees					CY_YTD_Distinct_All_Attendees
	, cy.YTD_Distinct_Paid_Attendees				CY_YTD_Distinct_Paid_Attendees
	, cy.YTD_Distinct_Comp_Attendees				CY_YTD_Distinct_Comp_Attendees
	, cy.YTD_Distinct_Owed_Attendees				CY_YTD_Distinct_Owed_Attendees
	, cy.YTD_Distinct_All_Companies					CY_YTD_Distinct_All_Companies
	, cy.YTD_Distinct_Paid_Companies				CY_YTD_Distinct_Paid_Companies
	, cy.YTD_Distinct_Comp_Companies				CY_YTD_Distinct_Comp_Companies
	, cy.YTD_Distinct_Owed_Companies				CY_YTD_Distinct_Owed_Companies
	, cy.YTD_Revenue								CY_YTD_Revenue

	, ly.Meet_Year									LY_Meet_Year
	, ly.MEETING									LY_MEETING
	, ly.BEGIN_DATE									LY_BEGIN_DATE
	, ly.TITLE										LY_TITLE
	, ly.MEETING_TYPE								LY_MEETING_TYPE
	, ly.DESCRIPTION								LY_DESCRIPTION
	, ly.Prior_Year_Code							LY_Prior_Year_Code
	, ly.Mtg_Count									LY_Mtg_Count
	, ly.Distinct_All_Attendees						LY_Distinct_All_Attendees
	, ly.Distinct_Paid_Attendees					LY_Distinct_Paid_Attendees
	, ly.Distinct_Comp_Attendees					LY_Distinct_Comp_Attendees
	, ly.Distinct_Owed_Attendees					LY_Distinct_Owed_Attendees
	, ly.Distinct_All_Companies						LY_Distinct_All_Companies
	, ly.Distinct_Paid_Companies					LY_Distinct_Paid_Companies
	, ly.Distinct_Comp_Companies					LY_Distinct_Comp_Companies
	, ly.Distinct_Owed_Companies					LY_Distinct_Owed_Companies
	, ly.Full_Year_Revenue							LY_Full_Year_Revenue
	, ly.YTD_Distinct_All_Attendees					LY_YTD_Distinct_All_Attendees
	, ly.YTD_Distinct_Paid_Attendees				LY_YTD_Distinct_Paid_Attendees
	, ly.YTD_Distinct_Comp_Attendees				LY_YTD_Distinct_Comp_Attendees
	, ly.YTD_Distinct_Owed_Attendees				LY_YTD_Distinct_Owed_Attendees
	, ly.YTD_Distinct_All_Companies					LY_YTD_Distinct_All_Companies
	, ly.YTD_Distinct_Paid_Companies				LY_YTD_Distinct_Paid_Companies
	, ly.YTD_Distinct_Comp_Companies				LY_YTD_Distinct_Comp_Companies
	, ly.YTD_Distinct_Owed_Companies				LY_YTD_Distinct_Owed_Companies
	, ly.YTD_Revenue								LY_YTD_Revenue

from ##sp_ICSC_Meetings_Overview cy
	full outer join ##sp_ICSC_Meetings_Overview ly on cy.Prior_Year_Code = ly.MEETING
where cy.Meet_Year = @YearCompare
	or (cy.Meet_Year is null and ly.Meet_Year <> @YearCompare)