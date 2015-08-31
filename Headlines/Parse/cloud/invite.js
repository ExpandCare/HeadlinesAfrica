Parse.Cloud.define("getListOfUsersFromEmailsList", function(request, response) 
{

  var User = Parse.Object.extend("User");
  var usersQuery = new Parse.Query(User);
  usersQuery.containedIn("email", request.params.emails);

  usersQuery.find(
  {
    success: function(results) 
    {
      console.log(results);
      console.log('RESULTS'.concat(results));
      response.success(results); 
    },
    error: function(error) 
    {
      response.error(error);
    }
  });

});