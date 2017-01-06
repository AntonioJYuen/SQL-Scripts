select *
from (
	select id, DATE_ADDED, ROW_NUMBER() over (PARTITION BY ID ORDER BY DATE_ADDED desc) Rownum
	from Name_Picture where id in (
			select id
			from Name_Picture
			group by id
			having count(id) > 1) ) a
where Rownum <> 1

select n.MEMBER_TYPE, n.STATUS, count(n.id)
FROM Name_Picture np
	inner join name n on np.ID = n.ID
where cast(PICTURE_LOGO as varbinary) = cast(0x30 as varbinary)
	or PICTURE_LOGO is null
group by n.MEMBER_TYPE, n.STATUS
order by n.STATUS, n.MEMBER_TYPE