Parse.Cloud.define("fillSearchPosts", function(request, response) 
{

var Post = Parse.Object.extend("Post");
var contentQuery = new Parse.Query(Post);
contentQuery.limit(1000);
contentQuery.skip(10000);
contentQuery.descending("createdAt");
var SearchPost = Parse.Object.extend("SearchPost");
contentQuery.find(
{
  success: function(results) 
  {

     for(var j = 0; j < results.length; j++)
     {
        var post = results[j];
        
        var searchPost = new SearchPost();
        searchPost.set("content", post.get("content").replace(/<(?:.|\n)*?>/gm, '').concat(" ", post.get("title")).toLowerCase());
        searchPost.set("post", post);
        
        searchPost.save(null, {
          success: function(searchPost)
          {
            if(j == results.length - 1)
            {
              response.success();
            }
          },
          error: function(searchPost, error) 
          {
            if(j == results.length - 1)
            {
              response.success();
            }
          }
        });
     }
     
     
  },
  error: function(error) 
  {

   
    response.error(error);
    
  }
});

});

Parse.Cloud.define("searchPost", function(request, response) {

var Post = Parse.Object.extend("Post");
//$.parse("asdfasdf").text();
var htmlRegExp = "(?![^<]*>)(?i)";

var contentQuery = new Parse.Query(Post);
//contentQuery.matches("content", htmlRegExp.concat(request.params.keyword));
contentQuery.matches("content", request.params.keyword);

var titleQuery = new Parse.Query(Post);
//titleQuery.matches("title", request.params.keyword);
titleQuery.matches("title", request.params.keyword);

var mainQuery = Parse.Query.or(contentQuery, titleQuery);

var startTime = new Date().getTime();

mainQuery.find({
  success: function(results) 
  {
     var responseDict = new Object();
     responseDict["posts"] = results;
     responseDict["keyword"] = request.params.keyword;

     var endTime = new Date().getTime(); 
     var time = endTime - startTime;
     console.log('Execution time: ' + time);
     response.success(responseDict);
  },
  error: function(error) 
  {

    var endTime = new Date().getTime(); 
    var time = endTime - startTime;
    console.log('Execution time: ' + time);
    response.error(error);
    
  }
});

});

Parse.Cloud.afterSave("Post", function(request, response)
{

   var SearchPost = Parse.Object.extend("SearchPost");
   var searchPost = new SearchPost();

   searchPost.set("content", request.object.get("content").replace(/<(?:.|\n)*?>/gm, '').concat(" ", request.object.get("title")).toLowerCase());
   searchPost.set("post", request.object);

   searchPost.save(null, {
     success: function(searchPost)
     {
         response.success();
     },
     error: function(searchPost, error) 
     {
         response.error(error);
     }
   });
});