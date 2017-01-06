select MEETING
	,TITLE
	,MEETING_TYPE
	,DESCRIPTION
	,BEGIN_DATE
	,END_DATE
	,STATUS
	,dbo.removeBreaks(ADDRESS_1) ADDRESS_1
	,dbo.removeBreaks(ADDRESS_2) ADDRESS_2
	,dbo.removeBreaks(ADDRESS_3) ADDRESS_3
	,CITY
	,STATE_PROVINCE
	,ZIP
	,COUNTRY
	,DIRECTIONS
	,COORDINATORS
	,dbo.removeBreaks(NOTES) NOTES
	,ALLOW_REG_STRING
	,EARLY_CUTOFF
	,REG_CUTOFF
	,LATE_CUTOFF
	,ORG_CODE
	,LOGO
	,MAX_REGISTRANTS
	,TOTAL_REGISTRANTS
	,TOTAL_CANCELATIONS
	,TOTAL_REVENUE
	,HEAD_COUNT
	,TAX_AUTHORITY_1
	,SUPPRESS_COOR
	,SUPPRESS_DIR
	,SUPPRESS_NOTES
	,MUF_1
	,MUF_2
	,MUF_3
	,MUF_4
	,MUF_5
	,MUF_6
	,MUF_7
	,MUF_8
	,MUF_9
	,MUF_10
	,INTENT_TO_EDIT
	,SUPPRESS_CONFIRM
	,WEB_VIEW_ONLY
	,WEB_ENABLED
	,POST_REGISTRATION
	,EMAIL_REGISTRATION
	,MEETING_URL
	,MEETING_IMAGE_NAME
	,CONTACT_ID
	,IS_FR_MEET
	,MEET_APPEAL
	,MEET_CAMPAIGN
	,MEET_CATEGORY
	,COMP_REG_REG_CLASS
	,COMP_REG_CALCULATION
	,SQUARE_FOOT_RULES
	,TAX_BY_ADDRESS
	,VAT_RULESET
	,REG_CLASS_STORED_PROC
	,WEB_REG_CLASS_METHOD
	,REG_OTHERS
	,ADD_GUESTS
from Meet_Master
where BEGIN_DATE >= '2016-1-1'