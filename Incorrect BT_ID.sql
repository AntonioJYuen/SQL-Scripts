select *
from (
	select t.TRANSACTION_DATE, t.TRANS_NUMBER, t.BT_ID, t.ST_ID, t.PAID_THRU trans_paid_thru, n.PAID_THRU name_paid_thru, ROW_NUMBER() over (partition by trans_number order by t.paid_thru desc, n.paid_thru desc) row_num
	from trans t
		inner join name n on t.st_id = n.ID
	where t.BT_ID <> ST_ID
		and t.bt_id <> n.CO_ID
		and TRANSACTION_DATE >= '2016-12-1'
		and SOURCE_SYSTEM = 'DUES'
)a
where row_num = 1