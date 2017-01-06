IF OBJECT_ID('tempdb.dbo.##Tmp_Weeks_Out', 'U') IS NOT NULL
	drop table ##Tmp_Weeks_Out;

create table ##Tmp_Weeks_out (MEETING varchar(10), Meeting_Type varchar(max), CY_Spons_Code varchar(10), CY_Expo1_Code varchar(10), CY_Expo2_Code varchar(10)
	, Last_Year_Code varchar(10), LY_Spons_Code varchar(10), LY_Expo1_Code varchar(10), LY_Expo2_Code varchar(10)
	, TITLE varchar(max), City varchar(max), STATE_PROVINCE varchar(max), Country varchar(max), Begin_Date date, Weeks_Out int, Product_Minor varchar(max)
	, [Description] varchar(max), CY_Unique_Registrants int, CY_QTY_Ordered numeric, CY_Revenue money, CY_Expected_Attendence varchar(max), CY_Expected_Revenue varchar(max), CY_Spon_Revenue money
	, CY_Expo1_Revenue money, CY_Expo2_Revenue money
	, LY_Unique_Registrants int, LY_QTY_Ordered numeric, LY_Revenue money, LY_Expected_Attendence varchar(max), LY_Expected_Revenue varchar(max), LY_Spon_Revenue money
	, LY_Expo1_Revenue money, LY_Expo2_Revenue money, INCOME_ACCOUNT varchar(max), DEFERRED_INCOME_ACCOUNT varchar(max))

insert into ##Tmp_Weeks_out
select distinct * --into ##Tmp_Weeks_Out
from (
	select mm.MEETING, mt.DESCRIPTION Meeting_Type, mm.MUF_2 Spons_Code, mm.MUF_3 Expo1_Code, mm.MUF_4 Expo2_Code
		, mm.MUF_1 Last_Year_Code, mm2.MUF_2, mm2.MUF_3, mm2.MUF_4
		, mm.TITLE, mm.CITY, mm.STATE_PROVINCE, mm.COUNTRY, mm.BEGIN_DATE, case when datediff(ww,getdate(),mm.BEGIN_DATE) < 0 then 0 else datediff(ww,getdate(),mm.BEGIN_DATE) end Weeks_Out, PRODUCT_MINOR
		, '' Description, '' CY_Unique_Registrants, 0 CY_QTY_Ordered, 0 CY_Revenue, 0 CY_Expected_Attendence, 0 CY_Expected_Revenue, 0 CY_Spon_Revenue, 0 CY_Expo1_Revenue, 0 CY_Expo2_Revenue
		, '' LY_Unique_Registrants, 0 LY_QTY_Ordered, 0 LY_Revenue, 0 LY_Expected_Attendence, 0 LY_Expected_Revenue, 0 LY_Spon_Revenue, 0 LY_Expo1_Revenue, 0 LY_Expo2_Revenue
		, '' INCOME_ACCOUNT, '' DEFERRED_INCOME_ACCOUNT
	from Meet_Master mm
		left join Meeting_Types mt on mm.MEETING_TYPE = left(mt.CODE,5)
		left join Meet_Master mm2 on mm.MUF_1 = mm2.MEETING
		inner join Product p on mm.MEETING = p.PRODUCT_MAJOR
	where mm.MEETING_TYPE not in ('SPON','EXPO')

	union
	
	select mm.MEETING, mt.DESCRIPTION Meeting_Type, mm.MUF_2 Spons_Code, mm.MUF_3 Expo1_Code, mm.MUF_4 Expo2_Code
		, mm.MUF_1 Last_Year_Code, mm2.MUF_2, mm2.MUF_3, mm2.MUF_4
		, mm.TITLE, mm.CITY, mm.STATE_PROVINCE, mm.COUNTRY, mm.BEGIN_DATE, case when datediff(ww,getdate(),mm.BEGIN_DATE) < 0 then 0 else datediff(ww,getdate(),mm.BEGIN_DATE) end Weeks_Out, PRODUCT_MINOR
		, '' Description, '' CY_Unique_Registrants, 0 CY_QTY_Ordered, 0 CY_Revenue, 0 CY_Expected_Attendence, 0 CY_Expected_Revenue, 0 CY_Spon_Revenue, 0 CY_Expo1_Revenue, 0 CY_Expo2_Revenue
		, '' LY_Unique_Registrants, 0 LY_QTY_Ordered, 0 LY_Revenue, 0 LY_Expected_Attendence, 0 LY_Expected_Revenue, 0 LY_Spon_Revenue, 0 LY_Expo1_Revenue, 0 LY_Expo2_Revenue
		, '' INCOME_ACCOUNT, '' DEFERRED_INCOME_ACCOUNT
	from Meet_Master mm
		left join Meeting_Types mt on mm.MEETING_TYPE = left(mt.CODE,5)
		left join Meet_Master mm2 on mm.muf_1 = mm2.MEETING
		left join Product p2 on mm2.MEETING = p2.PRODUCT_MAJOR
	where mm.MEETING_TYPE not in ('SPON','EXPO')
)a
where PRODUCT_MINOR is not null
	and BEGIN_DATE >= '2016-1-1'
	and BEGIN_DATE <= '2016-12-31'

