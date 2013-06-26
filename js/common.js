function simpleJSON2string(obj){
    if(typeof obj == "string")
        return obj;
    if(typeof JSON.stringify == "function"){
        return JSON.stringify(obj);
    } else {
        var str = "";
        for(var i in obj){
            if(typeof obj[i] != "object"){
                str += i+"="+obj[i]+"&";
            } else {
                //str += simpleJSON2string(obj[i])
            }
        }
        return str;
    }
}
function replaceStrTmpl(str,data){
    if(str != "undefined" && str != null){
	for(i in data){
	    var re = new RegExp("(=>"+i+"<=|=&gt;"+i+"&lt;=)",'g');
	    str = str.replace(re,data[i]);
	}
    }
    return str;
}

function getAlert(msg,type,x,y){
//параметрами задаются: текст сообщения, стилизация(ошибка или успех) и расположение
    msg = msg.replace(new RegExp("\s","g"), "");
    if(msg!=""){
	x = x!=undefined?x:20;
	y = y!=undefined?y:$(document).scrollTop()+20;
	$("#alert-popup")
	    .removeClass($("#alert-popup").attr('class'))
	    .addClass(type)
	    .css({
		top:y+"px",
		left:x+"px"
	    })
	    .html(msg)
	    .fadeIn();
	setTimeout(function(){
	    $("#alert-popup").fadeOut();
	},'2500');
    }
}

function unserializeData(data){
    var obj = {};
    var pairs = data.split("&");
    for(var i in pairs){
	var p = pairs[i].split("=");
	obj["\""+p[0]+"\""] = p[1];
    }
    return obj;
}
