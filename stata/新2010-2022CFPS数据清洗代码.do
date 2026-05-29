

/*==================================================
              1: 个人数据
==================================================*/
****2022****
//打开数据

use "D:\stata\CFPS原数据\2022\cfps2022person_202410.dta", clear

keep pid fid22  age gender cfps2022edu cfps2022eduy_im qea0  qn4001  qa701code   qp605_s_* qp201 qu201  qu202 qa301  qg301 jobclass qg101 qg302code  qg2032 qg6 qg11  fid20 fid18 fid16 fid14 fid12 fid10 provcd22 countyid22 cid22 urban22 ibirthy gender_pre party qa002 kw01 qea0 qn8012 qu201 qp201 qp605_s_1 qp605_s_2 qp605_s_3 qp605_s_4 qp605_s_5 qn4001 pd5total qm2016 qg12 incomea incomeb emp_income qg1203 qg1203 qga2 party qn4001 qn402 employ qn6012 qu92  qn1001 qn10021 qn10022 qn10023 qn10024 qn10025 qn10026 qn12012 qn12016 qp401  qq201 qq4010 qn1101 qg401 qg402 qg403 qg404 qg405 qg406 

rename provcd22 provcd
rename countyid22 countyid
rename cid22 cid
rename urban22 urban

label list

for var _all: replace X =. if inlist(X, -10, -9, -8, -2, -1)

tab qa301

tab qea0

recode qa301 (1 7= 1 "农业户口")(3 = 0 "非农户口")(5  79 =.), gen(hukou)

recode qea0  (2 3 = 1 "有配偶")(1 4 5 = 0 "无配偶"), gen(spouse)

recode cfps2022edu (1 = 0 "文盲/半文盲")(2 = 1 "小学")       (3 = 2 "初中") (4 = 3 "高中")       (5 = 4 "大专")(6 = 5 "大学本科")  (7 = 6 "硕士") (8 = 7 "博士") (79=.),gen(edu)

label var edu"受教育程度 0=文盲/半文盲 1=小学 2=初中 4=高中/中专/技校/职高 5=大专 6=大学本科 7=硕士 8=博士"

recode cfps2022edu (1 = 0 )(2 = 6) (3 = 9 ) (4 = 12 ) (5 = 15)(6 = 16 )  (7 = 19 ) (8 = 22) ( 9 = .),gen(educ)

label var educ"受教育年限 受教育程度 0=文盲/半文盲 6=小学 9=初中 12=高中/中专/技校/职高 15=大专 16=大学本科 19=硕士 22=博士"

des qp605_s_*
for var qp605_s_*:replace X=. if X==78

gen medsure_dum = 0

for var qp605_s_*: replace medsure_dum = 1 if X !=.

label var medsure_dum"是否购买医保"

recode hukou (0 = 0 )(1 = 1), gen (res)

label var res"户口性质 1=农业户口 0=非农户口"

recode qea0  (2 3 = 1)(1 4 5 = 0 ), gen(mar)

label var mar"婚姻状况 1=有配偶 0= 无配偶"

gen age_=age
label var age_"户主年龄"

recode gender  (1 = 1 )(0 = 0 ), gen(gen)
label var gen"性别 1=男 0=女"

recode qp201 (1 2 3 4 = 0 )(5 = 1) ,gen(unhealth)

bysort fid22: egen weak = sum (unhealth)
label var weak "家庭不健康人数" 

recode qp201 (1=5 )(2 = 4)(3=3)(4=2)(5=1) ,gen(health)
label var health"赋值1-5 数值越大，越健康"

gen size1=1
bysort fid22: egen size = sum (size1)
label var size "家庭规模"

recode hukou (1=1)(0=0) ,gen(rural)
label var rural"户口性质 1=农业户口 0=非农户口"

gen old1=1 if age_>=65
bys fid22: egen old=sum(old1)
label var old "老龄人口量"

gen job=0
replace job=1 if employ==1
label var job "当前工作状态"
gen wage=emp_income
label var wage "当前十二个月所有工作的收入"
gen dw=qn8012
label var dw"社会地位"

//缺失值替换为.
for var _all: replace X =. if inlist(X, -10, -9, -8, -2, -1) 

//1.年龄
sum age

//2.年龄平方
gen age2=age^2/100
label var  age2 "年龄平方"

//3.性别
label var gender "性别"


//5.教育
rename cfps2022eduy_im eduy //受教育年限
label var eduy "受教育年限"

//6.婚姻
sum qea0
label list qea0
recode qea0 (2 3 = 1 "是")(1 4 5= 0 "否"), gen(marrige)
label var marrige "婚姻状况"

//7.党员
gen communist=qn4001 
label var communist "是共产党员"

//8.民族
sum  qa701code
label list  qa701code
for var qa701code : replace X =. if inlist(X,79)
recode  qa701code (1=1 "汉族")(2/56=0 "其他"),gen(minzu)
label var minzu "民族"


//11.互联网使用
rename qu201 mobile //移动上网
rename qu202 computer //电脑上网
egen internet =rowmax( mobile computer)
label variable internet "互联网使用"


//13.工作地点
recode qg301 (1 2 3 4=1 "本县/市") (5 6 7=0 "非本县/市"),gen(workplace)
label variable workplace "工作地点"

//14.工作类型
sum jobclass

//15.工作性质
sum qg101
label list qg101
recode qg101(1=0 "农业工作")(5=1 "非农工作"),gen(worknature)
label var worknature "工作性质"

//16.行业
rename qg302code industry
label var  industry "行业"

//17.网购频率
recode qu92 (1 = 1 "是")(0 = 0 "否")(-10 -9 -8 -2 -1 79 =.), gen(onlineshopoping)
label variable onlineshopoping "是否网购"

//18.编制
rename qg2032 bianzhi
label variable bianzhi "编制"

//19.工作时长（小时/周）
rename qg6 workhour
label variable workhour "每周工作时长"

//20.工资收入（元/月）
rename qg11 gongzi
label variable gongzi "每月税后工资"

label variable qg401 "工作收入满意度"

label variable qg402 "工作安全满意度"

label variable qg403 "工作环境满意度"

label variable qg404 "工作时间满意度"

label variable qg405 "工作晋升满意度"

label variable qg406 "工作满意度"

label variable qn1101 "对本县市政府评价"

label variable qn10021 "对父母信任程度"

label variable qn10022 "对邻居信任程度"

label variable qn10023 "对美国人信任程度"

label variable qn10024 "对陌生人信任程度"

label variable qn10025 "对本地政府官员信任程度"

label variable qn10026 "对医生信任程度"

label variable qn12012 "对自己生活满意度"

label variable qn12016 "对自己未来信心程度"

label variable qp401 "半年内是否有慢性疾病"

label variable qq201 "过去一个月吸烟吗"

label variable qq4010 "睡眠时长（小时/天）"



order pid fid22 fid20 fid18 fid16 fid14 fid12 fid10 provcd countyid cid urban ibirthy age age2 gender edu educ eduy marrige communist minzu medsure_dum health internet hukou workplace jobclass worknature industry bianzhi workhour gongzi medsure_dum  res mar age_ gen unhealth weak health size rural old job wage dw qg401 qg402 qg403 qg404 qg405 qg406 qn1101 qn10021 qn10022 qn10023 qn10024 qn10025 qn10026 qn12012 qn12016 qp401 qq201 qq4010 mobile computer onlineshopoping

keep pid fid22 fid20 fid18 fid16 fid14 fid12 fid10 provcd countyid cid urban ibirthy age age2 gender edu educ eduy marrige communist minzu medsure_dum health internet hukou workplace jobclass worknature industry bianzhi workhour gongzi medsure_dum  res mar age_ gen unhealth weak health size rural old job wage dw qg401 qg402 qg403 qg404 qg405 qg406 qn1101 qn10021 qn10022 qn10023 qn10024 qn10025 qn10026 qn12012 qn12016 qp401 qq201 qq4010 mobile computer onlineshopoping 

save "D:\stata\CFPS原数据\2022\2022adult.dta "


****2020****
//打开数据

use "D:\stata\CFPS原数据\2020\cfps2020person_202306.dta", clear

keep pid fid20  age gender cfps2020edu cfps2020eduy_im qea0  qn4001  qa701code   qp605_s_* qp201 qu201  qu202 qa301  qg301 jobclass qg101 qg302code  qg2032 qg6 qg11 fid18 fid16 fid14 fid12 fid10 provcd20 countyid20 cid20 urban20 ibirthy gender_pre party qa002 w01 qea0 qn8012 qu201 qp201 qp605_s_1 qp605_s_2 qp605_s_3 qp605_s_4 qp605_s_5 qn4001 pd5total qm2016 qg12 incomea  incomeb emp_income qg1203 qg1203 qga2 party qn4001 qn402 employ  qn6012 qu92  qn1001 qn10021 qn10022 qn10023 qn10024 qn10025 qn10026 qn12012 qn12016 qp401  qq201 qq4010 qn1101 qg401 qg402 qg403 qg404 qg405 qg406

rename provcd20 provcd
rename countyid20 countyid
rename cid20 cid
rename urban20 urban

label list

for var _all: replace X =. if inlist(X, -10, -9, -8, -2, -1)

tab qa301

tab qea0

recode qa301 (1 7= 1 "农业户口")(3 = 0 "非农户口")(5  79 =.), gen(hukou)

recode qea0  (2 3 = 1 "有配偶")(1 4 5 = 0 "无配偶"), gen(spouse)

recode cfps2020edu (1 = 0 "文盲/半文盲")(2 = 1 "小学")       (3 = 2 "初中") (4 = 3 "高中")       (5 = 4 "大专")(6 = 5 "大学本科")  (7 = 6 "硕士") (8 = 7 "博士") (79=.),gen(edu)

label var edu"受教育程度 0=文盲/半文盲 1=小学 2=初中 4=高中/中专/技校/职高 5=大专 6=大学本科 7=硕士 8=博士"

recode cfps2020edu (1 = 0 )(2 = 6) (3 = 9 ) (4 = 12 ) (5 = 15)(6 = 16 )  (7 = 19 ) (8 = 22) ( 9 = .),gen(educ)

label var educ"受教育年限 受教育程度 0=文盲/半文盲 6=小学 9=初中 12=高中/中专/技校/职高 15=大专 16=大学本科 19=硕士 22=博士"

des qp605_s_*
for var qp605_s_*:replace X=. if X==78

gen medsure_dum = 0

for var qp605_s_*: replace medsure_dum = 1 if X !=.

label var medsure_dum"是否购买医保"

recode hukou (0 = 0 )(1 = 1), gen (res)

label var res"户口性质 1=农业户口 0=非农户口"

recode qea0  (2 3 = 1)(1 4 5 = 0 ), gen(mar)

label var mar"婚姻状况 1=有配偶 0= 无配偶"

gen age_=age
label var age_"户主年龄"

recode gender  (1 = 1 )(0 = 0 ), gen(gen)
label var gen"性别 1=男 0=女"

recode qp201 (1 2 3 4 = 0 )(5 = 1) ,gen(unhealth)

bysort fid20: egen weak = sum (unhealth)
label var weak "家庭不健康人数" 

recode qp201 (1=5 )(2 = 4)(3=3)(4=2)(5=1) ,gen(health)
label var health"赋值1-5 数值越大，越健康"

gen size1=1
bysort fid20: egen size = sum (size1)
label var size "家庭规模"

recode hukou (1=1)(0=0) ,gen(rural)
label var rural"户口性质 1=农业户口 0=非农户口"

gen old1=1 if age_>=65
bys fid20: egen old=sum(old1)
label var old "老龄人口量"

gen job=0
replace job=1 if employ==1
label var job "当前工作状态"

gen wage=emp_income
label var wage "当前十二个月所有工作的收入"

gen dw=qn8012
label var dw"社会地位"

//缺失值替换为.
for var _all: replace X =. if inlist(X, -10, -9, -8, -2, -1) 

//1.年龄
sum age

//2.年龄平方
gen age2=age^2/100
label var  age2 "年龄平方"

//3.性别
label var gender "性别"


//5.教育
rename cfps2020eduy_im eduy //受教育年限
label var eduy "受教育年限"

//6.婚姻
sum qea0
label list qea0
recode qea0 (2 3 = 1 "是")(1 4 5= 0 "否"), gen(marrige)
label var marrige "婚姻状况"

//7.党员
gen communist=qn4001 
label var communist "是共产党员"

//8.民族
sum  qa701code
label list  qa701code
for var qa701code : replace X =. if inlist(X,79)
recode  qa701code (1=1 "汉族")(2/56=0 "其他"),gen(minzu)
label var minzu "民族"


//11.互联网使用
rename qu201 mobile //移动上网
rename qu202 computer //电脑上网
egen internet =rowmax( mobile computer)
label variable internet "互联网使用"


//13.工作地点
recode qg301 (1 2 3 4=1 "本县/市") (5 6 7=0 "非本县/市"),gen(workplace)
label variable workplace "工作地点"

//14.工作类型
sum jobclass

//15.工作性质
sum qg101
label list qg101
recode qg101(1=0 "农业工作")(5=1 "非农工作"),gen(worknature)
label var worknature "工作性质"

//16.行业
rename qg302code industry
label var  industry "行业"

//17.是否网购
recode qu92 (1 = 1 "是")(0 = 0 "否")(-10 -9 -8 -2 -1 79 =.), gen(onlineshopoping)
label variable onlineshopoping "是否网购"

//18.编制
rename qg2032 bianzhi
label variable bianzhi "编制"

//19.工作时长（小时/周）
rename qg6 workhour
label variable workhour "每周工作时长"

//20.工资收入（元/月）
rename qg11 gongzi
label variable gongzi "每月税后工资"

label variable qg401 "工作收入满意度"

label variable qg402 "工作安全满意度"

label variable qg403 "工作环境满意度"

label variable qg404 "工作时间满意度"

label variable qg405 "工作晋升满意度"

label variable qg406 "工作满意度"

label variable qn1101 "对本县市政府评价"

label variable qn10021 "对父母信任程度"

label variable qn10022 "对邻居信任程度"

label variable qn10023 "对美国人信任程度"

label variable qn10024 "对陌生人信任程度"

label variable qn10025 "对本地政府官员信任程度"

label variable qn10026 "对医生信任程度"

label variable qn12012 "对自己生活满意度"

label variable qn12016 "对自己未来信心程度"

label variable qp401 "半年内是否有慢性疾病"

label variable qq201 "过去一个月吸烟吗"

label variable qq4010 "睡眠时长（小时/天）"


order  pid fid20 fid18 fid16 fid14 fid12 fid10 provcd countyid cid urban ibirthy age age2 gender edu educ eduy marrige communist minzu medsure_dum health internet hukou workplace jobclass worknature industry bianzhi workhour gongzi medsure_dum  res mar age_ gen unhealth weak health size rural old job wage dw qg401 qg402 qg403 qg404 qg405 qg406 qn1101 qn10021 qn10022 qn10023 qn10024 qn10025 qn10026 qn12012 qn12016 qp401 qq201 qq4010 mobile computer onlineshopoping 

keep  pid fid20 fid18 fid16 fid14 fid12 fid10 provcd countyid cid urban ibirthy age age2 gender edu educ eduy marrige communist minzu medsure_dum health internet hukou workplace jobclass worknature industry bianzhi workhour gongzi medsure_dum  res mar age_ gen unhealth weak health size rural old job wage dw qg401 qg402 qg403 qg404 qg405 qg406 qn1101 qn10021 qn10022 qn10023 qn10024 qn10025 qn10026 qn12012 qn12016 qp401 qq201 qq4010 mobile computer onlineshopoping 

save "D:\stata\CFPS原数据\2020\2020adult.dta "

****2018****
//打开数据
use "D:\stata\CFPS原数据\2018\cfps2018person_202012.dta", clear

keep pid fid18  age gender cfps2018edu cfps2018eduy_im qea0  qn4001  qa701code   qp605_s_* qp201 qu201  qu202 qa301  qg301 jobclass qg101 qg302code  qg2032 qg6 qg11 fid16 fid14 fid12 fid10 provcd18 countyid18 cid18 urban18 ibirthy gender_update party qa002 w01 qea0 qn8012 qu201 qp201 qp605_s_1 qp605_s_2 qp605_s_3 qp605_s_4 qp605_s_5 qn4001 pd5total qm2016 qg12 incomea  incomeb income qg1203 qg1203 employ qga2 party qn4001 qn402  qn6012 qu705  qn1001 qn10021 qn10022 qn10023 qn10024 qn10025 qn10026 qn12012 qn12016 qp401  qq201 qq4010 qn1101 qg401 qg402 qg403 qg404 qg405 qg406

rename provcd18 provcd
rename countyid18 countyid
rename cid18 cid
rename urban18 urban


label list

for var _all: replace X =. if inlist(X, -10, -9, -8, -2, -1)

tab qa301

tab qea0

recode qa301 (1 = 1 "农业户口")(3 = 0 "非农户口")(5 79 =.), gen(hukou)

recode qea0  (2 3 = 1 "有配偶")(1 4 5 = 0 "无配偶"), gen(spouse)

