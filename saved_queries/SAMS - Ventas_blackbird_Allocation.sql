SELECT  
                                                                                                                                           b.category_nbr AS Cat
                                                                                                                                          ,b.sub_category_nbr AS Subcat
                                                                                                                                          ,b.vendor_nbr_dept AS Vendor_Dept
                                                                                                                                          ,b.vendor_nbr AS Vendor_Nbr
                                                                                                                                          ,b.vendor_nbr_seq AS Vendor_Seq
                                                                                                                                          ,b.vendor_name AS Vendor_Name
                                                                                                                                          ,a.club_nbr AS Club_nbr
                                                                                                                                          ,a.status AS Status_club
-- Actual 

,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12233)THEN c.wkly_qty END ),0) ASqty_wk22_33
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12234)THEN c.wkly_qty END ),0) ASqty_wk22_34
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12235)THEN c.wkly_qty END ),0) ASqty_wk22_35
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12236)THEN c.wkly_qty END ),0) ASqty_wk22_36
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12237)THEN c.wkly_qty END ),0) ASqty_wk22_37
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12238)THEN c.wkly_qty END ),0) ASqty_wk22_38
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12239)THEN c.wkly_qty END ),0) ASqty_wk22_39
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12240)THEN c.wkly_qty END ),0) ASqty_wk22_40
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12141)THEN c.wkly_qty END ),0) ASqty_wk22_41
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12242)THEN c.wkly_qty END ),0) ASqty_wk22_42
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12243)THEN c.wkly_qty END ),0) ASqty_wk22_43
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12244)THEN c.wkly_qty END ),0) ASqty_wk22_44
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12245)THEN c.wkly_qty END ),0) ASqty_wk22_45
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12246)THEN c.wkly_qty END ),0) ASqty_wk22_46
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12247)THEN c.wkly_qty END ),0) ASqty_wk22_47
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12248)THEN c.wkly_qty END ),0) ASqty_wk22_48

,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12233)THEN c.wkly_qty*a.unit_cost END ),0) ASC_wk22_33
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12234)THEN c.wkly_qty*a.unit_cost END ),0) ASC_wk22_34
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12235)THEN c.wkly_qty*a.unit_cost END ),0) ASC_wk22_35
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12236)THEN c.wkly_qty*a.unit_cost END ),0) ASC_wk22_36
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12237)THEN c.wkly_qty*a.unit_cost END ),0) ASC_wk22_37
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12238)THEN c.wkly_qty*a.unit_cost END ),0) ASC_wk22_38
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12239)THEN c.wkly_qty*a.unit_cost END ),0) ASC_wk22_39
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12240)THEN c.wkly_qty*a.unit_cost END ),0) ASC_wk22_40
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12241)THEN c.wkly_qty*a.unit_cost END ),0) ASC_wk22_41
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12242)THEN c.wkly_qty*a.unit_cost END ),0) ASC_wk22_42
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12243)THEN c.wkly_qty*a.unit_cost END ),0) ASC_wk22_43
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12244)THEN c.wkly_qty*a.unit_cost END ),0) ASC_wk22_44
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12245)THEN c.wkly_qty*a.unit_cost END ),0) ASC_wk22_45
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12246)THEN c.wkly_qty*a.unit_cost END ),0) ASC_wk22_46
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12247)THEN c.wkly_qty*a.unit_cost END ),0) ASC_wk22_47
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12248)THEN c.wkly_qty*a.unit_cost END ),0) ASC_wk22_48

                                                                                                                                                                     
 FROM 
  wmt-edw-prod.MX_WC_VM.SKU_DLY_POS c, -- ventas
  wmt-edw-prod.MX_WC_VM.MDSE_INVENTORY a,
  wmt-edw-prod.MX_WC_VM.ITEM_DESC b

  where a.club_nbr=c.store_nbr
  AND c.ITEM_NBR = a.ITEM_NBR
  AND a.ITEM_NBR = b.item_nbr
  AND b.category_nbr IN  (3,
5,
6,
7,
9,
10,
11,
12,
14,
15,
16,
17,
18,
20,
29,
31,
32,
36,
50,
60,
61,
70,
71,
78,
80,
81,
85,
86,
92,
94,
97,
98)
AND a.club_nbr IN  (4727,
4728,
4746,
4790,
4791,
4792,
4801,
4805,
4827,
4832,
4841,
4862,
4877,
4878,
4879,
4901,
4910,
4911,
4913,
4934,
4935,
4936,
4937,
4938,
4939,
4944,
4945,
4946,
4947,
4948,
4949,
4950,
4951,
4954,
4955,
4957,
4958,
4960,
4961,
4968,
4969,
4970,
4972,
4973,
4975,
4977,
4978,
4979,
4981,
4982,
4983,
4984,
4985,
4986,
4987,
4988,
4991,
4992,
4999,
6204,
6205,
6206,
6207,
6208,
6209,
6210,
6211,
6212,
6213,
6215,
6217,
6218,
6219,
6221,
6222,
6223,
6224,
6225,
6226,
6227,
6232,
6233,
6234,
6236,
6237,
6240,
6241,
6242,
6244,
6248,
6249,
6251,
6252,
6254,
6258,
6260,
6261,
6263,
6264,
6274,
6275,
6279,
6285,
6288,
6294,
6390,
6391,
6392,
6393,
6394,
6395,
6396,
6397,
6398,
6467,
6468,
6469,
6470,
6497,
6513,
6523,
6534,
6557,
6563,
6574,
6576,
6577,
6578,
6583,
6584,
6585,
6586,
8118,
8121,
8122,
8124,
8127,
8240,
6282,
6298,
6287,
6300,
6297,
6289,
6277,
6247,
6305,
6265,
4989,
6229,
6293,
6286,
6296,
6309,
6246,
6308,
4941,
6290,
6307,
6243,
6295,
6283,
6313,
6314,
6317,
5854,
6315,
6320,
4914,
6312)

 GROUP BY 1,2,3,4,5,6,7,8
