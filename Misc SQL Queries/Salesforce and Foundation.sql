select i.REFERENCE_NUM, i.st_id [@id], '' fundrasingType, '' fundraisingCampaign, '' fundraisinglevel, a.DESCRIPTION fundraisingname
	, t.DatePaid, i.EFFECTIVE_DATE originalpledgedate, i.INSTALL_BILL_DATE pledgeinstallment_due_date, i.CHARGES pledgeinstallment_pledgeamount
	, i.CREDITS pledgeinstallment_amount_paid, i.BALANCE pledgeinstallment_balance
from Invoice i
	inner join Activity a on i.ORIGINATING_TRANS_NUM = a.ORIGINATING_TRANS_NUM and a.SOURCE_SYSTEM = 'FR'
	left join (select INVOICE_REFERENCE_NUM, sum(amount*-1) AmountPaid, max(transaction_date) DatePaid from trans t where JOURNAL_TYPE = 'PAY' group by INVOICE_REFERENCE_NUM) t on t.INVOICE_REFERENCE_NUM = i.REFERENCE_NUM 
where i.st_id = '1000291'
	and i.SOURCE_SYSTEM = 'FR'