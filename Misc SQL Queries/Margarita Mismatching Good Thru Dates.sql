create view ICSC_CERTIFICATION_MISMATCH_DATES
as

select r.STUDENT_ID, r.REGISTRATION_ITEM, r.ENROLLED_DATE, r.GOOD_THRU_DATE, x.MAX_THRU_DATE
from Cert_Register r
	left join (select STUDENT_ID, MAX(GOOD_THRU_DATE) MAX_THRU_DATE
				from Cert_Register 
				group by STUDENT_ID) x on r.STUDENT_ID = x.STUDENT_ID
where r.STUDENT_ID in (select STUDENT_ID--, count(registration_item) Num
						from Cert_Register
						where GOOD_THRU_DATE >= cast(getdate() as date)
						group by STUDENT_ID
						having count(registration_item) > 1)
	and r.GOOD_THRU_DATE <> x.MAX_THRU_DATE
	and r.GOOD_THRU_DATE >= cast(getdate() as date)
--order by r.REGISTRATION_ITEM, r.GOOD_THRU_DATE