
--select *
--from dbo.asi_SplitString('PRIM_BUS_CODE,SECONDARY_CODE,BIRTH_DATE,GENDER,FUNCTIONAL_TITLE,RESP_CODE,JOB_LEVEL,OWNERSHIP_TYPE,AREA_OF_INTEREST,AREA_OF_INTEREST,CountryOfInterest,RACE,PRIMARY_LANGUAGE,years_1to5,years_6to10,years_11to19,years_20ormore',',')

DECLARE @Active_Member_Count int

set @Active_Member_Count = (select count(n.id) 
							from name n inner join demographics d on n.id = d.id
							where n.COMPANY_RECORD = 0
								and n.STATUS = 'A'
								and n.MEMBER_TYPE not in ('NMI','PROS','BLANK'))

DECLARE db_cursor cursor fast_forward for
select ElementID, Element
from dbo.asi_SplitString('FIRST_NAME,LAST_NAME,FULL_NAME,Company,CITY,STATE_PROVINCE,COUNTRY,MEMBER_TYPE,JOIN_DATE,PAID_THRU,PRIM_BUS_CODE,SECONDARY_CODE,BIRTH_DATE,GENDER,FUNCTIONAL_TITLE,RESP_CODE,JOB_LEVEL,OWNERSHIP_TYPE,AREA_OF_INTEREST,AREA_OF_INTEREST,CountryOfInterest,RACE,PRIMARY_LANGUAGE,years_1to5,years_6to10,years_11to19,years_20ormore',',')

DECLARE @ElementID int
DECLARE @Element varchar(50)
DECLARE @SQLQuery varchar(max)

set @SQLQuery = ''

OPEN db_cursor
FETCH NEXT from db_cursor into @ElementID, @Element

while @@FETCH_STATUS = 0
BEGIN
	
	set @SQLQuery = @SQLQuery + 'select ''' + @Element + ''' Field, sum(case when ' + @Element + ' is not null and ' + @Element + ' <> '''' then 1 else 0 end) Num_Filled
, ' + cast(@Active_Member_Count as varchar(max)) + ' Total_Active_Members,
cast(cast(cast(sum(case when ' + @Element + ' is not null and ' + @Element + ' <> '''' then 1 else 0 end) as decimal(10,2))/' + cast(@Active_Member_Count as varchar(max)) + '*100 as decimal(10,2)) as varchar(max)) + ''%'' Percent_Filled
from name n inner join demographics d on n.id = d.id
where n.COMPANY_RECORD = 0
	and n.STATUS = ''A''
	and n.MEMBER_TYPE not in (''NMI'',''PROS'',''BLANK'')
union
'

	set @Element = ''
	FETCH NEXT from db_cursor into @ElementID, @Element
END

	CLOSE db_cursor
	DEALLOCATE db_cursor
	

SET @SQLQuery = SUBSTRING(@SQLQuery, 1, LEN(@SQLQuery) - CHARINDEX('u', REVERSE(@SQLQuery)))

EXEC (@SQLQuery)