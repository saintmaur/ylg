var globData;
function cancelEditClo(id){
	var form = $("#"+id);
	form.fadeOut();
	setTimeout(function(){
	    form.css('top','auto');
        form.find('input[type="text"]').each(function(){
            $(this).val("");
        });
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
	    url:"/get-look",
	    dataType:"json",
	    method:"post",
        data:"id="+id,
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

function saveLook(data){
    $.ajax({
	    url:"/save-look",
	    dataType:"json",
	    type:"post",
        data:data,
	    error:function(obj){
	        getAlert(obj.responseText,'error');
	    },
	    success:function(data){
	        $.fancybox.close();
	        document.location.href = "/look/"+data.id;
	    }
    });
}

function delCloItem(id){
    $("li#clo-"+id).remove();
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
    var obj = {};
    if(typeof data == "string"){
        var pairs = data.split("&");
        for(var i in pairs){
            pair = pairs[i].split("=");
            obj[pair[0]] = pair[1]
        }
    } else if (typeof data == "object") {
        obj = data;
    } else {
        return;
    }
    var tmpl = '<li class="clo-item" id="clo-'+($(".clo-item").size()+1)+'"><span class="category"><input type="text" name="category[]" value="=>category<=" /></span><ul><li><span class="clo-list-capt">бренд:</span>&nbsp;<input type="text" name="brand[]" value="=>brand<=" /></li><li><span class="clo-list-capt">магазин:</span>&nbsp;<input type="text" name="shop[]" value="=>shop<=" /></li></ul><div style="text-align:right"><a href="#" onclick="delCloItem(\''+($(".clo-item").size()+1)+'\')">удалить</a></div></li>';
    $("#clo-items-list").prepend(replaceStrTmpl(tmpl,obj));
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
    $.fancybox({
		href:"#edit-look-form-cont"
	});
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
			        //
			        $.fancybox({
			            href:"#edit-look-form-cont"
			        });
                    $("#edit-look-form-photo").find('img').attr('src',data['photo']);
                    $("#edit-look-form-photo").find('img').attr('src',data['photo']);
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
    $('.cancel-clo').click(function(){
	    cancelEditClo("clo-item-form");
	    return false;
    });
    $('.save-clo-data').click(function(){
	    cloId = $('#clo-item-form').find('input[name="clo-item-id"]');
        addCloLine($('#clo-item-form').find('input').serialize());
        cancelEditClo("clo-item-form");
	    return false;
    });
    $("#custom-reason-switch").click(function (){
        if($(this).is(':checked')){
            $("#reason").hide();
            $("#custom-reason-wrap").show();
        } else {
            $("#reason").show();
            $("#custom-reason-wrap").hide();
            $("#custom-reason").val("");
        }
    });
    $("#save-button").click(function (){
        saveLook($('#entity-edit-form').serialize()+"&status=0");
        return false;
    });

    $("#publish-button").click(function (){
        saveLook($('#entity-edit-form').serialize()+"&status=1");
        return false;
    });

});
