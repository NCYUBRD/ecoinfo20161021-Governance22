#先清除之前的背景資料，並建立ts表示寫code的日期、時間
rm(list = ls())
ts <- 2016111815

#1. 讀取資料����
#利用d�data.table讀取資料��
library(data.table)

#設立工作目錄，以便在此目錄中進行指令的撰寫和操作
setwd("c:\\Users/admin/Desktop/raw/")

#建立空的檔案空間，將目錄中所有檔案的data放進去
list <- list.files('.')
wed <- list()

#計算讀入空檔案中的檔案數為多少
length(list)




#2. 資料的初步整理
#利用for迴圈將資料中為��-9991, -9995, -9996, -9997, -9998, -9999的錯誤數值改為NA
for(i in 1:length(list)){ wed[[i]] <- fread (list[i],
  skip = 75,
  na.strings = c('-9991', '-9995', '-9996', '-9997', '-9998', '-9999'))
      }

#利用rbind將資料表格一個個往下疊加合併起來
for (i in 2:length(list)){
  wed[[1]] <- rbind(wed[[1]], wed[[i]])
}

#設定1~9的欄名
setnames(wed[[1]], 1:9,
         c('stno', 'yyyymmddhh', 'PSO1', 'TX01', 'RH01',
           'WD01', 'WD02', 'PP01', 'SS01'))

#將yyyymmddhh此欄的數值減去一小時，以避免程式忽略顯示為第24小時的資料
wed[[1]]$yyyymmddhh <- wed[[1]]$yyyymmddhh-1

#將yyyymmddhh此欄的數值轉換為時間戳記的格式，並設立時間戳記一欄
wed[[1]][, timestamp:= as.POSIXct (strptime(yyyymmddhh, '%Y%m%d%H'))]

#從yyyymmddhh一欄中只選取年、月、日的資料，並獨立為day一欄
wed[[1]][, day:= as.POSIXct (strptime(yyyymmddhh, '%Y%m%d'))]

#自yyyymmddhh中選取年、月的資料，並獨立出來成mon一欄
wed[[1]][, mon:= format.Date(timestamp, '%Y-%m')]
#以上完成資料的整理



#問題：
#(1)計算2006至2015年的每日平均氣溫：
#建立平均值的計算公式
mean_omit_na <- function(x){
  x <- as.numeric(x)
  return(mean(x, na.rm = T))
}

#利用�災ggregat聚合計算day欄data相同者在T�TX01欄data的平均值
#將所計算出的數值建立DAYTX一表格，表格內容即為每日的平均氣溫
DAYTX <- aggregate(wed[[1]]$TX01, by = list(wed[[1]]$day), FUN = mean_omit_na)


#(2)計算2006至2015年的每日平均氣溫：
#利用�災ggregat聚合計算mon欄data相同者在T�TX01欄data的平均值
#將所計算出的數值建立MONTHTX一表格，表格內容即為每月的平均氣溫
MONTHTX <- aggregate(wed[[1]]$TX01, by = list(wed[[1]]$mon), FUN = mean_omit_na)


#(3)計算2006至2015年的每日最高溫的平均：
#建立最大值的計算公式
MAX <- function(x){
  x <- as.numeric(x)
  return(max(x, na.rm = T))
}

#利用�災ggregat聚合計算day欄data相同者在T�TX01欄data的最大值
#將所計算出的數值建立MAXDAY一表格，表格內容即為每日的最高溫
MAXDAY <- aggregate(wed[[1]]$TX01, by = list (wed[[1]]$day), FUN = MAX)

#將MAXDAY的資料轉換成data.frame的格式，並命名成新的表格──MAXDAYdf
MAXDAYdf <- data.frame(MAXDAY)

#以計算平均值的公式，讀取、計算MAXDATdf第二欄的資料，所得數值命名成meanMAXDAY
meanMAXDAY <- mean(MAXDAYdf[,2])

#meanMAXDAY即為2006至2015年的每日最高溫的平均
list(meanMAXDAY)


#(4)計算2006至2015年的每日最低溫的平均：
#建立最小值的計算公式
MIN <- function(x){
  x <- as.numeric(x)
  return(min(x, na.rm = T))
}

#利用�災ggregat聚合計算day欄data相同者在T�TX01欄data的最小值
#將所計算出的數值建立MINDAY一表格，表格內容即為每日的最低溫
MINDAY <- aggregate(wed[[1]]$TX01, by = list (wed[[1]]$day), FUN = MIN)

#將MINDAY的資料轉換成data.frame的格式，並命名成新的表格──MINDAYdf
MINDAYdf <- data.frame(MINDAY)

#以計算平均值的公式，讀取、計算MINDATdf第二欄的資料，所得數值命名成meanMINDAY
meanMINDAY <- mean(MINDAYdf[,2])

#meanMAXDAY即為2006至2015年的每日最低溫的平均
list(meanMINDAY)


#(5)計算2006至2015年平均每月累積降水：
#建立計算累加值的公式
SUM <- function(x){
  x <- as.numeric(x)
  return(sum(x, na.rm = T))
}

#利用�災ggregat聚合計算mon欄data相同者在PPX01欄data的累加值
#將所計算出的數值建立SUMMONTH一表格，表格內容即為每月的累累ㄐ累積計雨量
SUMMONTH <- aggregate(wed[[1]]$PP01, by = list (wed[[1]]$mon), FUN = SUM)

