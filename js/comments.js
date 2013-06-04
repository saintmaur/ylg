var formTmpl,blockTmpl;
function removeComment(id){
    $("#"+id+"-comment").remove();
}

function mapCommentForm(data,id){
    //comment edit
    var cmtBlock = $(".comments-list").find("#"+id+"-comment");
 	var cmtForm = replaceStrTmpl(formTmpl,data);
	cmtBlock.hide().append(cmtForm);
}

function getCommentForm(sel,entityId,id){
    var block = $(sel);
    var data = {};
    console.log(entityId +' ' + id);
    if(!id){
	    data = {
	        "entity":"comment",
	        "entity-id":entityId,
	        "id":id,
	        "text":"",
	        "pack":"cmt"
	    }
    } else {

    }
	var cmtForm = $(replaceStrTmpl(formTmpl,data));
    $("#new-comment-form").hide();
    block.after(cmtForm)
    cmtForm.fadeIn();
}

function placeSavedComment(data){
    //place a block w data into appropriate place
    if(!$(".comments-list").find("#"+data.id+"-comment").size()){
	    if(data.entity == "comment"){
	        var target = $(".comments-list").find("#"+data['entity-id']+"-comment");
	        data['padding'] = parseInt(target.find('.comment-body').css("padding-left"))+20+"px"
	        var commentBlock = replaceStrTmpl(blockTmpl,data);
	        target.after($(commentBlock));
	        $("#0-comment-form").hide().find("form").trigger('reset');
	        $("#new-comment-form").fadeIn();
	    } else {
	        var commentBlock = replaceStrTmpl(blockTmpl,data);
	        $(".comments-list").append(commentBlock);
	        $("#new-comment-form").find("form").trigger('reset');
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

function delComment(id){
    $.ajax({
	    url:"/del-comment",
	    type:"post",
	    dataType:"json",
	    data:"id="+id,
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
    $(".edit-cmt").find('a').click(function(){
        var selId = $(this).attr('id');
        var id = selId.substring(selId.lastIndexOf('-')+1,selId.length);
        getCommentForm(id);
        return false;
    });
    $(".del-cmt").find('a').click(function(){
        var selId = $(this).attr('id');
        var id = selId.substring(selId.lastIndexOf('-')+1,selId.length);
        delComment(id);
        return false;
    });
});
