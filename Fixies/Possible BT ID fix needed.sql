select *
from trans
where bt_id = '134264'

select *
from trans t
	inner join (
		select BT_ID, ST_ID, TRANSACTION_DATE, count(trans_number) ct
		from trans
		where SOURCE_SYSTEM = 'DUES'
			and LINE_NUMBER = 1
			and TRANSACTION_DATE >= '2016-10-1'
			and SOURCE_CODE like 'W_%'
		group by TRANSACTION_DATE, BT_ID, ST_ID
		having count(trans_number) > 1
	) a on t.BT_ID = a.BT_ID and t.ST_ID = a.ST_ID and t.TRANSACTION_DATE = a.TRANSACTION_DATE
