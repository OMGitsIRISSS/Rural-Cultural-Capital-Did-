*-----------------------------
* 1. 基本统计特征分析
*-----------------------------
// 查看整体分布


sum Score, detail
histogram Score, frequency normal title("综合得分分布") 

//直方图

// 分年度分析

bysort year: sum Score, detail
table year, c(mean Score sd Score min Score max Score)

 //年度统计表

// 分地区分析（假设有province变量）

bysort province: sum Score, detail
table province year, c(mean Score) format(%9.3f) 

//地区年度得分矩阵


*-----------------------------
* 2. 得分验证性分析
*-----------------------------
// 验证与原始指标的相关性（预期应有合理相关性）


pwcorr Score $c, star(0.05)

// 

twoway (scatter Score 人均家庭纯收入) (lfit Score 人均家庭纯收入), ///
       title("得分与收入关系")

*-----------------------------
* 3. 异常值检测
*-----------------------------
// 识别前1%和后1%的极端值

xtile score_rank = Score, nq(100)
list id year Score if inlist(score_rank,1,100), sep(0)


// 按得分四分位数分组


xtile Score_group = Score, nq(4)


// 核密度图对比


kdensity Score, normal title("Score分布核密度估计")




// 绘制箱线图

graph box Score, over(year) ytitle(综合得分) title("年度得分分布箱线图")

*-----------------------------
* 4. 权重合理性验证
*-----------------------------
// 查看权重分布

tabstat w_*, stats(mean sd min max) col(stat)

// 绘制权重雷达图（需安装radar包）

ssc install radar
radar w_*, title(指标权重分布) rlabel(0(0.1)0.5)

*-----------------------------
* 5. 动态趋势分析
*-----------------------------
// 生成地区年度平均得分

preserve
collapse (mean) mean_score=Score (sd) sd_score=Score, by(province year)

// 绘制趋势图

xtset province year
xtline mean_score, overlay legend(off) title("各地区得分趋势")
restore

*-----------------------------
* 6. 分层分析（示例按得分四分位数分组）
*-----------------------------

xtile score_group = Score, nq(4)
label define sg 1 "低水平" 2 "中下水平" 3 "中上水平" 4 "高水平"
label values score_group sg

// 比较组间差异

tabstat $c, by(score_group) stats(mean sd) nototal

*-----------------------------
* 7. 空间可视化（需地理信息数据）
*-----------------------------
// 假设有省份经纬度数据

spmap Score using "china_coordinates.dta", id(province) ///
       clmethod(quantile) cln(5) title("综合得分空间分布")