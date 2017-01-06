select ID, TRANS_NUMBER, FIRST_NAME, LAST_NAME, Company, SOURCE_SYSTEM, TRANSACTION_DATE, TRANSACTION_TYPE, mm.Title DESCRIPTION, t.PRODUCT_CODE, GL_ACCOUNT, INVOICE_CHARGES, AMOUNT * -1 AMOUNT, CHECK_NUMBER, CC_NUMBER, CC_AUTHORIZE, BATCH_NUM, substring(GL_ACCOUNT,6,4) Proj_Code, mm.meeting Event, mm.City, mm.Country, mm.TAX_AUTHORITY_1
FROM TRANS t
	inner join name n on t.ST_ID = n.ID
	inner join product p on t.PRODUCT_CODE = p.PRODUCT_CODE
	inner join Meet_Master mm on p.PRODUCT_MAJOR = mm.MEETING
where gl_account like '____-____-20-_'
	and year(transaction_date) = 2015
order by TRANSACTION_DATE


