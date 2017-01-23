begin transaction

--select BATCH_NUM, convert(varchar,transaction_date,12)+'I', *
update t
set BATCH_NUM = convert(varchar,transaction_date,12)+'I'
from trans t
where t.ST_ID in ('1540620','1644328','1676748','1676813','1676814','1676734','1648120','1676918')
	and BATCH_NUM = ''

select BATCH_NUM, convert(varchar,transaction_date,12)+'I', t.*
from trans t
where t.ST_ID in ('1540620','1644328','1676748','1676813','1676814','1676734','1648120','1676918')
	and BATCH_NUM = convert(varchar,transaction_date,12)+'I'
	and t.TRANSACTION_DATE >= '2017-1-1'
	and t.SOURCE_SYSTEM = 'DUES'

commit transaction

select *
from batch
where BATCH_NUM = '170118I'

select sum(amount)
from trans
where BATCH_NUM = '170117I'
	and TRANSACTION_TYPE = 'DIST'