--Fix A Status Non-member records
begin transaction

update top (1000) name
set status = 'S'
from name
where MEMBER_TYPE in ('NM','NMI','PROS','PROC')
	and STATUS = 'A'

commit transaction

--Fix BT_ID in name table
begin transaction

update top (1000) name
set BT_ID = ''
from name
where datalength(BT_ID) > 0

commit transaction

--Remove " " from emails
begin transaction

update top (1000) name
set EMAIL = replace(email,' ','')
from name
where email like '% %'

update top (1000) Name_Address
set EMAIL = replace(email,' ','')
from Name_Address
where email like '% %'

commit transaction

