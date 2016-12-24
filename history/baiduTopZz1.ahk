;#############################
;##百度搜索风云榜今日最新资讯##
;##baiduTopZz by Zz 20150425##
;#############################
#NoEnv ;不检查空变量为环境变量
#SingleInstance,Force ;运行替换旧实例
FileEncoding,CP936 ;文件以中文编码加载
SetWorkingDir %A_ScriptDir% ;脚本当前工作目录
#Include *i %A_ScriptDir%\html代码识别.ahk ;引用html代码识别函数
;############
;##下载今日##
;############
filepath=Z:\Temps\  ;存放今日更新网页的缓存目录（★末尾必须为\）
IfNotExist %filepath%
	FileCreateDir,%filepath%
newslist:=Object()  ;存放资讯类别排行榜数组
newslist.Insert("今日热门搜索排行榜")
URLDownloadToFile,http://top.baidu.com/buzz?b=2&c=12&fr=topbuzz_b2_c12,%filepath%1.html
newslist.Insert("今日电影排行榜")
URLDownloadToFile,http://top.baidu.com/buzz?b=26&c=1&fr=topcategory_c1,%filepath%2.html
newslist.Insert("今日世说新词排行榜")
URLDownloadToFile,http://top.baidu.com/buzz?b=396&fr=topboards,%filepath%3.html
newslist.Insert("七日热点排行榜")
URLDownloadToFile,http://top.baidu.com/buzz?b=42&c=513&fr=topbuzz_b1_c513,%filepath%4.html
;★新增排行格式：
;newslist.Insert("排行榜标题")
;URLDownloadToFile,排行榜网址,%filepath%序号.html
showWeb:=0
;############
;##获得最新##
;############
newsfile=%filepath%news.html  ;结果展示的今日资讯网页
IfExist %newsfile%  ;如果已有则删除
	FileDelete,%newsfile%
FileAppend,<style>a{border-right: 1px dashed #000;padding:0 10px;line-height: 25px;}</style>,%newsfile%  ;写入网页简单样式头
Loop,4 ;循环比较上面4种类别资讯排行榜（★如增加则修改）
{
	Z_Index:=A_Index
	olds=""
	IfExist %A_ScriptDir%\list%Z_Index%.html
		FileRead,olds,%A_ScriptDir%\list%Z_Index%.html ;读取脚本目录下的历史资讯来比较(★保留)
	else
		MsgBox,初始化list%Z_Index%.html
	FileRead,news,%filepath%%Z_Index%.html  ;读取今日资讯网页来比较
	FileAppend,% "<h1>"newslist[Z_Index]"</h1>",%newsfile%  ;写入资讯类别排行榜标题
	Loop
	{
		titles:=GetNestedTag(news,"<a class=""list-title""",A_Index)  ;★根据html代码条件查找，详细用法可在html代码识别.ahk
		if(titles=""){
			break  ;资讯未找到，退出循环
		}
		finds:=GetNestedTag(olds,titles)  ;根据历史已读资讯标题来查找，未找到则加入今日资讯网页
		if(finds=""){
			showWeb:=1
			titles.="`n"
			FileAppend,%titles%,%newsfile%
			FileAppend,%titles%,%A_ScriptDir%\list%Z_Index%.html
		}
	}
}
if(showWeb=1){
	Run,%newsfile%  ;打开今日资讯网页
}
return