recode cfps2018edu (1 = 0 )(2 = 6) (3 = 9 ) (4 = 12 ) (5 = 15)(6 = 16 )  (7 = 19 ) (8 = 22),gen(educ)

label var educ"受教育年限 受教育程度 0=文盲/半文盲 6=小学 9=初中 12=高中/中专/技校/职高 15=大专 16=大学本科 19=硕士 22=博士"

des qp605_s_*
for var qp605_s_*:replace X=. if X==78

gen medsure_dum = 0

for var qp605_s_*: replace medsure_dum = 1 if X !=.

label var medsure_dum"是否购买医保"

recode hukou (0 = 0 )(1 = 1), gen (res)
label var res"户口性质 1=农业户口 0=非农户口"

recode qea0  (2 3 = 1)(1 4 5 = 0 ), gen(mar)
label var mar"婚姻状况 1=有配偶 0= 无配偶"

gen age_=age
label var age_"户主年龄"

recode gender  (1 = 1 )(0 = 0 ), gen(gen)
label var gen"性别 1=男 0=女"

recode qu201 (1 = 1 )( 0 = 0 ), gen(inter)
label var inter"是否上网 1=是 0=否"


recode qp201 (1 2 3 4 = 0 )(5 = 1) ,gen(unhealth)

bysort fid18: egen weak = sum (unhealth)
label var weak "家庭不健康人数" 

recode qp201 (1=5 )(2 = 4)(3=3)(4=2)(5=1) ,gen(health)
label var health"赋值1-5 数值越大，越健康"

gen size1=1
bysort fid18: egen size = sum (size1)
label var size "家庭规模"

recode hukou (1=1)(0=0) ,gen(rural)
label var rural"户口性质 1=农业户口 0=非农户口"

gen old1=1 if age_>=65
bys fid18: egen old=sum(old1)
label var old "老龄人口量"

gen job=0
replace job=1 if employ==1
label var job "当前工作状态"

gen wage=income
label var wage "当前十二个月所有工作的收入"

gen dw=qn8012
label var dw"社会地位"

label variable qg401 "工作收入满意度"

label variable qg402 "工作安全满意度"

label variable qg403 "工作环境满意度"

label variable qg404 "工作时间满意度"

label variable qg405 "工作晋升满意度"

label variable qg406 "工作满意度"

label variable qn1101 "对本县市政府评价"

label variable qn10021 "对父母信任程度"

label variable qn10022 "对邻居信任程度"

label variable qn10023 "对美国人信任程度"

label variable qn10024 "对陌生人信任程度"

label variable qn10025 "对本地政府官员信任程度"

label variable qn10026 "对医生信任程度"

label variable qn12012 "对自己生活满意度"

label variable qn12016 "对自己未来信心程度"

label variable qp401 "半年内是否有慢性疾病"

label variable qq201 "过去一个月吸烟吗"

label variable qq4010 "睡眠时长（小时/天）"


//缺失值替换为.
for var _all: replace X =. if inlist(X, -10, -9, -8, -2, -1) 

//1.年龄
sum age

//2.年龄平方
gen age2=age^2/100
label var  age2 "年龄平方"

//3.性别
label var gender "性别"

//4.学历
rename cfps2018edu edu
label var edu "学历"

//5.教育
rename cfps2018eduy_im eduy //受教育年限
label var eduy "受教育年限"

//6.婚姻
sum qea0
label list qea0
recode qea0 (2 3 = 1 "是")(1 4 5= 0 "否"), gen(marrige)
label var marrige "婚姻状况"

//7.党员
gen communist=qn4001 
label var communist "是共产党员"

//8.民族
sum  qa701code
label list  qa701code
for var qa701code : replace X =. if inlist(X,79)
recode  qa701code (1=1 "汉族")(2/56=0 "其他"),gen(minzu)
label var minzu "民族"


//11.互联网使用
rename qu201 mobile //移动上网
rename qu202 computer //电脑上网
egen internet =rowmax( mobile computer)
label variable internet "互联网使用"


//13.工作地点
recode qg301 (1 2 3 4=1 "本县/市") (5 6 7=0 "非本县/市"),gen(workplace)
label variable workplace "工作地点"

//14.工作类型
sum jobclass

//15.工作性质
sum qg101
label list qg101
recode qg101(1=0 "农业工作")(5=1 "非农工作"),gen(worknature)
label var worknature "工作性质"

//16.行业
rename qg302code industry
label var  industry "行业"

//17.是否网购
recode qu705 (1 2 3 4 5 6= 1 "是")(7 = 0 "否")(-10 -9 -8 -2 -1 =.), gen(onlineshopoping)
label variable onlineshopoping "是否网购"

//18.编制
rename qg2032 bianzhi
label variable bianzhi "编制"

//19.工作时长（小时/周）
rename qg6 workhour
label variable workhour "每周工作时长"

//20.工资收入（元/月）
rename qg11 gongzi
label variable gongzi "每月税后工资"

order  pid  fid18 fid16 fid14 fid12 fid10 provcd countyid cid urban ibirthy age age2 gender edu educ eduy marrige communist minzu medsure_dum health internet hukou workplace jobclass worknature industry bianzhi workhour gongzi medsure_dum  res mar age_ gen unhealth weak health size rural old job wage dw qg401 qg402 qg403 qg404 qg405 qg406 qn1101 qn10021 qn10022 qn10023 qn10024 qn10025 qn10026 qn12012 qn12016 qp401 qq201 qq4010 mobile computer onlineshopoping 

keep  pid  fid18 fid16 fid14 fid12 fid10 provcd countyid cid urban ibirthy age age2 gender edu educ eduy marrige communist minzu medsure_dum health internet hukou workplace jobclass worknature industry bianzhi workhour gongzi medsure_dum  res mar age_ gen unhealth weak health size rural old job wage dw qg401 qg402 qg403 qg404 qg405 qg406 qn1101 qn10021 qn10022 qn10023 qn10024 qn10025 qn10026 qn12012 qn12016 qp401 qq201 qq4010 mobile computer onlineshopoping 

save "D:\stata\CFPS原数据\2018\2018adult.dta"

****2016年****
use "D:\stata\CFPS原数据\2016\cfps2016adult_201906.dta", clear

keep pid fid16  cfps_age cfps_gender  cfps2016edu cfps2016eduy_im qea0  qn4001  pa701code   qp605_s_* qp201 ku201  ku202 pa301  qg301 jobclass qg101 qg302code  qg2032 qg6 qg11 fid14 fid12 fid10 provcd16 countyid16 cid16 urban16 cfps_birthy  qn4001 qea0 qn8012 qp201 qp605_s_1 qp605_s_2 qp605_s_3 qp605_s_4  qn4001 pd5total qm2014 qg12 incomea  incomeb income qg1203 qg1203 employ qga2  qn402  qn6012 ku705  pn1001 qn10021 qn10022 qn10023 qn10024 qn10025 qn10026 qn12012 qn12014 qp401  qq201 qq4010 qn1101 qg401 qg402 qg403 qg404 qg405 qg406 


rename provcd16 provcd
rename countyid16 countyid
rename cid16 cid
rename urban16 urban


label list

for var _all: replace X =. if inlist(X, -10, -9, -8, -2, -1)

tab pa301

tab qea0

recode pa301 (1 = 1 "农业户口")(3 = 0 "非农户口")(5 79 =.), gen(hukou)

recode qea0  (2 3 = 1 "有配偶")(1 4 5 = 0 "无配偶"), gen(spouse)

recode cfps2016edu (1 = 0 "文盲/半文盲")(2 = 1 "小学")       (3 = 2 "初中") (4 = 3 "高中")       (5 = 4 "大专")(6 = 5 "大学本科")  (7 = 6 "硕士") (8 = 7 "博士"),gen(edu)

label var edu"受教育程度 0=文盲/半文盲 1=小学 2=初中 4=高中/中专/技校/职高 5=大专 6=大学本科 7=硕士 8=博士"

recode cfps2016edu (1 = 0 )(2 = 6) (3 = 9 ) (4 = 12 ) (5 = 15)(6 = 16 )  (7 = 19 ) (8 = 22),gen(educ)

label var educ"受教育年限 受教育程度 0=文盲/半文盲 6=小学 9=初中 12=高中/中专/技校/职高 15=大专 16=大学本科 19=硕士 22=博士"

des qp605_s_*
for var qp605_s_*:replace X=. if X==78

gen medsure_dum = 0

for var qp605_s_*: replace medsure_dum = 1 if X !=.

label var medsure_dum"是否购买医保"

recode hukou (0 = 0 )(1 = 1), gen (res)
label var res"户口性质 1=农业户口 0=非农户口"

recode qea0  (2 3 = 1)(1 4 5 = 0 ), gen(mar)

label var mar"婚姻状况 1=有配偶 0= 无配偶"

gen age_=cfps_age
label var age_"户主年龄"

recode cfps_gender  (1 = 1 )(0 = 0 ), gen(gen)
label var gen"性别 1=男 0=女"

recode qp201 (1=5 )(2 = 4)(3=3)(4=2)(5=1) ,gen(health)
label var health"赋值1-5 数值越大，越健康"


recode qp201 (1 2 3 4 = 0 )(5 = 1) ,gen(unhealth)

bysort fid16: egen weak = sum (unhealth)
label var weak "家庭不健康人数" 

gen size1=1
bysort fid16: egen size = sum (size1)
label var size "家庭规模"

recode hukou (1=1)(0=0) ,gen(rural)
label var rural"户口性质 1=农业户口 0=非农户口"

gen old1=1 if age_>=65
bys fid16: egen old=sum(old1)
label var old "老龄人口量"

gen job=0
replace job=1 if employ==1
label var job "当前工作状态"

gen wage=income
label var wage "当前十二个月所有工作的收入"

gen dw=qn8012
label var dw"社会地位"

label variable qg401 "工作收入满意度"

label variable qg402 "工作安全满意度"

label variable qg403 "工作环境满意度"

label variable qg404 "工作时间满意度"

label variable qg405 "工作晋升满意度"

label variable qg406 "工作满意度"

label variable qn1101 "对本县市政府评价"

label variable qn10021 "对父母信任程度"

label variable qn10022 "对邻居信任程度"

label variable qn10023 "对美国人信任程度"

label variable qn10024 "对陌生人信任程度"

label variable qn10025 "对本地政府官员信任程度"

label variable qn10026 "对医生信任程度"

label variable qn12012 "对自己生活满意度"

label variable qn12014 "对自己未来信心程度"

label variable qp401 "半年内是否有慢性疾病"

label variable qq201 "过去一个月吸烟吗"

label variable qq4010 "睡眠时长（小时/天）"


//缺失值替换为.
for var _all: replace X =. if inlist(X, -10, -9, -8, -2, -1) 

//1.年龄
rename (cfps_age cfps_gender) (age gender)
sum age

//2.年龄平方
gen age2=age^2/100
label var  age2 "年龄平方"

//3.性别
label var gender "性别"


//5.教育
rename cfps2016eduy_im eduy //受教育年限
label var eduy "受教育年限"

//6.婚姻
sum qea0
label list qea0
recode qea0 (2 3 = 1 "是")(1 4 5= 0 "否"), gen(marrige)
label var marrige "婚姻状况"

//7.党员
gen communist=qn4001 
label var communist "是共产党员"

//8.民族
sum  pa701code
label list  pa701code
for var pa701code : replace X =. if inlist(X,79)
recode  pa701code (1=1 "汉族")(2/56=0 "其他"),gen(minzu)
label var minzu "民族"


//11.互联网使用
rename ku201 mobile //移动上网
rename ku202 computer //电脑上网
egen internet =rowmax( mobile computer)
label variable internet "互联网使用"

//13.工作地点
recode qg301 (1 2 3 4=1 "本县/市") (5 6 7=0 "非本县/市"),gen(workplace)
label variable workplace "工作地点"

//14.工作类型
sum jobclass

//15.工作性质
sum qg101
label list qg101
recode qg101(1=0 "农业工作")(5=1 "非农工作"),gen(worknature)
label var worknature "工作性质"

//16.行业
rename qg302code industry
label var  industry "行业"

//17.网购频率
recode ku705 (1 2 3 4 5 6= 1 "是")(7 = 0 "否")(-10 -9 -8 -2 -1 =.), gen(onlineshopoping)
label variable onlineshopoping "是否网购"

//18.编制
rename qg2032 bianzhi
label variable bianzhi "编制"

//19.工作时长（小时/周）
rename qg6 workhour
label variable workhour "每周工作时长"

//20.工资收入（元/月）
rename qg11 gongzi
label variable gongzi "每月税后工资"

rename cfps_birthy ibirthy
rename qn12014 qn12016


order  pid fid16 fid14 fid12 fid10 provcd countyid cid urban ibirthy age age2 gender edu educ eduy marrige communist minzu medsure_dum health internet hukou workplace jobclass worknature industry bianzhi workhour gongzi medsure_dum  res mar age_ gen unhealth weak health size rural old job wage dw qg401 qg402 qg403 qg404 qg405 qg406 qn1101 qn10021 qn10022 qn10023 qn10024 qn10025 qn10026 qn12012 qn12016 qp401 qq201 qq4010 mobile computer onlineshopoping 

keep  pid fid16 fid14 fid12 fid10 provcd countyid cid urban ibirthy age age2 gender edu educ eduy marrige communist minzu medsure_dum health internet hukou workplace jobclass worknature industry bianzhi workhour gongzi medsure_dum  res mar age_ gen unhealth weak health size rural old job wage dw qg401 qg402 qg403 qg404 qg405 qg406 qn1101 qn10021 qn10022 qn10023 qn10024 qn10025 qn10026 qn12012 qn12016 qp401 qq201 qq4010 mobile computer onlineshopoping 
save "D:\stata\CFPS原数据\2016\2016adult.dta"

****2014年****
use "D:\stata\CFPS原数据\2014\cfps2014adult_201906.dta",clear

keep pid fid14 cfps2014_age   cfps_gender  cfps2014edu cfps2014eduy_im qea0  pn401a  qa701code   qp605_s_* qp201 ku2 qa301  qg301 jobclass qg101 qg302code  qg6 qg11 fid12 fid10 provcd14 countyid14 cid14 urban14 cfps_birthy  cfps_party qea0 qn8012 qp201 qp605_s_1 qp605_s_2 qp605_s_3 qp605_s_4   ks9total qm2012 qg12 incomea  incomeb income qg1203 qg1203 employ qga2  qn402  qn6012 ku705  qn1001 qn10021 qn10022 qn10023 qn10024 qn10025 qn10026 qn12012 qn12014 qp401  qq201 qq4010 qn1101 qg4 

rename provcd14 provcd 
rename countyid14 countyid
rename cid14 cid
rename urban14 urban

label list

for var _all: replace X =. if inlist(X, -10, -9, -8, -2, -1)

tab qa301

tab qea0

recode qa301 (1 7= 1 "农业户口")(3 = 0 "非农户口")(5  79 =.), gen(hukou)

recode qea0  (2 3 = 1 "有配偶")(1 4 5 = 0 "无配偶"), gen(spouse)

recode cfps2014edu (1 = 0 "文盲/半文盲")(2 = 1 "小学")       (3 = 2 "初中") (4 = 3 "高中")       (5 = 4 "大专")(6 = 5 "大学本科")  (7 = 6 "硕士") (8 = 7 "博士") (79=.),gen(edu)

label var edu"受教育程度 0=文盲/半文盲 1=小学 2=初中 4=高中/中专/技校/职高 5=大专 6=大学本科 7=硕士 8=博士"

recode cfps2014edu (1 = 0 )(2 = 6) (3 = 9 ) (4 = 12 ) (5 = 15)(6 = 16 )  (7 = 19 ) (8 = 22) ( 9 = .),gen(educ)

label var educ"受教育年限 受教育程度 0=文盲/半文盲 6=小学 9=初中 12=高中/中专/技校/职高 15=大专 16=大学本科 19=硕士 22=博士"

des qp605_s_*
for var qp605_s_*:replace X=. if X==78

gen medsure_dum = 0

for var qp605_s_*: replace medsure_dum = 1 if X !=.

label var medsure_dum"是否购买医保"

recode hukou (0 = 0 )(1 = 1), gen (res)

label var res"户口性质 1=农业户口 0=非农户口"

recode qea0  (2 3 = 1)(1 4 5 = 0 ), gen(mar)

label var mar"婚姻状况 1=有配偶 0= 无配偶"

gen age_=cfps2014_age
label var age_"户主年龄"

recode cfps_gender  (1 = 1 )(0 = 0 ), gen(gen)
label var gen"性别 1=男 0=女"

recode qp201 (1 2 3 4 = 0 )(5 = 1) ,gen(unhealth)

bysort fid14: egen weak = sum (unhealth)
label var weak "家庭不健康人数" 

recode qp201 (1=5 )(2 = 4)(3=3)(4=2)(5=1) ,gen(health)
label var health"赋值1-5 数值越大，越健康"

gen size1=1
bysort fid14: egen size = sum (size1)
label var size "家庭规模"

