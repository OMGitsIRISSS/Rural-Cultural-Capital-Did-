
cd "D:\插补完数据"


*use 10-20非平衡面板插补数据, clear 
use 10-20非平衡面板, clear 

*借钱困难程度
recode ft901 Get (.=0)
gen 借钱困难程度 = (ft901 > 0 | Get > 0)  

*人情礼支出	\omega_3	家庭人情礼支出（元）
gen 人情礼支出 =  Soc

*土地资产	\omega_3	是否拥有分得的集体土地，是=1，否=0
gen 土地资产 = 1 if Land > 0 & Land != . 
replace 土地资产 = 0 if Land == 0 

*低风险金融资本	\omega_6	现金和存款总额（元）
gen 低风险金融资本 = savings

*高风险金融资本	\omega_7	金融产品总价
gen 高风险金融资本 = finance_asset
replace 高风险金融资本 = Fin if 高风险金融资本 == . & Fin != .

*人均家庭纯收入	\omega_8	人均家庭纯收入(元）
gen 人均家庭纯收入 = inc1

*家庭总房产	\omega_9	家庭房屋调查当年的市场总价值（万元）
gen 家庭总房产 = Est/10000
replace 家庭总房产 = Hast if 家庭总房产 == . & Hast != . 

*耐用消费品价值	\omega_{10}	家庭耐用消费品（汽车、电脑、家电等）调查当年的市场总价值（元）
gen 耐用消费品价值 = durables_asset

*是否从是农林牧副渔工作	\omega_{13}	是=1，否=0
gen 是否从是农林牧副渔工作 = agri

*是否养过牲畜或水产品	\omega_{14}	是=1，否=0
gen 是否养过牲畜或水产品 = (farm == 1)

*学历	\omega_{16}	文盲=1，小学=2，初中=3，普高或职高=4，本科/大专毕业或在读=5
recode edu (0= 1) (1=2) (2=3) (4=4) (5/8=5), gen(学历)

*教育培训	\omega_{17}	过去12个月教育培训支出（元）
gen 教育培训 = eexp 

*网络学习	\omega_{18}	是=1，否=0
egen 网络学习 = rowtotal(inter ku201)
recode 网络学习 (1/2=1)

order fid* pid year 借钱困难程度-网络学习
save 已有数据, replace 
	

*===================================================================================*
*                                                                                   *
*                                       2010                                        *
*                                                                                   *
*===================================================================================*
cd "D:\插补完数据\CFPS\2010"

use cfps2010adult_202008, clear 
merge 1:1 pid fid using cfps2010famconf_202008
drop _merge 
merge m:1 fid using cfps2010famecon_202008
keep if _merge == 3 
drop _merge 

rename fid fid10 
gen year = 2010  

*社会捐助	\omega_2	是否受到社会捐助是=1，否=0
gen 社会捐赠 = (welfare > 0) if welfare != .

*做饭用水	\omega_4	家庭饮食是否使用自来水、桶装水，纯净水，是=1，否=0
tab fb1
recode fb1 (1/2=0) (3/4=1) (5/77=0), gen(做饭用水)

*做饭燃料	\omega_5	家庭做饭是否采用电、天然气、管道煤气、太阳能等能源，是=1，否=0
tab fb2
recode fb2 (-1/2=0) (3/6=1) (77=0), gen(做饭燃料)

*农业机械价值	\omega_{11}	家庭农用机械调查当年的市场总价值（元）
recode fj302 (-8=0), gen(农业机械价值)

*离退休或养老金	\omega_{12}	有=1，没有=0
recode ff4 (-1=0), gen(离退休或养老金)
replace 离退休或养老金 = 1 if ff401 > 0 & 离退休或养老金 == 0 

*商业性保险	\omega_{13}	过去12个月商业性保险支出(元)
sum fh409 
recode fh409 (-2/-1=0), gen(商业性保险) 

*自家农副产品消费总值（元）	\omega_{14}	是=1，否=0
recode fk604_a_1 fk604_a_2 fk604_a_3 fk604_a_4 fk604_a_5 fk704_a_1 fk704_a_2 fk704_a_3 fk704_a_4 (-250000/-1=0)
egen 自家农副产品消费总值 = rowtotal(fk604_a_1 fk604_a_2 fk604_a_3 fk604_a_4 fk604_a_5 fk704_a_1 fk704_a_2 fk704_a_3 fk704_a_4)
gen 自家农副产品消费 = (自家农副产品消费总值 > 0)

*受访主要语言	\omega_{15}	是否为普通话，是=1，否=0
gen 受访者主要语言 = (qd2 == 1 | ks3 == 1)

rename tb4_a_p 最高学历 

keep pid fid* year 社会捐赠 做饭用水 做饭燃料 农业机械价值 离退休或养老金 商业性保险 自家农副产品消费 自家农副产品消费总值 受访者主要语言 最高学历 
compress 
save "D:\插补完数据\CFPS\year_2010", replace 

	
*===================================================================================*
*                                                                                   *
*                                       2012                                        *
*                                                                                   *
*===================================================================================*
cd "D:\插补完数据\CFPS\2012"

use CFPS_2012_adult, clear 
merge m:1 fid12 using CFPS_2012_family
keep if _merge == 3 
drop _merge 

gen year = 2012  	

*社会捐助	\omega_2	是否受到社会捐助是=1，否=0
recode fn101_a_* fn201 (-8/-1=0)
egen c = rowtotal(fn101_a_* fn201)
gen 社会捐赠 = (c > 0)

*做饭用水	\omega_4	家庭饮食是否使用自来水、桶装水，纯净水，是=1，否=0
tab fb1
recode fb1 (1/2=0) (3/4=1) (5/77=0), gen(做饭用水)

*做饭燃料	\omega_5	家庭做饭是否采用电、天然气、管道煤气、太阳能等能源，是=1，否=0
tab fb2, nol 
recode fb2 (-1/2=0) (3/6=1) (77=0), gen(做饭燃料)

*农业机械价值	\omega_{11}	家庭农用机械调查当年的市场总价值（元）
recode fs702_a_1 fs702_a_2 fs702_a_3 fs702_a_4 (-8/-1=0)
egen 农业机械价值 = rowtotal(fs702_a_1 fs702_a_2 fs702_a_3 fs702_a_4)

*离退休或养老金	\omega_{12}	有=1，没有=0
recode ff4 (-1=0), gen(离退休或养老金)
replace 离退休或养老金 = 1 if qi401 > 0 & qi401 != .

*商业性保险	\omega_{13}	过去12个月商业性保险支出(元)
sum fp515 
recode fp515 (-2/-1=0), gen(商业性保险) 

*自家农副产品消费总值（元）	\omega_{14}	是=1，否=0
recode fl7 (-8/-1=0)
gen 自家农副产品消费 = (fl7 > 0)
gen 自家农副产品消费总值 = fl7

*受访主要语言	\omega_{15}	是否为普通话，是=1，否=0
gen 受访者主要语言 = (qd201 == 1 | ks3m == 1)

rename edu 最高学历 

keep pid fid* year 社会捐赠 做饭用水 做饭燃料 农业机械价值 离退休或养老金 商业性保险 自家农副产品消费 自家农副产品消费总值 受访者主要语言 最高学历 
compress 
save "D:\插补完数据\CFPS\year_2012", replace 
	
	

*===================================================================================*
*                                                                                   *
*                                       2014                                        *
*                                                                                   *
*===================================================================================*
cd "D:\插补完数据\CFPS\2014"

use cfps2014adult_20161230, clear 
merge 1:1 pid fid14 using cfps2014famconf_20161230, force 
drop _merge 

merge m:1 fid14 using cfps2014famecon_20161230
keep if _merge == 3 
drop _merge 

gen year = 2014  	
	
*社会捐助	\omega_2	是否受到社会捐助是=1，否=0
recode fn2 (-8/-1=0)
gen 社会捐赠 = fn2 

*做饭用水	\omega_4	家庭饮食是否使用自来水、桶装水，纯净水，是=1，否=0
tab fa3
recode fa3 (-2/2=0) (3/4=1) (5/77=0), gen(做饭用水)

*做饭燃料	\omega_5	家庭做饭是否采用电、天然气、管道煤气、太阳能等能源，是=1，否=0
tab fa4, nol 
recode fa4 (-2/2=0) (3/6=1) (77=0), gen(做饭燃料)

*农业机械价值	\omega_{11}	家庭农用机械调查当年的市场总价值（元）
recode fl503 fl803 (-8/-1=0)
egen 农业机械价值 = rowtotal(fl503 fl803)

*离退休或养老金	\omega_{12}	有=1，没有=0
recode fn3 (-1=0) (5=0), gen(离退休或养老金)

*商业性保险	\omega_{13}	过去12个月商业性保险支出(元)
sum fp514 
recode fp514 (-2/-1=0), gen(商业性保险) 

*自家农副产品消费总值（元）	\omega_{14}	是=1，否=0
recode fl9 (-8/-1=0)
gen 自家农副产品消费 = (fl9 > 0)
gen 自家农副产品消费总值 = fl9

*受访主要语言	\omega_{15}	是否为普通话，是=1，否=0
gen 受访者主要语言 = (ks3m == 1 | qz103 == 1)

rename tb4_a14_p 最高学历 

keep pid fid* year 社会捐赠 做饭用水 做饭燃料 农业机械价值 离退休或养老金 商业性保险 自家农副产品消费 自家农副产品消费总值 受访者主要语言 最高学历 
compress 
save "D:\插补完数据\CFPS\year_2014", replace 



*===================================================================================*
*                                                                                   *
*                                       2016                                        *
*                                                                                   *
*===================================================================================*
cd "D:\插补完数据\CFPS\2016"

use Cfps2016adult_201709, clear 
merge 1:1 pid fid16 using cfps2016famconf_201804
drop _merge 
merge m:1 fid16 using Cfps2016famecon_201709
keep if _merge == 3 
drop _merge 

gen year = 2016 

*社会捐助	\omega_2	是否受到社会捐助是=1，否=0
recode fn2 (-8/-1=0) (5=0)
gen 社会捐赠 = fn2 

*做饭用水	\omega_4	家庭饮食是否使用自来水、桶装水，纯净水，是=1，否=0
tab fa3
recode fa3 (-2/2=0) (3/4=1) (5/77=0), gen(做饭用水)

*做饭燃料	\omega_5	家庭做饭是否采用电、天然气、管道煤气、太阳能等能源，是=1，否=0
tab fa4, nol 
recode fa4 (-2/2=0) (3/6=1) (77=0), gen(做饭燃料)

*农业机械价值	\omega_{11}	家庭农用机械调查当年的市场总价值（元）
recode fs7v (-8/-1=0)
egen 农业机械价值 = rowtotal(fs7v)

*离退休或养老金	\omega_{12}	有=1，没有=0
recode fn3 (-1=0) (5=0), gen(离退休或养老金)

*商业性保险	\omega_{13}	过去12个月商业性保险支出(元)
sum fp514 
recode fp514 (-2/-1=0), gen(商业性保险) 

*自家农副产品消费总值（元）	\omega_{14}	是=1，否=0
recode fl10 (-8/-1=0)
gen 自家农副产品消费 = (fl10 > 0)
gen 自家农副产品消费总值 = fl10

*受访主要语言	\omega_{15}	是否为普通话，是=1，否=0
gen 受访者主要语言 = (ks3m == 1 | qz103 == 1)

rename tb4_a16_p 最高学历 

keep pid fid* year 社会捐赠 做饭用水 做饭燃料 农业机械价值 离退休或养老金 商业性保险 自家农副产品消费 自家农副产品消费总值 受访者主要语言 最高学历 
compress 
save "D:\插补完数据\CFPS\year_2016", replace 
	
	

*===================================================================================*
*                                                                                   *
*                                       2018                                        *
*                                                                                   *
*===================================================================================*
cd "D:\插补完数据\CFPS\2018"

use cfps2018person_202012, clear 
merge 1:1 pid fid18 using cfps2018famconf_202008, force 
drop _merge 
merge m:1 fid18 using cfps2018famecon_202101
keep if _merge == 3 
drop _merge 

gen year = 2018 
	
*社会捐助	\omega_2	是否受到社会捐助是=1，否=0
recode fn2 (-8/-1=0) (5=0)
gen 社会捐赠 = fn2 

*做饭用水	\omega_4	家庭饮食是否使用自来水、桶装水，纯净水，是=1，否=0
tab fa3
recode fa3 (-2/2=0) (3/4=1) (5/77=0), gen(做饭用水)

*做饭燃料	\omega_5	家庭做饭是否采用电、天然气、管道煤气、太阳能等能源，是=1，否=0
tab fa4, nol 
recode fa4 (-2/2=0) (3/6=1) (77=0), gen(做饭燃料)

*农业机械价值	\omega_{11}	家庭农用机械调查当年的市场总价值（元）
recode fs7v (-8/-1=0)
egen 农业机械价值 = rowtotal(fs7v)

*离退休或养老金	\omega_{12}	有=1，没有=0
recode fn3 (-1=0) (5=0), gen(离退休或养老金)

*商业性保险	\omega_{13}	过去12个月商业性保险支出(元)
sum fp514 
recode fp514 (-2/-1=0), gen(商业性保险) 

*自家农副产品消费总值（元）	\omega_{14}	是=1，否=0
recode fl10 (-8/-1=0)
gen 自家农副产品消费 = (fl10 > 0)
gen 自家农副产品消费总值 = fl10

*受访主要语言	\omega_{15}	是否为普通话，是=1，否=0
gen 受访者主要语言 = (qs3m == 1 | qz103 == 1)

rename tb4_a18_p 最高学历 

keep pid fid* year 社会捐赠 做饭用水 做饭燃料 农业机械价值 离退休或养老金 商业性保险 自家农副产品消费 自家农副产品消费总值 受访者主要语言 最高学历 
compress 
save "D:\插补完数据\CFPS\year_2018", replace 
	
	
	
	
*===================================================================================*
*                                                                                   *
*                                       2020                                        *
*                                                                                   *
*===================================================================================*
cd "D:\插补完数据\CFPS\2020"

use cfps2020person_202112, clear 
merge 1:1 pid fid20 using cfps2020famconf_202301, force 
drop _merge 
merge m:1 fid20 using cfps2020famecon_202306
keep if _merge == 3 
drop _merge 

gen year = 2020 

*社会捐助	\omega_2	是否受到社会捐助是=1，否=0
recode fn2 (-8/-1=0) (5=0)
gen 社会捐赠 = fn2 

*做饭用水	\omega_4	家庭饮食是否使用自来水、桶装水，纯净水，是=1，否=0
tab fa3
recode fa3 (-2/2=0) (3/4=1) (5/77=0), gen(做饭用水)

*做饭燃料	\omega_5	家庭做饭是否采用电、天然气、管道煤气、太阳能等能源，是=1，否=0
tab fa4, nol 
recode fa4 (-2/2=0) (3/6=1) (77=0), gen(做饭燃料)

*农业机械价值	\omega_{11}	家庭农用机械调查当年的市场总价值（元）
recode fs7v (-8/-1=0)
egen 农业机械价值 = rowtotal(fs7v)

*离退休或养老金	\omega_{12}	有=1，没有=0
recode fn3 (-1=0) (5=0), gen(离退休或养老金)

*商业性保险	\omega_{13}	过去12个月商业性保险支出(元)
sum fp514 
recode fp514 (-2/-1=0), gen(商业性保险) 

*自家农副产品消费总值（元）	\omega_{14}	是=1，否=0
recode fl10 (-8/-1=0)
gen 自家农副产品消费 = (fl10 > 0)
gen 自家农副产品消费总值 = fl10

*受访主要语言	\omega_{15}	是否为普通话，是=1，否=0
gen 受访者主要语言 = (qs3m == 1 | qz103 == 1)

rename tb4_a20_p 最高学历 

keep pid fid* year 社会捐赠 做饭用水 做饭燃料 农业机械价值 离退休或养老金 商业性保险 自家农副产品消费 自家农副产品消费总值 受访者主要语言 最高学历 
compress 
compress 
save "D:\插补完数据\CFPS\year_2020", replace 
	
	

*===================================================================================*
*                                                                                   *
*                                合并后再清洗                                       *
*                                                                                   *
*===================================================================================*
cd "D:\插补完数据\CFPS"

***合并***
clear 
openall year_* 
drop fid_provcd18-fid_urban16
drop fid20 fid12 fid14 fid16 fid18 fidbaseline fid_base fid_countyid20 fid_cid20 fid_provcd20 fid_urban20

recode 最高学历 (-9/-1=.)
recode 最高学历 (1= 1) (2=2) (3=3) (4=4) (5/8=5), gen(学历水平)

merge m:1 fid10 pid year using "D:\插补完数据/已有数据" 
drop if _merge == 1 
drop _merge 

order fid* pid year 
sum 社会捐赠-网络学习
drop 学历 

recode 农业机械价值 (-2/-1=0)
recode 离退休或养老金 (-8=0) (2=0)
recode 商业性保险 (-8/0=0)
recode 人情礼支出 离退休或养老金 低风险金融资本 高风险金融资本 人均家庭纯收入 家庭总房产 耐用消费品价值 (.=0)
compress 

save "D:\插补完数据/2010_2020熵值法数据", replace 

export excel using D:\插补完数据/2010_2020熵值法数据.xlsx, replace firstrow(var) keepcellfmt 


	