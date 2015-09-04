var _ = require('underscore');

var apiKey = 'DhIV5y1Jq2KrQkF8dSQ2dB%2FGaQg2bkWyOZwJIC4xYxvqYCiKf8eNxAd4nZRO4horaieDysNnMq0xPUdp%2BMoIew%3D%3D',
    user = '1626111a-cea3-459f-ab82-a25a3548c34a',
    Post = Parse.Object.extend("Post");

function deleteBrokenPosts(status) {
    Parse.Cloud.useMasterKey();
    var Post = Parse.Object.extend('Post');
    var query = new Parse.Query(Post);

    function deletePosts(status) {
        query.equalTo("content", undefined);
        query.equalTo("content", "undefined");
        query.equalTo("content", "");
        query.doesNotExist("content");
        query.find({
            success: function(list) {
                console.log("Length of empty= " + list.length);
                if (list.length) {
                    Parse.Object.destroyAll(list).then(function(success) {
                        console.log('Delete success');
                        status.success('Job complete');
                    }, function(error) {
                        console.log('delete error');
                        status.error("Oops! Something went wrong: " + error.message + " (" + error.code + ")");
                    });
                } else {
                    console.log('Nothing to delete');
                    status.success('Job complete');
                }

            },
            error: function(error) {
                status.error("Somth going wrong with finding: " + JSON.stringify(error));
            }
        });
    }

    deletePosts(status);
}

function checkPosts(arr, options) 
{
    for (var i = 0; i < options.length; i++) {
        for (var j = 0; j < arr.length; j++) {
            if (!arr[j].get(options[i])) {
                arr.splice(j, 1);
                console.log('Delete post without content');
            }
        }
    }
    return arr;
}

