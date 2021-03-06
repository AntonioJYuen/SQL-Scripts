IF OBJECT_ID('tempdb.dbo.##Weeks_Out', 'U') IS NOT NULL
	drop table ##Weeks_Out

--Current Year Metrics
select p.PRODUCT_MAJOR CY_Meeting
	, (select MUF_1 from Meet_Master where MEETING = p.PRODUCT_MAJOR) LY_Meeting
	, p.PRODUCT_MINOR Product_Code
	, p.TITLE
	, sum(case when n.COMPANY_RECORD = 1 then 1 else 0 end) CY_Total_Companies
	, sum(case when n.COMPANY_RECORD = 0 then 1 else 0 end) CY_Total_Attendees
	, isnull(cast(sum(ol.QUANTITY_ORDERED) as decimal),0) CY_Total_Orders
	, isnull(cast(sum(ol.QUANTITY_ORDERED * pf.EXPECTED_ATTENDANCE) as decimal),0) CY_Total_Square_Footage
	, isnull(cast(sum(ol.QUANTITY_ORDERED * ol.UNIT_PRICE) as decimal),0) CY_Total_Payment
	, isnull(cast(max(pf.GUARANTEED_ATTENDANCE) as decimal),0) CY_Total_Budgeted_Orders
	, isnull(cast(max(pf.GUARANTEED_ATTENDANCE * pf.EXPECTED_ATTENDANCE) as decimal),0) CY_Total_Budgeted_Footage
	, isnull(cast(max(pf.SETTINGS) as decimal),0) CY_Total_Budgeted_Revenue
	, 0 LY_Total_Orders_YTD
	, 0 LY_Total_Square_Footage_YTD
	, 0 LY_Total_Payment_YTD
	, 0 LY_Total_Orders
	, 0 LY_Total_Square_Footage
	, 0 LY_Total_Payment
	, 0 LY_Total_Companies
	, 0 LY_Total_Attendees
	into ##Weeks_Out
from product p
	left join Product_Function pf on p.PRODUCT_CODE = pf.PRODUCT_CODE
	left join Order_Lines ol on p.PRODUCT_CODE = ol.PRODUCT_CODE
	left join Orders o on ol.ORDER_NUMBER = o.ORDER_NUMBER
	left join Name n on o.ST_ID = n.ID
	left join order_meet om on o.ORDER_NUMBER = om.ORDER_NUMBER
	left join Meet_Master mm on om.MEETING = mm.MEETING
where p.PRODUCT_MAJOR in (select distinct MEETING from Meet_Master mm where year(mm.BEGIN_DATE) >= year(getdate()))
group by p.PRODUCT_MAJOR, p.PRODUCT_MINOR, p.TITLE