#將SUMMONTH的資料轉換成data.frame的格式，並命名成新的表格──SUMMONTHdf
SUMMONTHdf <- data.frame(SUMMONTH)

#以計算平均值的公式，讀取、計算SUMMONTHdf第二欄的資料，所得數值命名成meanSUMMONTH
meanSUMMONTH <- mean(SUMMONTHdf[,2])

#meanSUMMONTH即為2006至2015年每月累積雨量的平均
list(meanSUMMONTH)


#(6)計算最暖月的每日最高溫平均：
#將記載每月平均氣溫的表格──MONTHTX轉匯成data.frame的格式
MONTHTXdf <- data.frame(MONTHTX)

#對MONTHTXdf中記載每月平均氣溫的x欄進行排序，最後一項為最大值
#並建立新表格──orderedMONTHTXdf
orderedMONTHTXdf <- setorder(MONTHTXdf,x)

#讀取記載年月份的第一欄最後一項的數值，此即為最暖月的年月份
orderedMONTHTXdf[length(list),1]



#利用�狄read讀取orderedMONTHTXdf[length(list),1]所得出的最暖月的年月份的氣象資料
#code寫法應為fread("c:\\Users/admin/Desktop/raw/最暖月的氣象資料檔案名", ......)
#將資料中為��-9991, -9995, -9996, -9997, -9998, -9999的錯誤數值改為NA
MAXMONTHdayTX <- fread("c:\\Users/admin/Desktop/raw/", 
                       skip = 75,
                       na.strings = c('-9991', '-9995', '-9996', '-9997', '-9998', '-9999'))

#設定1~9欄的欄名
setnames(MAXMONTHdayTX, 1:9,
         c('stno', 'yyyymmddhh', 'PSO1', 'TX01', 'RH01',
           'WD01', 'WD02', 'PP01', 'SS01'))

#將yyyymmddhh此欄的數值減去一小時，以避免程式忽略顯示為第24小時的資料
MAXMONTHdayTX$yyyymmddhh <- MAXMONTHdayTX$yyyymmddhh-1

#將yyyymmddhh此欄的數值轉換為時間戳記的格式，並設立時間戳記一欄
MAXMONTHdayTX[, timestamp:= as.POSIXct (strptime(yyyymmddhh, '%Y%m%d%H'))]

#從yyyymmddhh一欄中只選取年、月、日的資料，並獨立為day一欄
MAXMONTHdayTX[, day:= as.POSIXct (strptime(yyyymmddhh, '%Y%m%d'))]

#利用�災ggregat聚合計算day欄data相同者在TX01欄data的最大值
#建立一表格──MAXMONTHdayMAXTX，記載最暖月的每日最高溫
MAXMONTHdayMAXTX <- aggregate(MAXMONTHdayTX$TX01, by = list(MAXMONTHdayTX$day), FUN = MAX)


#使用計算平均值的公式計算MAXMONTHdayMAXTX第二欄的data，也就是對最暖月的每日最高溫做平均計算
lastMAXanswer <- mean(MAXMONTHdayMAXTX[,2])

#計算出的最後結果即為最暖月的每日最高溫平均
lastMAXanswer 


#(7)計算最冷月的每日最低溫平均：
#承續問題(6)，對MONTHTXdf中記載每月平均氣溫的x欄進行排序，第一項為最小值
#建立新表格──orderedMONTHTXdf
#讀取orderedMONTHTXdf的第一項第一列data即是最冷月的年月份
orderedMONTHTXdf[1,1]

#利用�狄read讀取orderedMONTHTXdf[1,1]所得出的最冷月的年月份的氣象資料
#code寫法應為fread("c:\\Users/admin/Desktop/raw/最冷月的氣象資料檔案名", ......)
#將資料中為��-9991, -9995, -9996, -9997, -9998, -9999的錯誤數值改為NA
MINMONTHdayTX <- fread("c:\\Users/admin/Desktop/raw/", 
                       skip = 75,
                       na.strings = c('-9991', '-9995', '-9996', '-9997', '-9998', '-9999'))

##設定1~9欄的欄名
setnames(MINMONTHdayTX, 1:9,
         c('stno', 'yyyymmddhh', 'PSO1', 'TX01', 'RH01',
           'WD01', 'WD02', 'PP01', 'SS01'))

#將yyyymmddhh此欄的數值減去一小時，以避免程式忽略顯示為第24小時的資料
MINMONTHdayTX$yyyymmddhh <- MINMONTHdayTX$yyyymmddhh-1

#將yyyymmddhh此欄的數值轉換為時間戳記的格式，並設立時間戳記一欄
MINMONTHdayTX[, timestamp:= as.POSIXct (strptime(yyyymmddhh, '%Y%m%d%H'))]

#從yyyymmddhh一欄中只選取年、月、日的資料，並獨立為day一欄
MINMONTHdayTX[, day:= as.POSIXct (strptime(yyyymmddhh, '%Y%m%d'))]

#利用�災ggregat聚合計算day欄data相同者在TX01欄data的最小值
#建立一表格──MINMONTHdayMINTX，記載最冷月的每日最低溫
MINMONTHdayMINTX <- aggregate(MINMONTHdayTX$TX01, by = list(MINMONTHdayTX$day), FUN = MIN)

##使用計算平均值的公式計算MINMONTHdayMINTX第二欄的data，也就是對最冷月的每日最低溫做平均計算
lastMINanswer <- mean(MINMONTHdayMINTX[,2])

#計算出的最後結果即為最冷月的每日最低溫平均
lastMINanswer 