--Update product descriptions
update t
set t.[Description] = p.TITLE
from Product p
	inner join ##Tmp_Weeks_Out t on p.PRODUCT_MAJOR = t.MEETING and p.PRODUCT_MINOR = t.PRODUCT_MINOR

update t
set t.[Description] = p.TITLE
from Product p
	inner join ##Tmp_Weeks_Out t on p.PRODUCT_MAJOR = t.Last_Year_Code and p.PRODUCT_MINOR = t.PRODUCT_MINOR and t.Description = ''

--Update CY Unique Reg/Budgeted Attendence and Revenue
update t
set t.CY_Unique_Registrants = CT
	, t.CY_Expected_Attendence = a.MUF_5
	, t.CY_Expected_Revenue = a.MUF_10
from
(
	select om.meeting, MUF_5, MUF_10, count(o.st_id) CT
	from orders o
		inner join Order_Meet om on o.ORDER_NUMBER = om.ORDER_NUMBER
		inner join Meet_Master mm on om.MEETING = mm.MEETING
	where o.STATUS not like 'C%'
		and om.MEETING in (select distinct MEETING from ##Tmp_Weeks_out)
	group by om.MEETING, MUF_5, MUF_10
) a
inner join ##Tmp_Weeks_out t on a.MEETING = t.MEETING

--Update LY Unique Reg/Budgeted Attendence and Revenue
update t
set t.LY_Unique_Registrants = CT
	, t.LY_Expected_Attendence = a.MUF_5
	, t.LY_Expected_Revenue = a.MUF_10
from
(
	select om.meeting, MUF_5, MUF_10, count(o.st_id) CT
	from orders o
		inner join Order_Meet om on o.ORDER_NUMBER = om.ORDER_NUMBER
		inner join Meet_Master mm on om.MEETING = mm.MEETING
	where o.STATUS not like 'C%'
		and om.MEETING in (select distinct Last_Year_Code from ##Tmp_Weeks_out)
		and om.MEETING <> ''
	group by om.MEETING, MUF_5, MUF_10
) a
inner join ##Tmp_Weeks_out t on a.MEETING = t.Last_Year_Code

--Update CY product Qty and Revenue
update t
set t.CY_QTY_Ordered = a.CT
	, t.CY_Revenue = a.Revenue
from
(
	select om.meeting, p.PRODUCT_MINOR, sum(ol.QUANTITY_ORDERED) CT, sum(ol.QUANTITY_ORDERED * ol.UNIT_PRICE) Revenue
	from orders o
		inner join Order_Meet om on o.ORDER_NUMBER = om.ORDER_NUMBER
		inner join Order_Lines ol on o.ORDER_NUMBER = ol.ORDER_NUMBER
		inner join Product p on ol.PRODUCT_CODE = p.PRODUCT_CODE
		inner join Meet_Master mm on om.MEETING = mm.MEETING
	where o.STATUS not like 'C%'
		and om.MEETING in (select distinct MEETING from ##Tmp_Weeks_out)
	group by om.MEETING, p.PRODUCT_MINOR
) a
inner join ##Tmp_Weeks_out t on a.MEETING = t.MEETING and a.PRODUCT_MINOR = t.Product_Minor

--Update LY product Qty and Revenue
update t
set t.LY_QTY_Ordered = a.CT
	, t.LY_Revenue = a.Revenue
from
(
	select om.meeting, p.PRODUCT_MINOR, sum(ol.QUANTITY_ORDERED) CT, sum(ol.QUANTITY_ORDERED * ol.UNIT_PRICE) Revenue
	from orders o
		inner join Order_Meet om on o.ORDER_NUMBER = om.ORDER_NUMBER
		inner join Order_Lines ol on o.ORDER_NUMBER = ol.ORDER_NUMBER
		inner join Product p on ol.PRODUCT_CODE = p.PRODUCT_CODE
		inner join Meet_Master mm on om.MEETING = mm.MEETING
	where o.STATUS not like 'C%'
		and om.MEETING in (select distinct Last_Year_Code from ##Tmp_Weeks_out)
	group by om.MEETING, p.PRODUCT_MINOR
) a
inner join ##Tmp_Weeks_out t on a.MEETING = t.Last_Year_Code and a.PRODUCT_MINOR = t.Product_Minor

--CY Sponsorship Revenue
update t
set t.CY_Spon_Revenue = a.Revenue
from
(
	select om.meeting, sum(o.TOTAL_PAYMENTS) Revenue
	from orders o
		inner join Order_Meet om on o.ORDER_NUMBER = om.ORDER_NUMBER
		inner join Meet_Master mm on om.MEETING = mm.MEETING
	where o.STATUS not like 'C%'
		and om.MEETING in (select distinct CY_Spons_Code from ##Tmp_Weeks_out)
		and om.MEETING <> ''
	group by om.MEETING
) a
inner join ##Tmp_Weeks_out t on a.MEETING = t.CY_Spons_Code

--LY Sponsorship Revenue
update t
set t.LY_Spon_Revenue = a.Revenue
from
(
	select om.meeting, sum(o.TOTAL_PAYMENTS) Revenue
	from orders o
		inner join Order_Meet om on o.ORDER_NUMBER = om.ORDER_NUMBER
		inner join Meet_Master mm on om.MEETING = mm.MEETING
	where o.STATUS not like 'C%'
		and om.MEETING in (select distinct LY_Spons_Code from ##Tmp_Weeks_out)
		and om.MEETING <> ''
	group by om.MEETING
) a
inner join ##Tmp_Weeks_out t on a.MEETING = t.LY_Spons_Code

--CY Expo1 Revenue
update t
set t.CY_Expo1_Revenue = a.Revenue
from
(
	select om.meeting, sum(o.TOTAL_PAYMENTS) Revenue
	from orders o
		inner join Order_Meet om on o.ORDER_NUMBER = om.ORDER_NUMBER
		inner join Meet_Master mm on om.MEETING = mm.MEETING
	where o.STATUS not like 'C%'
		and om.MEETING in (select distinct CY_Expo1_Code from ##Tmp_Weeks_out)
		and om.MEETING <> ''
	group by om.MEETING
) a
inner join ##Tmp_Weeks_out t on a.MEETING = t.CY_Expo1_Code

--CY Expo1 Revenue
update t
set t.LY_Expo1_Revenue = a.Revenue
from
(
	select om.meeting, sum(o.TOTAL_PAYMENTS) Revenue
	from orders o
		inner join Order_Meet om on o.ORDER_NUMBER = om.ORDER_NUMBER
		inner join Meet_Master mm on om.MEETING = mm.MEETING
	where o.STATUS not like 'C%'
		and om.MEETING in (select distinct LY_Expo1_Code from ##Tmp_Weeks_out)
		and om.MEETING <> ''
	group by om.MEETING
) a
inner join ##Tmp_Weeks_out t on a.MEETING = t.LY_Expo1_Code

--CY Expo2 Revenue
update t
set t.CY_Expo2_Revenue = a.Revenue
from
(
	select om.meeting, sum(o.TOTAL_PAYMENTS) Revenue
	from orders o
		inner join Order_Meet om on o.ORDER_NUMBER = om.ORDER_NUMBER
		inner join Meet_Master mm on om.MEETING = mm.MEETING
	where o.STATUS not like 'C%'
		and om.MEETING in (select distinct CY_Expo2_Code from ##Tmp_Weeks_out)
		and om.MEETING <> ''
	group by om.MEETING
) a
inner join ##Tmp_Weeks_out t on a.MEETING = t.CY_Expo2_Code

--CY Expo2 Revenue
update t
set t.LY_Expo2_Revenue = a.Revenue
from
(
	select om.meeting, sum(o.TOTAL_PAYMENTS) Revenue
	from orders o
		inner join Order_Meet om on o.ORDER_NUMBER = om.ORDER_NUMBER
		inner join Meet_Master mm on om.MEETING = mm.MEETING
	where o.STATUS not like 'C%'
		and om.MEETING in (select distinct LY_Expo2_Code from ##Tmp_Weeks_out)
		and om.MEETING <> ''
	group by om.MEETING
) a
inner join ##Tmp_Weeks_out t on a.MEETING = t.LY_Expo2_Code

--Update Income Accounts
update t
set t.INCOME_ACCOUNT = a.INCOME_ACCOUNT
	, t.DEFERRED_INCOME_ACCOUNT = a.DEFERRED_INCOME_ACCOUNT
from ##Tmp_Weeks_out t 
inner join (
	select p.PRODUCT_MAJOR, p.PRODUCT_MINOR
		, case when max(p.INCOME_ACCOUNT) = '' then max(pp.INCOME_ACCOUNT) else max(p.INCOME_ACCOUNT) end INCOME_ACCOUNT
		, case when max(p.DEFERRED_INCOME_ACCOUNT) = '' then max(pp.DEFERRED_INCOME_ACCOUNT) else max(p.DEFERRED_INCOME_ACCOUNT) end DEFERRED_INCOME_ACCOUNT
	from product p
		left join Product_Price pp on p.PRODUCT_CODE = pp.PRODUCT_CODE
	where p.PRODUCT_CODE like '2016%'
		and p.COMPLIMENTARY = 0
		and pp.COMPLIMENTARY = 0
	group by p.PRODUCT_MAJOR, p.PRODUCT_MINOR
) a on t.MEETING = a.PRODUCT_MAJOR and t.PRODUCT_MINOR = a.PRODUCT_MINOR

--Little Bit of Clean Up
update t
set t.CY_Unique_Registrants = NULL
	, t.CY_Expected_Attendence = NULL
	, t.CY_Expected_Revenue = NULL
	, t.CY_Spon_Revenue = NULL
	, t.CY_Expo1_Revenue = NULL
	, t.CY_Expo2_Revenue = NULL
	, t.LY_Unique_Registrants = NULL
	, t.LY_Expected_Attendence = NULL
	, t.LY_Expected_Revenue = NULL
	, t.LY_Spon_Revenue = NULL
	, t.LY_Expo1_Revenue = NULL
	, t.LY_Expo2_Revenue = NULL
from ##Tmp_Weeks_out t
where t.MEETING + t.Product_Minor not in (
		select a.MEETING + a.Product_Minor
		from (
			select *, ROW_NUMBER() over (PARTITION by t.MEETING order by t.MEETING, t.PRODUCT_MINOR) Row_Num
			from ##Tmp_Weeks_out t
		) a
		where Row_Num = 1)


select *
from ##Tmp_Weeks_out