select mm.MEETING
	, mt.DESCRIPTION MEETING_TYPE
	, mm.MUF_1 [Last Year Event]
	, mm.MUF_2 [Sponsorship Code]
	, mm.MUF_3 [Expo1 Code]
	, mm.MUF_4 [Expo2 Code]
	, mm.TITLE
	, mm.CITY
	, mm.STATE_PROVINCE
	, mm.COUNTRY
	, mm.BEGIN_DATE
	, case when datediff(ww,getdate(),mm.BEGIN_DATE) < 0 then 0 else datediff(ww,getdate(),mm.BEGIN_DATE) end Weeks_Out
	, CY.PRODUCT_MINOR
	, CY.Description
	, case when row_number() over (partition by cy.MEETING order by cy.description) = 1 then CY_Att.Registered else null end Unique_Registrants
	, isnull(CY.QTY_Ordered,0) QTY_Ordered
	, isnull(CY.Payments,0) Revenue
	, case when row_number() over (partition by cy.MEETING order by cy.description) = 1 then mm.MUF_5 else null end Expected_Attendence
	, case when row_number() over (partition by cy.MEETING order by cy.description) = 1 then mm.MUF_10 else null end Expected_Revenue
	, case when row_number() over (partition by cy.MEETING order by cy.description) = 1 then CY.Payments else null end Spon_Revenue
	, case when row_number() over (partition by cy.MEETING order by cy.description) = 1 then CY_Expo1.Payments else null end Expo2_Revenue
	, case when row_number() over (partition by cy.MEETING order by cy.description) = 1 then CY_Expo2.Payments else null end Expo2_Revenue
from Meet_Master mm
	inner join Meeting_Types mt on mm.MEETING_TYPE = mt.CODE
	left join Meet_Master mm2 on mm.MUF_1 = mm2.MEETING
	left join (select mm.MEETING, mm.MUF_5, mm.MUF_10, p.PRODUCT_MINOR,p.TITLE Description, sum(ol.QUANTITY_ORDERED) QTY_Ordered, isnull(sum(ol.UNIT_PRICE * ol.QUANTITY_ORDERED),0) Payments from Meet_Master mm inner join order_meet om on mm.MEETING = om.MEETING inner join Orders o on om.ORDER_NUMBER = o.ORDER_NUMBER inner join Order_Lines ol on om.ORDER_NUMBER = ol.ORDER_NUMBER inner join Product p on ol.PRODUCT_CODE = p.PRODUCT_CODE where o.STATUS not like 'C%' group by mm.MEETING, mm.MUF_5, mm.MUF_10, p.PRODUCT_MINOR, p.TITLE) CY  on mm.MEETING = CY.MEETING
	left join (select mm.MEETING, mm.MUF_5, mm.MUF_10, isnull(count(o.ST_ID),0) Registered, isnull(sum(o.TOTAL_PAYMENTS),0) Payments from Meet_Master mm inner join order_meet om on mm.MEETING = om.MEETING inner join Orders o on om.ORDER_NUMBER = o.ORDER_NUMBER where o.STATUS not like 'C%' group by mm.MEETING, mm.MUF_5, mm.MUF_10) CY_Att  on mm.MEETING = CY_Att.MEETING
	left join (select mm.MEETING, mm.MUF_5, mm.MUF_10, isnull(count(o.ST_ID),0) Registered, isnull(sum(o.TOTAL_PAYMENTS),0) Payments from Meet_Master mm inner join order_meet om on mm.MEETING = om.MEETING inner join Orders o on om.ORDER_NUMBER = o.ORDER_NUMBER where o.STATUS not like 'C%' group by mm.MEETING, mm.MUF_5, mm.MUF_10) CY_Spon  on mm.muf_2 = CY_Spon.MEETING
	left join (select mm.MEETING, mm.MUF_5, mm.MUF_10, isnull(count(o.ST_ID),0) Registered, isnull(sum(o.TOTAL_PAYMENTS),0) Payments from Meet_Master mm inner join order_meet om on mm.MEETING = om.MEETING inner join Orders o on om.ORDER_NUMBER = o.ORDER_NUMBER where o.STATUS not like 'C%' group by mm.MEETING, mm.MUF_5, mm.MUF_10) CY_Expo1  on mm.muf_3 = CY_Expo1.MEETING
	left join (select mm.MEETING, mm.MUF_5, mm.MUF_10, isnull(count(o.ST_ID),0) Registered, isnull(sum(o.TOTAL_PAYMENTS),0) Payments from Meet_Master mm inner join order_meet om on mm.MEETING = om.MEETING inner join Orders o on om.ORDER_NUMBER = o.ORDER_NUMBER where o.STATUS not like 'C%' group by mm.MEETING, mm.MUF_5, mm.MUF_10) CY_Expo2  on mm.muf_4 = CY_Expo2.MEETING
where mm.BEGIN_DATE >= '2016-1-1'
	and mm.BEGIN_DATE <= '2016-12-31'
	and mm.MEETING_TYPE not in ('SPON','EXPO')
	and mm.STATUS = 'A'
order by BEGIN_DATE, mm.MEETING, cy.Description
