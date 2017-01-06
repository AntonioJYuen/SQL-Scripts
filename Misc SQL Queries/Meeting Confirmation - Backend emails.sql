select o.ST_ID, o.FULL_NAME, o.COMPANY, o.FULL_ADDRESS
	, o.ADDRESS_1, o.ADDRESS_2, o.ADDRESS_3, o.CITY, o.STATE_PROVINCE, o.ZIP, o.COUNTRY
	, DATENAME(WEEKDAY, mm.BEGIN_DATE) + ', ' + DATENAME(MONTH, mm.BEGIN_DATE) + ' ' + DATENAME(DAY, mm.BEGIN_DATE) + ' ' + DATENAME(YEAR, mm.BEGIN_DATE) + ' through ' + DATENAME(WEEKDAY, mm.END_DATE) + ', ' + DATENAME(MONTH, mm.END_DATE) + ' ' + DATENAME(DAY, mm.END_DATE) + ' ' + DATENAME(YEAR, mm.END_DATE) Meet_Date
	, mm.TITLE Meeting_Title, mm.ADDRESS_1 + case when mm.ADDRESS_2 <> '' then char(10)+char(13) else '' end + mm.ADDRESS_2 + case when mm.ADDRESS_3 <> '' then char(10)+char(13) else '' end + mm.ADDRESS_3 + char(10)+char(13) + mm.CITY + case when mm.STATE_PROVINCE <> '' then ', ' else ' ' end + mm.STATE_PROVINCE + ' ' + mm.ZIP + case when mm.COUNTRY <> '' then char(10)+char(13) else '' end + mm.COUNTRY Full_Meeting_Address
	, mm.ADDRESS_1 Meet_Address_1, mm.ADDRESS_2 Meet_Address_2, mm.ADDRESS_3 Meet_Address_3, mm.CITY Meet_City, mm.STATE_PROVINCE Meet_State, mm.ZIP Meet_Zip, mm.COUNTRY Meet_Country
	, DATENAME(MONTH, o.ORDER_DATE) + ' ' + DATENAME(DAY, o.ORDER_DATE) + ' ' + DATENAME(YEAR, o.ORDER_DATE) ORDER_DATE
	, p.TITLE, ol.QUANTITY_ORDERED, ol.UNIT_PRICE, ol.QUANTITY_ORDERED * ol.UNIT_PRICE TOTAL_PRICE
	, o.BALANCE, o.PAY_TYPE, o.PAY_NUMBER, o.TOTAL_PAYMENTS
	, mm.MEETING, o.ORDER_NUMBER, isnull(o.SOURCE_CODE,'') SOURCE_CODE, isnull(o.SOURCE_SYSTEM,'') SOURCE_SYSTEM, o.EMAIL
from Orders o
	inner join Order_Meet om on o.ORDER_NUMBER = om.ORDER_NUMBER
	inner join Meet_Master mm on om.MEETING = mm.MEETING
	inner join Order_Lines ol on o.ORDER_NUMBER = ol.ORDER_NUMBER
	inner join Product p on ol.PRODUCT_CODE = p.PRODUCT_CODE
where o.ORDER_NUMBER in (select top 1 o.ORDER_NUMBER
							from Orders o
								inner join Order_Meet om on o.ORDER_NUMBER = om.ORDER_NUMBER
								inner join Meet_Master mm on om.MEETING = mm.MEETING
								left join Activity a on o.ORDER_NUMBER = cast(a.UF_1 as numeric(15,2)) and o.ST_ID = a.ID and a.activity_type = 'EMAILCFRM'
							where o.ORDER_DATE = dateadd(d,-1,cast(getdate() as date))
								and mm.MEETING_TYPE not in ('SPON','EXPO','COMM','AWRD')
								and o.SOURCE_CODE = ''
								and o.EMAIL like '%_@_%._%'
								and a.UF_1 is null
							order by ST_ID)
