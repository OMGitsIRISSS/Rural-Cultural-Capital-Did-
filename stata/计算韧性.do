// 定义全局宏变量

global c fid10 fid20 fid18 fid16 fid14 fid12 社会捐赠 做饭用水 做饭燃料 农业机械价值 离退休或养老金 商业性保险 自家农副产品消费总值 受访者主要语言 借钱困难程度 人情礼支出 土地资产 低风险金融资本 高风险金融资本 人均家庭纯收入 家庭总房产 耐用消费品价值 是否从是农林牧副渔工作 是否养过牲畜或水产品 网络学习 eexp edu

// 然后运行原始代码

qui sum year
global min_year=r(min)
global max_year=r(max)




forvalues year=$min_year / $max_year{
	use"C:\Users\utopia\Desktop\区县码+区县名称+2010_2020熵值法数据.dta", clear
	keep if year==`year'

	//标准化数据 正向指标
	
	foreach i in $c {
		qui sum `i'
		gen x_`i'=(`i'-r(min))/(r(max)-r(min))
		replace x_`i'=0.00001 if x_`i'==0
	}
	
	
	//计算指标比重
	
	foreach i in $c {
		egen `i'_sum=sum(x_`i')
		gen y_`i'=x_`i'/`i'_sum
	}

	//计算信息熵
	
	gen n=_N

	foreach i in $c {
		gen y_lny_`i'=y_`i'*ln(y_`i')
	}

	
	//求和
	
	foreach i in $c {
		egen y_lny_`i'_sum=sum(y_lny_`i')
	}

	
	//计算各指标的贡献总量
	
	foreach i in $c {
		gen E_`i'= -1/ln(n)*y_lny_`i'_sum
	}

	//计算指标权重
	
	foreach i in $c {
		gen d_`i'= 1-E_`i'
	}
	
	egen d_sum = rowtotal(d_*)
	foreach i in $c {
		gen W_`i'= d_`i'/d_sum
	}
	
	//计算综合得分
	
	foreach i in $c {
		gen Score_`i'= x_`i'*W_`i'
	}
	
	
	egen Score=rowtotal(Score_*)

	keep fid10 year countyname provname $c Score
	save data_`year', replace
}

clear
forvalues i= $min_year / $max_year {
   append using data_`i'
   rm data_`i'.dta
}


       //***********后续分析************//

// 对数转换（处理右偏）

gen log_Score = ln(Score + 0.00001)  

// 避免对0取对数




sort fid10 year
save "C:\Users\utopia\Desktop\entropy_result.dta", replace