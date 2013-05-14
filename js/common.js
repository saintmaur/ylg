function getAlert(msg,type,x,y){
//параметрами задаются: текст сообщения, стилизация(ошибка или успех) и расположение
    x = x!=undefined?x:20;
    y = y!=undefined?y:20;
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