
begin transaction

update top (1000) n
set n.EMAIL = a.EMAIL
from Name_Address n
	inner join (
				select n.id, n.email
				from njsqlimis15.testimis3.dbo.name n
					left join njsqlimis15.testimis3.dbo.name n2 on n.id = n2.co_id and n2.member_type like '%O'
				where n.company_record = 1
					and n.email <> ''
					and (n2.email is null or n.email <> n2.email)
					and n.status = 'A'
					and n.member_type not in ('PROC','NM')) a on n.id = a.id
where n.EMAIL = ''

select n.EMAIL, a.EMAIL
from Name_Address n
	inner join (
				select n.id, n.email
				from njsqlimis15.testimis3.dbo.name n
					left join njsqlimis15.testimis3.dbo.name n2 on n.id = n2.co_id and n2.member_type like '%O'
				where n.company_record = 1
					and n.email <> ''
					and (n2.email is null or n.email <> n2.email)
					and n.status = 'A'
					and n.member_type not in ('PROC','NM')) a on n.id = a.id
where n.EMAIL = ''

commit transaction