recode hukou (1=1)(0=0) ,gen(rural)
label var rural"户口性质 1=农业户口 0=非农户口"

gen old1=1 if age_>=65
bys fid14: egen old=sum(old1)
label var old "老龄人口量"

gen job=0
replace job=1 if employ==1
label var job "当前工作状态"

gen wage=income
label var wage "当前十二个月所有工作的收入"

gen dw=qn8012
label var dw"社会地位"


label variable qg4 "工作满意度"

label variable qn1101 "对本县市政府评价"

label variable qn10021 "对父母信任程度"

label variable qn10022 "对邻居信任程度"

label variable qn10023 "对美国人信任程度"

label variable qn10024 "对陌生人信任程度"

label variable qn10025 "对本地政府官员信任程度"

label variable qn10026 "对医生信任程度"

label variable qn12012 "对自己生活满意度"

label variable qn12014 "对自己未来信心程度"

label variable qp401 "半年内是否有慢性疾病"

label variable qq201 "过去一个月吸烟吗"

label variable qq4010 "睡眠时长（小时/天）"


//缺失值替换为.
for var _all: replace X =. if inlist(X, -10, -9, -8, -2, -1) 

//1.年龄
rename (cfps2014_age cfps_gender) (age gender)
sum age

//2.年龄平方
gen age2=age^2/100
label var  age2 "年龄平方"

//3.性别
label var gender "性别"


//5.教育
rename cfps2014eduy_im eduy //受教育年限
label var eduy "受教育年限"

//6.婚姻
sum qea0
label list qea0
recode qea0 (2 3 = 1 "是")(1 4 5= 0 "否"), gen(marrige)
label var marrige "婚姻状况"

//7.党员
gen communist=pn401a 
label var communist "是共产党员"

//8.民族
for var qa701code : replace X =. if inlist(X,79)
recode  qa701code (1=1 "汉族")(2/56=0 "其他"),gen(minzu)
label var minzu "民族"


//11.互联网使用
rename ku2 internet 
label variable internet "互联网使用"

//13.工作地点
recode qg301 (1 2 3 4=1 "本县/市") (5 6 7=0 "非本县/市"),gen(workplace)
label variable workplace "工作地点"

//14.工作类型
sum jobclass

//15.工作性质
sum qg101
label list qg101
recode qg101(1=0 "农业工作")(5=1 "非农工作"),gen(worknature)
label var worknature "工作性质"

//16.行业
rename qg302code industry
label var  industry "行业"

//17.网购频率
recode ku705 (1 2 3 4 5 6= 1 "是")(7 = 0 "否")(-10 -9 -8 -2 -1 =.), gen(onlineshopoping)
label variable onlineshopoping "是否网购"

//18.编制

//19.工作时长（小时/周）
rename qg6 workhour
label variable workhour "每周工作时长"

//20.工资收入（元/月）
rename qg11 gongzi
label variable gongzi "每月税后工资"

rename cfps_birthy ibirthy 
rename qg4 qg406
rename qn12014 qn12016


order  pid  fid14 fid12 fid10 provcd countyid cid urban ibirthy age age2 gender edu educ eduy marrige communist minzu medsure_dum health internet hukou workplace jobclass worknature industry  workhour gongzi medsure_dum  res mar age_ gen unhealth weak health size rural old job wage dw qg406 qn1101 qn10021 qn10022 qn10023 qn10024 qn10025 qn10026 qn12012 qn12016 qp401 qq201 qq4010 onlineshopoping 

keep  pid  fid14 fid12 fid10 provcd countyid cid urban ibirthy age age2 gender edu educ eduy marrige communist minzu medsure_dum health internet hukou workplace jobclass worknature industry  workhour gongzi medsure_dum  res mar age_ gen unhealth weak health size rural old job wage dw qg406 qn1101 qn10021 qn10022 qn10023 qn10024 qn10025 qn10026 qn12012 qn12016 qp401 qq201 qq4010 onlineshopoping 

save "D:\stata\CFPS原数据\2014\2014adult.dta"

****2012年****
use "D:\stata\CFPS原数据\2012\cfps2012adult_201906.dta",clear

keep pid fid12 cfps2012_age  cfps2012_gender_best edu2012 eduy2012  qe104 sn401 qa701code   qp605_s_* qp201   qa301   qg408_a_1 sg4101 qg401  qg410code_a_1  qg414_a_2 fid10 provcd countyid cid urban12 cfps_party cfps2012_birthy cfps2012_age cfps2012_gender qa301 qe104 qi5011 qi5012 qi5013 qi5014 qi5015 qi5016 qi5017 qi502 cfps2012_gender_best cfps2012_birthy_best sch2012 edu2012 eduy2012 urbancomm qp201 qg401 qg501 qc301 cfps_party qn402 sn401 ks9total_m qn12012 qn12014 qp605_s_* qn402 sn401 income qg101 qn6012 qn8012 qn1001 qn10021 qn10022 qn10023 qn10024 qn10025 qn10026 qq201  qn1101 qp401

rename urban12 urban

label list

for var _all: replace X =. if inlist(X, -10, -9, -8, -2, -1,79)

tab qa301

tab qe104

recode qa301 (1 = 1 "农业户口")(3 = 0 "非农户口")(5 79 =.), gen(hukou)

recode qe104  (2 3 = 1 "有配偶")(1 4 5 = 0 "无配偶"), gen(spouse)

recode edu2012 (1 = 0 "文盲/半文盲")(2 = 1 "小学")       (3 = 2 "初中") (4 = 3 "高中")       (5 = 4 "大专")(6 = 5 "大学本科")  (7 = 6 "硕士") (8 = 7 "博士") (9=.),gen(edu)

label var edu"受教育程度 0=文盲/半文盲 1=小学 2=初中 4=高中/中专/技校/职高 5=大专 6=大学本科 7=硕士 8=博士"

recode edu2012 (1 = 0 )(2 = 6) (3 = 9 ) (4 = 12 ) (5 = 15)(6 = 16 )  (7 = 19 ) (8 = 22) ( 9 = .),gen(educ)

label var educ"受教育年限 受教育程度 0=文盲/半文盲 6=小学 9=初中 12=高中/中专/技校/职高 15=大专 16=大学本科 19=硕士 22=博士"

recode hukou (0 = 0 )(1 = 1), gen (res)
label var res"户口性质 1=农业户口 0=非农户口"

recode qe104  (2 3 = 1)(1 4 5 = 0 ), gen(mar)
label var mar"婚姻状况 1=有配偶 0= 无配偶"

gen age_=cfps2012_age
label var age_"户主年龄"

gen date=cfps2012_birthy_best

recode cfps2012_gender_best   (1 = 1 )(0 = 0 ), gen(gen)
label var gen"性别 1=男 0=女"

recode qp201 (1 2 3 4 = 0 )(5 = 1) ,gen(unhealth)

bysort fid12: egen weak = sum (unhealth)
label var weak "家庭不健康人数" 

recode qp201 (1=5 )(2 = 4)(3=3)(4=2)(5=1) ,gen(health)
label var health"赋值1-5 数值越大，越健康"

gen size1=1
bysort fid12: egen size = sum (size1)
label var size "家庭规模"

recode hukou (1=1)(0=0) ,gen(rural)
label var rural"户口性质 1=农业户口 0=非农户口"

gen old1=1 if age_>=65
bys fid12: egen old=sum(old1)
label var old "老龄人口量"

gen 教育支出1=ks9total_m

des qp605_s_*
for var qp605_s_*:replace X=. if X==78

gen medsure_dum = 0

for var qp605_s_*: replace medsure_dum = 1 if X !=.

label var medsure_dum"是否购买医保"

gen dw=qn8012
label var dw"社会地位"

gen job=0
replace job=1 if qg101==1
label var job "当前工作状态"

gen wage=income
label var wage "当前十二个月所有工作的收入"

label variable qn1101 "对本县市政府评价"

label variable qn10021 "对父母信任程度"

label variable qn10022 "对邻居信任程度"

label variable qn10023 "对美国人信任程度"

label variable qn10024 "对陌生人信任程度"

label variable qn10025 "对本地政府官员信任程度"

label variable qn10026 "对医生信任程度"

label variable qn12012 "对自己生活满意度"

label variable qn12014 "对自己未来信心程度"

label variable qp401 "半年内是否有慢性疾病"

label variable qq201 "过去一个月吸烟吗"


//缺失值替换为.
for var _all: replace X =. if inlist(X, -10, -9, -8, -2, -1) 

//1.年龄
rename ( cfps2012_age  cfps2012_gender_best) (age gender)
sum age

//2.年龄平方
gen age2=age^2/100
label var  age2 "年龄平方"

//3.性别
label var gender "性别"

//5.教育
rename eduy2012  eduy //受教育年限
label var eduy "受教育年限"

//6.婚姻
recode  qe104 (2 3 = 1 "是")(1 4 5= 0 "否"), gen(marrige)
label var marrige "婚姻状况"

//7.党员
gen communist=sn401 
label var communist "是共产党员"

//8.民族
for var qa701code : replace X =. if inlist(X,79)
recode  qa701code (1=1 "汉族")(2/56=0 "其他"),gen(minzu)
label var minzu "民族"

//11.互联网使用

//13.工作地点
recode  qg408_a_1 (1 2 3 =1 "本县/市") (4 5 6 7=0 "非本县/市"),gen(workplace)
label variable workplace "工作地点"

//14.工作类型
rename sg4101 jobclass
label variable jobclass "工作类型"

//15.工作性质
sum qg401
label list qg401
recode qg401 (1=0 "农业工作")(5=1 "非农工作"),gen(worknature)
label var worknature "工作性质"

//16.行业
rename qg410code_a_1 industry
label var  industry "行业"

//17.网购频率

//18.编制

//19.工作时长（小时/周）

//20.工资收入（元/月）
rename cfps2012_birthy ibirthy
rename qn12014 qn12016

order  pid fid12 fid10 provcd countyid cid urban ibirthy age age2 gender edu educ eduy marrige communist minzu medsure_dum health hukou workplace jobclass worknature industry   medsure_dum  res mar age_ gen unhealth weak health size rural old job wage dw qn1101 qn10021 qn10022 qn10023 qn10024 qn10025 qn10026 qn12012 qn12016 qp401 qq201 

keep  pid fid12 fid10 provcd countyid cid urban ibirthy age age2 gender edu educ eduy marrige communist minzu medsure_dum health hukou workplace jobclass worknature industry   medsure_dum  res mar age_ gen unhealth weak health size rural old job wage dw qn1101 qn10021 qn10022 qn10023 qn10024 qn10025 qn10026 qn12012 qn12016 qp401 qq201 

save "D:\stata\CFPS原数据\2012\2012adult.dta"

****2010年****
use "D:\stata\CFPS原数据\2010\cfps2010adult_202008.dta",clear

keep pid fid qa1age gender cfps2010edu_best cfps2010eduy_best qe1  qa7_s_*  qa5code  qj3_s_*  qp3 ku2 qa2   qg4 qg308code qg403 qk101 provcd countyid cid urban gender qa1y qa1y_best qa1age qc1 qe1 qe1_best ku2 cfps2010edu_best cfps2010eduy_best cfps2010sch_best qj3_s_* qa2 qp3 ks90total qk802 qa701 qg3 income qn301_a_9 qm402 qq2 qm404 qg501 qg502 qg503 qg504 qg505 qg506 qn4 qm403 qp5 qq2


label list

for var _all: replace X =. if inlist(X, -10, -9, -8, -2, -1)

tab qa2

tab qe1_best

recode qa2 (1 = 1 "农业户口")(3 = 0 "非农户口")(5 79 =.), gen(hukou)

recode qe1_best  (2 3 = 1 "有配偶")(1 4 5 = 0 "无配偶"), gen(spouse)

recode cfps2010edu_best (1 = 0 "文盲/半文盲")(2 = 1 "小学")       (3 = 2 "初中") (4 = 3 "高中")       (5 = 4 "大专")(6 = 5 "大学本科")  (7 = 6 "硕士") (8 = 7 "博士") (9=.),gen(edu)

label var edu"受教育程度 0=文盲/半文盲 1=小学 2=初中 4=高中/中专/技校/职高 5=大专 6=大学本科 7=硕士 8=博士"

recode cfps2010edu_best (1 = 0 )(2 = 6) (3 = 9 ) (4 = 12 ) (5 = 15)(6 = 16 )  (7 = 19 ) (8 = 22) ( 9 = .),gen(educ)

label var educ"受教育年限 受教育程度 0=文盲/半文盲 6=小学 9=初中 12=高中/中专/技校/职高 15=大专 16=大学本科 19=硕士 22=博士"

des qj3_s_*
for var qj3_s_*:replace X=. if X==78
label list qj3_s_1

gen medsure_dum = 0

for var qj3_s_*: replace medsure_dum = 1 if X ==1 | X == 2 | X ==3 | X 

label var medsure_dum"是否购买医保"

recode hukou (0 = 0 )(1 = 1), gen (res)

label var res"户口性质 1=农业户口 0=非农户口"

recode qe1_best (2 3 = 1)(1 4 5 = 0 ), gen(mar)

label var mar"婚姻状况 1=有配偶 0= 无配偶"

gen age_=qa1age
label var age_"户主年龄"

gen date=qa1y_best

recode gender  (1 = 1 )(0 5 = 0 ), gen(gen)

label var gen"性别 1=男 0=女"

recode ku2 (1 = 1 )( 0 5 = 0 ), gen(inter)
label var inter"是否上网 1=是 0=否"

label list qp3

recode qp3 (1 2 = 0 )(3 4 5 = 1) ,gen(unhealth)

bysort fid: egen weak = sum (unhealth)
label var weak "家庭不健康人数" 

recode qp3 (1=5 )(2 = 4)(3=3)(4=2)(5=1) ,gen(health)
label var health"赋值1-5 数值越大，越健康"

gen size1=1
bysort fid: egen size = sum (size1)
label var size "家庭规模"

recode hukou (1=1)(0=0) ,gen(rural)
label var rural"户口性质 1=农业户口 0=非农户口"

gen old1=1 if age_>=65
bys fid: egen old=sum(old1)
label var old "老龄人口量"

gen job=0
replace job=1 if qg3==1
label var job "当前工作状态"

gen wage=income
label var wage "当前十二个月所有工作的收入"

gen dw=qm402
label var dw"社会地位"

ren fid fid10

label variable qg501 "工作收入满意度"

label variable qg502 "工作安全满意度"

label variable qg503 "工作环境满意度"

label variable qg504 "工作时间满意度"

label variable qg505 "工作晋升满意度"

label variable qg506 "工作满意度"

label variable qn4 "对本县市政府评价"

label variable qm403"对自己生活满意度"

label variable qm404 "对自己未来信心程度"

label variable qp5 "半年内是否有慢性疾病"

label variable qq2 "过去一个月吸烟吗"

//缺失值替换为.
for var _all: replace X =. if inlist(X, -10, -9, -8, -2, -1) 

//1.年龄
rename (qa1age gender) (age gender)
sum age

//2.年龄平方
gen age2=age^2/100
label var  age2 "年龄平方"

//3.性别
label var gender "性别"

//5.教育
rename  cfps2010eduy_best eduy //受教育年限
label var eduy "受教育年限"

//6.婚姻
recode qe1  (2 3 = 1 "是")(1 4 5= 0 "否"), gen(marrige)
label var marrige "婚姻状况"

//7.党员
gen  communist = 0
for var qa7_s_* : replace communist = 1 if X ==1
label var communist "是共产党员"

//8.民族
for var  qa5code  : replace X =. if inlist(X,79)
recode   qa5code  (1=1 "汉族")(2/56=0 "其他"),gen(minzu)
label var minzu "民族"


//11.互联网使用
rename ku2 internet 
label variable internet "互联网使用"


//13.工作地点


//14.工作类型
 

//15.工作性质
recode qg4(1=0 "农业工作")(5=1 "非农工作"),gen(worknature)
label var worknature "工作性质"

//16.行业
rename qg308code industry
label var  industry "行业"

//17.网购频率
 
//18.编制

//19.工作时长（小时/周）
rename qg403 qg6
gen qg6_=qg6*7
rename qg6_ workhour
label variable workhour "每周工作时长"

//20.工资收入（元/月）
rename qk101 gongzi
label variable gongzi "每月税后工资"

rename qa1y ibirthy
rename qg501 qg401
rename qg502 qg402
rename qg503 qg403
rename qg504 qg404
rename qg505 qg405
rename qg506 qg406
rename qn4  qn1101
rename qm403 qn12012
rename qm404 qn12016
rename qp5 qp401
rename qq2 qq201


order pid  fid10 provcd countyid cid urban ibirthy age age2 gender edu educ eduy marrige communist minzu medsure_dum health internet hukou  worknature industry  workhour gongzi medsure_dum  res mar age_ gen unhealth weak health size rural old job wage dw qg401 qg402 qg403 qg404 qg405 qg406 qn1101  qn12012 qn12016 qp401 qq201

