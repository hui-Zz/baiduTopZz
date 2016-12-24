;#############################
;##	 百度搜索风云榜资讯爬虫	##
;##	baiduTopZz2 v2 20160408	##
;#############################
#NoEnv ;不检查空变量为环境变量
#SingleInstance,Force ;运行替换旧实例
FileEncoding,CP936 ;文件以中文编码加载
SetWorkingDir %A_ScriptDir% ;脚本当前工作目录
#Include *i %A_ScriptDir%\html代码识别.ahk ;引用html代码识别函数
;#################
;##自定义修改变量##
;#################
oldsList=oldsList  ;（★[历史资讯]保留用于比较今日去除重复资讯）
fileName=TopZz  ;（★存放今日资讯文件名字）
filePath=%A_Temp%  ;（★存放今日更新网页的缓存目录）
newsFile=%filePath%\%fileName%News.html  ;（★存放比较结果的未读资讯网页文件,手动打开请改为桌面等路径）
showWeb:=0  ;（★是否自动展示资讯:0为自动模式,有未读才展示；1为始终自动展示；2为手动,始终不展示）
IfNotExist %filePath%
	FileCreateDir,%filePath%
;###############
;##下载今日资讯##
;###############
newsList:=Object()  ;存放资讯类别排行榜数组
newsList.Insert("今日热门搜索排行榜")
URLDownloadToFile,http://top.baidu.com/buzz?b=2&c=12&fr=topbuzz_b2_c12,%filePath%\%fileName%1.html
newsList.Insert("今日电影排行榜")
URLDownloadToFile,http://top.baidu.com/buzz?b=26&c=1&fr=topcategory_c1,%filePath%\%fileName%2.html
newsList.Insert("今日世说新词排行榜")
URLDownloadToFile,http://top.baidu.com/buzz?b=396&fr=topboards,%filePath%\%fileName%3.html
newsList.Insert("七日热点排行榜")
URLDownloadToFile,http://top.baidu.com/buzz?b=42&c=513&fr=topbuzz_b1_c513,%filePath%\%fileName%4.html
;（★新增排行格式★）
;newsList.Insert("排行榜标题")
;URLDownloadToFile,排行榜网址,%filePath%\%fileName%5(序号).html
;（★复制上面两行添加★）

;###################
;##未读资讯比较生成##
;###################
IfExist %newsFile%  ;如果已有则删除
	FileDelete,%newsFile%
FileAppend,<style>a{padding-right:20px;line-height:25px;}td{border-right:1px dashed #000;}input{cursor:pointer;}</style>`n,%newsFile%  ;写入网页简单样式头
Loop,% newsList.MaxIndex() ;循环比较newsList里所有类别资讯排行榜
{
	Z_Index:=A_Index
	olds=""
	IfExist %A_ScriptDir%\%oldsList%%Z_Index%.html
		FileRead,olds,%A_ScriptDir%\%oldsList%%Z_Index%.html ;[历史资讯]读取比较
	else
		MsgBox,初始化%A_ScriptDir%\%oldsList%%Z_Index%.html
	FileRead,news,%filePath%\%fileName%%Z_Index%.html  ;读取今日资讯网页来比较
	If A_DD=01
		FileAppend,<h2>%A_YYYY%%A_MM%</h2>`n,%A_ScriptDir%\%oldsList%%Z_Index%.html  ;[历史资讯]新的一个月月份
	FileAppend,% "<h1>"newsList[Z_Index]"",%newsFile%  ;写入资讯类别排行榜标题
	FileAppend,% "<input type='button' value='全选' onclick='CheckAll(" Z_Index-1 ")'/>",%newsFile%  ;写入选择按钮
	FileAppend,% "<input type='button' value='不选' onclick='UnCheck(" Z_Index-1 ")'/>",%newsFile%
	FileAppend,% "<input type='button' value='反选' onclick='OtherCheck(" Z_Index-1 ")'/>",%newsFile%
	FileAppend,% "<input type='button' value='打开' onclick='OpenCheck(" Z_Index-1 ")'/></h1>`n",%newsFile%
	FileAppend,<table border='0' cellpadding='0' cellspacing='0'>`n,%newsFile%
	FileAppend,<tr>`n,%newsFile%
	T_Index:=0
	Loop
	{
		titles:=GetNestedTag(news,"<a class=""list-title""",A_Index)  ;（★根据html代码条件查找，详细用法可在html代码识别.ahk）
		if(titles=""){
			FileAppend,</tr>`n,%newsFile%
			break  ;资讯未找到或已找完，退出循环
		}
		finds:=GetNestedTag(olds,titles)  ;根据历史已读资讯标题来查找，未找到则加入今日资讯网页
		if(finds=""){
			T_Index+=1
			showWeb:=(showWeb=0) ? 1 : showWeb
			FileAppend,<td onclick='tdCheck(this);'><input type='checkbox' onclick='this.checked=1==this.checked?!1:!0;' />,%newsFile%
			titles.="</td>`n"
			FileAppend,%titles%,%newsFile%
			FileAppend,%titles%,%A_ScriptDir%\%oldsList%%Z_Index%.html  ;[历史资讯]存档
			if (mod(T_Index,5)=0)
				FileAppend,</tr><tr>`n,%newsFile%
		}
	}
	FileAppend,</table>`n,%newsFile%
}
; 写入网页JS脚本
FileAppend,% "<script type='text/javascript'>",%newsFile%
FileAppend,% "function CheckAll(a){for(CheckBox=document.getElementsByTagName('table')[a].getElementsByTagName('input'),i=0;i<CheckBox.length;i++)CheckBox[i].checked=!0}",%newsFile%
FileAppend,% "function UnCheck(a){for(CheckBox=document.getElementsByTagName('table')[a].getElementsByTagName('input'),i=0;i<CheckBox.length;i++)CheckBox[i].checked=!1}",%newsFile%
FileAppend,% "function OtherCheck(a){for(CheckBox=document.getElementsByTagName('table')[a].getElementsByTagName('input'),i=0;i<CheckBox.length;i++)CheckBox[i].checked=1==CheckBox[i].checked?!1:!0}",%newsFile%
FileAppend,% "function OpenCheck(a){for(CheckBox=document.getElementsByTagName('table')[a].getElementsByTagName('input'),i=0;i<CheckBox.length;i++)1==CheckBox[i].checked&&CheckBox[i].nextSibling.click()}",%newsFile%
FileAppend,% "function tdCheck(t){t.getElementsByTagName('input')[0].checked=1==t.getElementsByTagName('input')[0].checked?!1:!0;}</script>",%newsFile%
if(showWeb=1){
	Run,%newsFile%  ;打开结果资讯网页
}
return
