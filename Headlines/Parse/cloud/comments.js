var _ = require("underscore");

/*
 * COMMENTS FUNCTIONS
 */


/*
 * FUNCTION TO GET POST COMMENT COUNT
 */
Parse.Cloud.define("getCommentCount", function(request, response){
	var commentQuery = new Parse.Query("Comment");

	var reqData = JSON.parse(request.body);

	commentQuery.equalTo("postId", { __type: "Pointer", className: "Post", objectId: reqData.postId });

	commentQuery.find().then(function(comments){
		if(comments.length){
			response.success(comments.length);
		} else {
			response.success(0);
		}
	});
});

Parse.Cloud.define("saveComment", function(request, response){
	var Comment = Parse.Object.extend("Comment");
	var postQuery = new Parse.Query("Post");

	var reqData = JSON.parse(request.body);

	if (reqData.userId && reqData.postId) {

		postQuery.equalTo("objectId", reqData.postId);

		var comment = new Comment();

		comment.set("userId", { __type: "Pointer", className: "_User", objectId: reqData.userId });
		comment.set("postId", { __type: "Pointer", className: "Post", objectId: reqData.postId });
		comment.set("text", reqData.text);
		comment.set("displayName", reqData.displayName);

		comment.save({
			success: function(){
				postQuery.first().then(function(post){
					var commentRelation = post.relation("comments");
					commentRelation.add(comment);
					post.save();

					response.success({ commentStatus: 1, object: comment });
				});
			},
			error: function(){
				response.success({ commentStatus: 0, object: [] });
			}
		});

	} else {
		response.error('Wrong comment parameters');
	}
});