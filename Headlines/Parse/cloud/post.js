Parse.Cloud.define("fillSearchPosts", function(request, response) 
{

var Post = Parse.Object.extend("Post");
var contentQuery = new Parse.Query(Post);
contentQuery.limit(200);
contentQuery.skip(800);
var SearchPost = Parse.Object.extend("SearchPost");
contentQuery.find(
{
  success: function(results) 
  {

     for(var j = 0; j < results.length; j++)
     {
        var post = results[j];
        
        var contentString = post.get("content").concat(" ", post.get("title"));

   var tokens = tokensFromString(contentString);

   var resultStr = "";

   for(var i = 0; i < tokens.length; i++)
   {
     var token = tokens[i];
     
     if(resultStr.length + token.length >= 998)
     {
        var searchPost = new SearchPost();

        searchPost.set("content", resultStr);
        searchPost.set("post", post);
        resultStr = "";
        searchPost.save();

     }
     else
     {
        resultStr = resultStr.concat(" ", token);
     }

   }

   if(resultStr.length > 0)
   {
      var searchPost = new SearchPost();

        searchPost.set("content", resultStr);
        searchPost.set("post", post);
        resultStr = "";
        searchPost.save();
   }
     }
     
     
  },
  error: function(error) 
  {

   
    response.error(error);
    
  }
});

});

Parse.Cloud.define("searchPost", function(request, response) {

var _ = require('underscore');
var SearchPost = Parse.Object.extend("SearchPost");



var tokens = tokensFromString(request.params.keyword);

var queries = [];

for(var i = 0; i < tokens.length; i++)
{
   var token = tokens[i];
   var subQuery = new Parse.Query(SearchPost);
   subQuery.contains("content", token);
   subQuery.include("post");
   queries.push(subQuery);

}

var contentQuery = Parse.Query.or.apply(Parse.Query, queries);


contentQuery.find(
{
  success: function(results) 
  {
    var postt = results[0];
    var res =  postt["post"];
    console.log('POST ='.concat(res));
     var responseDict = new Object();
     responseDict["posts"] = _.pluck(results, "post");
     responseDict["keyword"] = request.params.keyword;

     response.success(responseDict);
  },
  error: function(error) 
  {
    response.error(error);
  }
});

});

Parse.Cloud.afterSave("Post", function(request, response)
{
   
   var SearchPost = Parse.Object.extend("SearchPost");

   var contentString = request.object.get("content").concat(" ", request.object.get("title"));

   var tokens = tokensFromString(contentString);

   var resultStr = "";

   for(var i = 0; i < tokens.length; i++)
   {
     var token = tokens[i];

     if(resultStr.length + token.length > 999)
     {
        var searchPost = new SearchPost();

        searchPost.set("content", resultStr);
        searchPost.set("post", request.object);
        resultStr = "";
        searchPost.save();

     }
     else
     {
        resultStr = resultStr.concat(" ", token);
     }

   }

   if(resultStr.length > 0)
   {
      var searchPost = new SearchPost();

        searchPost.set("content", resultStr);
        searchPost.set("post", request.object);
        resultStr = "";
        searchPost.save();
   }
});

function tokensFromString(contentString) 
{
   var _ = require('underscore');

   var contentStr = contentString.replace(/<(?:.|\n)*?>/gm, '').toLowerCase();
   var tokens = contentStr.split(/[^A-Za-z]/);

   var toRemove = ['of', 'the', "in", "on", "at", "to", "a", "is", "for", "", "undefined", "as", "in", "and", "it", "any", "an", "or", "do", "does"];

   tokens = tokens.filter( function( el ) 
   {
      return toRemove.indexOf( el ) < 0;
   });

   tokens = _.uniq(tokens, false);

   return tokens;
}