keep pid  fid10 provcd countyid cid urban ibirthy age age2 gender edu educ eduy marrige communist minzu medsure_dum health internet hukou  worknature industry  workhour gongzi medsure_dum  res mar age_ gen unhealth weak health size rural old job wage dw qg401 qg402 qg403 qg404 qg405 qg406 qn1101  qn12012 qn12016 qp401 qq201

save "D:\stata\CFPS原数据\2010\2010adult.dta"


/*==================================================
              2: 家庭关系库
==================================================*/
****2022年****

//打开数据库

use "D:\stata\CFPS原数据\2022\cfps2022famconf_202410.dta",clear

keep fid22 pid co_a22_p tb1y_a_p alive_a22_p cfps2022_interv_p familysize22 tb2_a_c1

for var _all: replace X =. if inlist(X, -10, -9, -8, -2, -1)

//1.老年人数量  
*年龄
gen age =2022- tb1y_a_p
label variable age "个人年龄"
replace age=. if  cfps2022_interv_p==0 //是否完访问
replace age=. if  co_a22_p==0          //经济上一家人
replace age=. if  alive_a22_p==0       //是否健在
*是老年人
gen elder=0
replace  elder=1 if age>=65
replace  elder=. if age==.
label var elder "是老年人"
*老年人数量
bys fid22:egen elder_num=sum(elder) 
label var elder_num "家庭老年人口数量"

//2.少儿数量
*是儿童
gen child =0
replace child=1 if age<=15
replace child=. if age==.
label var child "是少儿"
*少儿数量
bys fid22:egen child_num=sum(child) 
label var child_num "家庭少儿人口数量"

//3.成年数量
*是成年人
gen adult=0
replace  adult=1 if age>15 & age<65
replace  adult=. if age==.
label var  adult "是成年"

bys fid22:egen adult_num=sum(adult) 
label var adult_num "家庭成年劳动人口数量"

//4.老年抚养比  
gen elder_p= elder_num / adult_num
label variable elder_p "老年抚养比"

//5.少儿抚养比
gen child_p= child_num/  adult_num
label variable child_p "少儿抚养比"

//6.一孩性别
rename tb2_a_c1 child_gender
label variable child_gender "一孩性别"


rename familysize22 familysize

order fid22 pid  elder_p child_p familysize child_gender
keep  fid22 pid  elder_p child_p familysize child_gender

save "D:\stata\CFPS原数据\2022\2022famcof.dta" 


****2020年****

//打开数据库
use "D:\stata\CFPS原数据\2020\cfps2020famconf_202306.dta",clear

keep fid20 pid co_a20_p tb1y_a_p alive_a20_p cfps2020_interv_p familysize20 tb2_a_c1

for var _all: replace X =. if inlist(X, -10, -9, -8, -2, -1)

//1.老年人数量  
*年龄
gen age =2020- tb1y_a_p
label variable age "个人年龄"
replace age=. if  cfps2020_interv_p==0 //是否完访问
replace age=. if  co_a20_p==0          //经济上一家人
replace age=. if  alive_a20_p==0       //是否健在
*是老年人
gen elder=0
replace  elder=1 if age>=65
replace  elder=. if age==.
label var elder "是老年人"
*老年人数量
bys fid20:egen elder_num=sum(elder) 
label var elder_num "家庭老年人口数量"

//2.少儿数量
*是儿童
gen child =0
replace child=1 if age<=15
replace child=. if age==.
label var child "是少儿"
*少儿数量
bys fid20:egen child_num=sum(child) 
label var child_num "家庭少儿人口数量"

//3.成年数量
*是成年人
gen adult=0
replace  adult=1 if age>15 & age<65
replace  adult=. if age==.
label var  adult "是成年"

bys fid20:egen adult_num=sum(adult) 
label var adult_num "家庭成年劳动人口数量"

//4.老年抚养比  
gen elder_p= elder_num / adult_num
label variable elder_p "老年抚养比"

//5.少儿抚养比
gen child_p= child_num/  adult_num
label variable child_p "少儿抚养比"

//6.一孩性别
rename tb2_a_c1 child_gender
label variable child_gender "一孩性别"


rename familysize20 familysize

order fid20 pid  elder_p child_p familysize child_gender
keep  fid20 pid  elder_p child_p familysize child_gender

save "D:\stata\CFPS原数据\2020\2020famcof.dta"

****2018年****

//打开数据库
use "D:\stata\CFPS原数据\2018\cfps2018famconf_202008.dta",clear

keep fid18 pid co_a18_p tb1y_a_p alive_a18_p cfps2018_interv_p familysize18 tb2_a_c1

for var _all: replace X =. if inlist(X, -10, -9, -8, -2, -1)

//1.老年人数量  
*年龄
gen age =2018- tb1y_a_p
label variable age "个人年龄"
replace age=. if  cfps2018_interv_p==0 //是否完访问
replace age=. if  co_a18_p==0          //经济上一家人
replace age=. if  alive_a18_p==0       //是否健在
*是老年人
gen elder=0
replace  elder=1 if age>=65
replace  elder=. if age==.
label var elder "是老年人"
*老年人数量
bys fid18:egen elder_num=sum(elder) 
label var elder_num "家庭老年人口数量"

//2.少儿数量
*是儿童
gen child =0
replace child=1 if age<=15
replace child=. if age==.
label var child "是少儿"
*少儿数量
bys fid18:egen child_num=sum(child) 
label var child_num "家庭少儿人口数量"

//3.成年数量
*是成年人
gen adult=0
replace  adult=1 if age>15 & age<65
replace  adult=. if age==.
label var  adult "是成年"

bys fid18:egen adult_num=sum(adult) 
label var adult_num "家庭成年劳动人口数量"

//4.老年抚养比  
gen elder_p= elder_num / adult_num
label variable elder_p "老年抚养比"

//5.少儿抚养比
gen child_p= child_num/  adult_num
label variable child_p "少儿抚养比"

//6.一孩性别
rename tb2_a_c1 child_gender
label variable child_gender "一孩性别"


rename familysize18 familysize

order fid18 pid  elder_p child_p familysize child_gender
keep  fid18 pid  elder_p child_p familysize child_gender

save "D:\stata\CFPS原数据\2018\2018famcof.dta"

****2016年****

//打开数据库
use "D:\stata\CFPS原数据\2016\cfps2016famconf_201804.dta",clear

keep fid16 pid co_a16_p tb1y_a_p alive_a16_p cfps2016_interv_p familysize16 tb2_a_c1

for var _all: replace X =. if inlist(X, -10, -9, -8, -2, -1)

//1.老年人数量  
*年龄
gen age =2016- tb1y_a_p
label variable age "个人年龄"
replace age=. if  cfps2016_interv_p==0 //是否完访问
replace age=. if  co_a16_p==0          //经济上一家人
replace age=. if  alive_a16_p==0       //是否健在
*是老年人
gen elder=0
replace  elder=1 if age>=65
replace  elder=. if age==.
label var elder "是老年人"
*老年人数量
bys fid16:egen elder_num=sum(elder) 
label var elder_num "家庭老年人口数量"

//2.少儿数量
*是儿童
gen child =0
replace child=1 if age<=15
replace child=. if age==.
label var child "是少儿"
*少儿数量
bys fid16:egen child_num=sum(child) 
label var child_num "家庭少儿人口数量"

//3.成年数量
*是成年人
gen adult=0
replace  adult=1 if age>15 & age<65
replace  adult=. if age==.
label var  adult "是成年"

bys fid16:egen adult_num=sum(adult) 
label var adult_num "家庭成年劳动人口数量"

//4.老年抚养比  
gen elder_p= elder_num / adult_num
label variable elder_p "老年抚养比"

//5.少儿抚养比
gen child_p= child_num/  adult_num
label variable child_p "少儿抚养比"

//6.一孩性别
rename tb2_a_c1 child_gender
label variable child_gender "一孩性别"

rename familysize16 familysize

order fid16 pid  elder_p child_p familysize child_gender
keep  fid16 pid  elder_p child_p familysize child_gender

save "D:\stata\CFPS原数据\2016\2016famcof.dta"

****2014年****

//打开数据库
use "D:\stata\CFPS原数据\2014\cfps2014famconf_170630.dta",clear

keep fid14 pid co_a14_p tb1y_a_p alive_a14_p cfps2014_interv_p familysize14 tb2_a_c1

for var _all: replace X =. if inlist(X, -10, -9, -8, -2, -1)

//1.老年人数量  
*年龄
gen age =2014- tb1y_a_p
label variable age "个人年龄"
replace age=. if  cfps2014_interv_p==0 //是否完访问
replace age=. if  co_a14_p==0          //经济上一家人
replace age=. if  alive_a14_p==0       //是否健在
*是老年人
gen elder=0
replace  elder=1 if age>=65
replace  elder=. if age==.
label var elder "是老年人"
*老年人数量
bys fid14:egen elder_num=sum(elder) 
label var elder_num "家庭老年人口数量"

//2.少儿数量
*是儿童
gen child =0
replace child=1 if age<=15
replace child=. if age==.
label var child "是少儿"
*少儿数量
bys fid14:egen child_num=sum(child) 
label var child_num "家庭少儿人口数量"

//3.成年数量
*是成年人
gen adult=0
replace  adult=1 if age>15 & age<65
replace  adult=. if age==.
label var  adult "是成年"

bys fid14:egen adult_num=sum(adult) 
label var adult_num "家庭成年劳动人口数量"

//4.老年抚养比  
gen elder_p= elder_num / adult_num
label variable elder_p "老年抚养比"

//5.少儿抚养比
gen child_p= child_num/  adult_num
label variable child_p "少儿抚养比"

//6.一孩性别
rename tb2_a_c1 child_gender
label variable child_gender "一孩性别"

rename familysize14 familysize

order fid14 pid  elder_p child_p familysize child_gender
keep  fid14 pid  elder_p child_p familysize child_gender

save "D:\stata\CFPS原数据\2014\2014famcof.dta"

****2012年****

//打开数据库
use "D:\stata\CFPS原数据\2012\cfps2012famconf_092015.dta",clear

keep fid12 pid tb1y_a_p cfps_interv_p alive_a_p  familysize tb2_a_c1

for var _all: replace X =. if inlist(X, -10, -9, -8, -2, -1)

//1.老年人数量  
*年龄
gen age =2012- tb1y_a_p
label variable age "个人年龄"
replace age=. if  cfps_interv_p==0 //是否完访问

replace age=. if  alive_a_p==0       //是否健在
*是老年人
gen elder=0
replace  elder=1 if age>=65
replace  elder=. if age==.
label var elder "是老年人"
*老年人数量
bys fid12:egen elder_num=sum(elder) 
label var elder_num "家庭老年人口数量"

//2.少儿数量
*是儿童
gen child =0
replace child=1 if age<=15
replace child=. if age==.
label var child "是少儿"
*少儿数量
bys fid12:egen child_num=sum(child) 
label var child_num "家庭少儿人口数量"

//3.成年数量
*是成年人
gen adult=0
replace  adult=1 if age>15 & age<65
replace  adult=. if age==.
label var  adult "是成年"

bys fid12:egen adult_num=sum(adult) 
label var adult_num "家庭成年劳动人口数量"

//4.老年抚养比  
gen elder_p= elder_num / adult_num
label variable elder_p "老年抚养比"

//5.少儿抚养比
gen child_p= child_num/  adult_num
label variable child_p "少儿抚养比"

//6.一孩性别
rename tb2_a_c1 child_gender
label variable child_gender "一孩性别"


order fid12 pid  elder_p child_p familysize child_gender
keep  fid12 pid  elder_p child_p familysize child_gender

save "D:\stata\CFPS原数据\2012\2012famcof.dta"


****2010年****

//打开数据库
use "D:\stata\CFPS原数据\2010\cfps2010famconf_202008",clear

keep fid  pid tb1y_a_p   alive_a_p  familysize tb2_a_c1

for var _all: replace X =. if inlist(X, -10, -9, -8, -2, -1)

//1.老年人数量  
*年龄
gen age =2010- tb1y_a_p
label variable age "个人年龄"
 

replace age=. if  alive_a_p==0       //是否健在
*是老年人
gen elder=0
replace  elder=1 if age>=65
replace  elder=. if age==.
label var elder "是老年人"
*老年人数量
bys fid :egen elder_num=sum(elder) 
label var elder_num "家庭老年人口数量"

//2.少儿数量
*是儿童
gen child =0
replace child=1 if age<=15
replace child=. if age==.
label var child "是少儿"
*少儿数量
bys fid :egen child_num=sum(child) 
label var child_num "家庭少儿人口数量"

//3.成年数量
*是成年人
gen adult=0
replace  adult=1 if age>15 & age<65
replace  adult=. if age==.
label var  adult "是成年"

bys fid :egen adult_num=sum(adult) 
label var adult_num "家庭成年劳动人口数量"

//4.老年抚养比  
gen elder_p= elder_num / adult_num
label variable elder_p "老年抚养比"

//5.少儿抚养比
gen child_p= child_num/  adult_num
label variable child_p "少儿抚养比"

//6.一孩性别
rename tb2_a_c1 child_gender
label variable child_gender "一孩性别"


order fid  pid  elder_p child_p familysize child_gender
keep  fid  pid  elder_p child_p familysize child_gender
rename fid fid10
 
save "D:\stata\CFPS原数据\2010\2010famcof.dta"

/*==================================================
              3: 家庭经济库
==================================================*/
****2022****

//打开数据
use "D:\stata\CFPS原数据\2022\cfps2022famecon_202410.dta",clear

//提取变量
keep fid22 fid20 fid18 fid16 fid14 fid12 fid10 provcd22 countyid22 urban22 pce expense finc fincome1 fincome1_per total_asset fu201 ft501 fm1 finance_asset savings resp1pid familysize22 ft8 fml_count resp1pid fa1 fa101 resp1pid fk1l fl3 fl6 fl9 fl10 fm1 fn4 fn5 fp515 fp516 fq801 fr101 fs2 fs201 fs4 fs401 ft1 ft1_est ft101 ft3 ft301 ft5 ft501 ft7 ft8 ft801_s_1 ft801_s_2 ft801_s_3 ft801_s_4 ft801_s_5 ft801_s_6 fu100 fu101 fu102 fu201 finc fexp fwage_1 foperate_1 fproperty_1 ftransfer_1  fincome1 fincome1_per fincome1_per_p finance_asset fixed_asset house_debts houseasset_gross houseasset_net land_asset nonhousing_debts otherhousevalue resivalue savings total_asset fn100 fn101 fn301 expense mortage fp503 ft4 company land_asset durables_asset financial_product finance_asset fixed_asset houseasset_gross fp510 fp511 med ft301 nonhousing_debts food dress house daily med trco eec other food dress house daily med trco eec other savings pce food food dress dress house daily daily med med trco trco eec eec other other eptran eptran epwelf epwelf mortage mortage expense land_asset houseasset_gross houseasset_gross finance_asset finance_asset fixed_asset fixed_asset fs3 fs301 durables_asset durables_asset total_asset ft201 ft301 ft901


label list

for var _all: replace X =. if inlist(X, -10, -9, -8, -2, -1)

recode fa1 ( 1 = 0 "居委会")(77 = .)(5 = 1 "村委会"),gen(hhicd)

recode fa101 ( 1 = 0 "居委会")(77 = .)(5 = 1 "村委会"),gen(hhicd1)

recode fa101 ( 1 = 0 )(77 = .)(5 = 1 ),gen(hhicd3)
recode fa1 ( 1 = 0 )(77 = .)(5 = 1 ),gen(hhicd4)

gen icd=0
replace icd=1 if hhicd3==1
replace icd=1 if hhicd4==1

recode fk1l(1 = 1 "是")(5 = 0 "否")(79=.) ,gen(agri1)

recode fl3(1 = 1 "是")(5 = 0 "否")(79=.),gen(plant1)

recode fl6(1 = 1 "是")(5 = 0 "否")(79=.),gen(farm1)

recode fm1(1 = 1 "是")(5 = 0 "否")(79=.),gen(business1)

recode fk1l(1 = 1 )(5 = 0 )(79=.) ,gen(agri)
label var agri"是否从事农林牧副渔工作 1=是 0=否"
recode fl3(1 = 1 )(5 = 0 )(79=.),gen(plant)
label var plant"是否从事种植业林业 1=是 0=否"
recode fl6(1 = 1 )(5 = 0 )(79=.),gen(farm)
label var farm"是否养过牲畜或水产品 1=是 0=否"
recode fm1(1 = 1 )(5 = 0 )(79=.),gen(business)
label var business"是否有人从事工商业 1=是 0=否"

gen get1=fn4 
gen get2=fn5
egen Get=rowtotal(get1 get2)
label var Get"亲戚朋友给的钱（元）"
gen get=log(Get+1)
label var get"亲戚朋友给的钱（元）对数"

gen sav=savings
gen cas=log(savings+1)
label var sav"现金及其存款总额"
label var cas"现金及其存款对数"

gen Soc=fu201
gen soc=log(Soc+1)
label var Soc"社会关系  人情支出礼"
label var soc"社会关系  人情支出礼对数"

gen t_inc1=fincome1
label var t_inc1"全部家庭纯收入"

