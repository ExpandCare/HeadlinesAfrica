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
        subQuery.contains("content", token);
        queries.push(subQuery);
      }

      var contentQuery = Parse.Query.or.apply(Parse.Query, queries);
      contentQuery.include("post");
      contentQuery.limit(500);
      contentQuery.descending("createdAt");
      contentQuery.skip(0);

      var searchPosts = [];

   getPosts(contentQuery, searchPosts,  {
        success: function(resultPosts)
        {
            if(skip < 0) 
            {
              response.error("Incorrect skip parameter");
            }
            else
            {

              var posts = [];
              for(var i = 0; i < resultPosts.length; i++)
              {
                 var post = resultPosts[i].get("post");
                 var tokensNumber = numberOfTokensInPost(resultPosts[i].get("content"), tokens);
                 
                 var isFoundPost = new Boolean(false);
                 
                 for(var j = 0; j < posts.length; j++)
                 {

                   var addedDict = posts[j];
                   var addedPost = addedDict['post'];
                   if(post && addedPost && addedPost.id == post.id)
                   {
                     addedDict["tokensNumber"] = addedDict["tokensNumber"] + tokensNumber;
                     posts[j] = addedDict;
                     isFoundPost = true;
                     break;
                   }

                 }

                 if(isFoundPost == false && post && post.get('title'))
                 {
                    
                    var postDict = new Object();
                    postDict["post"] = post;
                    postDict["tokensNumber"] = tokensNumber;
                    posts.push(postDict);
                 }

                 
              }
           
              posts.sort(compare);
              posts = _.pluck(posts, "post");
            
              posts = posts.slice(skip, skip + limit);
 
              var responseDict = new Object();
              responseDict["posts"]   = posts;
              responseDict["keyword"] = request.params.keyword;
              responseDict["count"]   = posts.length;
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

function getPosts(query, posts, response)
{
  query.find(
  {
     success: function(results) 
     {
       if(results.length > 0 && query._skip < 1500)
       {
         console.log('SKIP = '.concat(query._skip));
         posts.push.apply(posts, results);
         query.skip(query._skip + query._limit);
         getPosts(query, posts, response);
       }
       else
       {
         response.success(posts);
       }
     },
     error: function(error) 
     {
        response.error(error);
     }
  });
}

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

     if(post.indexOf(token) != -1)
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