if OBJECT_ID('tempdb..##Temp_Proj_Codes') is not null
	drop table ##Temp_Proj_Codes

SELECT mm.MEETING,
       isnull(stuff( (select distinct  ',' + SUBSTRING(INCOME_ACCOUNT,6,7) Budget_Code
						from Product_Price B
						where income_account <> ''
							AND mm.MEETING = left(B.PRODUCT_CODE,charindex('/',B.PRODUCT_CODE)-1)
               FOR XML PATH(''), TYPE).value('.', 'varchar(max)')
            ,1,1,''),'') AS Budget_Code into ##Temp_Proj_Codes
FROM Meet_Master mm
where mm.BEGIN_DATE >= '2015-1-1'
	and mm.BEGIN_DATE <= '2016-12-31'
GROUP BY mm.MEETING;

--select * from ##Temp_Proj_Codes

select mm.MEETING, MEETING_TYPE, TITLE, BEGIN_DATE, STATUS, TOTAL_REGISTRANTS, TOTAL_CANCELATIONS, TOTAL_REGISTRANTS - TOTAL_CANCELATIONS Attendees, TOTAL_REVENUE
	, e.Budget_Code
from meet_master mm
	left join ##Temp_Proj_Codes e on mm.MEETING = e.Meeting
where BEGIN_DATE >= '2015-1-1'
	and BEGIN_DATE <= '2016-12-31'