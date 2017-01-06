select cast(year(bill_begin-1) as varchar) + cast(month(bill_begin-1) as varchar), sum(num_billed)
from CSYS_Member_Product_Archive
where bill_begin >= '2015-1-2'
	and bill_begin <= '2016-1-1'
	--and product_code like 'DUES__'
	--and PRODUCT_CODE not like '%SM'
	and MEMBER_TYPE like '__'
	and member_type not like 'SM'
	--and (total_billed/Num_Billed) in (270.00,800.00,2160.00,75.00)
group by cast(year(bill_begin-1) as varchar) + cast(month(bill_begin-1) as varchar)
order by cast(cast(year(bill_begin-1) as varchar) + cast(month(bill_begin-1) as varchar) as int)