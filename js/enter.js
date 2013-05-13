$(document).ready(function(){
  $("#enter").click(function(){
    $.fancybox({
      href:"#enter-form"
    })
  });
  $("#submit").click(function(){
    $.ajax({
      url:"/ajax-enter",
      dataType:"json",
      data: {
        login : $("#login").val(),
        pass  : $("#pass").val()
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
});
