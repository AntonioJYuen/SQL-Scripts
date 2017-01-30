if OBJECT_ID('tempdb..##CDS_PULL') is not null
	drop table ##CDS_PULL;

SELECT        dbo.Orders.ST_ID AS ID, dbo.Orders.ORDER_DATE, dbo.Order_Badge.FIRST_NAME, dbo.Order_Badge.LAST_NAME, dbo.Order_Badge.SUFFIX, dbo.Order_Badge.DESIGNATION, 
                         dbo.Order_Meet.REGISTRANT_CLASS, dbo.Order_Badge.TITLE, dbo.Order_Meet.MEETING, dbo.Orders.ADDRESS_1, dbo.Orders.ADDRESS_2, dbo.Orders.CITY, dbo.Orders.STATE_PROVINCE, dbo.Orders.ZIP, 
                         dbo.Orders.COUNTRY, dbo.Orders.PHONE, dbo.Orders.FAX, dbo.Order_Badge.COMPANY, dbo.Orders.EMAIL, dbo.Order_Badge.MIDDLE_NAME, SUBSTRING(dbo.Order_Lines.PRODUCT_CODE, 9, 4) 
                         AS FUNCTION_CODE, dbo.Orders.ADDRESS_3, dbo.Orders.CO_ID AS COMPANY_ID, dbo.Orders.TOTAL_PAYMENTS, dbo.Orders.ORDER_NUMBER AS ICSC_ORDER_NUMBER, dbo.Name.MEMBER_TYPE, 
                         dbo.Name.STATUS, dbo.Name.JOIN_DATE, dbo.Name.PAID_THRU, dbo.Name.MEMBER_RECORD AS ismember, dbo.Name.COMPANY_RECORD AS iscompany,
						 cast(dbo.Name.TIME_STAMP as varbinary) NAME_STAMP, cast(dbo.Orders.TIME_STAMP as varbinary) ORDER_STAMP,
						 cast(dbo.Order_Meet.TIME_STAMP as varbinary) ORDER_MEET_STAMP, cast(dbo.Order_Badge.TIME_STAMP as varbinary) ORDER_BADGE_STAMP,
						 cast(dbo.Order_Lines.TIME_STAMP as varbinary) ORDER_LINES_STAMP
						 into ##CDS_PULL
FROM            dbo.Name INNER JOIN
                         dbo.Orders on dbo.Name.ID = dbo.Orders.ST_ID INNER JOIN
                         dbo.Order_Meet ON dbo.Orders.ORDER_NUMBER = dbo.Order_Meet.ORDER_NUMBER INNER JOIN
                         dbo.Order_Badge ON dbo.Orders.ORDER_NUMBER = dbo.Order_Badge.ORDER_NUMBER INNER JOIN
                         dbo.Order_Lines ON dbo.Orders.ORDER_NUMBER = dbo.Order_Lines.ORDER_NUMBER
WHERE        (NOT (dbo.Orders.STATUS LIKE 'C%')) AND (dbo.Order_Meet.MEETING in ('2016EDM')) AND (dbo.Order_Lines.QUANTITY_ORDERED > 0) AND (dbo.Order_Lines.PRODUCT_CODE IN ('2016EDM/FP', '2016EDM/EX'))
				AND (cast(dbo.Name.TIME_STAMP as varbinary) > (select NAME_STAMP from CDS_Last_Pulled)
					OR cast(dbo.Orders.TIME_STAMP as varbinary) > (select ORDER_STAMP from CDS_Last_Pulled)
					OR cast(dbo.Order_Meet.TIME_STAMP as varbinary) > (select ORDER_MEET_STAMP from CDS_Last_Pulled)
					OR cast(dbo.Order_Badge.TIME_STAMP as varbinary) > (select ORDER_BADGE_STAMP from CDS_Last_Pulled)
					OR cast(dbo.Order_Lines.TIME_STAMP as varbinary) > (select ORDER_LINES_STAMP from CDS_Last_Pulled))

begin transaction

if (select NAME_STAMP from CDS_LAST_PULLED) < (select max(NAME_STAMP) from ##CDS_PULL)
	update CDS_LAST_PULLED
	set NAME_STAMP = (select max(NAME_STAMP) from ##CDS_PULL);

if (select ORDER_STAMP from CDS_LAST_PULLED) < (select max(ORDER_STAMP) from ##CDS_PULL)
	update CDS_LAST_PULLED
	set ORDER_STAMP = (select max(NAME_STAMP) from ##CDS_PULL);

if (select ORDER_MEET_STAMP from CDS_LAST_PULLED) < (select max(ORDER_MEET_STAMP) from ##CDS_PULL)
	update CDS_LAST_PULLED
	set ORDER_MEET_STAMP = (select max(NAME_STAMP) from ##CDS_PULL);

if (select ORDER_BADGE_STAMP from CDS_LAST_PULLED) < (select max(ORDER_BADGE_STAMP) from ##CDS_PULL)
	update CDS_LAST_PULLED
	set ORDER_BADGE_STAMP = (select max(NAME_STAMP) from ##CDS_PULL);

if (select ORDER_LINES_STAMP from CDS_LAST_PULLED) < (select max(ORDER_LINES_STAMP) from ##CDS_PULL)
	update CDS_LAST_PULLED
	set ORDER_LINES_STAMP = (select max(NAME_STAMP) from ##CDS_PULL);

commit transaction

--select max(NAME_STAMP) NAME_STAMP, max(ORDER_STAMP) ORDER_STAMP, max(ORDER_MEET_STAMP) ORDER_MEET_STAMP, max(ORDER_BADGE_STAMP) ORDER_BADGE_STAMP, max(ORDER_LINES_STAMP) ORDER_LINES_STAMP
	--into CDS_Last_Pulled
--from ##CDS_PULL

--select * from CDS_Last_Pulled

select *
from ##CDS_PULL