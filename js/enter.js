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
        alert(obj.responseText);
    },
      success:function(data){
        window.location.href=data['location'];
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
        window.location.href=data['location'];
      }
    });
    return false;
  });
  // ...
});
