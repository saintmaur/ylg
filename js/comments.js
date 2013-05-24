var formTmpl = $("#comment-form-tmpl-wrap").html();
var blockTmpl = $("#comment-block-tmpl-wrap").html();

function removeComment(id){
    $("#"+id+"-comment").remove();
}

function mapCommentForm(data,id){
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

function placeSavedComment(data,id){
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
		placeCommentForm(data,id);
	    }
	}
    });
}


$(function(){
    $(".save-comment-link").click(function(){
	var entid = $(".comments-wrap").attr('id');
	var entity = entid.substring(0,id.indexOf('-'));

	var form = $(this).closest("form");
	var cid = form.find("#comment-id").val();
	var data = form.serialize();
	saveComment(entity,cid,data);
    });
    $(".edit-comment-link").click(function(){

    });
    $(".del-comment-link").click(function(){

    });
});
