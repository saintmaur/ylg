var formTmpl,blockTmpl;
function removeComment(id){
    $("#"+id+"-comment").remove();
}

function mapCommentForm(data,id){
//comment edit
    var cmtBlock = $(".comments-list").find("#"+id+"-comment");
    var x = cmtBlock.offset().left;
    var y = cmtBlock.offset().top;
    if(!$("#"+id+"-comment-form").size()){
	var cmtForm = replaceStrTmpl(formTmpl,data);
	cmtBlock.hide().append(cmtForm);
    } else {
	var cmtForm = $(".comments-list").find("#"+id+"-comment").hide();
	$("#"+id+"-comment-form").fadeIn();
    }
}

function getCommentForm(sel,entityId,id){
    var block = $(sel);
    var x = block.offset().left;
    var y = block.offset().top;
    if(!$("#"+id+"-comment-form").size()){
	var data = {
	    "entity":"comment",
	    "entity-id":entityId,
	    "id":id,
	    "text":"",
	    "pack":"cmt"
	}
	var cmtForm = $(replaceStrTmpl(formTmpl,data));
    } else {
	var cmtForm = $("#"+id+"-comment-form");
	cmtForm.find("form").trigger('reset');
	cmtForm.hide();
    }
    $("#new-comment-form").hide();
    console.log(block)
    block.after(cmtForm)
    cmtForm.fadeIn();
}

function placeSavedComment(data){
//place a block w data into appropriate place
    if(!$(".comments-list").find("#"+data.id+"-comment").size()){
	if(data.entity == "comment"){
	    var target = $(".comments-list").find("#"+data['entity-id']+"-comment");
	    data['padding'] = parseInt(target.css("padding-left"))+20+"px"
	    var commentBlock = replaceStrTmpl(blockTmpl,data);
	    target.after($(commentBlock));
	} else {
	    $(".comments-list").append(commentBlock);
	}
    } else {
	$(".comments-list").find("#"+data['entity-id']+"-comment").replaceWith(commentBlock);
    }
}
function getComment(entity,id){
    $.ajax({
	url:"/get-comment",
	type:"post",
	dataType:"json",
	data:"comment-id="+id+"&entity="+entity,
	error:function(obj){
	    getAlert(obj.responseText,"error");
	},
	success:function(data){
	    if(data.success){
		mapCommentForm(data,id);
	    }
	}
    });
}

function cancelEdit(id){
    var form = $("#"+id+"-comment-form").find("form");
    $("#"+id+"-comment-form").hide();
    form.trigger('reset');
    if(id){
	$(".comments-list").find("#"+id+"-comment").fadeIn();
    }
    $("#new-comment-form").show();
    return false;
}

function delComment(entity,id){
    $.ajax({
	url:"/del-comment",
	type:"post",
	dataType:"json",
	data:"comment-id="+id+"&entity="+entity,
	error:function(obj){
	    getAlert(obj.responseText,"error");
	},
	success:function(data){
	    if(data.success){
		removeComment(id);
	    }
	}
    });
}

function saveComment(entity,indata){
    $.ajax({
	url:"/save-comment",
	type:"POST",
	dataType:"json",
	data:indata,
	error:function(obj){
	    getAlert(obj.responseText,"error");
	},
	success:function(response){
	    if(response.success){
		getAlert(response.msg,"success");
		placeSavedComment($.parseJSON(response.data));
	    } else {
		getAlert(response.msg,"error");
	    }
	}
    });
}

$(function(){
    formTmpl = $("#comment-form-tmpl-wrap").html();
    blockTmpl = $("#comment-block-tmpl-wrap").html();

    $(".reply-on-comment-link").live({
	"click":function(){
	    var id = $(this).attr("id").substring($(this).attr("id").lastIndexOf("-")+1,$(this).attr("id").length);
	    getCommentForm("#"+id+"-comment",id,0);
	    return false;
	}
    });

    $(".save-comment").live({
	"click":function(){
	    var entid = $(".comments-wrap").attr('id');
	    var entity = entid.substring(0,entid.indexOf('-'));
	    var form = $(this).closest("form");
	    var cid = form.find("#comment-id").val();
	    var data = form.serialize();
	    saveComment(entity,data);
	    return false;
	}
    });
    $(".edit-comment-link").click(function(){

    });
    $(".del-comment-link").click(function(){

    });
});
