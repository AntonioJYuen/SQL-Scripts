SELECT csys_Country_Export.ICSC_REGION
	, dbo.Meet_Master.MEETING
	, dbo.Meet_Master.TITLE
	, YEAR(dbo.Meet_Master.BEGIN_DATE) AS [Year of Meeting]
	, CASE WHEN dbo.Meet_Master.COUNTRY = '' THEN dbo.Meet_Master.STATE_PROVINCE ELSE dbo.Meet_Master.COUNTRY END AS Region
	, dbo.Orders.COMPANY
	, CASE WHEN dbo.Demographics.PRIM_BUS_CODE = 'RET' THEN dbo.Demographics.PRIM_BUS_CODE WHEN dbo.Demographics.PRIM_BUS_CODE = '' and dbo.Order_Meet.REGISTRANT_CLASS = 'NM' then 'PROSPECT RET' ELSE '' END PRIM_BUS_CODE
	, dbo.Order_Meet.REGISTRANT_CLASS
	, dbo.Order_Lines.PRODUCT_CODE
	, dbo.Order_Lines.DESCRIPTION
	, dbo.Order_Lines.QUANTITY_ORDERED
	, dbo.Order_Lines.UNIT_PRICE
	, dbo.Orders.TOTAL_PAYMENTS
FROM         dbo.Order_Lines INNER JOIN
                      dbo.Order_Meet ON dbo.Order_Lines.ORDER_NUMBER = dbo.Order_Meet.ORDER_NUMBER INNER JOIN
                      dbo.Orders ON dbo.Order_Lines.ORDER_NUMBER = dbo.Orders.ORDER_NUMBER INNER JOIN
                      dbo.Meet_Master ON dbo.Order_Meet.MEETING = dbo.Meet_Master.MEETING INNER JOIN
                      dbo.Demographics ON dbo.Orders.BT_ID = dbo.Demographics.ID
					  LEFT JOIN dbo.csys_Country_Export on case when dbo.meet_master.country = '' then 'United States' else dbo.meet_master.country END = dbo.csys_Country_Export.COUNTRY_NAME
WHERE     (dbo.Meet_Master.MEETING_TYPE = 'expo') AND (YEAR(dbo.Meet_Master.BEGIN_DATE) = 2014) AND (NOT (dbo.Orders.STATUS LIKE 'c%'))
		and dbo.order_lines.DESCRIPTION not in ('Canadian Currency', 'Cancellation Fee', 'Discount', 'Writeoff', 'Write Off')