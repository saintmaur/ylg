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
	    "text":""
	}
	var cmtForm = replaceStrTmpl(formTmpl,data);
	block.after(cmtForm);
    }
}

function placeSavedComment(data,id){
//place a block w data into appropriate place
    var commentBlock = replaceStrTmpl(blockTmpl,data);
    if(!$(".comments-list").find("#"+id+"-comment").size()){
	$(".comments-list").append(commentBlock);
    } else {
	$(".comments-list").find("#"+id+"-comment").replaceWith(commentBlock);
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
    if(id){
	$(".comments-list").find("#"+id+"-comment").fadeIn();
	form.hide();
    } else {
	form.trigger( 'reset' );
    }
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

function saveComment(entity,id,data){
    $.ajax({
	url:"/save-comment",
	type:"post",
	dataType:"json",
	data:data+"&entity="+entity,
	error:function(obj){
	    getAlert(obj.responseText,"error");
	},
	success:function(data){
	    if(data.success){
		placeSavedComment(data,id);
	    }
	}
    });
}

$(function(){
    formTmpl = $("#comment-form-tmpl-wrap").html();
    blockTmpl = $("#comment-block-tmpl-wrap").html();

    $(".reply-on-comment-link").click(function(){
	var id = $(this).attr("id").substring($(this).attr("id").lastIndexOf("-")+1,$(this).attr("id").length);
	getCommentForm("#"+id+"-comment",id,0);
	return false;
    });

    $(".save-comment").live({
	"click":function(){
	    var entid = $(".comments-wrap").attr('id');
	    var entity = entid.substring(0,entid.indexOf('-'));
	    var form = $(this).closest("form");
	    var cid = form.find("#comment-id").val();
	    var data = form.serialize();
	    console.log(data);
	    saveComment(entity,cid,data);
	    return false;
	}
    });
    $(".edit-comment-link").click(function(){

    });
    $(".del-comment-link").click(function(){

    });
});
