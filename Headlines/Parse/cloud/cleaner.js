Parse.Cloud.job("cleaner", function(request, status){
    Parse.Cloud.useMasterKey();  
    var reqData = JSON.parse(request.body);
    console.log("Request = " + reqData.table);
    
    var Post = Parse.Object.extend(reqData.table);
    var query = new Parse.Query(Post);
    
    function deletePosts (status) {
        query.find({
            success: function(list) {
                console.log("Length = " + list.length);            

                Parse.Object.destroyAll(list).then(function(success) {
                    console.log('Delete');
                    
                    query.find({
                        success: function (list) {
                            if (list.length) {
                                console.log('Posts are still exist');
                                deletePosts(status);
                            } else {
                                console.log('No posts');
                                status.success("Cleaner success complete");
                            }
                        },
                        error: function (error) {
                            status.error("Somth going wrong with finding: " + JSON.stringify(err));
                        }
                    });
                    
                }, function(error) {
                    console.log('delete error');
                    status.error("Oops! Something went wrong: " + error.message + " (" + error.code + ")");
                });
            },
            error: function (error) {
                status.error("Somth going wrong with finding: " + JSON.stringify(err));
            }
        });
    }
    
    deletePosts (status);
    
});