--Insert Last Year Metric Totals
DECLARE db_cursor cursor fast_forward for
select (select top 1 CY_MEETING from ##Weeks_Out t where t.LY_Meeting = mm.MEETING)
	, mm.MEETING
	, p.PRODUCT_MINOR PRODUCT_CODE
	, p.TITLE
	, sum(case when n.COMPANY_RECORD = 1 then 1 else 0 end) LY_Total_Companies
	, sum(case when n.COMPANY_RECORD = 0 then 1 else 0 end) LY_Total_Attendees
	, isnull(cast(sum(ol.QUANTITY_ORDERED) as decimal),0) LY_Total_Orders
	, isnull(cast(sum(ol.QUANTITY_ORDERED * pf.EXPECTED_ATTENDANCE) as decimal),0) LY_Total_Square_Footage
	, isnull(cast(sum(ol.QUANTITY_ORDERED * ol.UNIT_PRICE) as decimal),0) LY_Total_Payment
from product p
	left join Product_Function pf on p.PRODUCT_CODE = pf.PRODUCT_CODE
	left join Order_Lines ol on p.PRODUCT_CODE = ol.PRODUCT_CODE
	left join Orders o on ol.ORDER_NUMBER = o.ORDER_NUMBER
	left join Name n on o.ST_ID = n.ID
	left join order_meet om on o.ORDER_NUMBER = om.ORDER_NUMBER
	left join Meet_Master mm on om.MEETING = mm.MEETING
where mm.MEETING in (select distinct mm.MUF_1 from ##Weeks_Out t inner join Meet_Master mm on t.CY_Meeting = mm.MEETING)
group by mm.Meeting, p.PRODUCT_MINOR, p.TITLE

Declare @CY_Meeting as varchar(max)
Declare @LY_Meeting as varchar(max)
Declare @Product_Code as varchar(max)
Declare @Title as varchar(max)
Declare @LY_Total_Companies as decimal
Declare @LY_Total_Attendees as decimal
Declare @LY_Total_Orders as decimal
Declare @LY_Total_Square_Footage as decimal
Declare @LY_Total_Payment as decimal

OPEN db_cursor
FETCH NEXT from db_cursor into @CY_Meeting, @LY_Meeting, @Product_Code, @Title, @LY_Total_Companies, @LY_Total_Attendees, @LY_Total_Orders, @LY_Total_Square_Footage, @LY_Total_Payment

while @@FETCH_STATUS = 0
BEGIN
	
	update ##Weeks_Out
	set LY_Total_Orders = @LY_Total_Orders, LY_Total_Square_Footage = @LY_Total_Payment, LY_Total_Payment = @LY_Total_Payment, LY_Total_Companies = @LY_Total_Companies, LY_Total_Attendees = @LY_Total_Attendees
	where LY_Meeting = @LY_Meeting and Product_Code = @Product_Code

	If @@ROWCOUNT = 0
		insert into ##Weeks_Out (CY_Meeting, LY_Meeting, Product_Code, Title, CY_Total_Companies, CY_Total_Orders, CY_Total_Square_Footage, CY_Total_Payment, CY_Total_Budgeted_Orders, CY_Total_Budgeted_Footage, CY_Total_Budgeted_Revenue, LY_Total_Orders_YTD, LY_Total_Square_Footage_YTD, LY_Total_Payment_YTD, LY_Total_Orders, LY_Total_Square_Footage, LY_Total_Payment, LY_Total_Companies, LY_Total_Attendees)
		select @CY_Meeting, @LY_Meeting, @Product_Code, @Title, 0, 0, 0, 0, 0, 0, 0, 0, 0, @LY_Total_Orders, @LY_Total_Square_Footage, @LY_Total_Payment, @LY_Total_Companies, 0, @LY_Total_Attendees

	set @CY_Meeting = ''
	set @LY_Meeting = ''
	set @Product_Code = ''
	set @Title = ''
	set @LY_Total_Companies = 0
	set @LY_Total_Attendees = 0
	set @LY_Total_Orders = 0
	set @LY_Total_Square_Footage = 0
	set @LY_Total_Payment = 0

	FETCH NEXT from db_cursor into @CY_Meeting, @LY_Meeting, @Product_Code, @Title, @LY_Total_Companies, @LY_Total_Attendees, @LY_Total_Orders, @LY_Total_Square_Footage, @LY_Total_Payment
END

	CLOSE db_cursor
	DEALLOCATE db_cursor

--Insert Last Year YTD Metric Totals
DECLARE db_cursor cursor fast_forward for
select (select top 1 CY_MEETING from ##Weeks_Out t where t.LY_Meeting = mm.MEETING)
	, mm.MEETING
	, p.PRODUCT_MINOR PRODUCT_CODE
	, p.TITLE
	, isnull(cast(sum(ol.QUANTITY_ORDERED) as decimal),0) LY_Total_Orders_YTD
	, isnull(cast(sum(ol.QUANTITY_ORDERED * pf.EXPECTED_ATTENDANCE) as decimal),0) LY_Total_Square_Footage_YTD
	, isnull(cast(sum(ol.QUANTITY_ORDERED * ol.UNIT_PRICE) as decimal),0) LY_Total_Payment_YTD
from product p
	left join Product_Function pf on p.PRODUCT_CODE = pf.PRODUCT_CODE
	left join Order_Lines ol on p.PRODUCT_CODE = ol.PRODUCT_CODE
	left join Orders o on ol.ORDER_NUMBER = o.ORDER_NUMBER
	left join order_meet om on o.ORDER_NUMBER = om.ORDER_NUMBER
	left join Meet_Master mm on om.MEETING = mm.MEETING
where o.ORDER_DATE <= 
		cast(year(mm.BEGIN_DATE) as varchar(4)) + '-' + 
		cast(month(getdate()) as varchar(2)) + '-' + cast(day(getdate()) as varchar(2))
		and mm.MEETING in (select distinct LY_Meeting from ##Weeks_Out)
group by mm.Meeting, p.PRODUCT_MINOR, p.TITLE

OPEN db_cursor
FETCH NEXT from db_cursor into @CY_Meeting, @LY_Meeting, @Product_Code, @Title, @LY_Total_Orders, @LY_Total_Square_Footage, @LY_Total_Payment

while @@FETCH_STATUS = 0
BEGIN
	
	update ##Weeks_Out
	set LY_Total_Orders_YTD = @LY_Total_Orders, LY_Total_Square_Footage_YTD = @LY_Total_Payment, LY_Total_Payment_YTD = @LY_Total_Payment
	where LY_Meeting = @LY_Meeting and Product_Code = @Product_Code

	set @CY_Meeting = ''
	set @LY_Meeting = ''
	set @Product_Code = ''
	set @Title = ''
	set @LY_Total_Orders = 0
	set @LY_Total_Square_Footage = 0
	set @LY_Total_Payment = 0

	FETCH NEXT from db_cursor into @CY_Meeting, @LY_Meeting, @Product_Code, @Title, @LY_Total_Orders, @LY_Total_Square_Footage, @LY_Total_Payment
END

	CLOSE db_cursor
	DEALLOCATE db_cursor

--Print Report
select t.CY_Meeting, t.LY_Meeting, mm.TITLE, t.TITLE, mm.CITY, mm.STATE_PROVINCE, mm.COUNTRY, t.LY_Total_Attendees
	, case when mm.begin_date <= getdate() then CY_Totals.CY_Total else 0 end CY_Number_Attended
	, case when mm.begin_date > getdate() then CY_Totals.CY_Total else 0 end CY_Number_Register
	, t.CY_Total_Payment, LY_Total_Payment 
from ##Weeks_Out t
	inner join Meet_Master mm on t.CY_Meeting = mm.MEETING
	inner join (select meeting, count(st_id) CY_Total from (select distinct meeting, st_id from orders o inner join order_meet om on o.ORDER_NUMBER = om.ORDER_NUMBER where o.STATUS not like 'C%')a group by MEETING) CY_Totals on t.CY_Meeting = CY_Totals.MEETING 
order by Begin_Date, CY_Meeting--, left(Product_code + '0', PATINDEX('%[0-9]%', Product_Code + '0')-1), CAST(SUBSTRING(Product_Code + '0', PATINDEX('%[0-9]%', Product_Code + '0'), LEN(Product_Code + '0')) AS INT)

select mm.MEETING, mt.description MEETING_TYPE, mm.MUF_1 ,mm.TITLE, mm.CITY, mm.STATE_PROVINCE, mm.COUNTRY, mm.BEGIN_DATE, datediff(ww,getdate(),mm.BEGIN_DATE) Weeks_Out
	, case when getdate() >= mm.BEGIN_DATE  then count(o.ST_ID) else 0 end CY_Attendence
	, case when getdate() < mm.BEGIN_DATE then count(o.ST_ID) else 0 end CY_Registers, sum(o.TOTAL_PAYMENTS) CY_Revenue
	, mm.muf_5 CY_Expected_Attendence, mm.muf_10 CY_Expected_Revenue
	, ly.LY_Total_Attendence, ly.LY_Total_Payments LY_Revenue, ly.LY_Expected_Attendence, ly.LY_Expected_Revenue
from Meet_Master mm 
	inner join meeting_types mt on mm.MEETING_TYPE = mt.code
	left join order_meet om on mm.MEETING = om.MEETING
	left join orders o on om.ORDER_NUMBER = o.ORDER_NUMBER and o.STATUS not like 'C%'
	left join (select lyom.MEETING, count(st_id) LY_Total_Attendence, sum(lyo.TOTAL_PAYMENTS) LY_Total_Payments, lymm.MUF_5 LY_Expected_Attendence, lymm.muf_10 LY_Expected_Revenue
				from order_meet lyom
					inner join orders lyo on lyom.ORDER_NUMBER = lyo.ORDER_NUMBER and lyo.STATUS not like 'C%'
					inner join Meet_Master lymm on lyom.MEETING = lymm.MEETING
				where lyom.MEETING in (select distinct MUF_1 from Meet_Master where year(BEGIN_DATE) = 2016) and lyom.MEETING <> ''
				group by lyom.MEETING, lymm.MUF_5, lymm.muf_10) LY on mm.MUF_1 = LY.MEETING
where year(mm.BEGIN_DATE) = 2016
group by mm.MEETING, mt.description, mm.MUF_1 ,mm.TITLE, mm.CITY, mm.STATE_PROVINCE, mm.COUNTRY, datediff(ww,getdate(),mm.BEGIN_DATE), mm.muf_5, mm.muf_10
	,ly.LY_Total_Attendence, ly.LY_Total_Payments, ly.LY_Expected_Attendence, ly.LY_Expected_Revenue, mm.BEGIN_DATE
order by mm.BEGIN_DATE