--select * from (
select r.STUDENT_ID, n.FULL_NAME, n.FIRST_NAME, n.LAST_NAME, n.TITLE, dbo.RemoveBreaks(n.COMPANY) COMPANY, n.EMAIL
	, dbo.removeBreaks(na.ADDRESS_1) ADDRESS_1, dbo.removeBreaks(na.ADDRESS_2) ADDRESS_2, dbo.removeBreaks(na.ADDRESS_3) ADDRESS_3
	, dbo.removeBreaks(na.CITY) CITY, na.STATE_PROVINCE, case when na.COUNTRY = '' then 'United States' else na.COUNTRY end COUNTRY, na.ZIP
	, n.EMAIL, na.PHONE, n.WORK_PHONE
	, isnull(ceu.UNITS,0) CEU_Credits
	, sum(case when r.REGISTRATION_ITEM like 'CLS%' then 1 else 0 end) 'CLS'
	, max(case when r.REGISTRATION_ITEM like 'CLS%' then r2.MIN_ENROLL_DATE else null end) 'CLS Earliest Enrolled Date'
	, max(case when r.REGISTRATION_ITEM like 'CLS%' then r2.MAX_THRU_DATE else null end) 'CLS Lastest Due Date'
	, sum(case when r.REGISTRATION_ITEM like 'CMD%' then 1 else 0 end) 'CMD'
	, max(case when r.REGISTRATION_ITEM like 'CMD%' then r2.MIN_ENROLL_DATE else null end) 'CMD Earliest Enrolled Date'
	, max(case when r.REGISTRATION_ITEM like 'CMD%' then r2.MAX_THRU_DATE else null end) 'CMD Lastest Due Date'
	, sum(case when r.REGISTRATION_ITEM like 'CRX%' then 1 else 0 end) 'CRX'
	, max(case when r.REGISTRATION_ITEM like 'CRX%' then r2.MIN_ENROLL_DATE else null end) 'CRX Earliest Enrolled Date'
	, max(case when r.REGISTRATION_ITEM like 'CRX%' then r2.MAX_THRU_DATE else null end) 'CRX Lastest Due Date'
	, sum(case when r.REGISTRATION_ITEM like 'CSM%' then 1 else 0 end) 'CSM'
	, max(case when r.REGISTRATION_ITEM like 'CSM%' then r2.MIN_ENROLL_DATE else null end) 'CSM Earliest Enrolled Date'
	, max(case when r.REGISTRATION_ITEM like 'CSM%' then r2.MAX_THRU_DATE else null end) 'CSM Lastest Due Date'
	, sum(case when r.REGISTRATION_ITEM like 'CDP%' then 1 else 0 end) 'CDP'
	, max(case when r.REGISTRATION_ITEM like 'CDP%' then r2.MIN_ENROLL_DATE else null end) 'CDP Earliest Enrolled Date'
	, max(case when r.REGISTRATION_ITEM like 'CDP%' then r2.MAX_THRU_DATE else null end) 'CDP Lastest Due Date'
	, sum(case when r.REGISTRATION_ITEM like 'SLD%' then 1 else 0 end) 'SLD'
	, max(case when r.REGISTRATION_ITEM like 'SLD%' then r2.MIN_ENROLL_DATE else null end) 'SLD Earliest Enrolled Date'
	, max(case when r.REGISTRATION_ITEM like 'SLD%' then r2.MAX_THRU_DATE else null end) 'SLD Lastest Due Date'
	, sum(case when r.REGISTRATION_ITEM like 'SCLS%' then 1 else 0 end) 'SCLS'
	, max(case when r.REGISTRATION_ITEM like 'SCLS%' then r2.MIN_ENROLL_DATE else null end) 'SCLS Earliest Enrolled Date'
	, max(case when r.REGISTRATION_ITEM like 'SCLS%' then r2.MAX_THRU_DATE else null end) 'SCLS Lastest Due Date'
	, sum(case when r.REGISTRATION_ITEM like 'SCMD%' then 1 else 0 end) 'SCMD'
	, max(case when r.REGISTRATION_ITEM like 'SCMD%' then r2.MIN_ENROLL_DATE else null end) 'SCMD Earliest Enrolled Date'
	, max(case when r.REGISTRATION_ITEM like 'SCMD%' then r2.MAX_THRU_DATE else null end) 'SCMD Lastest Due Date'
	, sum(case when r.REGISTRATION_ITEM like 'SCSM%' then 1 else 0 end) 'SCSM'
	, max(case when r.REGISTRATION_ITEM like 'SCSM%' then r2.MIN_ENROLL_DATE else null end) 'SCSM Earliest Enrolled Date'
	, max(case when r.REGISTRATION_ITEM like 'SCSM%' then r2.MAX_THRU_DATE else null end) 'SCSM Lastest Due Date'
from Cert_Register r
	inner join name n on r.STUDENT_ID = n.ID
	inner join Demographics d on n.ID = d.ID
	left join Name_Address na on n.id = na.id and na.PREFERRED_MAIL = 1
	inner join (select STUDENT_ID, REGISTRATION_ITEM, min(ENROLLED_DATE) MIN_ENROLL_DATE, max(GOOD_THRU_DATE) MAX_THRU_DATE from Cert_Register group by STUDENT_ID, REGISTRATION_ITEM) r2 on r.STUDENT_ID = r2.STUDENT_ID and r.REGISTRATION_ITEM = r2.REGISTRATION_ITEM
	left join (select ceu.ID, sum(ceu.UNITS) UNITS from icsc_Cert_meetingsCEU ceu group by ceu.ID) ceu on n.ID = ceu.ID
where GOOD_THRU_DATE >='2016-4-1'
	and GOOD_THRU_DATE <= '2017-4-30'
	and r.STATUS = 'P'
	and n.MEMBER_STATUS <> 'X'
group by r.STUDENT_ID, n.FULL_NAME, n.FIRST_NAME, n.LAST_NAME, n.TITLE, dbo.RemoveBreaks(n.COMPANY), n.EMAIL
	, dbo.removeBreaks(na.ADDRESS_1), dbo.removeBreaks(na.ADDRESS_2), dbo.removeBreaks(na.ADDRESS_3)
	, dbo.removeBreaks(na.CITY), na.STATE_PROVINCE, case when na.COUNTRY = '' then 'United States' else na.COUNTRY end, na.ZIP
	, n.EMAIL, na.PHONE, n.WORK_PHONE, isnull(ceu.UNITS,0)
--) b
--where [CLS Lastest Due Date] >= '2017-4-30'
--	or [CMD Lastest Due Date] >= '2017-4-30'
--	or [CRX Lastest Due Date] >= '2017-4-30'
--	or [CSM Lastest Due Date] >= '2017-4-30'
--	or [SLD Lastest Due Date] >= '2017-4-30'
--	or [CDP Lastest Due Date] >= '2017-4-30'
--	or [SCMD Lastest Due Date] >= '2017-4-30'
--	or [SCLS Lastest Due Date] >= '2017-4-30'
--	or [SCSM Lastest Due Date] >= '2017-4-30'
