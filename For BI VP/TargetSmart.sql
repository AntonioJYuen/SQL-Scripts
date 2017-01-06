select n.id, n.FIRST_NAME, n.MIDDLE_NAME, n.LAST_NAME, n.SUFFIX
	, dbo.removeBreaks(na1.ADDRESS_1) MAIL_ADDRESS_1, dbo.removeBreaks(na1.ADDRESS_2) MAIL_ADDRESS_2, dbo.removeBreaks(na1.ADDRESS_3) MAIL_ADDRESS_3, na1.CITY MAIL_CITY, na1.STATE_PROVINCE MAIL_STATE, na1.ZIP MAIL_ZIP
	, dbo.removeBreaks(na2.ADDRESS_1) BILL_ADDRESS_1, dbo.removeBreaks(na2.ADDRESS_2) BILL_ADDRESS_2, dbo.removeBreaks(na2.ADDRESS_3) BILL_ADDRESS_3, na2.CITY BILL_CITY, na2.STATE_PROVINCE BILL_STATE, na2.ZIP BILL_ZIP
	, dbo.removeBreaks(na3.ADDRESS_1) SHIP_ADDRESS_1, dbo.removeBreaks(na3.ADDRESS_2) SHIP_ADDRESS_2, dbo.removeBreaks(na3.ADDRESS_3) SHIP_ADDRESS_3, na3.CITY SHIP_CITY, na3.STATE_PROVINCE SHIP_STATE, na3.ZIP SHIP_ZIP
	, n.HOME_PHONE ,n.WORK_PHONE, d.CELL_PHONE
	, n.EMAIL
	, n.GENDER
	, cast(n.BIRTH_DATE as date) BIRTH_DATE
from name n
	inner join Demographics d on n.id = d.id 
	left join Name_Address na1 on n.id = na1.id and na1.PREFERRED_MAIL = 1
	left join Name_Address na2 on n.id = na2.id and na2.PREFERRED_MAIL = 0 and na2.PREFERRED_BILL = 1
	left join Name_Address na3 on n.id = na3.id and na3.PREFERRED_MAIL = 0 and na3.PREFERRED_BILL = 0 and na3.PREFERRED_SHIP = 1
where n.status = 'A'
	and n.country in ('United States','')
	and n.MEMBER_TYPE not in ('NMI','PROS','ST')
	and n.COMPANY_RECORD = 0