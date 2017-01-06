select t.bt_id,t.invoice_reference_num,t.transaction_date,product_code,t.description,
-- AMOUNT*-1 as invoice_credits,
/* Remove line above and unrem live below when ready for live. */
case when tv.amount >0 then t.AMOUNT*-1-tv.amount else t.AMOUNT*-1 end as invoice_credits,
substring(check_number,5,25) as cc_type,cc_number,cc_authorize, 'ICSC '+gt.description as cert_description,
case when product_code like 'cert_exam_%' then 'Application & Exam Receipt'
when product_code like 'cert_renew_%' then 'Certification Renewal Receipt' end
as Email_Title,
Case when product_code like 'cert_exam_%' Then
'<br>Please make note of the following conditions and deadlines.
<br><ul>
<br><li>Application fees are non-transferable and include a $95 ($195 NM) non-refundable eligibility evaluation fee and a $395 ($795 NM) exam registration fee. If, after your application is received, you are found to be ineligible, you will be issued a refund of your exam registration fee less a $25 administrative fee. 
<br>
<br><li>Cancellations must be requested in writing and must be submitted no less than 30 days before the start of your examination window in order to receive a full refund, less a $50 cancellation fee.
<br>
<br><li>If necessary, your Exam Windows may be changed to another within the same calendar year and no less than 15 days before the start of your original examination window. A $50 change fee will apply.</ul>'
Else ' ' End As BottomText 
from trans t inner join gen_tables gt on right(t.product_code,3)=gt.code and gt.table_name='designation'
/* Unrem the line below when ready for live.*/
left join tc_AMS_Receipt_Discount tv  on t.invoice_reference_num = tv.invoice_reference_num
where (right(t.product_code,3)=gt.code and gt.table_name='designation'
-- from trans t,gen_tables gt
-- where right(t.product_code,3)=gt.code and gt.table_name='designation'
and(product_code like 'cert_exam_%'
or product_code like 'cert_renew_%')
--and invoice_credits>0
and t.JOURNAL_TYPE in ('Pay','IN')
and t.AMOUNT<0
and not(t.bt_id in ('1447506','34286'))
and t.transaction_date between '2014-12-12' and '2015-2-1')
and case when tv.amount >0 then t.AMOUNT*-1-tv.amount else t.AMOUNT*-1 end = 125




select t.bt_id,t.invoice_reference_num,t.transaction_date,product_code,t.description,
-- AMOUNT*-1 as invoice_credits,
/* Remove line above and unrem live below when ready for live. */
case when tv.amount >0 then t.AMOUNT*-1-tv.amount else t.AMOUNT*-1 end as invoice_credits,
substring(check_number,5,25) as cc_type,cc_number,cc_authorize, 'ICSC '+gt.description as cert_description,
case when product_code like 'cert_exam_%' then 'Application & Exam Receipt'
when product_code like 'cert_renew_%' then 'Certification Renewal Receipt' end
as Email_Title,
Case when product_code like 'cert_exam_%' Then
'<br>Please make note of the following conditions and deadlines.
<br><ul>
<br><li>Application fees are non-transferable and include a $95 ($195 NM) non-refundable eligibility evaluation fee and a $395 ($795 NM) exam registration fee. If, after your application is received, you are found to be ineligible, you will be issued a refund of your exam registration fee less a $25 administrative fee. 
<br>
<br><li>Cancellations must be requested in writing and must be submitted no less than 30 days before the start of your examination window in order to receive a full refund, less a $50 cancellation fee.
<br>
<br><li>If necessary, your Exam Windows may be changed to another within the same calendar year and no less than 15 days before the start of your original examination window. A $50 change fee will apply.</ul>'
Else ' ' End As BottomText 
from trans t inner join gen_tables gt on right(t.product_code,3)=gt.code and gt.table_name='designation'
/* Unrem the line below when ready for live.*/
left join tc_AMS_Receipt_Discount tv  on t.invoice_reference_num = tv.invoice_reference_num
where (right(t.product_code,3)=gt.code and gt.table_name='designation'
-- from trans t,gen_tables gt
-- where right(t.product_code,3)=gt.code and gt.table_name='designation'
and(product_code like 'cert_exam_%'
or product_code like 'cert_renew_%')
--and invoice_credits>0
and t.JOURNAL_TYPE in ('Pay','IN')
and t.AMOUNT<0
and not(t.bt_id in ('1447506','34286'))
and t.transaction_date between '2015-1-15' and '2015-2-1')
and case when tv.amount >0 then t.AMOUNT*-1-tv.amount else t.AMOUNT*-1 end <> 125