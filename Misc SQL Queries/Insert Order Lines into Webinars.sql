--DECLARE @Meeting varchar(10)
--SET @Meeting = '2015WB1'

--Clear Temp Tables
IF OBJECT_ID(N'tempdb..##PRODUCT_CODES', N'U') IS NOT NULL
DROP TABLE ##PRODUCT_CODES
IF OBJECT_ID(N'tempdb..##MEM_SUB_PRODUCTS', N'U') IS NOT NULL
DROP TABLE ##MEM_SUB_PRODUCTS
IF OBJECT_ID(N'tempdb..##MEM_FIX_PRODUCTS', N'U') IS NOT NULL
DROP TABLE ##MEM_FIX_PRODUCTS
IF OBJECT_ID(N'tempdb..##SUB_PRODUCTS', N'U') IS NOT NULL
DROP TABLE ##SUB_PRODUCTS

--Create Temp Tables
CREATE TABLE ##SUB_PRODUCTS (PRODUCT_CODE varchar(31), MEETING varchar(10), DESCRIPTION varchar(60), CEU_TYPE varchar(15), CEU_AWARDED numeric(15,2))
CREATE TABLE ##PRODUCT_CODES (ST_ID varchar(15), PRODUCT_CODE varchar(31), ORDER_NUMBER numeric(15, 2), MEETING varchar(10))
CREATE TABLE ##MEM_SUB_PRODUCTS (ST_ID varchar(15), PRODUCT_CODE varchar(31), ORDER_NUMBER numeric(15, 2), MEETING varchar(10))
CREATE TABLE ##MEM_FIX_PRODUCTS (ST_ID varchar(15), PRODUCT_CODE varchar(31), ORDER_NUMBER numeric(15, 2), MEETING varchar(10), DESCRIPTION varchar(60), CEU_TYPE varchar(15), CEU_AWARDED numeric(15,2))

--Define Linked Products
insert into ##SUB_PRODUCTS (PRODUCT_CODE, MEETING, DESCRIPTION, CEU_TYPE, CEU_AWARDED)
select s.CHILD_PRODUCT_CODE, p.PRODUCT_MAJOR, sp.TITLE, f.CEU_TYPE, f.CEU_AMOUNT
from product p
	inner join Product_Sub s on p.PRODUCT_CODE = s.PRODUCT_CODE
	inner join Meet_Master mm on p.PRODUCT_MAJOR = mm.MEETING
	inner join Product sp on s.CHILD_PRODUCT_CODE = sp.PRODUCT_CODE
	inner join Product_Function f on s.PRODUCT_CODE = f.PRODUCT_CODE
where p.PRODUCT_CODE like '%/FP'
	and mm.MEETING_TYPE = 'WBNR'

--select * from ##SUB_PRODUCTS

--Declare Cursor Variables
DECLARE @ST_ID varchar(15)
DECLARE @PRODUCT_CODE varchar(31)
DECLARE @ORDER_NUMBER varchar(15)
DECLARE @MEETING_2 varchar(10)
DECLARE @ROW_POSITION int

--Row position for audit
Set @ROW_POSITION = 0

--Declare Cursor
DECLARE db_cursor cursor static for
select o.ST_ID, ol.PRODUCT_CODE, o.ORDER_NUMBER, mm.MEETING
from orders o
	inner join order_meet om on o.ORDER_NUMBER = om.ORDER_NUMBER
	inner join Order_Lines ol on o.ORDER_NUMBER = ol.ORDER_NUMBER
	inner join Meet_Master mm on om.MEETING = mm.MEETING
	inner join product p on ol.PRODUCT_CODE = p.PRODUCT_CODE
where o.STATUS not like 'C%'
	and mm.MEETING_TYPE = 'WBNR'
	--and o.SOURCE_CODE in ('W_MEETINGS','S_MEETINGS') 
	--and mm.MEETING = @Meeting 
	--and mm.BEGIN_DATE >= '2015-1-1'
order by ST_ID ASC, PRODUCT_CODE 

--Begin Loop
OPEN db_cursor
FETCH NEXT from db_cursor into @ST_ID, @PRODUCT_CODE, @ORDER_NUMBER, @MEETING_2

