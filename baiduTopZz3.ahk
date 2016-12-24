;####################################################
;#	百度搜索风云榜资讯爬虫baiduTopZz3 20160601 by Zz	#
;#	论坛更新地址：http://ahk8.com/thread-6066.html	#
;####################################################
#NoEnv ;不检查空变量为环境变量
#SingleInstance,Force ;运行替换旧实例
FileEncoding,CP936 ;文件以中文编码加载
SetWorkingDir %A_ScriptDir% ;脚本当前工作目录
#Include *i %A_ScriptDir%\html代码识别.ahk ;引用html代码识别函数
;####################
;#	自定义修改变量	#
;####################
fileName=TopZz  ;（★存放资讯文件名字前缀）
filePath=%A_Temp%  ;（★存放今日更新网页的缓存目录）
newsFile=%filePath%\%fileName%News.html  ;（★存放比较结果的未读资讯网页文件,手动打开请改为桌面等路径）
showWeb:=0  ;（★是否自动展示资讯:0为自动模式,有未读才展示；1为始终自动展示；2为手动,始终不展示）
IfNotExist %filePath%
	FileCreateDir,%filePath%
;############################
;#	下载资讯排行榜(可增加)	#
;############################
newsList:=Object()  ;存放资讯类别排行榜数组
newsUrlList:=Object()  ;存放资讯类别排行榜数组
newsList.Insert("今日热门")
newsUrlList.Insert("http://top.baidu.com/buzz?b=2&c=12&fr=topbuzz_b2_c12")
newsList.Insert("七日热点")
newsUrlList.Insert("http://top.baidu.com/buzz?b=42&c=513&fr=topbuzz_b1_c513")
newsList.Insert("今日电影")
newsUrlList.Insert("http://top.baidu.com/buzz?b=26&c=1&fr=topcategory_c1")
newsList.Insert("世说新词")
newsUrlList.Insert("http://top.baidu.com/buzz?b=396&fr=topboards")
newsList.Insert("今日动漫")
newsUrlList.Insert("http://top.baidu.com/buzz?b=23&fr=topboards")
newsList.Insert("热点人物")
newsUrlList.Insert("http://top.baidu.com/buzz?b=258&fr=topboards")
newsList.Insert("今日软件")
newsUrlList.Insert("http://top.baidu.com/buzz?b=20&fr=topboards")

;（★在此挑选你的排行榜http://top.baidu.com/boards?fr=topregion★）
;newsList.Insert("排行榜标题")
;newsUrlList.Insert("排行榜网址")
;（★复制上面两行修改后添加，不要的直接删除两行即可★）
Loop,% newsUrlList.MaxIndex() ;循环下载newsUrlList里所有资讯页面
{
	URLDownloadToFile,% newsUrlList[A_Index],% filePath "\" newsList[A_Index] ".html"
}
;####################
;#	未读资讯比较生成	#
;####################
IfExist %newsFile%  ;如果已有则删除
	FileDelete,%newsFile%
