select CO_ID, COMPANY, count(Email_Domain) Num_Email_Domains
from
(	select distinct n.CO_ID, dbo.removebreaks(isnull(n2.COMPANY,n.COMPANY)) COMPANY, lower(dbo.removeBreaks(right(n.EMAIL,len(n.EMAIL)-CHARINDEX('@',n.EMAIL)))) Email_Domain
	from name n
		left join name n2 on n.CO_ID = n2.ID
	where n.STATUS = 'A'
		and n.COMPANY_RECORD = 0
		and n.MEMBER_TYPE not in ('NMI','PROS'))a
where CO_ID <> ''
group by CO_ID, COMPANY
order by count(Email_Domain) desc