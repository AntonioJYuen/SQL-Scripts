select [ASIEXP13].YEAR1 AS 'Year',
	[ASIEXP13].[PERIODID] AS 'Period ID',
	RTRIM([GL00100].ACTNUMBR_1)+'-'
		+RTRIM([GL00100].ACTNUMBR_2)+'-'+RTRIM([GL00100].ACTNUMBR_3)+'-'
		+RTRIM([GL00100].ACTNUMBR_4) AS 'Account Number',
	[GL00100].[ACTDESCR] AS 'Account Description',
	(CASE WHEN [ASIEXP13].[CRDTAMNT]<0 THEN '-'+
			(SELECT CRNCYSYM 
			FROM DYNAMICS..MC40200 
			WHERE CURNCYID = 'Z-US$')
		+LTRIM(STR(abs([ASIEXP13].[CRDTAMNT]),100,
			(SELECT DECPLCUR 
			FROM DYNAMICS..MC40200 
			WHERE CURNCYID = 'Z-US$'))) 
	ELSE
			(SELECT CRNCYSYM 
			FROM DYNAMICS..MC40200 
			WHERE CURNCYID = 'Z-US$')
		+LTRIM(STR([ASIEXP13].[CRDTAMNT],100,
			(SELECT DECPLCUR 
			FROM DYNAMICS..MC40200 
			WHERE CURNCYID = 'Z-US$'))) END) AS 'Credit Amount',
	(CASE WHEN [ASIEXP13].[DEBITAMT]<0 THEN '-'+
			(SELECT CRNCYSYM 
			FROM DYNAMICS..MC40200 
			WHERE CURNCYID = 'Z-US$')
		+LTRIM(STR(abs([ASIEXP13].[DEBITAMT]),100,
			(SELECT DECPLCUR 
			FROM DYNAMICS..MC40200 
			WHERE CURNCYID = 'Z-US$'))) 
	ELSE
			(SELECT CRNCYSYM 
			FROM DYNAMICS..MC40200 
			WHERE CURNCYID = 'Z-US$')
		+LTRIM(STR([ASIEXP13].[DEBITAMT],100,
			(SELECT DECPLCUR 
			FROM DYNAMICS..MC40200 
			WHERE CURNCYID = 'Z-US$'))) END) AS 'Debit Amount' 
	, LTRIM(STR([ASIEXP13].[DEBITAMT],100,
			(SELECT DECPLCUR 
			FROM DYNAMICS..MC40200 
			WHERE CURNCYID = 'Z-US$'))) AS 'TEST'
	, ASIEXP13.CRDTAMNT
	, ASIEXP13.DEBITAMT
from ICSC..[ASIEXP13]
	left join ICSC..[GL00100] on [ASIEXP13].[ACTINDX] = [GL00100].[ACTINDX]