gen inc1=fincome1_per
label var inc1"人均家庭纯收入"

rename fwage_1 fwage 
rename foperate_1 foperate
rename fproperty_1 fproperty
rename ftransfer_1 ftransfer

gen Fin=finance_asset
gen fin=log(Fin+1)
label var Fin"家庭总金融资产（元）"
label var fin"家庭总金融资产（元）对数" 

gen Fix=fixed_asset
gen fix=log(Fix+1)
label var Fix"生产性固定资产（元）"
label var fix"生产性固定资产（元）对数" 

gen Esta=houseasset_net
gen esta=log(Esta+1)
label var Esta"家庭净房产（元）"
label var esta"家庭净房产（元）对数" 

gen Est=houseasset_gross
gen est=log(Est+1)
label var Est"家庭总房产（元）"
label var est"家庭总房产（元）对数" 

gen Land=land_asset
gen land=log(Land+1)
label var Land"土地资产（元）"
label var land"土地资产（元）对数" 

gen Nhd=nonhousing_debts
gen nhd=log(Nhd+1)
label var Nhd"非房贷的金融负债（元）"
label var nhd"非房贷的金融负债（元）对数" 

gen Asset=total_asset
gen asset=log(Asset+1)
label var Asset"家庭净资产（元）"
label var asset"家庭净资产（元）对数" 

egen Hast=rowtotal(otherhousevalue resivalue)
gen hast=log(Hast+1)
label var Hast"总房产市值（元）"
label var hast"总房产市值（元）对数"

gen exp=expense
label var exp"过去12个月总支出（元）"

gen give1=fp515 
gen give2=fp516
egen Give=rowtotal(give1 give2)
label var Give"给亲戚朋友的钱（元）"
gen give=log(Give+1)
label var give"给亲戚朋友的钱（元）对数"

gen fml=fml_count
label var fml"家庭人口数"

gen mor=mortage
label var mor"房贷支出"

gen chanquan=fr101
gen home=0
replace home=1 if chanquan>=1 & chanquan!=.
label var home"有无其他房产"

recode ft3(1=1)(0=0),gen(h_loan1)
label var h_loan1"是否有房产负债"
recode ft4(1=1)(0=0),gen(h_loan2)
label var h_loan2"是否有房产负债"
gen h_loan=0
replace h_loan=1 if h_loan1==1
replace h_loan=1 if h_loan2==1
label var h_loan"是否有房产负债"

gen qtqk=0
replace qtqk=1 if nonhousing_debts>0 & nonhousing_debts!=.
label var qtqk"是否有非房产负债"

gen mexp=med
label var mexp"医疗保健支出"

gen mexp1=fp511
label var mexp1"医疗支出"

gen eexp=fp510
label var eexp"教育支出"

gen fd=ft301*10000
label var fd"住房贷款"

gen fxzc=ft201
label var fxzc"风险资产"

recode fs3(1=1)(0 5=0)(79=.),gen(zd)
label var zd"是否经历征地 1=是 0=否"

gen zdbc=fs301
label var zdbc"征收土地补偿款"



for var _all: replace X =. if inlist(X, -10, -9, -8, -2, -1)

//年份
gen year=2022
label variable year "年份"

rename ( provcd22 countyid22 urban22 resp1pid )( provcd  countyid  urban  pid )

//1.总支出对数
gen lnconsume=ln(1+ expense )
label variable lnconsume "家庭总支出对数"

//2.总收入对数
gen lnincome=ln(1+ fincome1 )
label variable lnincome "家庭总收入对数"

//3.家庭人均支出
gen expense_p=0.0001*expense / familysize22
label variable expense_p "家庭人均支出"

//4.家庭人均收入
gen income_p=  0.0001*fincome1/ familysize22
label variable income_p "家庭人均收入"

//5.家庭净资产
sum total_asset
gen totalasset1=0.0001*total_asset
replace total_asset=totalasset1

//6.社会网络
rename fu201 social

//7.信贷约束
recode ft8 (1=1 "是") (5=0 "无") (79= . ),gen(limit)
label variable limit "信贷约束"

//8.是否有人个体私营
recode fm1 (1=1 "是") (5=0 "否") (79= . ),gen(entrep)
label variable entrep "是否有人从事个体私营（创业）"

//9.债务收入比
gen debt_p = ft501/ fincome1
label variable debt_p "债务收入比"

//10.金融资产
sum finance_asset

//11.存款
sum savings

//12.家庭收入
sum fincome1 fincome1_per

rename fp503 travel
rename fp510 school

order year fid22 fid20 fid18 fid16 fid14 fid12 fid10 pid hhicd hhicd4 icd  provcd countyid urban pid lnconsume lnincome expense_p income_p total_asset social limit business debt_p finance_asset savings fincome1 fincome1_per finc pce  agri plant farm entrep get1 get2 Get get sav cas Soc soc t_inc1 inc1 Fin fin Fix fix Esta esta Est est Land land Nhd nhd Asset asset Hast hast exp give1 give2 Give  give fml house mor h_loan qtqk  mexp mexp1 eexp food dress house daily med trco eec other savings pce food food dress dress house travel school daily daily med med trco trco eec eec other other eptran eptran epwelf epwelf mortage mortage expense land_asset houseasset_gross houseasset_gross finance_asset finance_asset fixed_asset fixed_asset durables_asset durables_asset total_asset fxzc fd zd zdbc finc ft201 house_debts fwage foperate fproperty ftransfer company financial_product nonhousing_debts fn100 fn101  resivalue

keep year fid22 fid20 fid18 fid16 fid14 fid12 fid10 pid hhicd hhicd4 icd  provcd countyid urban pid lnconsume lnincome expense_p income_p total_asset social limit business debt_p finance_asset savings fincome1 fincome1_per finc pce  agri plant farm entrep get1 get2 Get get sav cas Soc soc t_inc1 inc1 Fin fin Fix fix Esta esta Est est Land land Nhd nhd Asset asset Hast hast exp give1 give2 Give  give fml house mor h_loan qtqk  mexp mexp1 eexp food dress house daily med trco eec other savings pce food food dress dress house travel school daily daily med med trco trco eec eec other other eptran eptran epwelf epwelf mortage mortage expense land_asset houseasset_gross houseasset_gross finance_asset finance_asset fixed_asset fixed_asset durables_asset durables_asset total_asset fxzc fd zd zdbc finc ft201 house_debts fwage foperate fproperty ftransfer company financial_product nonhousing_debts fn100 fn101  resivalue

save "D:\stata\CFPS原数据\2022\2022fameco.dta"


****2020****

//打开数据
use "D:\stata\CFPS原数据\2020\cfps2020famecon_202306.dta",clear

//提取变量
keep fid20 fid18 fid16 fid14 fid12 fid10 provcd20 countyid20 urban20 pce expense finc fincome1 fincome1_per total_asset fu201 ft501 fm1 finance_asset savings resp1pid familysize20 ft8  fml_count resp1pid fa1 fa101 resp1pid fk1l fl3 fl6 fl9 fl10 fm1 fn4 fn5 fp515 fp516 fq801 fr101 fs2 fs201 fs4 fs401 ft1 ft1_est ft101 ft3 ft301 ft5 ft501 ft7 ft8 ft801_s_1 ft801_s_2 ft801_s_3 ft801_s_4 ft801_s_5 ft801_s_6 fu100 fu101 fu102 fu201 finc fexp fwage_1 foperate_1 fproperty_1 ftransfer_1  fincome1 fincome1_per fincome1_per_p finance_asset fixed_asset house_debts houseasset_gross houseasset_net land_asset nonhousing_debts otherhousevalue resivalue savings total_asset fn100 fn101 fn301 expense mortage fp503 ft4 company land_asset durables_asset financial_product finance_asset fixed_asset houseasset_gross fp510 fp511 med ft301 nonhousing_debts food dress house daily med trco eec other food dress house daily med trco eec other savings pce food food dress dress house daily daily med med trco trco eec eec other other eptran eptran epwelf epwelf mortage mortage expense land_asset houseasset_gross houseasset_gross finance_asset finance_asset fixed_asset fixed_asset fs3 fs301 durables_asset durables_asset total_asset ft201 ft301 ft901 


label list

for var _all: replace X =. if inlist(X, -10, -9, -8, -2, -1)

recode fa1 ( 1 = 0 "居委会")(77 = .)(5 = 1 "村委会"),gen(hhicd)

recode fa101 ( 1 = 0 "居委会")(77 = .)(5 = 1 "村委会"),gen(hhicd1)

recode fa101 ( 1 = 0 )(77 = .)(5 = 1 ),gen(hhicd3)
recode fa1 ( 1 = 0 )(77 = .)(5 = 1 ),gen(hhicd4)

gen icd=0
replace icd=1 if hhicd3==1
replace icd=1 if hhicd4==1

recode fk1l(1 = 1 "是")(5 = 0 "否")(79=.) ,gen(agri1)

recode fl3(1 = 1 "是")(5 = 0 "否")(79=.),gen(plant1)

recode fl6(1 = 1 "是")(5 = 0 "否")(79=.),gen(farm1)

recode fm1(1 = 1 "是")(5 = 0 "否")(79=.),gen(business1)

recode fk1l(1 = 1 )(5 = 0 )(79=.) ,gen(agri)
label var agri"是否从事农林牧副渔工作 1=是 0=否"
recode fl3(1 = 1 )(5 = 0 )(79=.),gen(plant)
label var plant"是否从事种植业林业 1=是 0=否"
recode fl6(1 = 1 )(5 = 0 )(79=.),gen(farm)
label var farm"是否养过牲畜或水产品 1=是 0=否"
recode fm1(1 = 1 )(5 = 0 )(79=.),gen(business)
label var business"是否有人从事工商业 1=是 0=否"

gen get1=fn4 
gen get2=fn5
egen Get=rowtotal(get1 get2)
label var Get"亲戚朋友给的钱（元）"
gen get=log(Get+1)
label var get"亲戚朋友给的钱（元）对数"

gen sav=savings
gen cas=log(savings+1)
label var sav"现金及其存款总额"
label var cas"现金及其存款对数"

gen Soc=fu201
gen soc=log(Soc+1)
label var Soc"社会关系  人情支出礼"
label var soc"社会关系  人情支出礼对数"

gen t_inc1=fincome1
label var t_inc1"全部家庭纯收入"

gen inc1=fincome1_per
label var inc1"人均家庭纯收入"

gen Fin=finance_asset
gen fin=log(Fin+1)
label var Fin"家庭总金融资产（元）"
label var fin"家庭总金融资产（元）对数" 

gen Fix=fixed_asset
gen fix=log(Fix+1)
label var Fix"生产性固定资产（元）"
label var fix"生产性固定资产（元）对数" 

gen Esta=houseasset_net
gen esta=log(Esta+1)
label var Esta"家庭净房产（元）"
label var esta"家庭净房产（元）对数" 

gen Est=houseasset_gross
gen est=log(Est+1)
label var Est"家庭总房产（元）"
label var est"家庭总房产（元）对数" 

gen Land=land_asset
gen land=log(Land+1)
label var Land"土地资产（元）"
label var land"土地资产（元）对数" 

gen Nhd=nonhousing_debts
gen nhd=log(Nhd+1)
label var Nhd"非房贷的金融负债（元）"
label var nhd"非房贷的金融负债（元）对数" 

gen Asset=total_asset
gen asset=log(Asset+1)
label var Asset"家庭净资产（元）"
label var asset"家庭净资产（元）对数" 

egen Hast=rowtotal(otherhousevalue resivalue)
gen hast=log(Hast+1)
label var Hast"总房产市值（元）"
label var hast"总房产市值（元）对数"

gen exp=expense
label var exp"过去12个月总支出（元）"

gen give1=fp515 
gen give2=fp516
egen Give=rowtotal(give1 give2)
label var Give"给亲戚朋友的钱（元）"
gen give=log(Give+1)
label var give"给亲戚朋友的钱（元）对数"

gen fml=fml_count
label var fml"家庭人口数"

gen mor=mortage
label var mor"房贷支出"

gen chanquan=fr101
gen home=0
replace home=1 if chanquan>=1 & chanquan!=.
label var home"有无其他房产"

recode ft3(1=1)(0=0),gen(h_loan1)
label var h_loan1"是否有房产负债"
recode ft4(1=1)(0=0),gen(h_loan2)
label var h_loan2"是否有房产负债"
gen h_loan=0
replace h_loan=1 if h_loan1==1
replace h_loan=1 if h_loan2==1
label var h_loan"是否有房产负债"

gen qtqk=0
replace qtqk=1 if nonhousing_debts>0 & nonhousing_debts!=.
label var qtqk"是否有非房产负债"

gen mexp=med
label var mexp"医疗保健支出"

gen mexp1=fp511
label var mexp1"医疗支出"

gen eexp=fp510
label var eexp"教育支出"

gen fd=ft301*10000
label var fd"住房贷款"

gen fxzc=ft201
label var fxzc"风险资产"

recode fs3(1=1)(0 5=0)(79=.),gen(zd)
label var zd"是否经历征地 1=是 0=否"

gen zdbc=fs301
label var zdbc"征收土地补偿款"

for var _all: replace X =. if inlist(X, -10, -9, -8, -2, -1)

//年份
gen year=2020
label variable year "年份"

rename ( provcd20 countyid20 urban20 resp1pid )( provcd  countyid  urban  pid )

//1.总支出对数
gen lnconsume=ln(1+ expense )
label variable lnconsume "家庭总支出对数"

//2.总收入对数
gen lnincome=ln(1+ fincome1 )
label variable lnincome "家庭总收入对数"

//3.家庭人均支出
gen expense_p=0.0001*expense / familysize20
label variable expense_p "家庭人均支出"

//4.家庭人均收入
gen income_p=  0.0001*fincome1/ familysize20
label variable income_p "家庭人均收入"

//5.家庭净资产
sum total_asset
gen totalasset1=0.0001*total_asset
replace total_asset=totalasset1

//6.社会网络
rename fu201 social

//7.信贷约束
recode ft8 (1=1 "是") (5=0 "无") (79= . ),gen(limit)
label variable limit "信贷约束"

//8.创业
recode fm1 (1=1 "是") (5=0 "否") (79= . ),gen(entrep)
label variable entrep "创业"

//9.债务收入比
gen debt_p = ft501/ fincome1
label variable debt_p "债务收入比"

//10.金融资产
sum finance_asset

//11.存款
sum savings

//12.家庭收入
sum fincome1 fincome1_per

rename fp503 travel
rename fp510 school

rename fwage_1 fwage 
rename foperate_1 foperate
rename fproperty_1 fproperty
rename ftransfer_1 ftransfer


order year fid20 fid18 fid16 fid14 fid12 fid10 pid hhicd hhicd4 icd  provcd countyid urban pid lnconsume lnincome expense_p income_p total_asset social limit business debt_p finance_asset savings fincome1 fincome1_per finc pce  agri plant farm entrep get1 get2 Get get sav cas Soc soc t_inc1 inc1 Fin fin Fix fix Esta esta Est est Land land Nhd nhd Asset asset Hast hast exp give1 give2 Give  give fml house mor h_loan qtqk  mexp mexp1 eexp food dress house daily med trco eec other savings pce food food dress dress house travel school daily daily med med trco trco eec eec other other eptran eptran epwelf epwelf mortage mortage expense land_asset houseasset_gross houseasset_gross finance_asset finance_asset fixed_asset fixed_asset durables_asset durables_asset total_asset fxzc fd zd zdbc finc ft201 house_debts fwage foperate fproperty ftransfer company financial_product nonhousing_debts fn100 fn101  resivalue

keep  year fid20 fid18 fid16 fid14 fid12 fid10 pid hhicd hhicd4 icd  provcd countyid urban pid lnconsume lnincome expense_p income_p total_asset social limit business debt_p finance_asset savings fincome1 fincome1_per finc pce  agri plant farm entrep get1 get2 Get get sav cas Soc soc t_inc1 inc1 Fin fin Fix fix Esta esta Est est Land land Nhd nhd Asset asset Hast hast exp give1 give2 Give  give fml house mor h_loan qtqk  mexp mexp1 eexp food dress house daily med trco eec other savings pce food food dress dress house travel school daily daily med med trco trco eec eec other other eptran eptran epwelf epwelf mortage mortage expense land_asset houseasset_gross houseasset_gross finance_asset finance_asset fixed_asset fixed_asset durables_asset durables_asset total_asset fxzc fd zd zdbc finc ft201 house_debts fwage foperate fproperty ftransfer company financial_product nonhousing_debts fn100 fn101  resivalue

save "D:\stata\CFPS原数据\2020\2020fameco.dta"


****2018****

//打开数据
use "D:\stata\CFPS原数据\2018\cfps2018famecon_202101.dta",clear

