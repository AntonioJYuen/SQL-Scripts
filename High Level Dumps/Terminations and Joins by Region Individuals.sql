if OBJECT_ID('tempdb..#Terms_And_Rejoins') is not null	
	drop table #Terms_And_Rejoins

select n.ID, n.FULL_NAME, dbo.removeBreaks(n.COMPANY) Company
	, rm.Region_Name
	, case when n.status = 'A' then 1 else 0 end Termed_Rejoined
	, case when n.status = 'S' then 1 else 0 end Termed_Not_Rejoined
	, 0 REJOINS
	, 0 NEW_JOINS
	, isnull([2016RECON],0) Attended_2016_RECON
	, isnull([2017RECON],0) Registered_2017_RECON
	into #Terms_And_Rejoins
from Name n
	inner join Demographics d on n.ID = d.ID
	left join Csys_ICSC_Regions_Mem rm on n.COUNTRY = rm.Country
	left join (select o.ST_ID
	, sum(case when om.MEETING = '2016RECON' then 1 else 0 end) as [2016RECON]
	, sum(case when om.MEETING = '2017RECON' then 1 else 0 end) as [2017RECON]
			from orders o
				inner join order_meet om on o.ORDER_NUMBER = om.ORDER_NUMBER
			where o.STATUS not like 'C%'
			group by o.ST_ID
	) a on n.ID = a.ST_ID
where d.TERMINATION_DATE >= '2017-2-1'
	and n.COMPANY_RECORD = 0


--select n.ID, n.FULL_NAME, n.COMPANY
--	, rm.Region_Name Region
--	, case when year(isnull(d.REJOIN_DATE,n.JOIN_DATE)) > year(n.JOIN_DATE) then 1 else 0 end REJOINS
--	, case when year(isnull(d.REJOIN_DATE,n.JOIN_DATE)) <= year(n.JOIN_DATE) then 1 else 0 end NEW_JOINS
--	, isnull([2016RECON],0) Attended_2016_RECON
--	, isnull([2017RECON],0) Registered_2017_RECON

update t
set REJOINS = case when year(isnull(d.REJOIN_DATE,n.JOIN_DATE)) > year(n.JOIN_DATE) then 1 else 0 end
	, NEW_JOINS = case when year(isnull(d.REJOIN_DATE,n.JOIN_DATE)) <= year(n.JOIN_DATE) then 1 else 0 end
from name n
	inner join #Terms_And_Rejoins t on n.ID = t.ID 
	inner join Demographics d on n.ID = d.ID
	left join Csys_ICSC_Regions_Mem rm on n.COUNTRY = rm.Country
	left join (select o.ST_ID
	, sum(case when om.MEETING = '2016RECON' then 1 else 0 end) as [2016RECON]
	, sum(case when om.MEETING = '2017RECON' then 1 else 0 end) as [2017RECON]
			from orders o
				inner join order_meet om on o.ORDER_NUMBER = om.ORDER_NUMBER
			where o.STATUS not like 'C%'
			group by o.ST_ID
	) a on n.ID = a.ST_ID
where ((	
		n.JOIN_DATE >= '2017-2-1'
			and n.JOIN_DATE <= '2017-2-28')
		or 
		(d.REJOIN_DATE >= '2017-2-1'
			and d.REJOIN_DATE <= '2017-2-28'
		))
	and n.COMPANY_RECORD = 0
	and n.STATUS = 'A'

insert into #Terms_And_Rejoins
select n.ID, n.FULL_NAME, dbo.removeBreaks(n.COMPANY) Company
	, rm.Region_Name Region
	, 0
	, 0
	, case when year(isnull(d.REJOIN_DATE,n.JOIN_DATE)) > year(n.JOIN_DATE) then 1 else 0 end REJOINS
	, case when year(isnull(d.REJOIN_DATE,n.JOIN_DATE)) <= year(n.JOIN_DATE) then 1 else 0 end NEW_JOINS
	, isnull([2016RECON],0) Attended_2016_RECON
	, isnull([2017RECON],0) Registered_2017_RECON
from name n
	inner join Demographics d on n.ID = d.ID
	left join Csys_ICSC_Regions_Mem rm on n.COUNTRY = rm.Country
	left join (select o.ST_ID
	, sum(case when om.MEETING = '2016RECON' then 1 else 0 end) as [2016RECON]
	, sum(case when om.MEETING = '2017RECON' then 1 else 0 end) as [2017RECON]
			from orders o
				inner join order_meet om on o.ORDER_NUMBER = om.ORDER_NUMBER
			where o.STATUS not like 'C%'
			group by o.ST_ID
	) a on n.ID = a.ST_ID
where ((	
		n.JOIN_DATE >= '2017-2-1'
			and n.JOIN_DATE <= '2017-2-28')
		or 
		(d.REJOIN_DATE >= '2017-2-1'
			and d.REJOIN_DATE <= '2017-2-28'
		))
	and n.COMPANY_RECORD = 0
	and n.STATUS = 'A'
	and n.ID not in (select ID from #Terms_And_Rejoins)

select *
from #Terms_And_Rejoins