function savePosts(response, options, cbNext) {
    var jsonResults = JSON.parse(response),
        postsArr = [],
        actions = [],
        post = {},
        checkedPosts = [];

    if (!jsonResults.results || !jsonResults.results.length)
    {
        console.log('No results for saving');
        cbNext();
    }
     else if (jsonResults.results.error) 
     {
        console.log('Import.io error');
        cbNext();
    } 
    else 
    {

        for (var i = 0; i < jsonResults.results.length; i++) 
        {
            post = new Post();

            var title = jsonResults.results[i]['title/_text'] || '',
                author = jsonResults.results[i]['author'] || '',
                image = jsonResults.results[i]['image'] || '',
                preview = jsonResults.results[i]['preview'] || '',
                link = jsonResults.results[i]['title'] || '',
                category = options.category || 'blogs',
                source = options.source || 'no source';

            if (typeof image === "string") 
            {
                image = [image];
            }

            post.set({
                title: title,
                author: author,
                image: image,
                preview: preview,
                link: link,
                category: category,
                country: options.country,
                source: source,
                sharesCount: 0
            });

            postsArr.push(post);
        }

        var acts = [];

        for (var i = 0; i < postsArr.length; i++) {
            acts.push(isPostExist(postsArr[i].get('title'), postsArr));
        }

        function isPostExist(title, postsArr) 
        {
            return function(next)
             {
                Parse.Cloud.useMasterKey();
                var Post = Parse.Object.extend('Post');
                var query = new Parse.Query(Post);

                query.equalTo("title", title);
                query.first({
                    success: function(object) 
                    {
                        if (object) 
                        {                    
                        } 
                        else 
                        {
                            for (var i = 0; i < postsArr.length; i++)
                             {                                 
                                if (postsArr[i].get('title') === title) 
                                {
                                    checkedPosts.push(postsArr[i]);
                                }
                            }
                        }
                        next();
                    },
                    error: function(error) 
                    {
                        console.log("Error: " + error.code + " " + error.message);
                        next();
                    }
                });
            };
        }

        _(acts).reduceRight(_.wrap, function() 
        {

            postsArr = checkedPosts;

            for (var i = 0; i < postsArr.length; i++) {
                if (options.source === 'This Day Live') {
                    actions.push(getThisDayPost(postsArr[i].get('link')));
                }
                if (options.source === 'Vanguard') {
                    actions.push(getVanguardPost(postsArr[i].get('link')));
                }
                if (options.source === 'Punch') {
                    actions.push(getPunchPost(postsArr[i].get('link')));
                }
                if (options.source === 'Linda Ikeji') {
                    actions.push(getLindaIkejiPost(postsArr[i].get('link')));
                }
                if (options.source === 'Bella Naija') {
                    actions.push(getBellaNaijaPost(postsArr[i].get('link')));
                }
                if (options.source === 'Goal') {
                    actions.push(getGoalPost(postsArr[i].get('link')));
                }
                if (options.source === 'Vibeghana') {
                    actions.push(getVibeghanaPost(postsArr[i].get('link')));
                }
                if (options.source === 'Mail & Guardian') {
                    actions.push(getMailAndGuardianPost(postsArr[i].get('link')));
                }
                if (options.source === 'Times Live') {
                    actions.push(getLiveTimesPost(postsArr[i].get('link')));
                }
                if (options.source === 'Angop') {
                    actions.push(getAngopPost(postsArr[i].get('link')));
                }
                if (options.source === 'Daily Guide') {
                    actions.push(getDailyGuideGhanaPost(postsArr[i].get('link')));
                }
                if (options.source === 'Egypt Independent') {
                    actions.push(getEgyptIndependentPost(postsArr[i].get('link')));
                }
                if (options.source === 'Cameroon POSTline') {
                    actions.push(getCameroonPostlinePost(postsArr[i].get('link')));
                }
                if (options.source === 'BDlive') {
                    actions.push(getBDLivePost(postsArr[i].get('link')));
                }
                if (options.source === 'Fin24') {
                    actions.push(getFin24Post(postsArr[i].get('link')));
                }
                if (options.source === 'Kenyan Post') {
                    actions.push(getKenyaPostPost(postsArr[i].get('link')));
                }
                if (options.source === 'The Star') {
                    actions.push(getTheStarPost(postsArr[i].get('link')));
                }
                if (options.source === 'Standard Digital') {
                    actions.push(getStandardPost(postsArr[i].get('link')));
                }
                if (options.source === 'NBE') {
                    actions.push(getNBEPost(postsArr[i].get('link')));
                };
                if (options.source === 'IOL') {
                    actions.push(getIOLPost(postsArr[i].get('link')));
                };
                if (options.source === 'Ahram Online') {
                    actions.push(getAhramOnlinePost(postsArr[i].get('link')));
                };
                if (options.source === 'SDE') {
                    actions.push(getSDEPost(postsArr[i].get('link')));
                };
                if (options.source === 'Standart Media') {
                    actions.push(getStandartMediaPost(postsArr[i].get('link')));
                };
                if (options.source === 'Cameroon Online') {
                    actions.push(getCameroonOnlinePost(postsArr[i].get('link')));
                };
                if (options.source === 'All Ghana News') {
                    actions.push(getAllGhanaNewsPost(postsArr[i].get('link')));
                };
                if (options.source === 'Morocco World News') {
                    actions.push(getMoroccoWorldNewsPost(postsArr[i].get('link')));
                };
            }

            _(actions).reduceRight(_.wrap, function() {
                postsArr = checkPosts(postsArr, ['content']);
                Parse.Object.saveAll(postsArr, {
                    success: function(objs) {
                        cbNext();
                    },
                    error: function(error) {
                        console.log('Multisaving error');
                        console.log(JSON.stringify(error));
                        cbNext();
                    }
                });
            })();

            function getStandardPost(url) {
                
                return function(next) {
                    var body = JSON.stringify({
                        "input": {
                            "webpage/url": url
                        }
                    });

                    Parse.Cloud.httpRequest({
                        method: 'POST',
                        url: "https://api.import.io/store/data/07ffc3fb-51cf-4a49-bc84-f1cb40c6648a/_query?_user=" + user + "&_apikey=" + apiKey,
                        body: body,
                        success: function(httpResponse) {
                            var data = JSON.parse(httpResponse.text);

                            for (var i = 0; i < postsArr.length; i++) {
                                if (postsArr[i].get('link') === url) {
                                    //Content
                                    if (data.results && data.results[0] && data.results[0].content) {

                                        if (typeof data.results[0].content === "string") {
                                            postsArr[i].set("content", data.results[0].content);
                                        } else {
                                            postsArr[i].set("content", data.results[0].content.join(''));
                                        }
                                    }

                                    //Author
                                    if (data.results && data.results[0] && data.results[0].author) {

                                        if (typeof data.results[0].author === "string") {
                                            postsArr[i].set("author", data.results[0].author);
                                        }
                                    }

                                     //images
                                     if (data.results && data.results[0] && data.results[0].image) {
                                         if (typeof data.results[0].image === "string") {
                                             postsArr[i].set("image", [data.results[0].image]);
                                         } else {
                                             postsArr[i].set("image", data.results[0].image);
                                         }
                                     }
                                }
                            }

                            console.log("Success: " + httpResponse.text);
                            next();
                        },
                        error: function(httpResponse) {
                            console.log("Error: " + httpResponse.text);
                            next();
                        }
                    });
                }
            }

            function getTheStarPost(url) {
                return function(next) {
                    var body = JSON.stringify({
                        "input": {
                            "webpage/url": url
                        }
                    });

                    Parse.Cloud.httpRequest({
                        method: 'POST',
                        url: "https://api.import.io/store/data/a6ed102e-fec2-4f9e-a0c7-222635aae36c/_query?_user=" + user + "&_apikey=" + apiKey,
                        body: body,
                        success: function(httpResponse) {
                            var data = JSON.parse(httpResponse.text);

                            for (var i = 0; i < postsArr.length; i++) {
                                if (postsArr[i].get('link') === url) {
                                    //Content
                                    if (data.results && data.results[0] && data.results[0].content) {

                                        if (typeof data.results[0].content === "string") {
                                            postsArr[i].set("content", data.results[0].content);
                                        } else {
                                            postsArr[i].set("content", data.results[0].content.join(''));
                                        }
                                    }

                                    //Author
                                    if (data.results && data.results[0] && data.results[0].author) {

                                        if (typeof data.results[0].author === "string") {
                                            postsArr[i].set("author", data.results[0].author);
                                        }
                                    }

                                     //images
                                     if (data.results && data.results[0] && data.results[0].image) {
                                         if (typeof data.results[0].image === "string") {
                                             postsArr[i].set("image", [data.results[0].image]);
                                         } else {
                                             postsArr[i].set("image", data.results[0].image);
                                         }
                                     }
                                }
                            }

                            console.log("Success: " + httpResponse.text);
                            next();
                        },
                        error: function(httpResponse) {
                            console.log("Error: " + httpResponse.text);
                            next();
                        }
                    });
                }
            }

            function getKenyaPostPost(url) {

                return function(next) {
                    var body = JSON.stringify({
                        "input": {
                            "webpage/url": url
                        }
                    });

                    Parse.Cloud.httpRequest({
                        method: 'POST',
                        url: "https://api.import.io/store/data/21b0d2f9-8eb1-4a14-a534-374cbe54eb4d/_query?_user=" + user + "&_apikey=" + apiKey,
                        body: body,
                        success: function(httpResponse) {
                            var data = JSON.parse(httpResponse.text);

                            for (var i = 0; i < postsArr.length; i++) {
                                if (postsArr[i].get('link') === url) {
                                    //Content
                                    if (data.results && data.results[0] && data.results[0].content) {

                                        if (typeof data.results[0].content === "string") {
                                            postsArr[i].set("content", data.results[0].content);
                                        } else {
                                            postsArr[i].set("content", data.results[0].content.join(''));
                                        }
                                    }

                                     //images
                                     if (data.results && data.results[0] && data.results[0].image) {
                                         if (typeof data.results[0].image === "string") {
                                             postsArr[i].set("image", [data.results[0].image]);
                                         } else {
                                             postsArr[i].set("image", data.results[0].image);
                                         }
                                     }
                                }
                            }

                            console.log("Success: " + httpResponse.text);
                            next();
                        },
                        error: function(httpResponse) {
                            console.log("Error: " + httpResponse.text);
                            next();
                        }
                    });
                }
            }

            function getNBEPost (url) {
            
                return function(next) {
                    var body = JSON.stringify({
                        "input": {
                            "webpage/url": url
                        }
                    });

                    Parse.Cloud.httpRequest({
                        method: 'POST',
                        url: "https://api.import.io/store/data/e007045f-1a33-4d66-8980-0c8285d4c232/_query?_user=" + user + "&_apikey=" + apiKey,
                        body: body,
                        success: function(httpResponse) {
                            var data = JSON.parse(httpResponse.text);

                            for (var i = 0; i < postsArr.length; i++) {
                                if (postsArr[i].get('link') === url) {
                                    //Content
                                    if (data.results && data.results[0] && data.results[0].content) {

                                        if (typeof data.results[0].content === "string") {
                                            postsArr[i].set("content", data.results[0].content);
                                        } else {
                                            postsArr[i].set("content", data.results[0].content.join(''));
                                        }
                                    }

                                     //images
                                     if (data.results && data.results[0] && data.results[0].image) {
                                         if (typeof data.results[0].image === "string") {
                                             postsArr[i].set("image", [data.results[0].image]);
                                         } else {
                                             postsArr[i].set("image", data.results[0].image);
                                         }
                                     }
                                }
                            }

                            console.log("Success: " + httpResponse.text);
                            next();
                        },
                        error: function(httpResponse) {
                            console.log("Error: " + httpResponse.text);
                            next();
                        }
                    });
                }
            }

            function getVibeghanaPost(url) {

                return function(next) {
                    var body = JSON.stringify({
                        "input": {
                            "webpage/url": url
                        }
                    });

                    Parse.Cloud.httpRequest({
                        method: 'POST',
                        url: "https://api.import.io/store/data/15638383-f437-49a6-8ec6-248ca8bcc71c/_query?_user=" + user + "&_apikey=" + apiKey,
                        body: body,
                        success: function(httpResponse) {
                            var data = JSON.parse(httpResponse.text);

                            for (var i = 0; i < postsArr.length; i++) {
                                if (postsArr[i].get('link') === url) {
                                    //Content
                                    if (data.results && data.results[0] && data.results[0].content) {

                                        if (typeof data.results[0].content === "string") {
                                            postsArr[i].set("content", data.results[0].content);
                                        } else {
                                            postsArr[i].set("content", data.results[0].content.join(''));
                                        }
                                    }

                                     //images
                                     if (data.results && data.results[0] && data.results[0].image) {
                                         if (typeof data.results[0].image === "string") {
                                             postsArr[i].set("image", [data.results[0].image]);
                                         } else {
                                             postsArr[i].set("image", data.results[0].image);
                                         }
                                     }
                                }
                            }

                            console.log("Success: " + httpResponse.text);
                            next();
                        },
                        error: function(httpResponse) {
                            console.log("Error: " + httpResponse.text);
                            next();
                        }
                    });
                }
            }

            function getAngopPost(url) {

                return function(next) {
                    var body = JSON.stringify({
                        "input": {
                            "webpage/url": url
                        }
                    });

                    Parse.Cloud.httpRequest({
                        method: 'POST',
                        url: "https://api.import.io/store/data/48c4a7e5-80e2-4533-8148-b9dda37540bd/_query?_user=" + user + "&_apikey=" + apiKey,
                        body: body,
                        success: function(httpResponse) {
                            var data = JSON.parse(httpResponse.text);

                            for (var i = 0; i < postsArr.length; i++) {
                                if (postsArr[i].get('link') === url) {
                                    //Content
                                    if (data.results && data.results[0] && data.results[0].content) {

                                        if (typeof data.results[0].content === "string") {
                                            postsArr[i].set("content", data.results[0].content);
                                        } else {
                                            postsArr[i].set("content", data.results[0].content.join(''));
                                        }
                                    }

                                    //images
                                    if (data.results && data.results[0] && data.results[0].image) {
                                        if (typeof data.results[0].image === "string") {
                                            postsArr[i].set("image", [data.results[0].image]);
                                        } else {
                                            postsArr[i].set("image", data.results[0].image);
                                        }
                                    }
                                }
                            }

                            console.log("Success: " + httpResponse.text);
                            next();
                        },
                        error: function(httpResponse) {
                            console.log("Error: " + httpResponse.text);
                            next();
                        }
                    });
                }
            }

            function getDailyGuideGhanaPost(url) {

                return function(next) {
                    var body = JSON.stringify({
                        "input": {
                            "webpage/url": url
                        }
                    });

                    Parse.Cloud.httpRequest({
                        method: 'POST',
                        url: "https://api.import.io/store/data/c7e9fbb0-ec12-46e0-92d1-1d2cf108510c/_query?_user=" + user + "&_apikey=" + apiKey,
                        body: body,
                        success: function(httpResponse) {
                            var data = JSON.parse(httpResponse.text);

                            for (var i = 0; i < postsArr.length; i++) 
                            {
                                if (postsArr[i].get('link') === url)
                                 {
                                    //Content
                                    if (data.results && data.results[0] && data.results[0].content)
                                     {

                                        if (typeof data.results[0].content === "string")
                                        {
                                            postsArr[i].set("content", data.results[0].content);
                                        } 
                                        else 
                                        {
                                            postsArr[i].set("content", data.results[0].content.join(''));
                                        }
                                    }

                                    
                                }
                            }

                            console.log("Success: " + httpResponse.text);
                            next();
                        },
                        error: function(httpResponse) {
                            console.log("Error: " + httpResponse.text);
                            next();
                        }
                    });
                }
            }

            function getThisDayPost(url) {

                return function(next) {
                    var body = JSON.stringify({
                        "input": {
                            "webpage/url": url
                        }
                    });

                    Parse.Cloud.httpRequest({
                        method: 'POST',
                        url: "https://api.import.io/store/data/f34758d0-5ed0-4ca7-88f8-0e2fbade2d56/_query?_user=" + user + "&_apikey=" + apiKey,
                        body: body,
                        success: function(httpResponse) {
                            var data = JSON.parse(httpResponse.text);

                            for (var i = 0; i < postsArr.length; i++) {
                                if (postsArr[i].get('link') === url) {
                                    //Content
                                    if (data.results && data.results[0].content) {

                                        if (typeof data.results[0].content === "string") {
                                            postsArr[i].set("content", data.results[0].content);
                                        } else {
                                            postsArr[i].set("content", data.results[0].content.join(''));
                                        }
                                    }
                                    //images
                                    if (data.results && data.results[0].image) {
                                        if (typeof data.results[0].image === "string") {
                                            postsArr[i].set("image", [data.results[0].image]);
                                        } else {
                                            postsArr[i].set("image", data.results[0].image);
                                        }
                                    }
                                }
                            }

                            console.log("Success: " + httpResponse.text);
                            next();
                        },
                        error: function(httpResponse) {
                            console.log("Error: " + httpResponse.text);
                            next();
                        }
                    });
                }
            }

            function getVanguardPost(url) {

                return function(next) {
                    var body = JSON.stringify({
                        "input": {
                            "webpage/url": url
                        }
                    });

                    Parse.Cloud.httpRequest({
                        method: 'POST',
                        url: "https://api.import.io/store/data/e324c678-6d32-44a6-ad05-249e7d6c7991/_query?_user=" + user + "&_apikey=" + apiKey,
                        body: body,
                        success: function(httpResponse) {
                            var data = JSON.parse(httpResponse.text);

                            for (var i = 0; i < postsArr.length; i++) {
                                if (postsArr[i].get('link') === url) {
                                    //Content
                                    if (data.results && data.results[0].content) {

                                        if (typeof data.results[0].content === "string") {
                                            postsArr[i].set("content", data.results[0].content);
                                        } else {
                                            postsArr[i].set("content", data.results[0].content.join(''));
                                        }
                                    }
                                }
                            }

                            console.log("Success: " + httpResponse.text);
                            next();
                        },
                        error: function(httpResponse) {
                            console.log("Error: " + httpResponse.text);
                            next();
                        }
                    });
                }
            }

            function getPunchPost(url) {

                return function(next) {
                    var body = JSON.stringify({
                        "input": {
                            "webpage/url": url
                        }
                    });

                    Parse.Cloud.httpRequest({
                        method: 'POST',
                        url: "https://api.import.io/store/data/3ee5c573-beae-4d38-bb95-0823dcdf9d97/_query?_user=" + user + "&_apikey=" + apiKey,
                        body: body,
                        success: function(httpResponse) {
                            var data = JSON.parse(httpResponse.text);

                            for (var i = 0; i < postsArr.length; i++) {
                                if (postsArr[i].get('link') === url) {
                                    //Content
                                    if (data.results && data.results[0].content) {

                                        if (typeof data.results[0].content === "string") {
                                            postsArr[i].set("content", data.results[0].content);
                                        } else {
                                            postsArr[i].set("content", data.results[0].content.join(''));
                                        }
                                    }
                                    //images
                                    if (data.results && data.results[0].image) {
                                        if (typeof data.results[0].image === "string") {
                                            postsArr[i].set("image", [data.results[0].image]);
                                        } else {
                                            postsArr[i].set("image", data.results[0].image);
                                        }
                                    }
                                }
                            }

                            console.log("Success: " + httpResponse.text);
                            next();
                        },
                        error: function(httpResponse) {
                            console.log("Error: " + httpResponse.text);
                            next();
                        }
                    });
                }
            }

            function getLindaIkejiPost(url) {

                return function(next) {
                    var body = JSON.stringify({
                        "input": {
                            "webpage/url": url
                        }
                    });

                    Parse.Cloud.httpRequest({
                        method: 'POST',
                        url: "https://api.import.io/store/data/8c61161a-c96d-4cf5-a2f1-2b5a3b131069/_query?_user=" + user + "&_apikey=" + apiKey,
                        body: body,
                        success: function(httpResponse) {
                            var data = JSON.parse(httpResponse.text);

                            for (var i = 0; i < postsArr.length; i++) {
                                if (postsArr[i].get('link') === url) {
                                    //Content
                                    if (data.results && data.results[0].content) {
                                        postsArr[i].set("author", 'Linda Ikeji');
                                        if (typeof data.results[0].content === "string") {
                                            postsArr[i].set("content", data.results[0].content);
                                        } else {
                                            postsArr[i].set("content", data.results[0].content.join(''));
                                        }
                                    }
                                }
                            }

                            console.log("Success: " + httpResponse.text);
                            next();
                        },
                        error: function(httpResponse) {
                            console.log("Error: " + httpResponse.text);
                            next();
                        }
                    });
                }
            }

            function getBellaNaijaPost(url) {

                return function(next) {
                    var body = JSON.stringify({
                        "input": {
                            "webpage/url": url
                        }
                    });

                    Parse.Cloud.httpRequest({
                        method: 'POST',
                        url: "https://api.import.io/store/data/6f7ed017-aebe-411c-8a20-430610cb1a45/_query?_user=" + user + "&_apikey=" + apiKey,
                        body: body,
                        success: function(httpResponse) {
                            var data = JSON.parse(httpResponse.text);

                            for (var i = 0; i < postsArr.length; i++) {
                                if (postsArr[i].get('link') === url) {
                                    //Content
                                    if (data.results && data.results[0].content) {
                                        postsArr[i].set("author", 'Bella Naija');
                                        if (typeof data.results[0].content === "string") {
                                            postsArr[i].set("content", data.results[0].content);
                                        } else {
                                            postsArr[i].set("content", data.results[0].content.join(''));
                                        }
                                    }
                                }
                            }

                            console.log("Success: " + httpResponse.text);
                            next();
                        },
                        error: function(httpResponse) {
                            console.log("Error: " + httpResponse.text);
                            next();
                        }
                    });
                }
            }
            
            function getGoalPost(url) {

                return function(next) {
                    var body = JSON.stringify({
                        "input": {
                            "webpage/url": url
                        }
                    });

                    Parse.Cloud.httpRequest({
                        method: 'POST',                        
                        url: "https://api.import.io/store/data/752213c9-8dc8-44b1-9195-41eaca45f120/_query?_user=" + user + "&_apikey=" + apiKey,
                        body: body,
                        success: function(httpResponse) {
                            var data = JSON.parse(httpResponse.text);
                           // console.log(data);

                            for (var i = 0; i < postsArr.length; i++) {
                                if (postsArr[i].get('link') === url) {
                                    //Content
                                    if (data.results && data.results[0] && data.results[0].content) {
                                        if (data.results[0].author) postsArr[i].set("author", data.results[0].author);
                                        if (data.results[0].image) postsArr[i].set("image", [data.results[0].image]);
                                        if (typeof data.results[0].content === "string") {
                                            postsArr[i].set("content", data.results[0].content);
                                        } else {//	                                        
                                            postsArr[i].set("content", data.results[0].content.join(''));
                                        }
                                    }
                                }
                            }

                            console.log("Success: " + httpResponse.text);
                            next();
                        },
                        error: function(httpResponse) {
                            console.log("Error: " + httpResponse.text);
                            next();
                        }
                    });
                }
            }

            function getMailAndGuardianPost(url) {

                return function(next) {
                    var body = JSON.stringify({
                        "input": {
                            "webpage/url": url
                        }
                    });

                    Parse.Cloud.httpRequest({
                        method: 'POST',                        
                        url: "https://api.import.io/store/data/45aebd4c-d87b-406c-98c8-0a18978a7dcd/_query?_user=" + user + "&_apikey=" + apiKey,
                        body: body,
                        success: function(httpResponse) {
                            var data = JSON.parse(httpResponse.text);
                           // console.log(data);

                            for (var i = 0; i < postsArr.length; i++) {
                                if (postsArr[i].get('link') === url) {
                                    //Content
                                    if (data.results && data.results[0] && data.results[0].content) {
                                        if (data.results[0].image) postsArr[i].set("image", [data.results[0].image]);
                                        if (typeof data.results[0].content === "string") {
                                            postsArr[i].set("content", data.results[0].content);
                                        } else {//                                          
                                            postsArr[i].set("content", data.results[0].content.join(''));
                                        }
                                    }
                                }
                            }

                            console.log("Success: " + httpResponse.text);
                            next();
                        },
                        error: function(httpResponse) {
                            console.log("Error: " + httpResponse.text);
                            next();
                        }
                    });
                }
            }

            function getLiveTimesPost(url) {

                return function(next) {
                    var body = JSON.stringify({
                        "input": {
                            "webpage/url": url
                        }
                    });

                    Parse.Cloud.httpRequest({
                        method: 'POST',                        
                        url: "https://api.import.io/store/data/fc2e0a32-d864-4de0-b2da-bb5055259696/_query?_user=" + user + "&_apikey=" + apiKey,
                        body: body,
                        success: function(httpResponse) {
                            var data = JSON.parse(httpResponse.text);
                          //  console.log(data);

                            for (var i = 0; i < postsArr.length; i++) {
                                if (postsArr[i].get('link') === url) {
                                    if (data.results && data.results[0] && data.results[0].author) postsArr[i].set("author", data.results[0].author);
                                    //Content
                                    if (data.results && data.results[0] && data.results[0].content) {
                                        if (typeof data.results[0].content === "string") {
                                            postsArr[i].set("content", data.results[0].content);
                                        } else {//                                          
                                            postsArr[i].set("content", data.results[0].content.join(''));
                                        }
                                    }
                                }
                            }

                            console.log("Success: " + httpResponse.text);
                            next();
                        },
                        error: function(httpResponse) {
                            console.log("Error: " + httpResponse.text);
                            next();
                        }
                    });
                }
            }

            function getEgyptIndependentPost(url) {

                return function(next) {
                    var body = JSON.stringify({
                        "input": {
                            "webpage/url": url
                        }
                    });

                    Parse.Cloud.httpRequest({
                        method: 'POST',                        
                        url: "https://api.import.io/store/data/213ccf53-bcb0-475d-8caa-eec9c4e99164/_query?_user=" + user + "&_apikey=" + apiKey,
                        body: body,
                        success: function(httpResponse) {
                            var data = JSON.parse(httpResponse.text);
                           // console.log(data);

                            for (var i = 0; i < postsArr.length; i++) {
                                if (postsArr[i].get('link') === url) {
                                     if (data.results && data.results[0] && data.results[0].image) postsArr[i].set("image", [data.results[0].image]);
                                     if (data.results && data.results[0] && data.results[0].author) postsArr[i].set("author", data.results[0].author);
                                    //Content
                                    if (data.results && data.results[0] && data.results[0].content) {
                                        if (typeof data.results[0].content === "string") {
                                            postsArr[i].set("content", data.results[0].content);
                                        } else {//                                          
                                            postsArr[i].set("content", data.results[0].content.join(''));
                                        }
                                    }
                                }
                            }

                            console.log("Success: " + httpResponse.text);
                            next();
                        },
                        error: function(httpResponse) {
                            console.log("Error: " + httpResponse.text);
                            next();
                        }
                    });
                }
            }

            function getCameroonPostlinePost(url) {

                return function(next) {
                    var body = JSON.stringify({
                        "input": {
                            "webpage/url": url
                        }
                    });

                    Parse.Cloud.httpRequest({
                        method: 'POST',                        
                        url: "https://api.import.io/store/data/6bd719b1-1276-4a0c-a679-32348762657f/_query?_user=" + user + "&_apikey=" + apiKey,
                        body: body,
                        success: function(httpResponse) {
                            var data = JSON.parse(httpResponse.text);
                          //  console.log(data);

                            for (var i = 0; i < postsArr.length; i++) {
                                if (postsArr[i].get('link') === url) {
                                    //Content
                                    if (data.results && data.results[0] && data.results[0].content) {
                                        if (typeof data.results[0].content === "string") {
                                            postsArr[i].set("content", data.results[0].content);
                                        } else {//                                          
                                            postsArr[i].set("content", data.results[0].content.join(''));
                                        }
                                    }
                                }
                            }

                            console.log("Success: " + httpResponse.text);
                            next();
                        },
                        error: function(httpResponse) {
                            console.log("Error: " + httpResponse.text);
                            next();
                        }
                    });
                }
            }

            function getBDLivePost(url) {

                return function(next) {
                    var body = JSON.stringify({
                        "input": {
                            "webpage/url": url
                        }
                    });

                    Parse.Cloud.httpRequest({
                        method: 'POST',                        
                        url: "https://api.import.io/store/data/2598d99a-5348-4e20-ba00-b9b83751b206/_query?_user=" + user + "&_apikey=" + apiKey,
                        body: body,
                        success: function(httpResponse) {
                            var data = JSON.parse(httpResponse.text);
                           // console.log(data);

                            for (var i = 0; i < postsArr.length; i++) {
                                if (postsArr[i].get('link') === url) {
                                    if (data.results && data.results[0] && data.results[0].image) postsArr[i].set("image", [data.results[0].image]);
                                    if (data.results && data.results[0] && data.results[0].author) postsArr[i].set("author", data.results[0].author);
                                    //Content
                                    if (data.results && data.results[0] && data.results[0].content) {
                                        if (typeof data.results[0].content === "string") {
                                            postsArr[i].set("content", data.results[0].content);
                                        } else {//                                          
                                            postsArr[i].set("content", data.results[0].content.join(''));
                                        }
                                    }
                                }
                            }

                            console.log("Success: " + httpResponse.text);
                            next();
                        },
                        error: function(httpResponse) {
                            console.log("Error: " + httpResponse.text);
                            next();
                        }
                    });
                }
            }

            function getFin24Post(url) {

                return function(next) {
                    var body = JSON.stringify({
                        "input": {
                            "webpage/url": url
                        }
                    });

                    Parse.Cloud.httpRequest({
                        method: 'POST',                        
                        url: "https://api.import.io/store/data/2e257e13-d35b-49cb-be72-ee4d11533eda/_query?_user=" + user + "&_apikey=" + apiKey,
                        body: body,
                        success: function(httpResponse) {
                            var data = JSON.parse(httpResponse.text);
                           // console.log(data);

                            for (var i = 0; i < postsArr.length; i++) {
                                if (postsArr[i].get('link') === url) {
                                    if (data.results && data.results[0] && data.results[0].image) postsArr[i].set("image", [data.results[0].image]);
                                    //Content
                                    if (data.results && data.results[0] && data.results[0].content) {
                                        if (typeof data.results[0].content === "string") {
                                            postsArr[i].set("content", data.results[0].content);
                                        } else {//                                          
                                            postsArr[i].set("content", data.results[0].content.join(''));
                                        }
                                    }
                                }
                            }

                            console.log("Success: " + httpResponse.text);
                            next();
                        },
                        error: function(httpResponse) {
                            console.log("Error: " + httpResponse.text);
                            next();
                        }
                    });
                }
            }

            function getIOLPost(url) {

                return function(next) {
                    var body = JSON.stringify({
                        "input": {
                            "webpage/url": url
                        }
                    });

                    Parse.Cloud.httpRequest({
                        method: 'POST',                        
                        url: "https://api.import.io/store/data/2d95d065-8591-494c-8a73-ec0dbd1748f2/_query?_user=" + user + "&_apikey=" + apiKey,
                        body: body,
                        success: function(httpResponse) {
                            var data = JSON.parse(httpResponse.text);
                           // console.log(data);

                            for (var i = 0; i < postsArr.length; i++) {
                                if (postsArr[i].get('link') === url) {
                                    if (data.results && data.results[0] && data.results[0].image) postsArr[i].set("image", [data.results[0].image]);
                                    //Content
                                    if (data.results && data.results[0] && data.results[0].content) {
                                        if (typeof data.results[0].content === "string") {
                                            postsArr[i].set("content", data.results[0].content);
                                        } else {//                                          
                                            postsArr[i].set("content", data.results[0].content.join(''));
                                        }
                                    }
                                }
                            }

                            console.log("Success: " + httpResponse.text);
                            next();
                        },
                        error: function(httpResponse) {
                            console.log("Error: " + httpResponse.text);
                            next();
                        }
                    });
                }
            }

            function getAhramOnlinePost(url) {

                return function(next) {
                    var body = JSON.stringify({
                        "input": {
                            "webpage/url": url.replace("/AllPortal", "")
                        }
                    });

                    Parse.Cloud.httpRequest({
                        method: 'POST',                        
                        url: "https://api.import.io/store/data/c6249f6b-bef7-4add-a286-02599f1cfd0c/_query?_user=" + user + "&_apikey=" + apiKey,
                        body: body,
                        success: function(httpResponse) {
                            var data = JSON.parse(httpResponse.text);
                           // console.log(data);

                            for (var i = 0; i < postsArr.length; i++) {
                                if (postsArr[i].get('link') === url) {
                                    if (data.results && data.results[0] && data.results[0].image) postsArr[i].set("image", [data.results[0].image]);
                                    if (data.results && data.results[0] && data.results[0].author) postsArr[i].set("author", data.results[0].author);
                                    //Content
                                    if (data.results && data.results[0] && data.results[0].content) {
                                        if (typeof data.results[0].content === "string") {
                                            postsArr[i].set("content", data.results[0].content);
                                        } else {//                                          
                                            postsArr[i].set("content", data.results[0].content.join(''));
                                        }
                                    }
                                }
                            }

                            console.log("Success: " + httpResponse.text);
                            next();
                        },
                        error: function(httpResponse) {
                            console.log("Error: " + httpResponse.text);
                            next();
                        }
                    });
                }
            }

            function getSDEPost(url) {

                return function(next) {
                    var body = JSON.stringify({
                        "input": {
                            "webpage/url": url
                        }
                    });

                    Parse.Cloud.httpRequest({
                        method: 'POST',                        
                        url: "https://api.import.io/store/data/b76809ff-cd8f-4993-a28b-1fa2ca34a74f/_query?_user=" + user + "&_apikey=" + apiKey,
                        body: body,
                        success: function(httpResponse) {
                            var data = JSON.parse(httpResponse.text);
                           // console.log(data);

                            for (var i = 0; i < postsArr.length; i++) {
                                if (postsArr[i].get('link') === url) {
                                    if (data.results && data.results[0] && data.results[0].author) postsArr[i].set("author", data.results[0].author);
                                    if (data.results && data.results[0] && data.results[0].image) postsArr[i].set("image", [data.results[0].image]);
                                    //Content
                                    if (data.results && data.results[0] && data.results[0].content) {
                                        if (typeof data.results[0].content === "string") {
                                            postsArr[i].set("content", data.results[0].content);
                                        } else {//                                          
                                            postsArr[i].set("content", data.results[0].content.join(''));
                                        }
                                    }
                                }
                            }

                            console.log("Success: " + httpResponse.text);
                            next();
                        },
                        error: function(httpResponse) {
                            console.log("Error: " + httpResponse.text);
                            next();
                        }
                    });
                }
            }

            function getStandartMediaPost(url) {

                return function(next) {
                    var body = JSON.stringify({
                        "input": {
                            "webpage/url": url
                        }
                    });

                    Parse.Cloud.httpRequest({
                        method: 'POST',                        
                        url: "https://api.import.io/store/data/a98bcc89-60ee-4fa7-a12f-555430f080ce/_query?_user=" + user + "&_apikey=" + apiKey,
                        body: body,
                        success: function(httpResponse) {
                            var data = JSON.parse(httpResponse.text);
                           // console.log(data);

                            for (var i = 0; i < postsArr.length; i++) {
                                if (postsArr[i].get('link') === url) {
                                    if (data.results && data.results[0] && data.results[0].author) postsArr[i].set("author", data.results[0].author);
                                    //Content
                                    if (data.results && data.results[0] && data.results[0].content) {
                                        if (typeof data.results[0].content === "string") {
                                            postsArr[i].set("content", data.results[0].content);
                                        } else {//                                          
                                            postsArr[i].set("content", data.results[0].content.join(''));
                                        }
                                    }
                                }
                            }

                            console.log("Success: " + httpResponse.text);
                            next();
                        },
                        error: function(httpResponse) {
                            console.log("Error: " + httpResponse.text);
                            next();
                        }
                    });
                }
            }

            function getCameroonOnlinePost(url) {

                return function(next) {
                    var body = JSON.stringify({
                        "input": {
                            "webpage/url": url
                        }
                    });

                    Parse.Cloud.httpRequest({
                        method: 'POST',                        
                        url: "https://api.import.io/store/data/4fed2b6d-b5cd-42b9-9eb7-735c9146bda5/_query?_user=" + user + "&_apikey=" + apiKey,
                        body: body,
                        success: function(httpResponse) {
                            var data = JSON.parse(httpResponse.text);
                           // console.log(data);

                            for (var i = 0; i < postsArr.length; i++) {
                                if (postsArr[i].get('link') === url) {
                                    //Content
                                    if (data.results && data.results[0] && data.results[0].content) {
                                        if (typeof data.results[0].content === "string") {
                                            postsArr[i].set("content", data.results[0].content);
                                        } else {//                                          
                                            postsArr[i].set("content", data.results[0].content.join(''));
                                        }
                                    }
                                }
                            }

                            console.log("Success: " + httpResponse.text);
                            next();
                        },
                        error: function(httpResponse) {
                            console.log("Error: " + httpResponse.text);
                            next();
                        }
                    });
                }
            }

            function getAllGhanaNewsPost(url) {

                return function(next) {
                    var body = JSON.stringify({
                        "input": {
                            "webpage/url": url
                        }
                    });

                    Parse.Cloud.httpRequest({
                        method: 'POST',                        
                        url: "https://api.import.io/store/data/88b168d9-c494-45a2-8c37-9b245f578af6/_query?_user=" + user + "&_apikey=" + apiKey,
                        body: body,
                        success: function(httpResponse) {
                            var data = JSON.parse(httpResponse.text);
                           // console.log(data);

                            for (var i = 0; i < postsArr.length; i++) {
                                if (postsArr[i].get('link') === url) {
                                    if (data.results && data.results[0] && data.results[0].image) postsArr[i].set("image", [data.results[0].image]);
                                    //Content
                                    if (data.results && data.results[0] && data.results[0].content) {
                                        if (typeof data.results[0].content === "string") {
                                            postsArr[i].set("content", data.results[0].content);
                                        } else {//                                          
                                            postsArr[i].set("content", data.results[0].content.join(''));
                                        }
                                    }
                                }
                            }

                            console.log("Success: " + httpResponse.text);
                            next();
                        },
                        error: function(httpResponse) {
                            console.log("Error: " + httpResponse.text);
                            next();
                        }
                    });
                }
            }

            function getMoroccoWorldNewsPost(url) {

                return function(next) {
                    var body = JSON.stringify({
                        "input": {
                            "webpage/url": url
                        }
                    });

                    Parse.Cloud.httpRequest({
                        method: 'POST',                        
                        url: "https://api.import.io/store/data/10709c90-0bf9-4a6b-b82d-a21cf5bb77cb/_query?_user=" + user + "&_apikey=" + apiKey,
                        body: body,
                        success: function(httpResponse) {
                            var data = JSON.parse(httpResponse.text);
                           // console.log(data);

                            for (var i = 0; i < postsArr.length; i++) {
                                if (postsArr[i].get('link') === url) {
                                    if (data.results && data.results[0] && data.results[0].author) postsArr[i].set("author", data.results[0].author);
                                    //Content
                                    if (data.results && data.results[0] && data.results[0].content) {
                                        if (typeof data.results[0].content === "string") {
                                            postsArr[i].set("content", data.results[0].content);
                                        } else {//                                          
                                            postsArr[i].set("content", data.results[0].content.join(''));
                                        }
                                    }
                                }
                            }

                            console.log("Success: " + httpResponse.text);
                            next();
                        },
                        error: function(httpResponse) {
                            console.log("Error: " + httpResponse.text);
                            next();
                        }
                    });
                }
            }

        })();
    }
}

