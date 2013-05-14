$(document).ready(function(){
  // enter btn
  $("#enter").click(function(){
    $.fancybox({
      href:"#enter-form"
    })
  });
  // submit dialog btn
  $("#enter-submit").click(function(){
    $.ajax({
      url:"/ajax-enter",
      dataType:"json",
      data: {
        login : $("#enter-login").val(),
        pass  : $("#enter-pass").val()
      },
      type: "POST",
      method:"post",
      error:function(obj){
	  getAlert(obj.responseText,"error");
      },
      success:function(data){
	  if(data.passed){
	      getAlert(data.msg,"success");
	      window.location.href=data.location;
	  } else {
	      getAlert(data.msg,"error");
	  }

      }
    });
    return false;
  });
  // send-login dialog btn
  $("#send-login").click(function(){
    $.ajax({
      url:"/ajax-send-login",
      dataType:"json",
      data: {
        login : $("#enter-login").val(),
      },
      type: "POST",
      method:"post",
      error:function(obj){
        alert(obj.responseText);
      },
      success:function(data){
        window.location.href=data.location;
      }
    });
    return false;
  });
  // register btn
  $("#register").click(function(){
    $.fancybox({
      href:"#register-form"
    })
  });
  $("#register-submit").click(function(){
    $.ajax({
      url:"/ajax-register",
      dataType:"json",
      data: {
        login : $("#register-login").val()
      },
      type: "POST",
      method:"post",
      error:function(obj){
        alert(obj.responseText);
      },
      success:function(data){
        window.location.href=data.location;
      }
    });
    return false;
  });
  // logoff btn
  $("#logoff").click(function(){
    $.ajax({
      url:"/ajax-logoff",
      dataType:"json",
      data: "logoff",
      type: "POST",
      method:"post",
      error:function(obj){
        alert(obj.responseText);
      },
      success:function(data){
        window.location.href=data.location;
      }
    });
    return false;
  });
});