//提取变量
keep fid18 fid16 fid14 fid12 fid10 provcd18 countyid18 urban18 pce expense finc fincome2 fincome2_per total_asset fu201 ft501 fm1 finance_asset savings resp1pid familysize18 ft8  fml_count fa1 fa101 resp1pid fk1l fl3 fl6 fl9 fl10 fm1 fn4 fn5 fp5070 fp515 fp516 fq801 fr101 fs2 fs201 fs4 fs401 ft1 ft1_est ft101 ft3 ft301 ft5 ft501 ft7 ft8 ft801_s_1 ft801_s_2 ft801_s_3 ft801_s_4 ft801_s_5 fu100 fu101 fu102 fu201 finc fexp finc1 fexp1 fwage_1 fwage_2 foperate_1 foperate_2 fproperty_1 fproperty_2 ftransfer_1 ftransfer_2 felse_1 felse_2 fincome1 fincome2 fincome1_per fincome1_per_p fincome2_per fincome2_per_p  fixed_asset house_debts houseasset_gross houseasset_net land_asset nonhousing_debts otherhousevalue resivalue savings financial_product total_asset familysize18 fswt_natcs18n fn100 fn101 expense fp503 fp511 med fp510 ft4 company durables_asset finance_asset fixed_asset houseasset_gross land_asset financial_product ft301 nonhousing_debts food dress house daily med trco eec other food dress house daily med trco eec other savings pce food food dress dress house daily daily med med trco trco eec eec other other eptran eptran epwelf epwelf mortage mortage expense land_asset houseasset_gross houseasset_gross finance_asset finance_asset fixed_asset fixed_asset durables_asset durables_asset total_asset countyid18 ft201 ft901 ft301 finc fs3 fs301



label list

for var _all: replace X =. if inlist(X, -10, -9, -8, -2, -1)

recode fa1 ( 1 = 0 "居委会")(77 = .)(5 = 1 "村委会"),gen(hhicd)

recode fa101 ( 1 = 0 "居委会")(77 = .)(5 = 1 "村委会"),gen(hhicd1)

recode fa101 ( 1 = 0 )(77 = .)(5 = 1 ),gen(hhicd3)
recode fa1 ( 1 = 0 )(77 = .)(5 = 1 ),gen(hhicd4)

gen icd=0
replace icd=1 if hhicd3==1
replace icd=1 if hhicd4==1

recode fk1l(1 = 1 "是")(5 = 0 "否") (79=.),gen(agri1)

recode fl3(1 = 1 "是")(5 = 0 "否")(79=.),gen(plant1)

recode fl6(1 = 1 "是")(5 = 0 "否")(79=.),gen(farm1)

recode fm1(1 = 1 "是")(5 = 0 "否"),gen(business1)

recode fk1l(1 = 1 )(5 = 0 )(79=.) ,gen(agri)
label var agri"是否从事农林牧副渔工作 1=是 0=否"
recode fl3(1 = 1 )(5 = 0 )(79=.),gen(plant)
label var plant"是否从事种植业林业 1=是 0=否"
recode fl6(1 = 1 )(5 = 0 )(79=.),gen(farm)
label var farm"是否养过牲畜或水产品 1=是 0=否"
recode fm1(1 = 1 )(5 = 0 )(79=.),gen(business)
label var business"是否有人从事工商业 1=是 0=否"

recode fs2(1 = 1 "是")(5 = 0 "否")(79=.),gen(out)

recode fs2(1 = 1 )(5 = 0 )(79=.),gen(outer)
label var outer"是否转出土地 1=是 0=否"

gen 土地租金=fs201
gen 土地租金对数=log(土地租金)

rename fwage_1 fwage 
rename foperate_1 foperate
rename fproperty_1 fproperty
rename ftransfer_1 ftransfer

gen get1=fn4 
gen get2=fn5
egen Get=rowtotal(get1 get2)
label var Get"亲戚朋友给的钱（元）"
gen get=log(Get+1)
label var get"亲戚朋友给的钱（元）对数"

gen sav=savings
gen cas=log(savings+1)
label var sav"现金及其存款总额"
label var cas"现金及其存款对数"

gen Soc=fu201
gen soc=log(Soc+1)
label var Soc"社会关系  人情支出礼"
label var soc"社会关系  人情支出礼对数"

gen Deb=ft501
gen deb=log(Deb+1)
label var Deb"待偿贷款额"
label var deb"代偿贷款额对数" 

gen t_inc1=fincome1
label var t_inc1"全部家庭纯收入"
gen t_inc2=fincome2
label var t_inc2"全部家庭纯收入（与2010年可比）"

gen inc1=fincome1_per
label var inc1"人均家庭纯收入"
gen inc2=fincome2_per
label var inc2"人均家庭纯收入（与2010年可比）"

gen Fin=financial_product
gen fin=log(Fin+1)
label var Fin"家庭总金融资产（元）"
label var fin"家庭总金融资产（元）对数" 

gen Fix=fixed_asset
gen fix=log(Fix+1)
label var Fix"生产性固定资产（元）"
label var fix"生产性固定资产（元）对数" 

gen Esta=houseasset_net
gen esta=log(Esta+1)
label var Esta"家庭净房产（元）"
label var esta"家庭净房产（元）对数" 

gen Est=houseasset_gross
gen est=log(Est+1)
label var Est"家庭总房产（元）"
label var est"家庭总房产（元）对数" 

gen Land=land_asset
gen land=log(Land+1)
label var Land"土地资产（元）"
label var land"土地资产（元）对数" 

gen Nhd=nonhousing_debts
gen nhd=log(Nhd+1)
label var Nhd"非房贷的金融负债（元）"
label var nhd"非房贷的金融负债（元）对数" 

gen Asset=total_asset
gen asset=log(Asset+1)
label var Asset"家庭净资产（元）"
label var asset"家庭净资产（元）对数" 

egen Hast=rowtotal(otherhousevalue resivalue)
gen hast=log(Hast+1)
label var Hast"总房产市值（元）"
label var hast"总房产市值（元）对数"

gen exp=expense
label var exp"过去12个月总支出（元）"
gen con=fexp1
label var con"总支出调整（元/年）"

gen give1=fp515 
gen give2=fp516
egen Give=rowtotal(give1 give2)
label var Give"给亲戚朋友的钱（元）"
gen give=log(Give+1)
label var give"给亲戚朋友的钱（元）对数"

gen fml=fml_count
label var fml"家庭人口数"

recode ft3(1=1)(0=0),gen(h_loan1)
label var h_loan1"是否有房产负债"
recode ft4(1=1)(0=0),gen(h_loan2)
label var h_loan2"是否有房产负债"
gen h_loan=0
replace h_loan=1 if h_loan1==1
replace h_loan=1 if h_loan2==1
label var h_loan"是否有房产负债"

gen qtqk=0
replace qtqk=1 if nonhousing_debts>0 & nonhousing_debts!=.
label var qtqk"是否有非房产负债"

gen h_asset=houseasset_gross
label var h_asset"房屋资产"

gen mexp=med
label var mexp"医疗保健支出"

gen mexp1=fp511
label var mexp1"医疗支出"

gen eexp=fp510
label var eexp"教育支出"

gen fd=ft301*10000
label var fd"住房贷款"

gen fxzc=ft201
label var fxzc"风险资产"

recode fs3(1=1)(0 5=0)(79=.),gen(zd)
label var zd"是否经历征地 1=是 0=否"

gen zdbc=fs301
label var zdbc"征收土地补偿款"

for var _all: replace X =. if inlist(X, -10, -9, -8, -2, -1)

//年份
gen year=2018
label variable year "年份"

rename ( provcd18 countyid18 urban18 resp1pid )( provcd  countyid  urban  pid )

//1.总支出对数
gen lnconsume=ln(1+ expense )
label variable lnconsume "家庭总支出对数"

//2.总收入对数
gen lnincome=ln(1+ fincome2 )
label variable lnincome "家庭总收入对数"

//3.家庭人均支出
gen expense_p=0.0001*expense / familysize18
label variable expense_p "家庭人均支出"

//4.家庭人均收入
gen income_p=  0.0001*fincome2/ familysize18
label variable income_p "家庭人均收入"

//5.家庭净资产
sum total_asset
gen totalasset1=0.0001*total_asset
replace total_asset=totalasset1

//6.社会网络
rename fu201 social

//7.信贷约束
recode ft8 (1=1 "是") (5=0 "无") (79= . ),gen(limit)
label variable limit "信贷约束"

//8.创业
recode fm1 (1=1 "是") (5=0 "否") (79= . ),gen(entrep)
label variable entrep "创业"

//9.债务收入比
gen debt_p = ft501/ fincome2
label variable debt_p "债务收入比"

//10.金融资产
sum finance_asset

//11.存款
sum savings

//12.家庭收入
sum fincome2 fincome2_per

rename fp503 travel
rename fp510 school

order year fid18 fid16 fid14 fid12 fid10 pid hhicd hhicd4 icd  provcd countyid urban pid lnconsume lnincome expense_p income_p total_asset social limit business debt_p finance_asset savings fincome1 fincome1_per finc pce  agri plant farm entrep get1 get2 Get get sav cas Soc soc t_inc1 inc1 Fin fin Fix fix Esta esta Est est Land land Nhd nhd Asset asset Hast hast exp give1 give2 Give  give fml house mor h_loan qtqk  mexp mexp1 eexp food dress house daily med trco eec other savings pce food food dress dress house travel school daily daily med med trco trco eec eec other other eptran eptran epwelf epwelf mortage mortage expense land_asset houseasset_gross houseasset_gross finance_asset finance_asset fixed_asset fixed_asset durables_asset durables_asset total_asset fxzc fd zd zdbc finc ft201 house_debts fwage foperate fproperty ftransfer company financial_product nonhousing_debts fn100 fn101  resivalue

keep year fid18 fid16 fid14 fid12 fid10 pid hhicd hhicd4 icd  provcd countyid urban pid lnconsume lnincome expense_p income_p total_asset social limit business debt_p finance_asset savings fincome1 fincome1_per finc pce  agri plant farm entrep get1 get2 Get get sav cas Soc soc t_inc1 inc1 Fin fin Fix fix Esta esta Est est Land land Nhd nhd Asset asset Hast hast exp give1 give2 Give  give fml house mor h_loan qtqk  mexp mexp1 eexp food dress house daily med trco eec other savings pce food food dress dress house travel school daily daily med med trco trco eec eec other other eptran eptran epwelf epwelf mortage mortage expense land_asset houseasset_gross houseasset_gross finance_asset finance_asset fixed_asset fixed_asset durables_asset durables_asset total_asset fxzc fd zd zdbc finc ft201 house_debts fwage foperate fproperty ftransfer company financial_product nonhousing_debts fn100 fn101  resivalue

save "D:\stata\CFPS原数据\2018\2018fameco.dta"


****2016****

//打开数据
use "D:\stata\CFPS原数据\2016\cfps2016famecon_201807.dta",clear

//提取变量
keep   fid16 fid14 fid12 fid10 provcd16 countyid16 urban16 pce expense finc fincome2 fincome2_per total_asset fu201 ft501 fm1 finance_asset savings resp1pid familysize16 ft8 fml2016_count fa1 fa101 resp1pid fk1l fl3 fl6 fl9 fl10 fm1 fn4 fn5 fp515 fp516 fq801 fr101 fs2 fs201 fs4 fs401 ft1 ft1_est ft101 ft3 ft301 ft5 ft501 ft7 ft8 ft801_s_1 ft801_s_2 ft801_s_3 ft801_s_4 ft801_s_5 ft801_s_6 fu100 fu101 fu102 fu201 finc fexp fwage_1 fwage_2 foperate_1 foperate_2 fproperty_1 fproperty_2 ftransfer_1 ftransfer_2 felse_1 felse_2 fincome1 fincome2 fincome1_per fincome1_per_p fincome2_per fincome2_per_p finance_asset fixed_asset house_debts houseasset_gross houseasset_net land_asset nonhousing_debts nonhousing_debts otherhousevalue resivalue savings total_asset familysize16 expense fp503 fp511 med fp510 company finance_asset fixed_asset land_asset durables_asset houseasset_gross ft4 ft301 nonhousing_debts food dress house daily med trco eec other food dress house daily med trco eec other savings pce food food dress dress house daily daily med med trco trco eec eec other other eptran eptran epwelf epwelf mortage mortage expense land_asset houseasset_gross houseasset_gross finance_asset finance_asset fixed_asset fixed_asset durables_asset durables_asset total_asset ft901 ft201 ft301 finc fs3 fs301 fn100 fn101

rename fwage_1 fwage 
rename foperate_1 foperate
rename fproperty_1 fproperty
rename ftransfer_1 ftransfer

label list

for var _all: replace X =. if inlist(X, -10, -9, -8, -2, -1)

recode fa1 ( 1 = 0 "居委会")(77 = .)(5 = 1 "村委会"),gen(hhicd)

recode fa101 ( 1 = 0 "居委会")(77 = .)(5 = 1 "村委会"),gen(hhicd1)

recode fa101 ( 1 = 0 )(77 = .)(5 = 1 ),gen(hhicd3)
recode fa1 ( 1 = 0 )(77 = .)(5 = 1 ),gen(hhicd4)

gen icd=0
replace icd=1 if hhicd3==1
replace icd=1 if hhicd4==1

recode fk1l(1 = 1 "是")(5 = 0 "否")(79=.) ,gen(agri1)

recode fl3(1 = 1 "是")(5 = 0 "否")(79=.),gen(plant1)

recode fl6(1 = 1 "是")(5 = 0 "否")(79=.),gen(farm1)

recode fm1(1 = 1 "是")(5 = 0 "否")(79=.),gen(business1)

recode fk1l(1 = 1 )(5 = 0 )(79=.) ,gen(agri)
label var agri"是否从事农林牧副渔工作 1=是 0=否"
recode fl3(1 = 1 )(5 = 0 )(79=.),gen(plant)
label var plant"是否从事种植业林业 1=是 0=否"
recode fl6(1 = 1 )(5 = 0 )(79=.),gen(farm)
label var farm"是否养过牲畜或水产品 1=是 0=否"
recode fm1(1 = 1 )(5 = 0 )(79=.),gen(business)
label var business"是否有人从事工商业 1=是 0=否"

recode fs2(1 = 1 "是")(5 = 0 "否")(79=.),gen(out)

recode fs2(1 = 1 )(5 = 0 )(79=.),gen(outer)
label var outer"是否转出土地 1=是 0=否"

gen get1=fn4 
gen get2=fn5
egen Get=rowtotal(get1 get2)
label var Get"亲戚朋友给的钱（元）"
gen get=log(Get+1)
label var get"亲戚朋友给的钱（元）对数"

gen sav=savings
gen cas=log(savings+1)
label var sav"现金及其存款总额"
label var cas"现金及其存款对数"

gen Soc=fu201
gen soc=log(Soc+1)
label var Soc"社会关系  人情支出礼"
label var soc"社会关系  人情支出礼对数"

gen t_inc1=fincome1
label var t_inc1"全部家庭纯收入"
gen t_inc2=fincome2
label var t_inc2"全部家庭纯收入（与2010年可比）"

gen inc1=fincome1_per
label var inc1"人均家庭纯收入"
gen inc2=fincome2_per
label var inc2"人均家庭纯收入（与2010年可比）"

gen Fin=finance_asset
gen fin=log(Fin+1)
label var Fin"家庭总金融资产（元）"
label var fin"家庭总金融资产（元）对数" 

gen Fix=fixed_asset
gen fix=log(Fix+1)
label var Fix"生产性固定资产（元）"
label var fix"生产性固定资产（元）对数" 

gen Esta=houseasset_net
gen esta=log(Esta+1)
label var Esta"家庭净房产（元）"
label var esta"家庭净房产（元）对数" 

gen Est=houseasset_gross
gen est=log(Est+1)
label var Est"家庭总房产（元）"
label var est"家庭总房产（元）对数" 

gen Land=land_asset
gen land=log(Land+1)
label var Land"土地资产（元）"
label var land"土地资产（元）对数" 

gen Nhd=nonhousing_debts
gen nhd=log(Nhd+1)
label var Nhd"非房贷的金融负债（元）"
label var nhd"非房贷的金融负债（元）对数" 

gen Asset=total_asset
gen asset=log(Asset+1)
label var Asset"家庭净资产（元）"
label var asset"家庭净资产（元）对数" 

egen Hast=rowtotal(otherhousevalue resivalue)
gen hast=log(Hast+1)
label var Hast"总房产市值（元）"
label var hast"总房产市值（元）对数"

gen exp=expense
label var exp"过去12个月总支出（元）"

gen give1=fp515 
gen give2=fp516
egen Give=rowtotal(give1 give2)
label var Give"给亲戚朋友的钱（元）"
gen give=log(Give+1)
label var give"给亲戚朋友的钱（元）对数"

gen fml=fml2016_count
label var fml"家庭人口数"

recode ft3(1=1)(0=0),gen(h_loan1)
label var h_loan1"是否有房产负债"
recode ft4(1=1)(0=0),gen(h_loan2)
label var h_loan2"是否有房产负债"
gen h_loan=0
replace h_loan=1 if h_loan1==1
replace h_loan=1 if h_loan2==1
label var h_loan"是否有房产负债"

gen qtqk=0
replace qtqk=1 if nonhousing_debts>0 & nonhousing_debts!=.
label var qtqk"是否有非房产负债"