while @@FETCH_STATUS = 0
BEGIN

	Set @ROW_POSITION = @ROW_POSITION + 1

	if ((select top 1 ST_ID from ##PRODUCT_CODES order by ST_ID desc) <> '' and (select top 1 ST_ID from ##PRODUCT_CODES order by ST_ID desc) <> @ST_ID and (select top 1 ORDER_NUMBER from ##PRODUCT_CODES order by ORDER_NUMBER desc) <> @ORDER_NUMBER) or @ROW_POSITION = @@CURSOR_ROWS
	BEGIN

	LASTROW:

		insert into ##MEM_SUB_PRODUCTS (ST_ID, PRODUCT_CODE, ORDER_NUMBER, MEETING)
		select ST_ID, PRODUCT_CODE, ORDER_NUMBER, MEETING from ##PRODUCT_CODES

		--select * from ##MEM_SUB_PRODUCTS
		if not exists(select * from ##MEM_FIX_PRODUCTS f inner join ##MEM_SUB_PRODUCTS m on m.ORDER_NUMBER = f.ORDER_NUMBER)
		BEGIN 
			insert into ##MEM_FIX_PRODUCTS (ST_ID, PRODUCT_CODE, ORDER_NUMBER, MEETING, DESCRIPTION, CEU_TYPE, CEU_AWARDED)
			--select (select Top 1 ST_ID from ##MEM_SUB_PRODUCTS) ST_ID, PRODUCT_CODE, (select ORDER_NUMBER from ##MEM_SUB_PRODUCTS) from ##SUB_PRODUCTS where PRODUCT_CODE not in (select PRODUCT_CODE from ##MEM_SUB_PRODUCTS)
			select distinct m.ST_ID, s.PRODUCT_CODE, m.ORDER_NUMBER, m.MEETING, s.DESCRIPTION, s.CEU_TYPE, s.CEU_AWARDED
			from ##SUB_PRODUCTS s
				inner join ##MEM_SUB_PRODUCTS m on s.MEETING = m.MEETING
			where s.PRODUCT_CODE not in (select PRODUCT_CODE from ##MEM_SUB_PRODUCTS)
		END
		truncate table ##MEM_SUB_PRODUCTS
		truncate table ##PRODUCT_CODES

		--Last Row Fix
		if @ROW_POSITION = @@CURSOR_ROWS
		BEGIN
			truncate table ##PRODUCT_CODES
			insert into ##PRODUCT_CODES (ST_ID, PRODUCT_CODE, ORDER_NUMBER, MEETING)
			select @ST_ID, @PRODUCT_CODE, @ORDER_NUMBER, @MEETING_2
			SET @ROW_POSITION = -9999

			GOTO LASTROW
		END

	END
	
	--Insert functions that exist in the order
	insert into ##PRODUCT_CODES (ST_ID, PRODUCT_CODE, ORDER_NUMBER, MEETING)
	select @ST_ID, @PRODUCT_CODE, @ORDER_NUMBER, @MEETING_2

	FETCH NEXT from db_cursor into @ST_ID, @PRODUCT_CODE, @ORDER_NUMBER, @MEETING_2

END

	SET @ST_ID = ''
	SET @PRODUCT_CODE = ''
	SET @ORDER_NUMBER = ''
	SET @MEETING_2 = ''

	CLOSE db_cursor
	DEALLOCATE db_cursor
	
--select * from ##PRODUCT_CODES
--select * from ##MEM_SUB_PRODUCTS
--select * from ##MEM_FIX_PRODUCTS

------delete from ##MEM_FIX_PRODUCTS where ORDER_NUMBER <> '1895869.00'

DECLARE @LINE_NUMBER varchar(max)
--DECLARE @ST_ID varchar(15)
--DECLARE @PRODUCT_CODE varchar(31)
--DECLARE @ORDER_NUMBER varchar(15)
--DECLARE @MEETING_2 varchar(10)
--DECLARE @ROW_POSITION int
DECLARE @DESCRIPTION varchar(60)
DECLARE @CEU_Type varchar(15)
DECLARE @CEU_Awarded numeric(15,2)

--Declare Cursor
DECLARE input_cursor cursor static for
select ST_ID, PRODUCT_CODE, ORDER_NUMBER, MEETING, DESCRIPTION, CEU_TYPE, CEU_AWARDED from ##MEM_FIX_PRODUCTS

--Begin Loop
OPEN input_cursor
FETCH NEXT from input_cursor into @ST_ID, @PRODUCT_CODE, @ORDER_NUMBER, @MEETING_2, @Description, @CEU_Type, @CEU_Awarded

while @@FETCH_STATUS = 0
BEGIN

	select @LINE_NUMBER = max(LINE_NUMBER) + 1  
	from Order_Lines
	where ORDER_NUMBER = @ORDER_NUMBER

	if not exists(select * from Order_Lines where ORDER_NUMBER = @ORDER_NUMBER and PRODUCT_CODE = @PRODUCT_CODE)
	BEGIN
		--select @ST_ID, @PRODUCT_CODE, @ORDER_NUMBER, @MEETING_2, @LINE_NUMBER

		insert into Order_Lines (ORDER_NUMBER, LINE_NUMBER, PRODUCT_CODE, DESCRIPTION, QUANTITY_ORDERED, QUANTITY_SHIPPED, CEU_TYPE, CEU_AWARDED)
		select @ORDER_NUMBER, @LINE_NUMBER, @PRODUCT_CODE, @DESCRIPTION, 1, 1, @CEU_Type, @CEU_Awarded
	END

	FETCH NEXT from input_cursor into @ST_ID, @PRODUCT_CODE, @ORDER_NUMBER, @MEETING_2, @Description, @CEU_Type, @CEU_Awarded

END

	CLOSE input_cursor
	DEALLOCATE input_cursor