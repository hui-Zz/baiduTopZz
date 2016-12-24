;~ 文本=
;~ (
    ;~ <div id="header">测试测试1
        ;~ <div class="logo">测试测试2
            ;~ <h1>测试测试3</h1>
        ;~ </div>
        ;~ <div class="break">测试测试4</div>
        ;~ <div class="nav">测试测试5
        ;~ </div>
    ;~ </div>
    ;~ 8888
    ;~ </div>
;~ )
;注意，（"）也就是引号的转义必须且只能是（""），两个引号。所以（"<div id=""header"">"）的实际意思就是（<div id="header">）
;~ MsgBox, % GetNestedTag(文本,"<div id=""header"">")
;~ MsgBox, % GetNestedTag(文本,"<div cla")    ;虽然标签信息不完整，但只要有符合的，也是能匹配的
;~ MsgBox, % GetNestedTag(文本,"<div class=""",2)
;~ MsgBox, % GetNestedTag(文本,"<h1>")
;~ MsgBox, % GetNestedTag(文本,"<h1")

;此函数匹配到的字符串，包含起点与终点字符串。
;例如“<em>abc</em>”，tag“<em>”，匹配到的结果就是“<em>abc</em>”。
;最后一个参数的意思是返回第n个符合的字串（参考示例便于理解）。
;修改自英文官网找到的同名函数，改掉了几个bug
GetNestedTag(data,tag,occurrence=1)
{
    if (data="" Or tag="")
        return
    tag:=Trim(tag)    ;移除前后的空格和tab，使得匹配“<img ”“<img”都能成功
    Start:=InStr(data,tag,false,1,occurrence)
    if (Start=0)    ;没有匹配的字符串则返回空值 主要是涉及到正常会返回字符串，所以不正常的时候，返回空值比返回0保险
        return
    RegExMatch(tag,"S)<([a-zA-Z0-9]*)",basetag) ;“iS)<([a-z]*)”这样的匹配规则，无法匹配类似H2这样带数字的标签
    Loop
    {
        until:=InStr(data, "</" . basetag1 . ">", false, Start, A_Index) + StrLen("</" . basetag1 . ">")    ;"</" basetag1 ">"等效于"</" . basetag1 . ">"
        Strng:=SubStr(data, Start, until - Start)

        ;前面条件针对“<h1>”后面针对“<h1”
        if (tag="<" . basetag1 . ">" or tag="<" . basetag1)
        {
            StringReplace, strng, strng, <%basetag1%>, <%basetag1%>, UseErrorLevel ; start counting to make match 匹配类似<head>的情况
            OpenCount:=ErrorLevel
        }
        else
        {
            StringReplace, strng, strng, <%basetag1%%A_Space%, <%basetag1%%A_Space%, UseErrorLevel ; start counting to make match 匹配类似<head id="">的情况
            OpenCount:=ErrorLevel
        }
        StringReplace, strng, strng, </%basetag1%>, </%basetag1%>, UseErrorLevel
        CloseCount:=ErrorLevel
        if (OpenCount = CloseCount)
            break

        ;这里控制能识别的嵌套不超过下面的数字那么多层（默认250）
        if (A_Index > 250) ; for safety so it won't get stuck in an endless loop,
        {                 ; it is unlikely to have over 250 nested tags
            strng=
            break
        }
    }
    if (StrLen(strng) < StrLen(tag)) ; something went wrong/can't find it
        strng=
    return strng
}