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

var domain = 'sandboxb85831dca97e47ae9510e39032a837bc.mailgun.org',
   apiKey = 'key-1466082c429d6cf9e8b7c4f5da6cb4b3';
     
   var Mailgun = require('mailgun');
   Mailgun.initialize(domain, apiKey);
 
Parse.Cloud.job("reviewResources", function(request, response)
{
 
    var resources = [{
        source: 'Goal',
        category: 'Sports',
        country: 'Euro Soccer'
    }, {
        source: 'Linda Ikeji',
        category: 'Blogs',
        country: 'Nigeria'
    }, {
        source: 'Bella Naija',
        category: 'Blogs',
        country: 'Nigeria'
    }, {
        source: 'Punch',
        category: 'News',
        country: 'Nigeria'
    }, {
        source: 'Punch',
        category: 'Politics',
        country: 'Nigeria'
    }, {
        source: 'Punch',
        category: 'Business',
        country: 'Nigeria'
    }, {
        source: 'Punch',
        category: 'Sports',
        country: 'Nigeria'
    }, {
        source: 'Punch',
        category: 'Healthcare',
        country: 'Nigeria'
    }, {
        source: 'Vanguard',
        category: 'News',
        country: 'Nigeria'
    }, {
        source: 'Vanguard',
        category: 'Business',
        country: 'Nigeria'
    }, {
        source: 'Vanguard',
        category: 'Sports',
        country: 'Nigeria'
    }, {
        source: 'Vanguard',
        category: 'Politics',
        country: 'Nigeria'
    }, {
        source: 'Vanguard',
        category: 'Technology',
        country: 'Nigeria'
    }, {
        source: 'This Day Live',
        category: 'Healthcare',
        country: 'Nigeria'
    }, {
        source: 'This Day Live',
        category: 'Healthcare',
        country: 'Nigeria'
    }, {
        source: 'This Day Live',
        category: 'Politics',
        country: 'Nigeria'
    }, {
        source: 'This Day Live',
        category: 'News',
        country: 'Nigeria'
    }, {
        source: 'This Day Live',
        category: 'Sports',
        country: 'Nigeria'
    }, {
        source: 'This Day Live',
        category: 'Business',
        country: 'Nigeria'
    }, {
        source: 'Vibeghana',
        category: 'Politics',
        country: 'Ghana'
    }, {
        source: 'Vibeghana',
        category: 'Business',
        country: 'Ghana'
    }, {
        source: 'Vibeghana',
        category: 'Healthcare',
        country: 'Ghana'
    }, {
        source: 'Mail & Guardian',
        category: 'Business',
        country: 'South Africa'
    }, {
        source: 'Times Live',
        category: 'Business',
        country: 'South Africa'
    }, {
        source: 'Times Live',
        category: 'Food',
        country: 'South Africa'
    }, {
        source: 'Daily Guide',
        category: 'Business',
        country: 'Ghana'
    }, {
        source: 'Daily Guide',
        category: 'Politics',
        country: 'Ghana'
    }, {
        source: 'Daily Guide',
        category: 'Blogs',
        country: 'Ghana'
    }, {
        source: 'Daily Guide',
        category: 'Sports',
        country: 'Ghana'
    }, {
        source: 'Times Live',
        category: 'Politics',
        country: 'South Africa'
    }, {
        source: 'Angop',
        category: 'Business',
        country: 'Angola'
    }, {
        source: 'Angop',
        category: 'Healthcare',
        country: 'Angola'
    }, {
        source: 'Angop',
        category: 'Politics',
        country: 'Angola'
    }, {
        source: 'Angop',
        category: 'Blogs',
        country: 'Angola'
    }, {
        source: 'Angop',
        category: 'Sports',
        country: 'Angola'
    }, {
        source: 'Angop',
        category: 'Technology',
        country: 'Angola'
    }, {
        source: 'Egypt Independent',
        category: 'Business',
        country: 'Egypt'
    }, {
        source: 'Egypt Independent',
        category: 'Healthcare',
        country: 'Egypt'
    }, {
        source: 'Egypt Independent',
        category: 'Technology',
        country: 'Egypt'
    }, {
        source: 'Cameroon POSTline',
        category: 'Business',
        country: 'Cameroon'
    }, {
        source: 'Cameroon POSTline',
        category: 'Healthcare',
        country: 'Cameroon'
    }, {
        source: 'Cameroon POSTline',
        category: 'Sports',
        country: 'Cameroon'
    }, {
        source: 'BDlive',
        category: 'Business',
        country: 'South Africa'
    }, {
        source: 'BDlive',
        category: 'Healthcare',
        country: 'South Africa'
    }, {
        source: 'BDlive',
        category: 'Politics',
        country: 'South Africa'
    },{
        source: 'Fin24',
        category: 'Business',
        country: 'South Africa'
    }, {
        source: 'NBE',
        category: 'Business',
        country: 'Ethiopia'
    }, {
        source: 'NBE',
        category: 'Business',
        country: 'Ethiopia'
    }, {
        source: 'NBE',
        category: 'Business',
        country: 'Ethiopia'
    }, {
        source: 'Fin24',
        category: 'Business',
        country: 'South Africa'
    }, { 
        source: 'NBE',
        category: 'Healthcare',
        country: 'Ethiopia'
    }, {
        source: 'NBE',
        category: 'Politics',
        country: 'Ethiopia'
    }, {
        source: 'NBE',
        category: 'Technology',
        country: 'Ethiopia'
    }, {
        source: 'NBE',
        category: 'Blogs',
        country: 'Ethiopia'
    }, {
        source: 'Fin24',
        category: 'Business',
        country: 'South Africa'
    }, {
        source: 'Fin24',
        category: 'Technology',
        country: 'South Africa'
    }, {
        source: 'Kenyan Post',
        category: 'Politics',
        country: 'Kenya'
    }, {
        source: 'The Star',
        category: 'Blogs',
        country: 'Kenya'
    }, {
        source: 'The Star',
        category: 'Sports',
        country: 'Kenya'
    }, {
        source: 'The Star',
        category: 'Business',
        country: 'Kenya'
    }, {
        source: 'IOL',
        category: 'Sports',
        country: 'South Africa'
    }, {
        source: 'IOL',
        category: 'Blogs',
        country: 'South Africa'
    }, {
        source: 'IOL',
        category: 'Technology',
        country: 'South Africa'
    }, {
        source: 'IOL',
        category: 'Blogs',
        country: 'South Africa'
    },{
        source: 'Standard Digital',
        category: 'Business',
        country: 'Kenya'
    }, {
        source: 'Standard Digital',
        category: 'Technology',
        country: 'Kenya'
    }, {
        source: 'Ahram Online',
        category: 'Sports',
        country: 'Egypt'
     }, {
        source: 'Ahram Online',
        category: 'Blogs',
        country: 'Egypt'
    }, {
        source: 'Ahram Online',
        category: 'Blogs',
        country: 'Egypt'
    }, {
        source: 'Ahram Online',
        category: 'Politics',
        country: 'Egypt'
    }, {
        source: 'SDE',
        category: 'Blogs',
        country: 'Kenya'
    }, {
        source: 'Standart Media',
        category: 'Business',
        country: 'Kenya'
    }, {
        source: 'Standart Media',
        category: 'Healthcare',
        country: 'Kenya'
    }, {
        source: 'Cameroon Online',
        category: 'Sports',
        country: 'Cameroon'
    }, {
        source: 'Cameroon Online',
        category: 'Technology',
        country: 'Cameroon'
    }, {
        source: 'Cameroon Online',
        category: 'Politics',
        country: 'Cameroon'
    }, {
        source: 'Cameroon Online',
        category: 'Blogs',
        country: 'Cameroon'
    }, {
        source: 'Ahram Online',
        category: 'Business',
        country: 'Egypt'
    }, {
        source: 'All Ghana News',
        category: 'Politics',
        country: 'Ghana'
    }, {
        source: 'All Ghana News',
        category: 'Business',
        country: 'Ghana'
    }, {
        source: 'All Ghana News',
        category: 'Healthcare',
        country: 'Ghana'
    }, {
        source: 'All Ghana News',
        category: 'Sports',
        country: 'Ghana'
    }, {
        source: 'All Ghana News',
        category: 'Technology',
        country: 'Ghana'
    }, {
        source: 'Vibeghana',
        category: 'Blogs',
        country: 'Ghana'
    }, {
        source: 'Morocco World News',
        category: 'Sports',
        country: 'Morocco'
    }, {
        source: 'Morocco World News',
        category: 'Healthcare',
        country: 'Morocco'
    }, {
        source: 'Morocco World News',
        category: 'Business',
        country: 'Morocco'
    }, {
        source: 'Morocco World News',
        category: 'Blogs',
        country: 'Morocco'
    }, {
        source: 'Morocco World News',
        category: 'Politics',
        country: 'Morocco'
    }, {
        source: 'Morocco World News',
        category: 'Technology',
        country: 'Morocco'
    }, {
        source: 'Daily News Egypt',
        category: 'Politics',
        country: 'Egypt'
    }, {
        source: 'Graphic Online',
        category: 'Business',
        country: 'Ghana'
    }, {
        source: 'The Chronicle',
        category: 'Business',
        country: 'Ghana'
    }, {
        source: 'The Chronicle',
        category: 'Healthcare',
        country: 'Ghana'
    }
    ];
  
    var i = 0;
    var resultStr = "RESOURCES COUNT: ".concat(resources.length).concat("\n");
    var currentDate = new Date();
    for(var j = 0; j < resources.length; j++)
    {
      var resource = resources[j];
      var Post = Parse.Object.extend("Post");
      var contentQuery = new Parse.Query(Post);
      contentQuery.equalTo("source", resource.source);
      contentQuery.equalTo("category", resource.category);
      contentQuery.equalTo("country", resource.country);
      contentQuery.limit(1);
      contentQuery.descending("createdAt");
       
      contentQuery.find(
      {
         success: function(results) 
         {
           if(results.length > 0)
           {
            var daysDiff = dayDiff(results[0].createdAt, currentDate);
            resultStr = resultStr.concat(i).concat(":").concat(results[0].get("country")).concat("; ").concat(results[0].get("category")).concat("; ").concat(results[0].get("source")).concat("; days = ").concat(daysDiff);
           }
           else
           {
            resultStr = resultStr.concat(i).concat(":").concat(" NO POSTS");
           }
 
           resultStr = resultStr.concat("\n");
             
           ++i;
 
           if(i == resources.length)
           {
              Mailgun.sendEmail({
                            to: request.params.email,
                            from: "Headlines@CloudCode.com",
                            subject:  "Reviewed resources",
                            text: resultStr
                        }, {
                            success: function(httpResponse) {
                            },
                            error: function(httpResponse) {
                            }
                        });
             response.success();
           }
        
         },
         error: function(error) 
         {
           resultStr = resultStr.concat(i).concat(":").concat("ERROR:");
           resultStr = resultStr.concat("\n");
           ++i;
 
           if(i == resources.length)
           {
              Mailgun.sendEmail({
                            to: request.params.email,
                            from: "Headlines@CloudCode.com",
                            subject: "Reviewed resources",
                            text: resultStr
                        }, {
                            success: function(httpResponse) {
                            },
                            error: function(httpResponse) {
                            }
                        });
             response.success();
           }
         }
      });
 
 
    }
 
     
});
 
function dayDiff(startdate, enddate) {
  var dayCount = 0;
 
  while(enddate >= startdate) {
    dayCount++;
    startdate.setDate(startdate.getDate() + 1);
  }
 
return dayCount; 
}
