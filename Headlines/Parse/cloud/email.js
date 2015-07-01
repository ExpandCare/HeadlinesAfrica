var domain = 'sandboxb85831dca97e47ae9510e39032a837bc.mailgun.org',
    apiKey = 'key-1466082c429d6cf9e8b7c4f5da6cb4b3';
    
var Mailgun = require('mailgun');
Mailgun.initialize(domain, apiKey);

Parse.Cloud.define("resetPassword", function (request, response) { 
    var reqData = JSON.parse(request.body);
    
    var User = Parse.Object.extend("User");
    var query = new Parse.Query(User);
    
    var newPass = generatePass(8),
        email = reqData.email,
        subject = "Reset password",
        text = "New password: " + newPass;
        
    Parse.Cloud.useMasterKey();
    query.equalTo("email", email);
    
    query.first({
        success: function(object) {            
            if(object) {                  
                object.set("password", newPass);
                console.log("Find such = " + JSON.stringify(object));
                Parse.Cloud.useMasterKey();
                object.save().then(
                    function(user) {
                        console.log('Password changed', user);
                        
                        Mailgun.sendEmail({
                            to: email,
                            from: "Headlines@CloudCode.com",
                            subject: subject,
                            text: text
                        }, {
                            success: function(httpResponse) {
                                console.log(httpResponse);
                                response.success("Email sent!");
                            },
                            error: function(httpResponse) {
                                console.error(httpResponse);
                                response.error("Something wrong with email");
                            }
                        });
                        
                    },
                    function(error) {
                        console.log('Something went wrong with saving', JSON.stringify(error));
                        response.error("Something wrong with saving");
                    }
                );
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
    
    
});

function makeRand(max){
        // Generating random number from 0 to max (argument)
        return Math.floor(Math.random() * max);
}
function generatePass(len){
        // password Lenght
        var length = len;
        var result = '';
        // allowed characters
        var symbols = new Array(
                                'q','w','e','r','t','y','u','i','o','p',
                                'a','s','d','f','g','h','j','k','l',
                                'z','x','c','v','b','n','m',
                                'Q','W','E','R','T','Y','U','I','O','P',
                                'A','S','D','F','G','H','J','K','L',
                                'Z','X','C','V','B','N','M',
                                1,2,3,4,5,6,7,8,9,0
        );
        for (i = 0; i < length; i++){
                result += symbols[makeRand(symbols.length)];
        }
        return result;
}