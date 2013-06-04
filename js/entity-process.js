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
	        getAlert(obj.responseText,'error');
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
	        getAlert(obj.responseText,'error');
	    },
	    success:function(data){
	        $.fancybox.close();
	        document.location.reload(true);
	    }
    });
}

function delCloItem(id){
    $.ajax({
	    url:"#",
	    dataType:"json",
	    type:"post",
	    error:function(obj){
	        getAlert(obj.responseText,'error');
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

function vote(pack,entity,id,vote,sel){
    $.ajax({
	    url:"/vote",
	    dataType:"json",
	    type:"post",
	    data:'entity-id='+id+'&vote='+vote+"&entity="+entity+'&pack='+pack,
	    error:function(obj){
	        getAlert(obj.responseText,'error');
	    },
	    success:function(data){
	        if(data['passed']){
		        getAlert(data['msg'],"success");
                $('#'+entity+'-'+id).find('.vote-link').each(function(){
                    $(this).replaceWith('<span class="disabled">'+$(this).html()+'</span>');
                });

		        updVotes(pack,entity,id,sel);
	        } else {
		        getAlert(data.msg,"error");
	        }
	    }
    });
    return false;
}
function updVotes(pack,entity,id,sel){
    var vote = {success:false,vote:0}
    $.ajax({
	    url:"/get-entity-votes",
	    dataType:"json",
	    type:"post",
	    data:'entity-id='+id+'&entity='+entity+'&pack='+pack,
	    error:function(obj){
	        getAlert(obj.responseText,'error');
	    },
	    success:function(data){
	        if(data['success']){
		        $(sel).find('.l').text(data['like']);
		        $(sel).find('.s').text(data['sum']);
		        $(sel).find('.d').text(data['dislike']);
	        }
	    }
    });
    return false;
}

$(function(){
	$('a.call-upload-form').click(function(){
	    if(!$("#__ajaxUploadIFRAME").size()){
		    ajaxUploadIframe = $('<iframe src="/js/form.html" id="__ajaxUploadIFRAME" name="__ajaxUploadIFRAME"></iframe>').attr('style','style="width:0px;height:0px;border:1px solid #fff;display:none"').hide();
		    $(document.body).append(ajaxUploadIframe);
	    } else {
		    ajaxUploadIframe = $("#__ajaxUploadIFRAME");
		    ajaxUploadIframe.attr('src','/js/form.html');
		    document.getElementById("__ajaxUploadIFRAME").location.reload();
	    }
	    ajaxUploadIframe.load(function(){
		    input = ajaxUploadIframe.contents().find('input[name="file"]');
		    form = ajaxUploadIframe.contents().find('#file-upload-form');
		    input.change(function(){
		        form.submit();
		        ajaxUploadIframe.load(function() {
			        response = $(this).contents().find('html body').text();
			        ajaxUploadIframe.remove();
			        var data = jQuery.parseJSON(response);
			        //TODO: error handling
			        $("#edit-look-form-photo").find('img').attr('src',data['photo']);
			        $.fancybox({
			            href:"#edit-look-form-cont"
			        });
		        });
		    });
		    input.click();
	    });
    });

    $('.edit-look-link-cont').click(function(){
	    getLook($(this).attr('id'));
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
