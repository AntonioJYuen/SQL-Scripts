select ID
,ADDRESS_NUM
,PURPOSE
,COMPANY
,ADDRESS_1
,ADDRESS_2
,CITY
,STATE_PROVINCE
,ZIP
,COUNTRY
,CRRT
,DPB
,BAR_CODE
,COUNTRY_CODE
,ADDRESS_FORMAT
,dbo.removeBreaks(FULL_ADDRESS) FULL_ADDRESS
,COUNTY
,US_CONGRESS
,STATE_SENATE
,STATE_HOUSE
,MAIL_CODE
,PHONE
,FAX
,TOLL_FREE
,COMPANY_SORT
,NOTE
,STATUS
,LAST_UPDATED
,LIST_STRING
,PREFERRED_MAIL
,PREFERRED_BILL
,LAST_VERIFIED
,EMAIL
,BAD_ADDRESS
,NO_AUTOVERIFY
,LAST_QAS_BATCH
,ADDRESS_3
,PREFERRED_SHIP
from Name_Address
where LAST_UPDATED >= '2016-1-1'