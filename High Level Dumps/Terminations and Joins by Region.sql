select month(d.TERMINATION_DATE) Month_Terminated
	, isnull(rm.Region_Name, ur.ICSC_USA_REGION) Region
	, sum(case when n.status = 'A' then 1 else 0 end) Rejoined
	, sum(case when n.status = 'S' then 1 else 0 end) Not_Rejoined
from Name n
	inner join Demographics d on n.ID = d.ID
	left join Csys_ICSC_Regions_Mem rm on n.COUNTRY = rm.Country
	left join csys_ICSC_USA_regions ur on n.STATE_PROVINCE = ur.STATE_CODE
where d.TERMINATION_DATE >= '2017-2-1'
	and n.COMPANY_RECORD = 0
group by month(d.TERMINATION_DATE),isnull(rm.Region_Name, ur.ICSC_USA_REGION)

select month(case when n.JOIN_DATE between '2017-2-1' and '2017-2-28' then n.JOIN_DATE else d.REJOIN_DATE end) Month_Joined_Rejoined
	, isnull(rm.Region_Name, ur.ICSC_USA_REGION) Region
	, sum(case when year(isnull(d.REJOIN_DATE,n.JOIN_DATE)) > year(n.JOIN_DATE) then 1 else 0 end) REJOINS
	, sum(case when year(isnull(d.REJOIN_DATE,n.JOIN_DATE)) <= year(n.JOIN_DATE) then 1 else 0 end) NEW_JOINS
from name n
	inner join Demographics d on n.ID = d.ID
	left join Csys_ICSC_Regions_Mem rm on n.COUNTRY = rm.Country
	left join csys_ICSC_USA_regions ur on n.STATE_PROVINCE = ur.STATE_CODE
where ((	
		n.JOIN_DATE >= '2017-2-1'
			and n.JOIN_DATE <= '2017-2-28')
		or 
		(d.REJOIN_DATE >= '2017-2-1'
			and d.REJOIN_DATE <= '2017-2-28'
		))
	and n.COMPANY_RECORD = 0
	and n.STATUS = 'A'
group by month(case when n.JOIN_DATE between '2017-2-1' and '2017-2-28' then n.JOIN_DATE else d.REJOIN_DATE end), isnull(rm.Region_Name, ur.ICSC_USA_REGION)