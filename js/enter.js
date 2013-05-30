$(document).ready(function(){
  //
  $("#btn-login").click(function(){
    $.fancybox({
      href:"#form-login"
    })
  });
  //
  $("#btn-form-login-submit").click(function(){
    $.ajax({
      url:"/action-login",
      dataType:"json",
      data: {
        login     : $("#fld-form-login--login").val(),
        password  : $("#fld-form-login--password").val()
      },
      type: "POST",
      method:"post",
      error:function(obj){
	    getAlert(obj.responseText,"error");
      },
      success:function(data){
	    if(data.passed){
	      getAlert(data.msg,"success");
		window.location.reload();
	    } else {
	      getAlert(data.msg,"error");
	    }
      }
    });
    return false;
  });
  //
  $("#btn-send-login").click(function(){
    $.ajax({
      url:"/action-send-login",
      dataType:"json",
      data: {
        login : $("#fld-form-login--login").val(),
      },
      type: "POST",
      method:"post",
      error:function(obj){
        alert(obj.responseText);
      },
      success:function(data){
          window.location.reload();
      }
    });
    return false;
  });
  //
  $("#btn-register").click(function(){
    $.fancybox({
      href:"#form-register"
    })
  });
  $("#btn-form-register-submit").click(function(){
    $.ajax({
      url:"/action-register",
      dataType:"json",
      data: {
        login : $("#fld-form-register--login").val()
      },
      type: "POST",
      method:"post",
      error:function(obj){
        alert(obj.responseText);
      },
      success:function(data){
          window.location.reload();
      }
    });
    return false;
  });
  //
  $("#btn-logoff").click(function(){
    $.ajax({
      url:"/action-logoff",
      dataType:"json",
      data: "logoff",
      type: "POST",
      method:"post",
      error:function(obj){
        alert(obj.responseText);
      },
      success:function(data){
          window.location.reload();
      }
    });
    return false;
  });
});
