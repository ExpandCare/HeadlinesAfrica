Parse.Cloud.define("signIn", function(request, response) {

    var reqData = JSON.parse(request.body);

    if (reqData.email && reqData.pass) {
        var User = Parse.Object.extend("User");
        var query = new Parse.Query(User);
        var email = reqData.email.toLowerCase();
        var password = reqData.pass;        

        Parse.Cloud.useMasterKey();

        query.equalTo("email", email);
        query.first({
        	success: function(user) {        		
        		if (user) {
        			if (user.get('email') == 'Obodoechinaca@gmail.com'.toLowerCase()) {	        			
	        			Parse.User.logIn(user.get('email'), password, {
							success: function(user) {
							    response.success(true);
							},
							error: function(user, error) {
							    console.log('Wrong password');
		                		response.error("Wrong password");
							}
						});
	        		} else {
	        			console.log('Not admin tried to login to push sender');
                		response.error("Not admin");
	        		}
        		} else {
        			console.log('No such user');
	                response.error("No such user");
        			
        		} 
        		
        	},
        	error: function(error) {
	            console.log("Error: " + error.code + " " + error.message);               
	            response.error("Something wrong with finding user");
	        }
    	});
    } else {
    	response.error("Error: wrong parameters");
    }
});

Parse.Cloud.define("getPosts", function(request, response) {
	var reqData = JSON.parse(request.body);

	var Post = Parse.Object.extend("Post");
    var query = new Parse.Query(Post);
    var queryLength = new Parse.Query(Post);
    var params = ['title', 'category', 'source', 'link', 'content', 'author', 'createdAt'];
    query.exists("content");
    // query.descending("createdAt");
    if(reqData.start) {
    	console.log("Start = " + reqData.start);    	
    	query.skip(reqData.start);    	
    }

    if(reqData.length) {
		console.log("Posts per page = " + reqData.length);
    	query.limit(reqData.length);    	
	}

	if(reqData['search[value]']) {
		console.log('Search = ' + reqData['search[value]']);
		query.startsWith("title", reqData['search[value]']);
		// query.matches("title", '/'+reqData['search[value]']+'/', 'i');
		queryLength.startsWith("title", reqData['search[value]']);
	}

	if(reqData['order[0][column]'] && reqData['order[0][dir]']) {
		console.log('Sort = ' + reqData['order[0][column]']);
		console.log('Dire = ' + reqData['order[0][dir]']);
		if (reqData['order[0][column]'] <= 6) {
			if(reqData['order[0][dir]'] == 'desc') {
				query.descending(params[reqData['order[0][column]']]);
			} else {
				query.ascending(params[reqData['order[0][column]']]);
			}
		}
	}
    
    queryLength.count({
		success: function(count) {		    
		    var length = count;		    

		    query.find({
		        success: function(list) {		        	
		        	var ult = {
		        		data: list,		        		
		        		draw: reqData.draw,
		        		recordsTotal: length,
		        		recordsFiltered: length
		        	};
		            console.log(JSON.stringify(list));
		            response.success(ult);
		        },
		        error: function(error) {
		            response.error({error: JSON.stringify(error)});
		        }
		    });
		},
		error: function(error) {
		   
		}
	});    
	
});