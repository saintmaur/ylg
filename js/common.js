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
