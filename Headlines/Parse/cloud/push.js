Parse.Cloud.job("send_post", function(request, status){
	
	var query = new Parse.Query(Parse.Installation);  
	//query.equalTo('deviceType', 'ios');

  	var reqData = JSON.parse(request.body);
  	if (reqData.postId) {

	    console.log("Request = " + reqData.postId);

	    var Post = Parse.Object.extend("Post");
	    var postQuery = new Parse.Query(Post);
	    
	    postQuery.get(reqData.postId, {
	        success: function(post) {
	            if (post) {
	            	
	            	var message = reqData.message || post.get('title');
	            	console.log('Mes = ' + message);

					Parse.Push.send({
					    where: query,
					    articleId: post.id,
					    data: {
					      	alert: post.get('title')
					    }
					}, {
					    success: function() {
					      	status.success('Push success');
					    },
					    error: function(error) {
					      	status.error('Push error');
					    }
					});
	                // status.success('Push success');
	            } else {
	                status.error('Article not found');
	            }
	        },
	        error: function(object, error) {
	            console.log("Error: " + error.code + " " + error.message);
	            response.error('Nothing found');
	        }
	    }); 

	} else {
		status.error('Parameter error: postId undefined');
	}
});

Parse.Cloud.define("sendPostByPush", function(request, response) {
    var query = new Parse.Query(Parse.Installation);  
	//query.equalTo('deviceType', 'ios');

  	var reqData = JSON.parse(request.body);
  	if (reqData.postId) {

	    console.log("Request = " + reqData.postId);

	    var Post = Parse.Object.extend("Post");
	    var postQuery = new Parse.Query(Post);
	    
	    postQuery.get(reqData.postId, {
	        success: function(post) {
	            if (post) {
	            	
	            	var message = reqData.message || post.get('title');
	            	console.log('Mes Push was sended= ' + message);

					Parse.Push.send({
					    where: query,
					    articleId: post.id,
					    data: {
					      	alert: message,
					      	articleId: post.id,
						    sound: "default"
					    }
					}, {
					    success: function() {
					      	response.success('Push success');
					    },
					    error: function(error) {
					      	response.error('Push error');
					    }
					});
	                // response.success('Push success: ' + message);
	            } else {
	                response.error('Article not found');
	            }
	        },
	        error: function(object, error) {
	            console.log("Error: " + error.code + " " + error.message);
	            response.error('Nothing found');
	        }
	    }); 

	} else {
		response.error('Parameter error: postId undefined');
	}
});
