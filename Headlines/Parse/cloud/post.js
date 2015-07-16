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

Parse.Cloud.define("searchPost", function(request, response) 
{

   if(request.params.keyword.length > 100)
   {
      response.error("Search phrase is too long. Please, enter less than 100 characters.");
      return;
   }

   if(request.params.keyword.length == 0)
   {
      response.error("Please, enter search phrase");
      return;
   }
 

   var limit;
   var skip;

   if(!request.params.limit)
   {
      limit = 20;
   }
   else
   {
      limit = request.params.limit;
   }

   if(!request.params.skip)
   {
      skip = 0;
   }
   else
   {
      skip = request.params.skip;
   }
  
   var _ = require('underscore');
   var SearchPost = Parse.Object.extend("SearchPost");

   var tokens = tokensFromString(request.params.keyword);

   if(tokens.length == 0)
   {
      var respDict = new Object();
      respDict["posts"] = tokens;
      respDict["keyword"] = request.params.keyword;
      response.success(respDict);
   }
   else
   {
      var queries = [];

    for(var i = 0; i < tokens.length; i++)
    {
      var token = tokens[i];
      var subQuery = new Parse.Query(SearchPost);
      subQuery.contains("content", " ".concat(token).concat(" "));
      queries.push(subQuery);

   }

   var contentQuery = Parse.Query.or.apply(Parse.Query, queries);
   contentQuery.include("post");
   contentQuery.limit(1000);

   contentQuery.find(
   {
     success: function(results) 
     {
       if(skip < 0) 
       {
          response.error("Incorrect skip parameter");
       }
       else
       {
          var posts = [];
          for(var i = 0; i < results.length; i++)
          {
              var post = results[i].get("post");
              var tokensNumber = numberOfTokensInPost(results[i].get("content"), tokens);
        
              var postDict = new Object();
              postDict["post"] = post;
              postDict["tokensNumber"] = tokensNumber;

              posts.push(postDict);
          }
           
           posts.sort(compare);
           posts = _.pluck(posts, "post");
           
           var uniqueIds = [];
           var uniquePosts = [];
           
           for(var i = 0; i < posts.length; i++)
           {
               var post = posts[i];

               if(post !== null && typeof post === 'object')
               {
                  if(!_.contains(uniqueIds, post.id))
                  {
                     uniquePosts.push(post);
                     uniqueIds.push(post.id);
                  }
               }

           }

           uniquePosts = uniquePosts.slice(skip, skip + limit);

           var responseDict = new Object();
           responseDict["posts"]   = uniquePosts;
           responseDict["keyword"] = request.params.keyword;
           responseDict["count"]   = uniquePosts.length;
           responseDict["limit"]   = limit;
           responseDict["skip"]    = skip;

           response.success(responseDict);
          }
       
     },
     error: function(error) 
     {
        if(error.code == 154)
        {
          response.error("Search phrase is too long. Please, reduce the number of words.");
        }
        else
        {
          response.error(error);
        }
       
     }
   });
   }



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

function compare(a, b) 
{
  if (a.tokensNumber > b.tokensNumber)
  {
    return -1;
  }
    
  if (a.tokensNumber < b.tokensNumber)
  {
     return 1;
  }
   
  return 0;
}

function numberOfTokensInPost(post, tokens)
{
  var tokensNumber = 0;
  
  for(var i = 0; i < tokens.length; i++)
  {
     var token = tokens[i];

     if(post.indexOf(" ".concat(token).concat(" ")) != -1)
     {
       tokensNumber++;
     }
  }

  return tokensNumber;
}

function tokensFromString(contentString) 
{
   var _ = require('underscore');

   var contentStr = contentString.replace(/<(?:.|\n)*?>/gm, '').toLowerCase();
   var tokens = contentStr.split(/[^A-Za-z]/);

   var toRemove = ['of', 'the', "in", "on", "at", "to", "a", "is", "for", "", "undefined", "as", "in", "and", "it", "any", "an", "or", "do", "does", "be", "with", "you", "that", "he", "was", "are", "i", "his", "they", "one", "have", "this", "from", "had", "by", "but", "some", "what", "there", "we", "can", "out", "other", "were", "all", "your", "up", "use", "she", "each", "has", "her"];

   tokens = tokens.filter( function( el ) 
   {
     if(el.length < 3)
     {
       return false;
     }
     return toRemove.indexOf( el ) < 0;
   });

   if(tokens.length > 0)
   {
     tokens = _.uniq(tokens, false);
   }

   return tokens;
}