FileAppend,<style>a{padding-right:20px;line-height:25px;}td{border-right:1px dashed #000;}input{cursor:pointer;}</style>`n,%newsFile%  ;写入网页简单样式头
Loop,% newsUrlList.MaxIndex() ;循环比较newsUrlList里所有资讯内容
{
	newsName:=newsList[A_Index]
	newsUrl:=newsUrlList[A_Index]
	olds=""
	If(A_MM=01 && A_DD=01)
		FileMove,%A_ScriptDir%\%fileName%%newsName%.html,% A_ScriptDir "\" newsName (A_Year-1) ".html"
	IfExist %A_ScriptDir%\%fileName%%newsName%.html
		FileRead,olds,%A_ScriptDir%\%fileName%%newsName%.html ;[历史资讯]读取后比较今日去除重复资讯
	else
		FileAppend,<h1>%newsName%</h1>`n,%A_ScriptDir%\%fileName%%newsName%.html  ;[历史资讯]初始化
	FileRead,news,%filePath%\%newsName%.html  ;读取今日资讯网页来比较
	FileAppend,% "<h1><a target='_blank' href='" newsUrl "'>" newsName "</a>",%newsFile%  ;写入资讯类别排行榜标题
	FileAppend,% "<input type='button' value='选十' onclick='Check10(" A_Index-1 ")'/>",%newsFile%  ;写入选择按钮
	FileAppend,% "<input type='button' value='全选' onclick='CheckAll(" A_Index-1 ")'/>",%newsFile%  ;写入选择按钮
	FileAppend,% "<input type='button' value='不选' onclick='UnCheck(" A_Index-1 ")'/>",%newsFile%
	FileAppend,% "<input type='button' value='反选' onclick='OtherCheck(" A_Index-1 ")'/>",%newsFile%
	FileAppend,% "<input type='button' value='打开' onclick='OpenCheck(" A_Index-1 ")'/></h1>`n",%newsFile%
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
		if(finds="" && T_Index=0)
			FileAppend,<h2>%A_YYYY%%A_MM%%A_DD%</h2>`n,%A_ScriptDir%\%fileName%%newsName%.html  ;[历史资讯]存档日期
		if(finds=""){
			T_Index+=1
			showWeb:=(showWeb=0) ? 1 : showWeb
			FileAppend,<td onclick='tdCheck(this);'><input type='checkbox' onclick='this.checked=1==this.checked?!1:!0;' ,%newsFile%
			if(T_Index<11)
				FileAppend,checked='checked' ,%newsFile%
			FileAppend,/>,%newsFile%
			FileAppend,%titles%`n,%A_ScriptDir%\%fileName%%newsName%.html  ;[历史资讯]存档
			titles.="</td>`n"
			FileAppend,%titles%,%newsFile%
			if(mod(T_Index,5)=0)
				FileAppend,</tr><tr>`n,%newsFile%
		}
	}
	FileAppend,</table>`n,%newsFile%
}
; 写入网页JS脚本
FileAppend,% "<script type='text/javascript'>",%newsFile%
FileAppend,% "var ten;",%newsFile%
FileAppend,% "for(i=0;i<document.getElementsByTagName('table').length;i++)document.getElementsByTagName('table')[i].getElementsByTagName('tr')[0].getElementsByTagName('td')[0]||(document.getElementsByTagName('h1')[i].style.display='none');",%newsFile%
FileAppend,% "function Check10(a){UnCheck(a);CheckBox=document.getElementsByTagName('table')[a].getElementsByTagName('input');ten=!ten||ten>=CheckBox.length?10:ten+=10;for(i=ten-10;i<ten;i++)CheckBox[i].checked=!0}",%newsFile%
FileAppend,% "function CheckAll(a){for(CheckBox=document.getElementsByTagName('table')[a].getElementsByTagName('input'),i=0;i<CheckBox.length;i++)CheckBox[i].checked=!0}",%newsFile%
FileAppend,% "function UnCheck(a){for(CheckBox=document.getElementsByTagName('table')[a].getElementsByTagName('input'),i=0;i<CheckBox.length;i++)CheckBox[i].checked=!1}",%newsFile%
FileAppend,% "function OtherCheck(a){for(CheckBox=document.getElementsByTagName('table')[a].getElementsByTagName('input'),i=0;i<CheckBox.length;i++)CheckBox[i].checked=1==CheckBox[i].checked?!1:!0}",%newsFile%
FileAppend,% "function OpenCheck(a){for(CheckBox=document.getElementsByTagName('table')[a].getElementsByTagName('input'),i=0;i<CheckBox.length;i++)1==CheckBox[i].checked&&window.open(CheckBox[i].nextSibling.href)}",%newsFile%
FileAppend,% "function tdCheck(t){t.getElementsByTagName('input')[0].checked=1==t.getElementsByTagName('input')[0].checked?!1:!0;}</script>",%newsFile%
if(showWeb=1){
	Run,%newsFile%  ;打开结果资讯网页--incognito(无痕模式)
}
return
