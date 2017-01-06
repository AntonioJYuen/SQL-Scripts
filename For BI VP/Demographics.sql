select *
from Demographics
where id in ( select id
from Name
where LAST_UPDATED >= '2016-1-1')