gen mexp=med
label var mexp"医疗保健支出"

gen mexp1=fp511
label var mexp1"医疗支出"

gen eexp=fp510
label var eexp"教育支出"

gen fd=ft301*10000
label var fd"住房贷款"

gen fxzc=ft201
label var fxzc"风险资产"

recode fs3(1=1)(0 5=0)(79=.),gen(zd)
label var zd"是否经历征地 1=是 0=否"

gen zdbc=fs301
label var zdbc"征收土地补偿款"

rename fp503 travel
rename fp510 school

for var _all: replace X =. if inlist(X, -10, -9, -8, -2, -1)

//年份
gen year=2016
label variable year "年份"

rename ( provcd16 countyid16 urban16 resp1pid )( provcd  countyid  urban  pid )

//1.总支出对数
gen lnconsume=ln(1+ expense )
label variable lnconsume "家庭总支出对数"

//2.总收入对数
gen lnincome=ln(1+  fincome2 )
label variable lnincome "家庭总收入对数"

//3.家庭人均支出
gen expense_p=0.0001*expense / familysize16
label variable expense_p "家庭人均支出"

//4.家庭人均收入
gen income_p=  0.0001*fincome2/ familysize16
label variable income_p "家庭人均收入"

//5.家庭净资产
sum total_asset
gen totalasset1=0.0001*total_asset
replace total_asset=totalasset1

//6.社会网络
rename fu201 social

//7.信贷约束
recode ft8 (1=1 "是") (5=0 "无") (79= . ),gen(limit)
label variable limit "信贷约束"

//8.创业
recode fm1 (1=1 "是") (5=0 "否") (79= . ),gen(entrep)
label variable entrep "创业"

//9.债务收入比
gen debt_p = ft501/  fincome2
label variable debt_p "债务收入比"

//10.金融资产
sum finance_asset

//11.存款
sum savings

//12.家庭收入
sum fincome2 fincome2_per

//13.流动性约束
gen mfinc=2*fincome2/12
gen liquid=(finance_asset<=mfinc)
label var mfinc 家庭两个月收入
label var liquid 流动性约束


order year fid16 fid14 fid12 fid10 pid hhicd hhicd4 icd  provcd countyid urban pid lnconsume lnincome expense_p income_p total_asset social limit business debt_p finance_asset savings fincome1 fincome1_per finc pce  agri plant farm entrep get1 get2 Get get sav cas Soc soc t_inc1 inc1 Fin fin Fix fix Esta esta Est est Land land Nhd nhd Asset asset Hast hast exp give1 give2 Give  give fml house mor h_loan qtqk  mexp mexp1 eexp food dress house daily med trco eec other savings pce food food dress dress house travel school daily daily med med trco trco eec eec other other eptran eptran epwelf epwelf mortage mortage expense land_asset houseasset_gross houseasset_gross finance_asset finance_asset fixed_asset fixed_asset durables_asset durables_asset total_asset fxzc fd zd zdbc finc ft201 house_debts fwage foperate fproperty ftransfer company  nonhousing_debts fn100 fn101  resivalue

keep year fid16 fid14 fid12 fid10 pid hhicd hhicd4 icd  provcd countyid urban pid lnconsume lnincome expense_p income_p total_asset social limit business debt_p finance_asset savings fincome1 fincome1_per finc pce  agri plant farm entrep get1 get2 Get get sav cas Soc soc t_inc1 inc1 Fin fin Fix fix Esta esta Est est Land land Nhd nhd Asset asset Hast hast exp give1 give2 Give  give fml house mor h_loan qtqk  mexp mexp1 eexp food dress house daily med trco eec other savings pce food food dress dress house travel school daily daily med med trco trco eec eec other other eptran eptran epwelf epwelf mortage mortage expense land_asset houseasset_gross houseasset_gross finance_asset finance_asset fixed_asset fixed_asset durables_asset durables_asset total_asset fxzc fd zd zdbc finc ft201 house_debts fwage foperate fproperty ftransfer company  nonhousing_debts fn100 fn101  resivalue


save "D:\stata\CFPS原数据\2016\2016fameco.dta"


****2014****

//打开数据
use "D:\stata\CFPS原数据\2014\cfps2014famecon_201906.dta",clear

//提取变量
keep    fid14 fid12 fid10 provcd14 countyid14 urban14 pce expense finc fincome2 fincome2_per total_asset fu201 ft501 fm1 finance_asset savings fresp1pid familysize  ft8 fid14 fid12 fid10 fml2014num fa1 fresp1pid fk1l fl3 fl6 fl9 fl10 fm1 fn4 fn5 fp515 fp516 fq801 fr101 ft1 ft1_est ft101 ft3 ft5 ft501 ft7 ft8 ft801_s_1 ft801_s_2 ft801_s_3 ft801_s_4 ft801_s_5 fu101 fu102 fu201 finc fexp fwage_1 fwage_2 foperate_1 foperate_2 fproperty_1 fproperty_2 ftransfer_1 ftransfer_2 felse_1 felse_2 fincome1 fincome2 fincome1_per fincome1_per_p fincome2_per fincome2_per_p finance_asset fixed_asset house_debts houseasset_gross houseasset_net land_asset nonhousing_debts nonhousing_debts otherhousevalue resivalue savings total_asset  fswt_natcs14 fn1_s_1 fn1_s_2 fn1_s_3 fn1_s_4 fn101 expense fp503 company durables_asset finance_asset financial_product fixed_asset houseasset_gross land_asset med fp511 fp510 ft4 fw12 fw241 ft301 nonhousing_debts food dress house daily med trco eec other food dress house daily med trco eec other savings  pce food food dress dress house daily daily med med trco trco eec eec other other eptran eptran epwelf epwelf mortage mortage expense land_asset houseasset_gross houseasset_gross finance_asset finance_asset fixed_asset fixed_asset durables_asset durables_asset total_asset ft201 finc ft301 ft901 finc fs3 fs301 fn101 fp510

rename fwage_1 fwage 
rename foperate_1 foperate
rename fproperty_1 fproperty
rename ftransfer_1 ftransfer

label list

for var _all: replace X =. if inlist(X, -10, -9, -8, -2, -1)

recode fa1 ( 1 = 0 "居委会")(77 = .)(5 = 1 "村委会"),gen(hhicd)

recode fa1 ( 1 = 0 )(77 = .)(5 = 1 ),gen(hhicd4)

gen icd=0
replace icd=1 if hhicd4==1

recode fk1l(1 = 1 "是")(5 0= 0 "否") ,gen(agri1)

recode fl3(1 = 1 "是")(5 0= 0 "否"),gen(plant1)

recode fl6(1 = 1 "是")(5 0= 0 "否"),gen(farm1)

recode fm1(1 = 1 "是")(5 0= 0 "否"),gen(business1)

recode fk1l(1 = 1 )(5 0= 0 ) ,gen(agri)
label var agri"是否从事农林牧副渔工作 1=是 0=否"
recode fl3(1 = 1 )(5 0= 0 ),gen(plant)
label var plant"是否从事种植业林业 1=是 0=否"
recode fl6(1 = 1 )(5 0 = 0 ),gen(farm)
label var farm"是否养过牲畜或水产品 1=是 0=否"
recode fm1(1 = 1 )(5 0= 0 ),gen(business)
label var business"是否有人从事工商业 1=是 0=否"

gen get1=fn4 
gen get2=fn5
egen Get=rowtotal(get1 get2)
label var Get"亲戚朋友给的钱（元）"
gen get=log(Get+1)
label var get"亲戚朋友给的钱（元）对数"

gen sav=savings
gen cas=log(savings+1)
label var sav"现金及其存款总额"
label var cas"现金及其存款对数"

gen Soc=fu201
gen soc=log(Soc+1)
label var Soc"社会关系  人情支出礼"
label var soc"社会关系  人情支出礼对数"

gen t_inc1=fincome1
label var t_inc1"全部家庭纯收入"
gen t_inc2=fincome2
label var t_inc2"全部家庭纯收入（与2010年可比）"

gen inc1=fincome1_per
label var inc1"人均家庭纯收入"
gen inc2=fincome2_per
label var inc2"人均家庭纯收入（与2010年可比）"

gen Fin=finance_asset
gen fin=log(Fin+1)
label var Fin"家庭总金融资产（元）"
label var fin"家庭总金融资产（元）对数" 

gen Fix=fixed_asset
gen fix=log(Fix+1)
label var Fix"生产性固定资产（元）"
label var fix"生产性固定资产（元）对数" 

gen Esta=houseasset_net
gen esta=log(Esta+1)
label var Esta"家庭净房产（元）"
label var esta"家庭净房产（元）对数" 

gen Est=houseasset_gross
gen est=log(Est+1)
label var Est"家庭总房产（元）"
label var est"家庭总房产（元）对数" 

gen Land=land_asset
gen land=log(Land+1)
label var Land"土地资产（元）"
label var land"土地资产（元）对数" 

gen Nhd=nonhousing_debts
gen nhd=log(Nhd+1)
label var Nhd"非房贷的金融负债（元）"
label var nhd"非房贷的金融负债（元）对数" 

gen Asset=total_asset
gen asset=log(Asset+1)
label var Asset"家庭净资产（元）"
label var asset"家庭净资产（元）对数" 

egen Hast=rowtotal(otherhousevalue resivalue)
gen hast=log(Hast+1)
label var Hast"总房产市值（元）"
label var hast"总房产市值（元）对数"

gen exp=expense
label var exp"过去12个月总支出（元）"

gen give1=fp515 
gen give2=fp516
egen Give=rowtotal(give1 give2)
label var Give"给亲戚朋友的钱（元）"
gen give=log(Give+1)
label var give"给亲戚朋友的钱（元）对数"

gen fml=fml2014num
label var fml"家庭人口数"

recode ft3(1=1)(0=0),gen(h_loan1)
label var h_loan1"是否有房产负债"
recode ft4(1=1)(0=0),gen(h_loan2)
label var h_loan2"是否有房产负债"
gen h_loan=0
replace h_loan=1 if h_loan1==1
replace h_loan=1 if h_loan2==1
label var h_loan"是否有房产负债"

gen qtqk=0
replace qtqk=1 if nonhousing_debts>0 & nonhousing_debts!=.
label var qtqk"是否有非房产负债"

gen h_asset=houseasset_gross
label var h_asset"房屋资产"

gen mexp=med
label var mexp"医疗保健支出"

gen mexp1=fp511
label var mexp1"医疗支出"

gen eexp=fp510
label var eexp"教育支出"

gen fd=ft301*10000
label var fd"住房贷款"

gen fxzc=ft201
label var fxzc"风险资产"

recode fs3(1=1)(0 5=0)(79=.),gen(zd)
label var zd"是否经历征地 1=是 0=否"

gen zdbc=fs301
label var zdbc"征收土地补偿款"

rename fp503 travel
rename fp510 school

for var _all: replace X =. if inlist(X, -10, -9, -8, -2, -1)

//年份
gen year=2014
label variable year "年份"

rename ( provcd14 countyid14 urban14 fresp1pid )( provcd  countyid  urban  pid )

//1.总支出对数
gen lnconsume=ln(1+ expense )
label variable lnconsume "家庭总支出对数"

//2.总收入对数
gen lnincome=ln(1+  fincome2 )
label variable lnincome "家庭总收入对数"

//3.家庭人均支出
gen expense_p=0.0001*expense / familysize
label variable expense_p "家庭人均支出"

//4.家庭人均收入
gen income_p=  0.0001*fincome2/ familysize
label variable income_p "家庭人均收入"

//5.家庭净资产
sum total_asset
gen totalasset1=0.0001*total_asset
replace total_asset=totalasset1

//6.社会网络
rename fu201 social

//7.信贷约束
recode ft8 (1=1 "是") (5=0 "无") (79= . ),gen(limit)
label variable limit "信贷约束"

//8.创业
recode fm1 (1=1 "是") (5=0 "否") (79= . ),gen(entrep)
label variable entrep "创业"

//9.债务收入比
gen debt_p = ft501/ fincome2
label variable debt_p "债务收入比"

//10.金融资产
sum finance_asset

//11.存款
sum savings

//12.家庭收入
sum fincome2 fincome2_per



order year fid14 fid12 fid10 pid hhicd hhicd4 icd  provcd countyid urban pid lnconsume lnincome expense_p income_p total_asset social limit business debt_p finance_asset savings fincome1 fincome1_per finc pce  agri plant farm entrep get1 get2 Get get sav cas Soc soc t_inc1 inc1 Fin fin Fix fix Esta esta Est est Land land Nhd nhd Asset asset Hast hast exp give1 give2 Give  give fml house mor h_loan qtqk  mexp mexp1 eexp food dress house daily med trco eec other savings pce food food dress dress house travel school daily daily med med trco trco eec eec other other eptran eptran epwelf epwelf mortage mortage expense land_asset houseasset_gross houseasset_gross finance_asset finance_asset fixed_asset fixed_asset durables_asset durables_asset total_asset fxzc fd zd zdbc finc ft201 house_debts fwage foperate fproperty ftransfer company  nonhousing_debts fn101  resivalue


keep year fid14 fid12 fid10 pid hhicd hhicd4 icd  provcd countyid urban pid lnconsume lnincome expense_p income_p total_asset social limit business debt_p finance_asset savings fincome1 fincome1_per finc pce  agri plant farm entrep get1 get2 Get get sav cas Soc soc t_inc1 inc1 Fin fin Fix fix Esta esta Est est Land land Nhd nhd Asset asset Hast hast exp give1 give2 Give  give fml house mor h_loan qtqk  mexp mexp1 eexp food dress house daily med trco eec other savings pce food food dress dress house travel school daily daily med med trco trco eec eec other other eptran eptran epwelf epwelf mortage mortage expense land_asset houseasset_gross houseasset_gross finance_asset finance_asset fixed_asset fixed_asset durables_asset durables_asset total_asset fxzc fd zd zdbc finc ft201 house_debts fwage foperate fproperty ftransfer company  nonhousing_debts fn101  resivalue

save "D:\stata\CFPS原数据\2014\2014fameco.dta"


****2012****

//打开数据

use "D:\stata\CFPS原数据\2012\cfps2012famconf_092015.dta",clear

merge m:1 fid12 using "D:\stata\CFPS原数据\2012\cfps2012famecon_201906.dta",force

keep if _merge==3
drop _merge

sort fid12

br fid12 pid code_a_p fresp1

gen pid_1=code_a_p-100

gen pid_2=fresp1

keep if pid_1==pid_2

duplicates drop fid12,force

br fid12 pid code_a_p fresp1 pid_1 pid_2

keep fid12 pid fresp1

save "D:\stata\CFPS原数据\2012\cfps2012pid.dta",replace

use"D:\stata\CFPS原数据\2012\cfps2012pid.dta",clear

merge m:1 fid using "D:\stata\CFPS原数据\2012\cfps2012famecon_201906.dta",force

keep if _merge==3
drop _merge


//提取变量
keep     fid12 fid10 provcd countyid  urban12 pce expense  fincome2 fincome2_per total_asset  ft801  fm1 finance_asset savings   familysize    ft8_s_* fid12 fid10 fresp1 fk1l fl2 fm1 fn1_s_1 fn1_s_2 fn1_s_3 fn1_s_4 fn1_s_5 fn101_a_1 fn101_a_2 fn101_a_3 fn101_a_4 fn101_a_5 fn101_a_6 fn101_a_7 fn101_a_8 savings land_asset houseasset_gross finance_asset fixed_asset nonhousing_debts total_asset wage_1 wage_2 foperate_1 foperate_2 ftransfer_1 ftransfer_2 fproperty_1 fproperty_2 felse_1 felse_2 fincome1 fincome2 fincome1_per fincome2_per expense fs2 fs202  fs403 fs405 fp502 fn3 fn4 fn5 fn6 fp502 fr3 fq5 durables_asset fixed_asset fixed_asset finance_asset finance_asset houseasset_gross houseasset_gross land_asset land_asset med fp508 company savings house1_debts total_asset nonhousing_debts ind_debts bank_debts fp509 fq5 house_debts fq501_best fq501_best nonhousing_debts food dress house daily med trco eec other pid savings stock stock funds funds debit_other resivalue_new otherhousevalue pce food food dress dress house daily daily med med trco trco eec eec other other eptran eptran epwelf epwelf mortage mortage expense land_asset houseasset_gross houseasset_gross finance_asset finance_asset fixed_asset fixed_asset durables_asset durables_asset total_asset urban12 provcd countyid cid house_debts ft601 ft901 ft401 ft301 ft501 familysize fn202_a_1



label list

for var _all: replace X =. if inlist(X, -10, -9, -8, -2, -1)

recode fk1l(1 = 1 "是")(5 0 = 0 "否") (79=.),gen(agri1)

recode fl2(1 = 1 "是")(5 0 = 0 "否")(79 =.),gen(plant1)

recode fm1(1 = 1 "是")(5 0= 0 "否")(79=.),gen(business1)

