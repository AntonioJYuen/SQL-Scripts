select r.STUDENT_ID, n.FIRST_NAME, n.LAST_NAME, r.REGISTRATION_ITEM, r.ENROLLED_DATE, r.GOOD_THRU_DATE
from Cert_Register r
	inner join name n on r.STUDENT_ID = n.ID
where r.GOOD_THRU_DATE > = '2015-1-1'
	and r.REGISTRATION_ITEM in ('CLS','CLS2')
	and r.STATUS = 'P'
	and ENROLLED_DATE >= '2015-12-31'