function getPostsList(options) {
    return function(next) {
        Parse.Cloud.httpRequest({
            url: options.url,
            success: function(httpResponse) {
               // console.log(options.source + ' ' + options.category);
                savePosts(httpResponse.text, {
                    category: options.category,
                    source: options.source,
                    country: options.country
                }, next);
            },
            error: function(httpResponse) {
                console.log('Request error ' + options.source + ' ' + options.category + ': ' + httpResponse.text);
                next();
            }
        });
    };
}

Parse.Cloud.job("updateAll", function(request, status) {
    var options = [{
        url: "https://api.import.io/store/data/189a8329-a73e-4191-a6ea-60378c052659/_query?input/webpage/url=http%3A%2F%2Flindaikeji.blogspot.com%2F&_user=" + user + "&_apikey=" + apiKey,
        source: 'Linda Ikeji',
        category: 'Blogs',
        country: 'Nigeria'
    }, {
        url: "https://api.import.io/store/data/42180d9a-c7e4-4ec2-9165-ed375eb17ec3/_query?input/webpage/url=http%3A%2F%2Fwww.bellanaija.com%2F&_user=" + user + "&_apikey=" + apiKey,
        source: 'Bella Naija',
        category: 'Blogs',
        country: 'Nigeria'
    }, {
        url: "https://api.import.io/store/data/4e026c09-2614-4e40-8202-79c281b13f3a/_query?input/webpage/url=http%3A%2F%2Fwww.punchng.com%2Fnews%2F&_user=" + user + "&_apikey=" + apiKey,
        source: 'Punch',
        category: 'News',
        country: 'Nigeria'
    }, {
        url: "https://api.import.io/store/data/749c2e0c-4982-44e6-8c01-ee4b80c2a472/_query?input/webpage/url=http%3A%2F%2Fwww.punchng.com%2Fpolitics%2F&_user=" + user + "&_apikey=" + apiKey,
        source: 'Punch',
        category: 'Politics',
        country: 'Nigeria'
    }, {
        url: "https://api.import.io/store/data/73175fef-c946-42db-ad40-1287ca5ddd96/_query?input/webpage/url=http%3A%2F%2Fwww.punchng.com%2Fbusiness%2Fbusiness-economy%2F&_user=" + user + "&_apikey=" + apiKey,
        source: 'Punch',
        category: 'Business',
        country: 'Nigeria'
    }, {
        url: "https://api.import.io/store/data/78fa3062-9149-41ff-a919-ff8d0edc2897/_query?input/webpage/url=http%3A%2F%2Fwww.punchng.com%2Fsports%2F&_user=" + user + "&_apikey=" + apiKey,
        source: 'Punch',
        category: 'Sports',
        country: 'Nigeria'
    }, {
        url: "https://api.import.io/store/data/0bcdd7d3-31e5-4787-b525-42d1d2d2c145/_query?input/webpage/url=http%3A%2F%2Fwww.punchng.com%2Fhealth%2Fhealthwise%2F&_user=" + user + "&_apikey=" + apiKey,
        source: 'Punch',
        category: 'Healthcare',
        country: 'Nigeria'
    }, {
        url: "https://api.import.io/store/data/c48cf559-c0e5-4485-9087-dab4715f19b5/_query?input/webpage/url=http%3A%2F%2Fwww.vanguardngr.com%2Fcategory%2Fnational-news%2F&_user=" + user + "&_apikey=" + apiKey,
        source: 'Vanguard',
        category: 'News',
        country: 'Nigeria'
    }, {
        url: "https://api.import.io/store/data/0ba525cf-d031-4406-8d5e-dab550487f0f/_query?input/webpage/url=http%3A%2F%2Fwww.vanguardngr.com%2Fcategory%2Fbusiness%2F&_user=" + user + "&_apikey=" + apiKey,
        source: 'Vanguard',
        category: 'Business',
        country: 'Nigeria'
    }, {
        url: "https://api.import.io/store/data/72230680-4385-47aa-a900-970c4a1203c9/_query?input/webpage/url=http%3A%2F%2Fwww.vanguardngr.com%2Fcategory%2Fsports%2F&_user=" + user + "&_apikey=" + apiKey,
        source: 'Vanguard',
        category: 'Sports',
        country: 'Nigeria'
    }, {
        url: "https://api.import.io/store/data/b539fb7d-3049-408d-b6fd-a235c74de478/_query?input/webpage/url=http%3A%2F%2Fwww.vanguardngr.com%2Fcategory%2Fpolitics%2F&_user=" + user + "&_apikey=" + apiKey,
        source: 'Vanguard',
        category: 'Politics',
        country: 'Nigeria'
    }, {
        url: "https://api.import.io/store/data/0b2b12c8-3974-4335-b6d7-8b79371374ce/_query?input/webpage/url=http%3A%2F%2Fwww.vanguardngr.com%2Fcategory%2Ftechnology%2F&_user=" + user + "&_apikey=" + apiKey,
        source: 'Vanguard',
        category: 'Technology',
        country: 'Nigeria'
    }, {
        url: "https://api.import.io/store/data/51ecbd34-6575-45ce-b68d-0dbdd5355b35/_query?input/webpage/url=http%3A%2F%2Fwww.thisdaylive.com%2Fhealth-and-wellbeing%2F&_user=" + user + "&_apikey=" + apiKey,
        source: 'This Day Live',
        category: 'Healthcare',
        country: 'Nigeria'
    }, {
        url: "https://api.import.io/store/data/8d73dc13-f159-4106-b75a-122674c96969/_query?input/webpage/url=http%3A%2F%2Fwww.thisdaylive.com%2Flife-and-style%2F&_user=" + user + "&_apikey=" + apiKey,
        source: 'This Day Live',
        category: 'Healthcare',
        country: 'Nigeria'
    }, {
        url: "https://api.import.io/store/data/be7d3490-801a-4f28-96f8-58ffb228261b/_query?input/webpage/url=http%3A%2F%2Fwww.thisdaylive.com%2Fpoliticsthisday%2F&_user=" + user + "&_apikey=" + apiKey,
        source: 'This Day Live',
        category: 'Politics',
        country: 'Nigeria'
    }, {
        url: "https://api.import.io/store/data/4a6dd05d-c24e-4f71-83b9-7c8b199a4219/_query?input/webpage/url=http%3A%2F%2Fwww.thisdaylive.com%2Fnews%2F&_user=" + user + "&_apikey=" + apiKey,
        source: 'This Day Live',
        category: 'News',
        country: 'Nigeria'
    }, {
        url: "https://api.import.io/store/data/27be2039-cf5b-4788-a264-c279c1f6bae5/_query?input/webpage/url=http%3A%2F%2Fwww.thisdaylive.com%2Fthisdaysports%2F&_user=" + user + "&_apikey=" + apiKey,
        source: 'This Day Live',
        category: 'Sports',
        country: 'Nigeria'
    }, {
        url: "https://api.import.io/store/data/b06358ff-8966-408c-8b44-a80f4ec3f938/_query?input/webpage/url=http%3A%2F%2Fwww.thisdaylive.com%2Fthisdaybusiness%2F&_user=" + user + "&_apikey=" + apiKey,
        source: 'This Day Live',
        category: 'Business',
        country: 'Nigeria'
    }, {
        url: "https://api.import.io/store/data/ddbe78d5-0529-43d7-a570-2a6ec07927cc/_query?input/webpage/url=http%3A%2F%2Fwww.goal.com%2Fen%2Fnews%2Farchive%2F1%3FICID%3DOP&_user=" + user + "&_apikey=" + apiKey,
        source: 'Goal',
        category: 'Sports',
        country: 'Euro Soccer'
    }, {
        url: "https://api.import.io/store/data/fe91f34b-2ea0-4a8c-afe7-727a73800935/_query?input/webpage/url=http%3A%2F%2Fvibeghana.com%2Fcategory%2Fpolitics%2F&_user=" + user + "&_apikey=" + apiKey,
        source: 'Vibeghana',
        category: 'Politics',
        country: 'Ghana'
    }, {
        url: "https://api.import.io/store/data/a9865e42-4cd4-4578-916e-d21896c9ff8e/_query?input/webpage/url=http%3A%2F%2Fvibeghana.com%2Fcategory%2Fbuisness%2F&_user=" + user + "&_apikey=" + apiKey,
        source: 'Vibeghana',
        category: 'Business',
        country: 'Ghana'
    }, {
        url: "https://api.import.io/store/data/d1ea65fc-edae-4eb6-9f78-914435c9c4aa/_query?input/webpage/url=http%3A%2F%2Fvibeghana.com%2Fcategory%2Fhealth%2Fpage%2F4%2F&_user=" + user + '&_apikey=' + apiKey,
        source: 'Vibeghana',
        category: 'Healthcare',
        country: 'Ghana'
    }, {
        url: "https://api.import.io/store/data/0125e943-bb25-466f-811e-500036f36e37/_query?input/webpage/url=http%3A%2F%2Fmg.co.za%2Fsection%2Fbusiness%2F&_user=" + user + "&_apikey=" + apiKey,
        source: 'Mail & Guardian',
        category: 'Business',
        country: 'South Africa'
    }, {
        url: "https://api.import.io/store/data/d6bfeb2e-2312-4afb-9fb4-0850f794dfd8/_query?input/webpage/url=http%3A%2F%2Fwww.timeslive.co.za%2Fbusinesstimes%2F&_user=" + user + "&_apikey=" + apiKey,
        source: 'Times Live',
        category: 'Business',
        country: 'South Africa'
    }, {
        url: "https://api.import.io/store/data/e110eaaf-d45a-4fe2-9ff6-e7e8c4d9ec66/_query?input/webpage/url=http%3A%2F%2Fwww.timeslive.co.za%2Flifestyle%2Ffood%2F&_user=" + user + "&_apikey=" + apiKey,
        source: 'Times Live',
        category: 'Food',
        country: 'South Africa'
    }, {
        url: "https://api.import.io/store/data/83e39aea-740c-4875-8a5b-de275f59c42d/_query?input/webpage/url=http%3A%2F%2Fwww.dailyguideghana.com%2Fcategory%2Fbusiness-news%2F&_user=" + user + "&_apikey=" + apiKey,
        source: 'Daily Guide',
        category: 'Business',
        country: 'Ghana'
    }, {
        url: "https://api.import.io/store/data/8be14aca-8165-4e2d-a22b-32bb023c28fa/_query?input/webpage/url=http%3A%2F%2Fwww.dailyguideghana.com%2Fcategory%2Fpolitical-news%2F&_user=" + user + "&_apikey=" + apiKey,
        source: 'Daily Guide',
        category: 'Politics',
        country: 'Ghana'
    }, {
        url: "https://api.import.io/store/data/47fef2c8-3371-4bf0-b389-d34da0457cd6/_query?input/webpage/url=http%3A%2F%2Fwww.dailyguideghana.com%2Fcategory%2Fentertainment-news%2F&_user=" + user + "&_apikey=" + apiKey,
        source: 'Daily Guide',
        category: 'Blogs',
        country: 'Ghana'
    }, {
        url: "https://api.import.io/store/data/35648233-7e1c-4317-8774-18132bd83e3e/_query?input/webpage/url=http%3A%2F%2Fwww.dailyguideghana.com%2Fcategory%2Fsports-news%2F&_user=" + user + "&_apikey=" + apiKey,
        source: 'Daily Guide',
        category: 'Sports',
        country: 'Ghana'
    }, {
        url: "https://api.import.io/store/data/c4b83de8-a4b4-4df1-ad5a-fee4adef05d8/_query?input/webpage/url=http%3A%2F%2Fwww.timeslive.co.za%2Fpolitics%2F&_user=" + user + "&_apikey=" + apiKey,
        source: 'Times Live',
        category: 'Politics',
        country: 'South Africa'
    }, {
        url: "https://api.import.io/store/data/b2a86faf-b676-406c-8e17-21e55b7b9a22/_query?input/webpage/url=http%3A%2F%2Fwww.portalangop.co.ao%2Fangola%2Fen_us%2Fnoticias%2Feconomia.html&_user=" + user + "&_apikey=" + apiKey,
        source: 'Angop',
        category: 'Business',
        country: 'Angola'
    }, {
        url: "https://api.import.io/store/data/a12849ba-bdca-4df3-887f-9b64390366b4/_query?input/webpage/url=http%3A%2F%2Fwww.portalangop.co.ao%2Fangola%2Fen_us%2Fnoticias%2Fsaude.html&_user=" + user + "&_apikey=" + apiKey,
        source: 'Angop',
        category: 'Healthcare',
        country: 'Angola'
    }, {
        url: "https://api.import.io/store/data/6200a57d-f591-4c72-9a0b-6e6f1f6e2976/_query?input/webpage/url=http%3A%2F%2Fwww.portalangop.co.ao%2Fangola%2Fen_us%2Fnoticias%2Fpolitica.html&_user=" + user + "&_apikey=" + apiKey,
        source: 'Angop',
        category: 'Politics',
        country: 'Angola'
    }, {
        url: "https://api.import.io/store/data/2318614d-c70b-4ecd-bbab-55ddcd538019/_query?input/webpage/url=http%3A%2F%2Fwww.portalangop.co.ao%2Fangola%2Fen_us%2Fnoticias%2Flazer-e-cultura.html&_user=" + user + "&_apikey=" + apiKey,
        source: 'Angop',
        category: 'Blogs',
        country: 'Angola'
    }, {
        url: "https://api.import.io/store/data/0eece8f3-c22d-4939-b8b5-4e57d23ce341/_query?input/webpage/url=http%3A%2F%2Fwww.portalangop.co.ao%2Fangola%2Fen_us%2Fnoticias%2Fdesporto.html&_user=" + user + "&_apikey=" + apiKey,
        source: 'Angop',
        category: 'Sports',
        country: 'Angola'
    }, {
        url: "https://api.import.io/store/data/2c006c0b-eb88-4c4e-b356-af4176175ee0/_query?input/webpage/url=http%3A%2F%2Fwww.portalangop.co.ao%2Fangola%2Fen_us%2Fnoticias%2Fciencia-e-tecnologia.html&_user=" + user + "&_apikey=" + apiKey,
        source: 'Angop',
        category: 'Technology',
        country: 'Angola'
    }, {
        url: "https://api.import.io/store/data/c1def6b1-5d24-4f4e-9cc7-3a0bb6dfd98b/_query?input/webpage/url=http%3A%2F%2Fwww.egyptindependent.com%2F%2Fsubchannel%2FLocal%2520press%2520review&_user=" + user + "&_apikey=" + apiKey,
        source: 'Egypt Independent',
        category: 'Business',
        country: 'Egypt'
    }, {
        url: "https://api.import.io/store/data/056cd4ac-6a72-4e9d-908e-1df10e50a676/_query?input/webpage/url=http%3A%2F%2Fwww.egyptindependent.com%2F%2Fsubchannel%2F834104&_user=" + user + "&_apikey=" + apiKey,
        source: 'Egypt Independent',
        category: 'Healthcare',
        country: 'Egypt'
    }, {
        url: "https://api.import.io/store/data/95dce79c-0f3b-4b7f-ad9c-a7fff34a2cd8/_query?input/webpage/url=http%3A%2F%2Fwww.egyptindependent.com%2Fsubchannel%2F189&_user=" + user + "&_apikey=" + apiKey,
        source: 'Egypt Independent',
        category: 'Technology',
        country: 'Egypt'
    }, {
        url: "https://api.import.io/store/data/3742bff9-dff7-4b83-8f47-21fa45df8e0b/_query?input/webpage/url=http%3A%2F%2Fwww.cameroonpostline.com%2Fcategory%2Fbusiness%2F&_user=" + user + "&_apikey=" + apiKey,
        source: 'Cameroon POSTline',
        category: 'Business',
        country: 'Cameroon'
    }, {
        url: "https://api.import.io/store/data/4404a8bd-5b9a-4462-9e27-d01928a597cf/_query?input/webpage/url=http%3A%2F%2Fwww.cameroonpostline.com%2Fcategory%2Fhealth%2F&_user=" + user + "&_apikey=" + apiKey,
        source: 'Cameroon POSTline',
        category: 'Healthcare',
        country: 'Cameroon'
    }, {
        url: "https://api.import.io/store/data/9bb4ad6b-f5ca-47e5-8d79-4bcfbbc99690/_query?input/webpage/url=http%3A%2F%2Fwww.cameroonpostline.com%2Fcategory%2Fsport%2F&_user=" + user + "&_apikey=" + apiKey,
        source: 'Cameroon POSTline',
        category: 'Sports',
        country: 'Cameroon'
    }, {
        url: "https://api.import.io/store/data/05863c9f-1a3d-4324-bdd3-b9ac94aca783/_query?input/webpage/url=http%3A%2F%2Fwww.bdlive.co.za%2Fbusiness%2F&_user=" + user + "&_apikey=" + apiKey,
        source: 'BDlive',
        category: 'Business',
        country: 'South Africa'
    }, {
        url: "https://api.import.io/store/data/dc7aeb36-9ab9-4cde-8f40-f8f7e4597a07/_query?input/webpage/url=http%3A%2F%2Fwww.bdlive.co.za%2Fnational%2Fhealth%2F&_user=" + user + "&_apikey=" + apiKey,
        source: 'BDlive',
        category: 'Healthcare',
        country: 'South Africa'
    }, {
        url: "https://api.import.io/store/data/40ba7a8e-368f-4875-bb33-c441783390b0/_query?input/webpage/url=http%3A%2F%2Fwww.bdlive.co.za%2Fnational%2Fpolitics%2F&_user=" + user + "&_apikey=" + apiKey,
        source: 'BDlive',
        category: 'Politics',
        country: 'South Africa'
    },{
        url: "https://api.import.io/store/data/3ce28d3b-2ff4-402d-be6c-eaf451c30ca9/_query?input/webpage/url=http%3A%2F%2Fwww.fin24.com%2Feconomy&_user=" + user + "&_apikey=" + apiKey,
        source: 'Fin24',
        category: 'Business',
        country: 'South Africa'
    }, {
        url: "https://api.import.io/store/data/a4d20d04-7758-4808-ac94-42accbd19f63/_query?input/webpage/url=http%3A%2F%2Fnewbusinessethiopia.com%2Findex.php%2Ftravel&_user=" + user + "&_apikey=" + apiKey,
        source: 'NBE',
        category: 'Business',
        country: 'Ethiopia'
    }, {
        url: "https://api.import.io/store/data/08e2a9a7-ab59-4471-9ace-42b559ab6d87/_query?input/webpage/url=http%3A%2F%2Fnewbusinessethiopia.com%2Findex.php%2Ffinance&_user=" + user + "&_apikey=" + apiKey,
        source: 'NBE',
        category: 'Business',
        country: 'Ethiopia'
    }, {
        url: "https://api.import.io/store/data/9b1b2f58-05dc-48f2-a98f-be8721e6e3ec/_query?input/webpage/url=http%3A%2F%2Fnewbusinessethiopia.com%2Findex.php%2Ftrade&_user=" + user + "&_apikey=" + apiKey,
        source: 'NBE',
        category: 'Business',
        country: 'Ethiopia'
    }, {
        url: "https://api.import.io/store/data/494d4c7b-1ca1-4ae2-a2d7-484bfb3dd64a/_query?input/webpage/url=http%3A%2F%2Fwww.fin24.com%2Fcompanies%2Fretail&_user=" + user + "&_apikey=" + apiKey,
        source: 'Fin24',
        category: 'Business',
        country: 'South Africa'
    }, { 
        url: "https://api.import.io/store/data/e2753c13-493e-49ee-9711-d464edb24afe/_query?input/webpage/url=http%3A%2F%2Fnewbusinessethiopia.com%2Findex.php%2Fsociety%2Fcontent%2F14%2Fhealth&_user=" + user + "&_apikey=" + apiKey,
        source: 'NBE',
        category: 'Healthcare',
        country: 'Ethiopia'
    }, {
        url: "https://api.import.io/store/data/b935b2d1-969c-4131-b94f-384d4c04dbf3/_query?input/webpage/url=http%3A%2F%2Fnewbusinessethiopia.com%2Findex.php%2Fgovernance&_user=" + user + "&_apikey=" + apiKey,
        source: 'NBE',
        category: 'Politics',
        country: 'Ethiopia'
    }, {
        url: "https://api.import.io/store/data/62355a50-5a12-4814-a831-d92d307d980f/_query?input/webpage/url=http%3A%2F%2Fnewbusinessethiopia.com%2Findex.php%2Ftechnology&_user=" + user + "&_apikey=" + apiKey,
        source: 'NBE',
        category: 'Technology',
        country: 'Ethiopia'
    }, {
        url: "https://api.import.io/store/data/1e5d5f1f-1d79-496f-af37-96114cb7b468/_query?input/webpage/url=http%3A%2F%2Fnewbusinessethiopia.com%2Findex.php%2Fsociety%2Fcontent%2F19%2Fentertainment&_user=" + user + "&_apikey=" + apiKey,
        source: 'NBE',
        category: 'Blogs',
        country: 'Ethiopia'
    }, {
        url: "https://api.import.io/store/data/e6bc9b44-6907-44e5-a2be-794965443a2d/_query?input/webpage/url=http%3A%2F%2Fwww.fin24.com%2Fcompanies%2Ftravelandleisure&_user=" + user + "&_apikey=" + apiKey,
        source: 'Fin24',
        category: 'Business',
        country: 'South Africa'
    }, {
        url: "https://api.import.io/store/data/9fc3138a-d778-48d2-b72c-a93fe0d9d7ae/_query?input/webpage/url=http%3A%2F%2Fwww.fin24.com%2Ftech&_user=" + user + "&_apikey=" + apiKey,
        source: 'Fin24',
        category: 'Technology',
        country: 'South Africa'
    }, {
        url: "https://api.import.io/store/data/f306bfaf-6a1f-4648-8efe-edd53e70e0fd/_query?input/webpage/url=http%3A%2F%2Fwww.kenyan-post.com%2Fsearch%2Flabel%2FPolitics%3Fmax-results%3D10&_user=" + user + "&_apikey=" + apiKey,
        source: 'Kenyan Post',
        category: 'Politics',
        country: 'Kenya'
    }, {
        url: "https://api.import.io/store/data/fee52272-c407-4db4-8269-4cca38e85615/_query?input/webpage/url=http%3A%2F%2Fwww.the-star.co.ke%2Fsections%2Fstarlife&_user=" + user + "&_apikey=" + apiKey,
        source: 'The Star',
        category: 'Blogs',
        country: 'Kenya'
    }, {
        url: "https://api.import.io/store/data/10f930d7-21c0-486b-9595-5dd0d7d3947e/_query?input/webpage/url=http%3A%2F%2Fwww.the-star.co.ke%2Fsections%2Fsports&_user=" + user + "&_apikey=" + apiKey,
        source: 'The Star',
        category: 'Sports',
        country: 'Kenya'
    }, {
        url: "https://api.import.io/store/data/4718ecd0-6e3d-486a-9325-da01a9943018/_query?input/webpage/url=http%3A%2F%2Fwww.the-star.co.ke%2Fsections%2Feastern&_user=" + user + "&_apikey=" + apiKey,
        source: 'The Star',
        category: 'Business',
        country: 'Kenya'
    }, {
        url: "https://api.import.io/store/data/71071b3a-db41-4c0c-aca6-d6d848054009/_query?input/webpage/url=http%3A%2F%2Fwww.iol.co.za%2Fsport%2Fmore-sport&_user=" + user + "&_apikey=" + apiKey,
        source: 'IOL',
        category: 'Sports',
        country: 'South Africa'
    }, {
        url: "https://api.import.io/store/data/fe6bc2c9-f7df-4b12-bfb8-eb9bc79ef76f/_query?input/webpage/url=http%3A%2F%2Fwww.iol.co.za%2Ftonight%2Ftv-radio%2Flocal-news%3Fpage%3D1&_user=" + user + "&_apikey=" + apiKey,
        source: 'IOL',
        category: 'Blogs',
        country: 'South Africa'
    }, {
        url: "https://api.import.io/store/data/1768aac7-5098-4768-b769-93153762adb4/_query?input/webpage/url=http%3A%2F%2Fwww.iol.co.za%2Fscitech&_user=" + user + "&_apikey=" + apiKey,
        source: 'IOL',
        category: 'Technology',
        country: 'South Africa'
    }, {
        url: "https://api.import.io/store/data/9fa08ed2-63f2-4e7e-8502-1347e4dc7747/_query?input/webpage/url=http%3A%2F%2Fwww.iol.co.za%2Flifestyle&_user=" + user + "&_apikey=" + apiKey,
        source: 'IOL',
        category: 'Blogs',
        country: 'South Africa'
    },{
        url: "https://api.import.io/store/data/b8bce319-e308-44ec-8117-cee5bb425cdc/_query?input/webpage/url=http%3A%2F%2Fwww.standardmedia.co.ke%2Fbusiness%2Fcategory%2Folder%2F19%2Fbusiness-news&_user=" + user + "&_apikey=" + apiKey,
        source: 'Standard Digital',
        category: 'Business',
        country: 'Kenya'
    }, {
        url: "https://api.import.io/store/data/3f380ec0-2fee-43b1-95ab-b5052b042ded/_query?input/webpage/url=http%3A%2F%2Fwww.standardmedia.co.ke%2Fbusiness%2Fcategory%2Folder%2F42%2Fsci-tech&_user=" + user + "&_apikey=" + apiKey,
        source: 'Standard Digital',
        category: 'Technology',
        country: 'Kenya'
    }, {
        url: "https://api.import.io/store/data/37ca9bc4-9201-4236-9709-a63b61da3344/_query?input/webpage/url=http%3A%2F%2Fenglish.ahram.org.eg%2FAllPortal%2F6%2FSports%2F0.aspx&_user=" + user + "&_apikey=" + apiKey,
        source: 'Ahram Online',
        category: 'Sports',
        country: 'Egypt'
     }, {
        url: "https://api.import.io/store/data/f112c23a-2340-4863-ba94-8108fd431751/_query?input/webpage/url=http%3A%2F%2Fenglish.ahram.org.eg%2FAllPortal%2F7%2FLife--Style%2F0.aspx&_user=" + user + "&_apikey=" + apiKey,
        source: 'Ahram Online',
        category: 'Blogs',
        country: 'Egypt'
    }, {
        url: "https://api.import.io/store/data/671891a2-f53f-41be-baac-104abdad4602/_query?input/webpage/url=http%3A%2F%2Fenglish.ahram.org.eg%2FAllPortal%2F5%2FArts--Culture%2F0.aspx&_user=" + user + "&_apikey=" + apiKey,
        source: 'Ahram Online',
        category: 'Blogs',
        country: 'Egypt'
    }, {
        url: "https://api.import.io/store/data/9d2629b2-c541-4cea-8a50-d126005c8320/_query?input/webpage/url=http%3A%2F%2Fenglish.ahram.org.eg%2FAllCategory%2F1%2F64%2FEgypt%2FPolitics-%2F6.aspx&_user=" + user + "&_apikey=" + apiKey,
        source: 'Ahram Online',
        category: 'Politics',
        country: 'Egypt'
    }, {
        url: "https://api.import.io/store/data/a911c3f6-f849-4158-b1e6-80a00140b6b8/_query?input/webpage/url=http%3A%2F%2Fwww.sde.co.ke%2Fcategory%2Folder%2F106%2Flocal-news&_user=" + user + "&_apikey=" + apiKey,
        source: 'SDE',
        category: 'Blogs',
        country: 'Kenya'
    }, {
        url: "https://api.import.io/store/data/71d69541-deb4-4996-8acf-b2d3fbefa043/_query?input/webpage/url=http%3A%2F%2Fwww.standardmedia.co.ke%2Fbusiness%2Fcategory%2Folder%2F4%2Fbusiness&_user=" + user + "&_apikey=" + apiKey,
        source: 'Standart Media',
        category: 'Business',
        country: 'Kenya'
    }, {
        url: "https://api.import.io/store/data/bd99ea81-32c5-4b03-9773-5e28a2b44815/_query?input/webpage/url=http%3A%2F%2Fwww.standardmedia.co.ke%2Fhealth%2Fcategory%2Folder%2F41%2Fhealth&_user=" + user + "&_apikey=" + apiKey,
        source: 'Standart Media',
        category: 'Healthcare',
        country: 'Kenya'
    }, {
        url: "https://api.import.io/store/data/6b60757a-402f-4ac1-b925-fd167bf6f2b4/_query?input/webpage/url=http%3A%2F%2Fwww.cameroononline.org%2Fsports-news%2F&_user=" + user + "&_apikey=" + apiKey,
        source: 'Cameroon Online',
        category: 'Sports',
        country: 'Cameroon'
    }, {
        url: "https://api.import.io/store/data/635f1c45-3e44-423f-b015-2be0be9173a4/_query?input/webpage/url=http%3A%2F%2Fwww.cameroononline.org%2Fbusiness-news%2F&_user=" + user + "&_apikey=" + apiKey,
        source: 'Cameroon Online',
        category: 'Technology',
        country: 'Cameroon'
    }, {
        url: "https://api.import.io/store/data/67e64fcc-5eb4-4bae-8a78-513207016e25/_query?input/webpage/url=http%3A%2F%2Fwww.cameroononline.org%2Fpolitic-news%2F&_user=" + user + "&_apikey=" + apiKey,
        source: 'Cameroon Online',
        category: 'Politics',
        country: 'Cameroon'
    }, {
        url: "https://api.import.io/store/data/bb271a94-a2b7-4306-9035-82350d55be49/_query?input/webpage/url=http%3A%2F%2Fwww.cameroononline.org%2Fsociety-news%2F&_user=" + user + "&_apikey=" + apiKey,
        source: 'Cameroon Online',
        category: 'Blogs',
        country: 'Cameroon'
    }, {
        url: "https://api.import.io/store/data/75e6824d-c478-4a56-ab93-1415c871394f/_query?input/webpage/url=http%3A%2F%2Fenglish.ahram.org.eg%2FAllPortal%2F3%2FBusiness%2F0.aspx&_user=" + user + "&_apikey=" + apiKey,
        source: 'Ahram Online',
        category: 'Business',
        country: 'Egypt'
    }, {
        url: "https://api.import.io/store/data/ea80c63c-965e-4058-8858-4a89b49bd137/_query?input/webpage/url=http%3A%2F%2Fwww.allghananews.com%2Fpolitics&_user=" + user + "&_apikey=" + apiKey,
        source: 'All Ghana News',
        category: 'Politics',
        country: 'Ghana'
    }, {
        url: "https://api.import.io/store/data/cd5d9dde-a108-40fa-80af-54e2c3c85d3d/_query?input/webpage/url=http%3A%2F%2Fwww.allghananews.com%2Fbusiness-and-economy&_user=" + user + "&_apikey=" + apiKey,
        source: 'All Ghana News',
        category: 'Business',
        country: 'Ghana'
    }, {
        url: "https://api.import.io/store/data/1e3a4282-ff66-4154-a7e0-0b1e601b1dd6/_query?input/webpage/url=http%3A%2F%2Fwww.allghananews.com%2Fhealth-lifestyle&_user=" + user + "&_apikey=" + apiKey,
        source: 'All Ghana News',
        category: 'Healthcare',
        country: 'Ghana'
    }, {
        url: "https://api.import.io/store/data/c4212b9c-436a-45c0-ba63-8c7832aaf3be/_query?input/webpage/url=http%3A%2F%2Fwww.allghananews.com%2Fsports&_user=" + user + "&_apikey=" + apiKey,
        source: 'All Ghana News',
        category: 'Sports',
        country: 'Ghana'
    }, {
        url: "https://api.import.io/store/data/c56a8168-ff09-4469-8db3-13b65d4eb37e/_query?input/webpage/url=http%3A%2F%2Fvibeghana.com%2Fcategory%2Fentertainment%2F&_user=" + user + "&_apikey=" + apiKey,
        source: 'Vibeghana',
        category: 'Blogs',
        country: 'Ghana'
    }, {
        url: "https://api.import.io/store/data/ac83198e-b128-4a8f-b904-ced94f3d75be/_query?input/webpage/url=http%3A%2F%2Fwww.moroccoworldnews.com%2Fcategory%2Fsports%2F&_user=" + user + "&_apikey=" + apiKey,
        source: 'Morocco World News',
        category: 'Sports',
        country: 'Morocco'
    }, {
        url: "https://api.import.io/store/data/f6463856-9409-484c-a163-560545bc78bd/_query?input/webpage/url=http%3A%2F%2Fwww.moroccoworldnews.com%2Fcategory%2Fsociety%2F&_user=" + user + "&_apikey=" + apiKey,
        source: 'Morocco World News',
        category: 'Healthcare',
        country: 'Morocco'
    }, {
        url: "https://api.import.io/store/data/5a8f9724-75d4-48f6-aabe-f7b21fa78c46/_query?input/webpage/url=http%3A%2F%2Fwww.moroccoworldnews.com%2Fcategory%2Feconomy%2F&_user=" + user + "&_apikey=" + apiKey,
        source: 'Morocco World News',
        category: 'Business',
        country: 'Morocco'
    }, {
        url: "https://api.import.io/store/data/9ff45296-1b12-4742-83b9-6eea275d20b2/_query?input/webpage/url=http%3A%2F%2Fwww.moroccoworldnews.com%2Fcategory%2Fculture%2F&_user=" + user + "&_apikey=" + apiKey,
        source: 'Morocco World News',
        category: 'Blogs',
        country: 'Morocco'
    }, {
        url: "https://api.import.io/store/data/e9ab49c0-c006-42ce-a960-8660d44e79c1/_query?input/webpage/url=http%3A%2F%2Fwww.moroccoworldnews.com%2Fcategory%2Fopinion%2F&_user=" + user + "&_apikey=" + apiKey,
        source: 'Morocco World News',
        category: 'Politics',
        country: 'Morocco'
    }, {
        url: "https://api.import.io/store/data/63ee7206-b2c5-4882-8074-82ee03a38946/_query?input/webpage/url=http%3A%2F%2Fwww.moroccoworldnews.com%2Fcategory%2Feducation%2F&_user=" + user + "&_apikey=" + apiKey,
        source: 'Morocco World News',
        category: 'Technology',
        country: 'Morocco'
    }
    ];

    Parse.Cloud.useMasterKey();
    var actions = [];

    for (var i = 0; i < options.length; i++) {
        actions.push(getPostsList(options[i]));
    }

    _(actions).reduceRight(_.wrap, function() {
        console.log('Job complete');
        deleteBrokenPosts(status);
    })();
});