recode fk1l(1 = 1 )(5 0= 0 )(79=.) ,gen(agri)
label var agri"是否从事农林牧副渔工作 1=是 0=否"
recode fl2(1 = 1 )(5 0= 0 )(79=.),gen(plant)
label var plant"是否从事种植业林业 1=是 0=否"

recode fm1(1 = 1 )(5 0= 0 )(79=.),gen(business)
label var business"是否有人从事工商业 1=是 0=否"

gen get1=fn3 
gen get2=fn4
egen Get=rowtotal(get1 get2)
label var Get"亲戚朋友给的钱（元）"
gen get=log(Get+1)
label var get"亲戚朋友给的钱（元）对数"

gen give1=fn5 
gen give2=fn6
egen Give=rowtotal(give1 give2)
label var Give"给亲戚朋友的钱（元）"
gen give=log(Give+1)
label var give"给亲戚朋友的钱（元）对数"

gen sav=savings
gen cas=log(savings+1)
label var sav"现金及其存款总额"
label var cas"现金及其存款对数"

gen t_inc1=fincome1
label var t_inc1"全部家庭纯收入"
gen t_inc2=fincome2
label var t_inc2"全部家庭纯收入（与2010年可比）"

gen inc1=fincome1_per
label var inc1"人均家庭纯收入"
gen inc2=fincome2_per
label var inc2"人均家庭纯收入（与2010年可比）"

gen Fin=finance_asset
gen fin=log(Fin+1)
label var Fin"家庭总金融资产（元）"
label var fin"家庭总金融资产（元）对数" 

gen Fix=fixed_asset
gen fix=log(Fix+1)
label var Fix"生产性固定资产（元）"
label var fix"生产性固定资产（元）对数" 

gen Est=houseasset_gross
gen est=log(Est+1)
label var Est"家庭总房产（元）"
label var est"家庭总房产（元）对数" 

gen Land=land_asset
gen land=log(Land+1)
label var Land"土地资产（元）"
label var land"土地资产（元）对数" 

gen Nhd=nonhousing_debts
gen nhd=log(Nhd+1)
label var Nhd"非房贷的金融负债（元）"
label var nhd"非房贷的金融负债（元）对数" 

gen Asset=total_asset
gen asset=log(Asset+1)
label var Asset"家庭净资产（元）"
label var asset"家庭净资产（元）对数" 

gen exp=expense
label var exp"过去12个月总支出（元）"

recode fq5(1=1)(0=0),gen(h_loan)
label var h_loan"是否有房产负债"

gen qtqk=0
replace qtqk=1 if nonhousing_debts>0 & nonhousing_debts!=.
label var qtqk"是否有非房产负债"

gen mexp=med
label var mexp"医疗保健支出"

gen mexp1=fp509
label var mexp1"医疗支出"

gen eexp=fp508
label var eexp"教育支出"

gen jiaoyu=eexp/exp
label var jiaoyu"教育支出占比"

egen fxzc=rowtotal(ft601 ft401 ft301 ft501)
label var fxzc"风险资产"

gen zd=0
replace zd=1 if fn202_a_1!=. & fn202_a_1>0
label var zd"是否经历征地 1=是 0=否"

gen fml=familysize

rename fresp1 fresp1pid

rename wage_1 fwage 
rename foperate_1 foperate
rename fproperty_1 fproperty
rename ftransfer_1 ftransfer

for var _all: replace X =. if inlist(X, -10, -9, -8, -2, -1)

//年份
gen year=2012
label variable year "年份"

rename   urban12   urban

//1.总支出对数
gen lnconsume=ln(1+ expense )
label variable lnconsume "家庭总支出对数"

//2.总收入对数
gen lnincome=ln(1+ fincome2 )
label variable lnincome "家庭总收入对数"

//3.家庭人均支出
gen expense_p=0.0001*expense / familysize
label variable expense_p "家庭人均支出"

//4.家庭人均收入
gen income_p= 0.0001*fincome2/ familysize
label variable income_p "家庭人均收入"

//5.家庭净资产
sum total_asset
gen totalasset1=0.0001*total_asset
replace total_asset=totalasset1

//6.社会网络
 

//7.信贷约束
gen limit=1
for var ft8_s_*: replace limit= 0 if X ==1
label variable limit "信贷约束"

//8.创业
recode fm1 (1=1 "是") (5=0 "否") (79= . ),gen(entrep)
label variable entrep "创业"

//9.债务收入比
gen debt_p = ft801/  fincome2
label variable debt_p "债务收入比"

//10.金融资产
sum finance_asset

//11.存款
sum savings

//12.家庭收入
sum fincome2 fincome2_per

rename fp502 travel
rename fp508 school
rename resivalue_new resivalue

gen fn101=fn101_a_1+ fn101_a_2+ fn101_a_3+ fn101_a_4+ fn101_a_5+ fn101_a_6+ fn101_a_7+ fn101_a_8

order year fid12 fid10 pid  provcd countyid urban pid lnconsume lnincome expense_p income_p total_asset  limit business debt_p finance_asset savings fincome1 fincome1_per pce  agri plant entrep get1 get2 Get get sav cas t_inc1 inc1 Fin fin Fix fix  Est est Land land Nhd nhd Asset asset exp give1 give2 Give  give fml house mor h_loan qtqk  mexp mexp1 eexp food dress house daily med trco eec other savings pce food food dress dress house travel school daily daily med med trco trco eec eec other other eptran eptran epwelf epwelf mortage mortage expense land_asset houseasset_gross houseasset_gross finance_asset finance_asset fixed_asset fixed_asset durables_asset durables_asset total_asset fxzc zd  house_debts fwage foperate fproperty ftransfer company  nonhousing_debts fn101  resivalue

keep year fid12 fid10 pid  provcd countyid urban pid lnconsume lnincome expense_p income_p total_asset  limit business debt_p finance_asset savings fincome1 fincome1_per pce  agri plant entrep get1 get2 Get get sav cas t_inc1 inc1 Fin fin Fix fix  Est est Land land Nhd nhd Asset asset exp give1 give2 Give  give fml house mor h_loan qtqk  mexp mexp1 eexp food dress house daily med trco eec other savings pce food food dress dress house travel school daily daily med med trco trco eec eec other other eptran eptran epwelf epwelf mortage mortage expense land_asset houseasset_gross houseasset_gross finance_asset finance_asset fixed_asset fixed_asset durables_asset durables_asset total_asset fxzc zd  house_debts fwage foperate fproperty ftransfer company  nonhousing_debts fn101  resivalue

save "D:\stata\CFPS原数据\2012\2012fameco.dta"


****2010****

//打开数据

use "D:\stata\CFPS原数据\2010\cfps2010famconf_202008.dta" ,clear

merge m:1 fid using "D:\stata\CFPS原数据\2010\cfps2010famecon_202008.dta",force

keep if _merge==3
drop _merge

sort fid

br fid pid code_a_p tb7

gen pid_1=code_a_p-100

gen pid_2=tb7

keep if pid_1==pid_2

duplicates drop fid,force

br fid pid code_a_p tb7 pid_1 pid_2

keep fid pid tb7

save "D:\stata\CFPS原数据\2010\cfps2010pid.dta",replace

use"D:\stata\CFPS原数据\2010\cfps2010pid.dta",clear

merge m:1 fid using "D:\stata\CFPS原数据\2010\cfps2010famecon_202008.dta",force

keep if _merge==3
drop _merge


//提取变量
keep     fid  provcd countyid urban pce expense  faminc_net indinc_net total_asset fc301 fh2_s_* fe3  fh201_a_*  savings   familysize tb7 stock  funds fid fe202 fe2_s_1 fe2_s_2 fe2_s_3 fe3 ff2 ff601 fg4 ff8 fh601 fk5 tb7 familysize inc_agri net_agri finc firm fproperty welfare felse faminc_old faminc faminc_net indinc indinc_net foperate foperate_net land_asset savings stock funds total_asset expense fk1 firm fe5 fe501 fh303 fh405 fh404  dress house_debts nonhousing_debts med fh404 fh202_s_1 fh202_s_2 fh202_s_3 fh202_s_4 fh202_s_5 otherhousevalue resivalue_new stock funds debit_other food dress house daily trco eec med other pid otherasset land_asset total_asset company savings stock stock funds funds debit_other resivalue_new otherhousevalue pce food food dress dress house daily daily med med trco trco eec eec other other eptran eptran epwelf epwelf mortage mortage expense fe9 fe902 


label list

for var _all: replace X =. if inlist(X, -10, -9, -8, -2, -1)

recode fk1(1 = 1 "是")(5 0 = 0 "否") (79 = .),gen(agri1)

recode fe3(1 = 1 "是")(5 0= 0 "否") (79 = .),gen(business1)

recode fe5(1 = 1 "是")(5 0= 0 "否") (79 = .),gen(out1)

recode fk1(1 = 1 )(5 0= 0 ) (79=.),gen(agri)
label var agri"是否从事农林牧副渔工作 1=是 0=否"

recode fe3(1 = 1 )(5 0= 0 )(79=.),gen(business)
label var business"是否有人从事工商业 1=是 0=否"

gen sav=savings
gen cas=log(savings+1)
label var sav"现金及其存款总额"
label var cas"现金及其存款对数"

gen Soc=ff8
gen soc=log(Soc+1)
label var Soc"社会关系  人情支出礼"
label var soc"社会关系  人情支出礼对数"

gen t_inc1=faminc_net
label var t_inc1"全部家庭纯收入"
gen inc1=indinc_net
label var inc1"人均家庭纯收入"

gen Land=land_asset
gen land=log(Land+1)
label var Land"土地资产（元）"
label var land"土地资产（元）对数" 

gen Asset=total_asset
gen asset=log(Asset+1)
label var Asset"家庭净资产（元）"
label var asset"家庭净资产（元）对数" 

gen exp=expense
label var exp"过去12个月总支出（元）"

gen fml=familysize
label var fml"家庭人口数"

des fh202_s_*
label list fh202_s_1

gen h_loan=0
gen qtqk=0

for var fh202_s_*: replace h_loan = 1 if X ==1 
for var fh202_s_*: replace qtqk = 1 if  X == 2 | X ==3 | X == 4 | X==5 |X==77

label var h_loan"是否有房产负债"
label var qtqk"是否非房产负债"

gen mexp=med
label var mexp"医疗保健支出"

gen eexp=fh404
label var eexp"教育支出"

gen jiaoyu=eexp/exp
label var jiaoyu"教育支出占比"

egen fxzc=rowtotal(stock funds)
label var fxzc"风险资产"

recode fe9(1=1)(0 5=0)(79=.),gen(zd)
label var zd"是否经历征地 1=是 0=否"

gen zdmj=fe902
label var zdmj"征地面积"

rename tb7 fresp1pid 
rename fid fid10

for var _all: replace X =. if inlist(X, -10, -9, -8, -2, -1)


rename (faminc_net indinc_net)( fincome2 fincome2_per )
//年份
gen year=2010
label variable year "年份"


//1.总支出对数
gen lnconsume=ln(1+ expense )
label variable lnconsume "家庭总支出对数"

//2.总收入对数
gen lnincome=ln(1+ fincome2)
label variable lnincome "家庭总收入对数"

//3.家庭人均支出
gen expense_p=0.0001*expense / familysize
label variable expense_p "家庭人均支出"

//4.家庭人均收入
gen income_p= 0.0001*fincome2/ familysize
label variable income_p "家庭人均收入"

//5.家庭净资产
sum total_asset
gen totalasset1=0.0001*total_asset
replace total_asset=totalasset1

//6.社会网络
rename  fc301 social

//7.信贷约束
gen limit=1
for var fh2_s_* : replace limit= 0 if X ==1
label variable limit "信贷约束"

//8.创业
rename fe3 entrep
label variable entrep "创业"

//9.债务收入比
gen debt_p = (fh201_a_1+ fh201_a_3 +fh201_a_5+ fh201_a_6)/ fincome2 
label variable debt_p "债务收入比"

//10.金融资产（不准确，有待确认）
gen finance_asset= stock + funds +savings

//11.存款
sum savings

//12.家庭收入
sum fincome2 fincome2_per

gen school = eexp
rename finc fwage
rename welfare ftransfer

rename fincome2 fincome1
rename fincome2_per fincome1_per
rename fk1 plant 
rename fe202 fn101
rename resivalue_new resivalue

order year fid10 pid  provcd countyid urban pid lnconsume lnincome expense_p income_p total_asset  limit business debt_p finance_asset savings fincome1 fincome1_per pce  agri plant entrep  sav cas t_inc1 inc1 Land land Asset asset exp  fml house mor h_loan qtqk  mexp  eexp food dress house daily med trco eec other savings pce food food dress dress house  school daily daily med med trco trco eec eec other other eptran eptran epwelf epwelf mortage mortage expense land_asset  finance_asset finance_asset  total_asset fxzc zd  house_debts fwage foperate fproperty ftransfer company  nonhousing_debts fn101  resivalue

keep year fid10 pid  provcd countyid urban pid lnconsume lnincome expense_p income_p total_asset  limit business debt_p finance_asset savings fincome1 fincome1_per pce  agri plant entrep  sav cas t_inc1 inc1 Land land Asset asset exp  fml house mor h_loan qtqk  mexp  eexp food dress house daily med trco eec other savings pce food food dress dress house  school daily daily med med trco trco eec eec other other eptran eptran epwelf epwelf mortage mortage expense land_asset  finance_asset finance_asset  total_asset fxzc zd  house_debts fwage foperate fproperty ftransfer company  nonhousing_debts fn101  resivalue

save "D:\stata\CFPS原数据\2010\2010fameco.dta"


/*==================================================
              4: 合并
==================================================*/
**merge
*2022
use "D:\stata\CFPS原数据\2022\2022fameco.dta",clear
merge m:1 fid22 pid using D:\stata\CFPS原数据\2022\2022famcof.dta,keep(3) nogen
merge m:1 fid22 pid using D:\stata\CFPS原数据\2022\2022adult.dta,keep(3) nogen
save "D:\stata\CFPS原数据\2022\2022cfps.dta"

*2020
use "D:\stata\CFPS原数据\2020\2020fameco.dta",clear
merge m:1 fid20 pid using D:\stata\CFPS原数据\2020\2020famcof.dta,keep(3) nogen
merge m:1 fid20 pid using D:\stata\CFPS原数据\2020\2020adult.dta,keep(3) nogen
save "D:\stata\CFPS原数据\2020\2020cfps.dta"

*2018
use "D:\stata\CFPS原数据\2018\2018fameco.dta",clear
merge m:1 fid18 pid using D:\stata\CFPS原数据\2018\2018famcof.dta,keep(3) nogen
merge m:1 fid18 pid using D:\stata\CFPS原数据\2018\2018adult.dta,keep(3) nogen
save "D:\stata\CFPS原数据\2018\2018cfps.dta"

*2016
use "D:\stata\CFPS原数据\2016\2016fameco.dta",clear
merge m:1 fid16 pid using D:\stata\CFPS原数据\2016\2016famcof.dta,keep(3) nogen
merge m:1 fid16 pid using D:\stata\CFPS原数据\2016\2016adult.dta,keep(3) nogen
save "D:\stata\CFPS原数据\2016\2016cfps.dta"

*2014
use "D:\stata\CFPS原数据\2014\2014fameco.dta",clear
merge m:1 fid14 pid using D:\stata\CFPS原数据\2014\2014famcof.dta,keep(3) nogen
merge m:1 fid14 pid using D:\stata\CFPS原数据\2014\2014adult.dta,keep(3) nogen
save "D:\stata\CFPS原数据\2014\2014cfps.dta"

*2012
use "D:\stata\CFPS原数据\2012\2012fameco.dta"
merge m:1 fid12 pid using D:\stata\CFPS原数据\2012\2012famcof.dta,keep(3) nogen
merge m:1 fid12 pid using D:\stata\CFPS原数据\2012\2012adult.dta,keep(3) nogen
save 5.2012cfps.dta,replace 

*2010
use "D:\stata\CFPS原数据\2010\2010fameco.dta",clear
merge m:1 fid10  pid using D:\stata\CFPS原数据\2010\2010famcof.dta,keep(3) nogen
merge m:1 fid10  pid using D:\stata\CFPS原数据\2010\2010adult.dta,keep(3) nogen
rename fid fid10
save "D:\stata\CFPS原数据\2010\2010cfps.dta"


**append
use "D:\stata\CFPS原数据\2022\2022cfps.dta",clear
append using D:\stata\CFPS原数据\2020\2020cfps.dta
append using D:\stata\CFPS原数据\2018\2018cfps.dta
append using D:\stata\CFPS原数据\2016\2016cfps.dta
append using D:\stata\CFPS原数据\2014\2014cfps.dta
append using D:\stata\CFPS原数据\2012\2012cfps.dta
append using D:\stata\CFPS原数据\2010\2010cfps.dta
merge m:1 countyid using D:\stata\CFPS原数据\顺序码匹配.dta, nogen
label var provname	"受访所在省份"
label var cityname	"受访所在城市"
label var countyname	"受访所在区县"
save D:\stata\CFPS原数据\2010-2022cfps非平衡面板数据.dta,replace


/* End of do-file */


