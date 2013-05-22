var globData;
    function cancelEdit(id){
	var form = $("#"+id);
	var formEl = form.find('form');
	form.fadeOut();
	setTimeout(function(){
	    formEl.trigger( 'reset' );;
	    form.css('top','auto');
	},"1000");

    };
function replaceStrTmpl(str,data){
    for(i in data){
	str.replace("=>"+i+"<=",data[i]);
    }
    return str;
}

function getCloItem(id){
    $.ajax({
	url:"#",
	dataType:"json",
	method:"post",
	error:function(obj){
	    //alert(obj.responseText);
	},
	success:function(data){
	    globData = data;
	}
    });
}

function getLook(id){
    $.ajax({
	url:"#",
	dataType:"json",
	method:"post",
	error:function(obj){
	    //alert(obj.responseText);
	},
	success:function(data){
	    $('input[name="photo"]').val(data['photo']);
	    $('img#look-photo').attr('src',data['photo']);
	    $('select[name="look-whereto"] option[value="'+data['whereto']+'"]').attr("selected", "selected");
	    $('input[name="id"]').val(data['id']);
	    $('#clo-items-list').html("");
	    for(i in data['items']){
		$('#clo-items-list').append(replaceStrTmpl('<li id="item-=>id<="><span class="category">=>category<=</span><ul><li class="brand"><span class="clo-list-capt">бренд:</span>&nbsp;<a href="#">=>brand<=</a></li><li class="shop"><span class="clo-list-capt">магазин:</span>&nbsp;<a href="#">=>shop<=</a></li></ul><div class="eddel-block"><a href="#" class="edit" onclick="getCloLineForm(=>id<=)">ред.</a><br/><a href="#" onclick="delCloItem(=>id<=)" class="del">del.</a></div></li>',data['items'][i]))
	    }
	    $.fancybox({
		href:"#edit-look-form-cont"
	    });
	}
    });
}

function publishLook(id){
    $.ajax({
	url:"#",
	dataType:"json",
	method:"post",
	error:function(obj){
	    alert(obj.responseText);
	},
	success:function(data){
	    $.fancybox.close();
	    $('#look-'+id).find('.edit-look-link-cont').remove();
	}
    });
}

function saveLook(id){
    $.ajax({
	url:"#",
	dataType:"json",
	method:"post",
	error:function(obj){
	    alert(obj.responseText);
	},
	success:function(data){
	    $.fancybox.close();
	}
    });
}

function delCloItem(id){
    $.ajax({
	url:"#",
	dataType:"json",
	method:"post",
	error:function(obj){
	    alert(obj.responseText);
	},
	success:function(data){
	    $('#item-'+id).remove();
	}
    });
}

function getCloLineForm(id){
    var startFrom = 0;
    var form = $("#clo-item-form");

    if(id){
	startFrom = $("#item-"+id).offset().top;
	getCloItem(id);
	for(i in globData){
	    form.find('input[name="'+i+'"]').val(globData[i]);
	}
    }
    if(startFrom){
	form.find('input[name="clo-item-id"]').val(id);
	form.css('top',parseInt(startFrom-100)+"px");
    }
    form.slideDown();
}

function addCloLine(data){
    var tmpl = '<li><span class="category">=>category<=</span><ul><li><span class="clo-list-capt">бренд:</span>&nbsp;<a href="#">=>brand<=</a></li><li><span class="clo-list-capt">магазин:</span>&nbsp;<a href="#">=>shop<=</a></li></ul></li>';
    $("#clo-items-list").prepend(replaceStrTmpl(tmpl,data));
}

function editCloLine(data){
    var tmpl = '<span class="category">=>category<=</span><ul><li><span class="clo-list-capt">бренд:</span>&nbsp;<a href="#">=>brand<=</a></li><li><span class="clo-list-capt">магазин:</span>&nbsp;<a href="#">=>shop<=</a></li></ul>';
    saveCloItem(data);
    $("#item-"+globData['id']).html(replaceStrTmpl(tmpl,globData));
}

$(function(){
    $('a.call-upload-form').ajaxUpload(
      {
	    url:'/file',
	    secureuri:false,
	    name:'custom_img',
        type: "POST",
        method: "POST",
	    onSubmit:function() {

	    },
	    onComplete: function (data, status)
	    {
		//var obj = jQuery.parseJSON(data);
		$("#edit-look-form-cont").find('img').attr('src',data['photo']);
		$.fancybox({
		    href:"#edit-look-form-cont"
		});
	    }
      }
    );
    $('.edit-look-link-cont').click(function(){

	$.fancybox({
	    href:"#edit-look-form-cont"
	});
    });
    $('#clo-select').click(function(){
	getCloLineForm(0);
	return false;
    });
    $('.cancel').click(function(){
	cancelEdit("clo-item-form");
	return false;
    });
    $('.save-data').click(function(){
	cloId = $('#clo-item-form').find('input[name="clo-item-id"]');
	$.ajax({
	    url:"",
	    data:'look-id='+$('#edit-look-form-cont').find('input[name="id"]')+'&'+$('#clo-item-form').find('input').serialize(),
	    dataType:"json",
	    method:"post",
	    error:function(obj){
		alert(obj.responseText);
	    },
	    success:function(data){
		if(cloId){
		    editCloLine(data);
		} else {
		    addCloLine(data);
		}
		cancelEdit("clo-item-form");
	    }
	});
	return false;
    });
});