Parse.Cloud.define("getPostById", function(request, response) {
    var Post = Parse.Object.extend("Post");
    var query = new Parse.Query(Post);

    var reqData = JSON.parse(request.body);

    if (reqData.id) {
        query.get(reqData.id, {
            success: function(post) {
                if (post) {
                    response.success(post);
                } else {
                    response.success(false);
                }
            },
            error: function(object, error) {
                console.log("Error: " + error.code + " " + error.message);
                response.error('Nothing found');
            }
        });
    }

});


Parse.Cloud.define("getLikeCount", function(request, response){
	var likeQuery = new Parse.Query("Like");

	var reqData = JSON.parse(request.body);

	likeQuery.equalTo("postId", { __type: "Pointer", className: "Post", objectId: reqData.postId });

	likeQuery.find().then(function(likes){
		if(likes.length){
			response.success(likes.length);
		} else {
			response.success(0);
		}
	});
});

Parse.Cloud.define("isLiked", function(request, response) {
	var Like = Parse.Object.extend("Like");
	var query = new Parse.Query("Like");

	var reqData = JSON.parse(request.body);

	if (reqData.userId && reqData.postId) {

		query.equalTo("userId", {
			__type: "Pointer",
			className: "_User",
			objectId: reqData.userId
		});

		query.equalTo("postId", {
			__type: "Pointer",
			className: "Post",
			objectId: reqData.postId
		});

		query.find().then(function(result){
			if(result.length){
				if(result[0].get("userId")){
					var getUserId = result[0].get("userId").id;

					if(getUserId === reqData.userId){
						response.success(true);
					} else {
						response.success(false);
					}

				} else {
					console.log('Can not get userId!');
					response.success(false);
				}
			} else {				
				response.success(false);
			}
		});

	}
     else 
     {
		response.error('Wrong parameters');
	}

});

