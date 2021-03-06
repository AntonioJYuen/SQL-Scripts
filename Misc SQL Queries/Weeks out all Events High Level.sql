select mm.MEETING
	, mt.CODE MEETING_TYPE_CODE
	, mt.DESCRIPTION MEETING_TYPE
	, mm.MUF_1 [Last Year Event]
	, mm.MUF_2 [Sponsorship Code]
	, mm.MUF_3 [Expo1 Code]
	, mm.MUF_4 [Expo2 Code]
	, mm.TITLE
	, mm.CITY
	, mm.STATE_PROVINCE
	, case when mm.COUNTRY = '' then 'United States' else mm.COUNTRY end COUNTRY
	, mm.BEGIN_DATE
	, case when datediff(ww,getdate(),mm.BEGIN_DATE) < 0 then 0 else datediff(ww,getdate(),mm.BEGIN_DATE) end Weeks_Out
	--, CY.PRODUCT_MINOR
	--, CY.Description
	--, case when row_number() over (partition by cy.MEETING order by cy.description) = 1 then CY_Att.Registered else null end Unique_Registrants
	--, isnull(CY.QTY_Ordered,0) QTY_Ordered
	--, isnull(CY.Payments,0) CY_Revenue
	, mm.MUF_5 Expected_Attendence
	, mm.MUF_10 Expected_Revenue
	--, CY.Payments Spon_Revenue
	--, CY_Expo1.Payments Expo2_Revenue
	--, CY_Expo2.Payments Expo2_Revenue
	, isnull(CY.Registered,0) CY_Registered
	, LY_YTD.Registered LY_YTD_Registered
	, LY.Registered LY_Registered
	, I.Income_Account
	, I.Budget
	, I.Department
	--, LY.Payments LY_Revenue
from Meet_Master mm
	inner join Meeting_Types mt on mm.MEETING_TYPE = mt.CODE
	left join Meet_Master mm2 on mm.MUF_1 = mm2.MEETING	
	left join (select mm.MEETING, mm.MUF_5, mm.MUF_10, isnull(count(o.ST_ID),0) Registered, isnull(sum(o.TOTAL_PAYMENTS),0) Payments from Meet_Master mm inner join order_meet om on mm.MEETING = om.MEETING inner join Orders o on om.ORDER_NUMBER = o.ORDER_NUMBER where o.STATUS not like 'C%' group by mm.MEETING, mm.MUF_5, mm.MUF_10) CY  on mm.MEETING = CY.MEETING
	left join (select mm.MEETING, mm.MUF_5, mm.MUF_10, isnull(count(o.ST_ID),0) Registered, isnull(sum(o.TOTAL_PAYMENTS),0) Payments from Meet_Master mm inner join order_meet om on mm.MEETING = om.MEETING inner join Orders o on om.ORDER_NUMBER = o.ORDER_NUMBER where o.STATUS not like 'C%' group by mm.MEETING, mm.MUF_5, mm.MUF_10) LY  on mm.MUF_1 = LY.MEETING
	left join (select mm.MEETING, mm.MUF_5, mm.MUF_10, isnull(count(o.ST_ID),0) Registered, isnull(sum(o.TOTAL_PAYMENTS),0) Payments from Meet_Master mm inner join order_meet om on mm.MEETING = om.MEETING inner join Orders o on om.ORDER_NUMBER = o.ORDER_NUMBER where o.STATUS not like 'C%' and o.ORDER_DATE <= cast(cast(year(mm.BEGIN_DATE) as varchar(4))+'-'+convert(varchar(5),getdate(),10) as date) group by mm.MEETING, mm.MUF_5, mm.MUF_10) LY_YTD  on mm.MUF_1 = LY_YTD.MEETING
	--left join (select mm.MEETING, mm.MUF_5, mm.MUF_10, isnull(count(o.ST_ID),0) Registered, isnull(sum(o.TOTAL_PAYMENTS),0) Payments from Meet_Master mm inner join order_meet om on mm.MEETING = om.MEETING inner join Orders o on om.ORDER_NUMBER = o.ORDER_NUMBER where o.STATUS not like 'C%' group by mm.MEETING, mm.MUF_5, mm.MUF_10) CY_Att  on mm.MEETING = CY_Att.MEETING
	left join (select mm.MEETING, mm.MUF_5, mm.MUF_10, isnull(count(o.ST_ID),0) Registered, isnull(sum(o.TOTAL_PAYMENTS),0) Payments from Meet_Master mm inner join order_meet om on mm.MEETING = om.MEETING inner join Orders o on om.ORDER_NUMBER = o.ORDER_NUMBER where o.STATUS not like 'C%' group by mm.MEETING, mm.MUF_5, mm.MUF_10) CY_Spon  on mm.muf_2 = CY_Spon.MEETING
	left join (select mm.MEETING, mm.MUF_5, mm.MUF_10, isnull(count(o.ST_ID),0) Registered, isnull(sum(o.TOTAL_PAYMENTS),0) Payments from Meet_Master mm inner join order_meet om on mm.MEETING = om.MEETING inner join Orders o on om.ORDER_NUMBER = o.ORDER_NUMBER where o.STATUS not like 'C%' group by mm.MEETING, mm.MUF_5, mm.MUF_10) CY_Expo1  on mm.muf_3 = CY_Expo1.MEETING
	left join (select mm.MEETING, mm.MUF_5, mm.MUF_10, isnull(count(o.ST_ID),0) Registered, isnull(sum(o.TOTAL_PAYMENTS),0) Payments from Meet_Master mm inner join order_meet om on mm.MEETING = om.MEETING inner join Orders o on om.ORDER_NUMBER = o.ORDER_NUMBER where o.STATUS not like 'C%' group by mm.MEETING, mm.MUF_5, mm.MUF_10) CY_Expo2  on mm.muf_4 = CY_Expo2.MEETING
	left join (select PRODUCT_MAJOR, max(SUBSTRING(isnull(INCOME_ACCOUNT,''),6,7)) Income_Account, max(SUBSTRING(isnull(INCOME_ACCOUNT,''),6,4)) Budget, max(SUBSTRING(isnull(INCOME_ACCOUNT,''),11,2)) Department
					from (
						select p.PRODUCT_MAJOR, case when p.INCOME_ACCOUNT = '' then pp.INCOME_ACCOUNT else p.INCOME_ACCOUNT end INCOME_ACCOUNT
						from Product p
							left join (select PRODUCT_CODE, max(INCOME_ACCOUNT) INCOME_ACCOUNT from Product_Price group by PRODUCT_CODE) pp on p.PRODUCT_CODE = pp.PRODUCT_CODE
							inner join Meet_Master mm on p.PRODUCT_MAJOR = mm.MEETING
						where PRODUCT_MAJOR like '2016%'
							and PRODUCT_MINOR like 'FP%'
					)a
					group by PRODUCT_MAJOR
				) I on mm.MEETING = I.PRODUCT_MAJOR
where mm.BEGIN_DATE >= '2016-1-1'
	and mm.BEGIN_DATE <= '2016-12-31'
	and mm.MEETING_TYPE not in ('SPON','EXPO')
	and mm.STATUS = 'A'
order by BEGIN_DATE, mm.MEETING