Parse.Cloud.define("unlike", function(request, response) {
	var Like = Parse.Object.extend("Like");
	var query = new Parse.Query("Like");

	var reqData = JSON.parse(request.body);

	if (reqData.userId && reqData.postId)
     {

		query.equalTo("postId", {
			__type: "Pointer",
			className: "Post",
			objectId: reqData.postId
		});

		query.find().then(function(result){
			if(result.length){
				result[0].destroy();
				response.success('Destroyed!');
			} else {
				response.error("Like wasn't found");
			}
		});


	}
    else 
    {
		response.error('Wrong parameters');
	}

});

Parse.Cloud.define("like", function(request, response) {
	var Like = Parse.Object.extend("Like");
	var query = new Parse.Query("Like");
	var postQuery = new Parse.Query("Post");

	var reqData = JSON.parse(request.body);

	if (reqData.userId && reqData.postId) {

		query.equalTo("userId", { __type: "Pointer", className: "_User", objectId: reqData.userId });
		query.equalTo("postId", { __type: "Pointer", className: "Post", objectId: reqData.postId });

		query.first().then(function(result){


				var after_all = _.after(1, function(){
					response.success("Like successfully saved!");
				});

				postQuery.equalTo("objectId", reqData.postId);

				var like = new Like();

				like.set("userId", { __type: "Pointer", className: "_User", objectId: reqData.userId });
				like.set("postId", { __type: "Pointer", className: "Post", objectId: reqData.postId });

				like.save({
					success: function(){
						postQuery.first().then(function(post){
							var likeRelation = post.relation("likes");
							likeRelation.add(like);
							post.save();
							after_all();
						});
					},
					error: function(){

					}
				});
			//}
		});

	} else {
		response.error('Wrong parameters');
	}

});