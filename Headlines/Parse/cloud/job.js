var _ = require('underscore');

var apiKey = 'DhIV5y1Jq2KrQkF8dSQ2dB%2FGaQg2bkWyOZwJIC4xYxvqYCiKf8eNxAd4nZRO4horaieDysNnMq0xPUdp%2BMoIew%3D%3D',
    user = '1626111a-cea3-459f-ab82-a25a3548c34a',
    Post = Parse.Object.extend("Post");

Parse.Cloud.define("getFeed", function(request, response) {
    var query = new Parse.Query(Post);
    console.log('getFeed detected!');
    query.find({
        success: function(posts) {
            console.log('query - SUCCESS');
            console.log('POST: ' + posts);
            response.success(posts);
        },
        error: function(object, error) {
            console.log('query - FAIL');
            console.log(error);
            response.error(error);
        }
    });
});

/* ============ lindaikeji.blogspot.com ============== */

Parse.Cloud.define("getLindaikeji", function(request, response) {
    Parse.Cloud.httpRequest({
        url: "https://api.import.io/store/data/189a8329-a73e-4191-a6ea-60378c052659/_query?input/webpage/url=http%3A%2F%2Flindaikeji.blogspot.com%2F&_user=" + user + "&_apikey=" + apiKey,
        success: function(httpResponse) {
            savePosts(httpResponse.text, 'blogs', 'Linda Ikeji');
            console.log("success: " + httpResponse.text);
            response.success(httpResponse.text);
        },
        error: function(httpResponse) {
            console.error("error: " + httpResponse.text);
            response.error("Request failed with response code " + httpResponse.status);
        }
    });
});

/* ============ bellanaija.com ============== */
Parse.Cloud.define("getBellanaija", function(request, response) {
    Parse.Cloud.httpRequest({
        url: "https://api.import.io/store/data/42180d9a-c7e4-4ec2-9165-ed375eb17ec3/_query?input/webpage/url=http%3A%2F%2Fwww.bellanaija.com%2F&_user=" + user + "&_apikey=" + apiKey,
        success: function(httpResponse) {
            savePosts(httpResponse.text, 'blogs', 'BellaNaija');
            console.log(httpResponse.text);
            response.success(httpResponse.text);
        },
        error: function(httpResponse) {
            console.log(httpResponse.text);
            response.error("Request failed with response code " + httpResponse.status);
        }
    });
});

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
/* ============ tribune.com.ng ============== */

Parse.Cloud.define("getTribuneSports", function(request, response) {
    Parse.Cloud.httpRequest({
        url: "https://api.import.io/store/data/d77d3aa7-62cf-4830-9a9c-edb6f2a97f66/_query?input/webpage/url=http%3A%2F%2Fwww.tribune.com.ng%2Fnews%2Fsports&_user=" + user + "&_apikey=" + apiKey,
        success: function(httpResponse) {
            savePosts(httpResponse.text, 'sports', 'Nigerian Tribune');
            console.log(httpResponse.text);
            response.success(httpResponse.text);
        },
        error: function(httpResponse) {
            console.log(httpResponse.text);
            response.error("Request failed with response code " + httpResponse.status);
        }
    });
});

Parse.Cloud.define("getTribuneNews", function(request, response) {
    Parse.Cloud.httpRequest({
        url: "https://api.import.io/store/data/3b350857-0830-47a6-9ca0-663c50ee6678/_query?input/webpage/url=http%3A%2F%2Fwww.tribune.com.ng%2Fnews%2Fnews-headlines&_user=" + user + "&_apikey=" + apiKey,
        success: function(httpResponse) {
            savePosts(httpResponse.text, 'politics', 'Nigerian Tribune');
            console.log(httpResponse.text);
            response.success(httpResponse.text);
        },
        error: function(httpResponse) {
            console.log(httpResponse.text);
            response.error("Request failed with response code " + httpResponse.status);
        }
    });
});

function checkPosts(arr, options) {
    //    console.log("Start = " + JSON.stringify(options));
    for (var i = 0; i < options.length; i++) {
        for (var j = 0; j < arr.length; j++) {
            if (!arr[j].get(options[i])) {
                arr.splice(j, 1);
                console.log('Delete post without content');
            }
            //            console.log("Content = " + typeof arr[j].get(options[i]) );
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

    if (!jsonResults.results || !jsonResults.results.length) {
        console.log('No results for saving');
        cbNext();
    } else if (jsonResults.results.error) {
        console.log('Import.io error');
        cbNext();
    } else {

        // console.log('Count of results: ' + jsonResults.results.length);

        for (var i = 0; i < jsonResults.results.length; i++) {
            post = new Post();

            var title = jsonResults.results[i]['title/_text'] || '',
                author = jsonResults.results[i]['author'] || '',
                image = jsonResults.results[i]['image'] || '',
                preview = jsonResults.results[i]['preview'] || '',
                link = jsonResults.results[i]['title'] || '',
                category = options.category || 'blogs',
                source = options.source || 'no source';

            //        console.log('Image: ' + image);

            if (typeof image === "string") {
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

        function isPostExist(title, postsArr) {
            return function(next) {
                Parse.Cloud.useMasterKey();
                var Post = Parse.Object.extend('Post');
                var query = new Parse.Query(Post);

                query.equalTo("title", title);
                query.first({
                    success: function(object) {
                        if (object) { //                    
                            //                            console.log("already exists"); 
                        } else {
                            for (var i = 0; i < postsArr.length; i++) { //                                
                                if (postsArr[i].get('title') === title) {
                                    checkedPosts.push(postsArr[i]);
                                    // console.log("New object = " + JSON.stringify(postsArr[i]));
                                }
                            }
                        }
                        next();
                    },
                    error: function(error) {
                        console.log("Error: " + error.code + " " + error.message);
                        next();
                    }
                });
            };
        }

        _(acts).reduceRight(_.wrap, function() {
            // console.log('checking complete');
            console.log('Count of new posts = ' + checkedPosts.length);
            console.log('New posts = ' + JSON.stringify(checkedPosts));

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
            }

            _(actions).reduceRight(_.wrap, function() {
                postsArr = checkPosts(postsArr, ['content']);
                Parse.Object.saveAll(postsArr, {
                    success: function(objs) {
                        // console.log('All models were saved = ' + JSON.stringify(objs));
                        //                status.success("updateFeed success complete");
                        cbNext();
                    },
                    error: function(error) {
                        console.log('Multisaving error');
                        console.log(JSON.stringify(error));
                        //                status.error('Error in savePosts: ' + JSON.stringify(error));
                        cbNext();
                    }
                });
            })();

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
                        url: "https://api.import.io/store/data/da68010f-c52d-4272-a02f-ab0ec3b4c5b6/_query?_user=" + user + "&_apikey=" + apiKey,
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
                            console.log(data);

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
        })();
    }
}

function getPostsList(options) {
    return function(next) {
        Parse.Cloud.httpRequest({
            url: options.url,
            success: function(httpResponse) {
                console.log(options.source + ' ' + options.category);
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

Parse.Cloud.job("updateThisDayLive", function(request, status) {
    var options = [{
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
    }];

    Parse.Cloud.useMasterKey();
    var actions = [];

    for (var i = 0; i < options.length; i++) {
        actions.push(getPostsList(options[i]));
    }

    _(actions).reduceRight(_.wrap, function() {
        console.log('Job complete');
        deleteBrokenPosts(status);
        //        status.success("updateFeed complete");
    })();

});

Parse.Cloud.job("updateVanguard", function(request, status) {
    var options = [{
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
    }];
    Parse.Cloud.useMasterKey();
    var actions = [];

    for (var i = 0; i < options.length; i++) {
        actions.push(getPostsList(options[i]));
    }

    _(actions).reduceRight(_.wrap, function() {
        console.log('Job complete');
        deleteBrokenPosts(status);
        //        status.success("updateFeed complete");
    })();
});

Parse.Cloud.job("updatePunch", function(request, status) {
    var options = [{
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
    }];

    Parse.Cloud.useMasterKey();
    var actions = [];

    for (var i = 0; i < options.length; i++) {
        actions.push(getPostsList(options[i]));
    }

    _(actions).reduceRight(_.wrap, function() {
        console.log('Job complete');
        deleteBrokenPosts(status);
        //        status.success("updateFeed complete");
    })();
});

Parse.Cloud.job("updateBlogs", function(request, status) {
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
    }];

    Parse.Cloud.useMasterKey();
    var actions = [];

    for (var i = 0; i < options.length; i++) {
        actions.push(getPostsList(options[i]));
    }

    _(actions).reduceRight(_.wrap, function() {
        console.log('Job complete');
        deleteBrokenPosts(status);
        //        status.success("updateFeed complete");
    })();
});

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
        country: 'Nigeria'
    }];

    Parse.Cloud.useMasterKey();
    var actions = [];

    for (var i = 0; i < options.length; i++) {
        actions.push(getPostsList(options[i]));
    }

    _(actions).reduceRight(_.wrap, function() {
        console.log('Job complete');
        deleteBrokenPosts(status);
        //        status.success("updateFeed complete");
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

Parse.Cloud.job("TestJob", function(request, status) {
    Parse.Cloud.useMasterKey();
    //    console.log();
	var someXml =  "<div class=\"article-text\" itemprop=\"articleBody\"> <p class=\"leading\">COMMENT: Diego Simeone's men pride themselves on their combative style, but it worked against them as they crashed out of the Champions League </p> <div class=\"module module-bet-windrawwin clearfix\"> <div class=\"hidden\" data-index=\"1\" data-bookmaker=\"PaddyPower\" data-bookmaker-url=\"http://www.paddypower.com/football?AFF_ID=10065409&amp;leg=stamp~|hcap_value~|selections~361774445|stake~[STAKE]&amp;bs_add_leg_to_slip=1\" data-role=\"bookmaker\"> <h4 class=\"fontface\">Bet</h4> <select> <option value=\"5\" data-value-away=\"£75\" data-value-draw=\"£30\" data-value-home=\"£5.85\"> £5</option> <option selected=\"selected\" value=\"10\" data-value-away=\"£150\" data-value-draw=\"£60\" data-value-home=\"£11.7\"> £10</option> <option value=\"20\" data-value-away=\"£300\" data-value-draw=\"£120\" data-value-home=\"£23.4\"> £20</option> <option value=\"50\" data-value-away=\"£750\" data-value-draw=\"£300\" data-value-home=\"£58.5\"> £50</option> <option value=\"100\" data-value-away=\"£1500\" data-value-draw=\"£600\" data-value-home=\"£117\"> £100</option> </select> <span class=\"fontface\">=</span> <a class=\"bet home\" target=\"\" href=\"http://www.paddypower.com/football?AFF_ID=10065409&amp;leg=stamp~|hcap_value~|selections~361774445|stake~[STAKE]&amp;bs_add_leg_to_slip=1\"> <span class=\"result\"><img width=\"18\" height=\"18\" alt=\"Atletico Madrid\" src=\"http://secure.cache.images.core.optasports.com/soccer/teams/150x150/2020.png\" />ATM</span> <span class=\"amount\"></span> </a> <a class=\"bet draw\" target=\"\" href=\"http://www.paddypower.com/football?AFF_ID=10065409&amp;leg=stamp~|hcap_value~|selections~361774449|stake~[STAKE]&amp;bs_add_leg_to_slip=1\"> <span class=\"result\">Draw</span> <span class=\"amount\"></span> </a> <a class=\"bet away\" target=\"\" href=\"http://www.paddypower.com/football?AFF_ID=10065409&amp;leg=stamp~|hcap_value~|selections~361774447|stake~[STAKE]&amp;bs_add_leg_to_slip=1\"> <span class=\"result\"><img width=\"18\" height=\"18\" alt=\"Elche\" src=\"http://secure.cache.images.core.optasports.com/soccer/teams/150x150/2043.png\" />ELC</span> <span class=\"amount\"></span> </a> <img alt=\"\" class=\"hidden\" src=\"http://ad.doubleclick.net/ad/N7312.128055.GOAL.COM/B6698976.9;sz=1x1;ord=1429774009?\" /> <a class=\"bet-logo\" target=\"\" href=\"http://www.paddypower.com/football?AFF_ID=10065409&amp;leg=stamp~|hcap_value~|selections~361774445|stake~[STAKE]&amp;bs_add_leg_to_slip=1\"><img alt=\"PaddyPower\" src=\"http://i2.goal.com/web/goal/2015.04.21-v1/images/betting/paddypower_w.png\" /></a> </div> <div class=\"hidden\" data-index=\"2\" data-bookmaker=\"Bet365\" data-bookmaker-url=\"http://www.bet365.com/instantbet/default.asp?participantid=719823724&amp;affiliatecode=365_076057&amp;odds=0&amp;Instantbet=1\" data-role=\"bookmaker\"> <h4 class=\"fontface\">Bet</h4> <select> <option value=\"5\" data-value-away=\"£85\" data-value-draw=\"£35\" data-value-home=\"£5.9\"> £5</option> <option selected=\"selected\" value=\"10\" data-value-away=\"£170\" data-value-draw=\"£70\" data-value-home=\"£11.8\"> £10</option> <option value=\"20\" data-value-away=\"£340\" data-value-draw=\"£140\" data-value-home=\"£23.6\"> £20</option> <option value=\"50\" data-value-away=\"£850\" data-value-draw=\"£350\" data-value-home=\"£59\"> £50</option> <option value=\"100\" data-value-away=\"£1700\" data-value-draw=\"£700\" data-value-home=\"£118\"> £100</option> </select> <span class=\"fontface\">=</span> <a class=\"bet home\" target=\"\" href=\"http://www.bet365.com/instantbet/default.asp?participantid=719823724&amp;affiliatecode=365_076057&amp;odds=0&amp;Instantbet=1\"> <span class=\"result\"><img width=\"18\" height=\"18\" alt=\"Atletico Madrid\" src=\"http://secure.cache.images.core.optasports.com/soccer/teams/150x150/2020.png\" />ATM</span> <span class=\"amount\"></span> </a> <a class=\"bet draw\" target=\"\" href=\"http://www.bet365.com/instantbet/default.asp?participantid=719823727&amp;affiliatecode=365_076057&amp;odds=0&amp;Instantbet=1\"> <span class=\"result\">Draw</span> <span class=\"amount\"></span> </a> <a class=\"bet away\" target=\"\" href=\"http://www.bet365.com/instantbet/default.asp?participantid=719823728&amp;affiliatecode=365_076057&amp;odds=0&amp;Instantbet=1\"> <span class=\"result\"><img width=\"18\" height=\"18\" alt=\"Elche\" src=\"http://secure.cache.images.core.optasports.com/soccer/teams/150x150/2043.png\" />ELC</span> <span class=\"amount\"></span> </a> <a class=\"bet-logo\" target=\"\" href=\"http://www.bet365.com/instantbet/default.asp?participantid=719823724&amp;affiliatecode=365_076057&amp;odds=0&amp;Instantbet=1\"><img alt=\"Bet365\" src=\"http://i1.goal.com/web/goal/2015.04.21-v1/images/betting/bet365_w.png\" /></a> </div> <div class=\"hidden\" data-index=\"3\" data-bookmaker=\"WilliamHill\" data-bookmaker-url=\"http://ads2.williamhill.com/redirect.aspx?pid=39770151&amp;lpid=908300452&amp;bid=1092072397&amp;var3=en/nui/free-bet/%23http://sports.williamhill.com/bet/EN/addtoslip?action=BuildSlip%26price=y%26ew=n%26sel=856190081%26ustake=[STAKE]%26url=http://sports.williamhill.com/bet/en/betting/e/7483966\" data-role=\"bookmaker\"> <h4 class=\"fontface\">Bet</h4> <select> <option value=\"5\" data-value-away=\"£85\" data-value-draw=\"£32.5\" data-value-home=\"£5.9\"> £5</option> <option selected=\"selected\" value=\"10\" data-value-away=\"£170\" data-value-draw=\"£65\" data-value-home=\"£11.8\"> £10</option> <option value=\"20\" data-value-away=\"£340\" data-value-draw=\"£130\" data-value-home=\"£23.6\"> £20</option> <option value=\"50\" data-value-away=\"£850\" data-value-draw=\"£325\" data-value-home=\"£59\"> £50</option> <option value=\"100\" data-value-away=\"£1700\" data-value-draw=\"£650\" data-value-home=\"£118\"> £100</option> </select> <span class=\"fontface\">=</span> <a class=\"bet home\" target=\"\" href=\"http://ads2.williamhill.com/redirect.aspx?pid=39770151&amp;lpid=908300452&amp;bid=1092072397&amp;var3=en/nui/free-bet/%23http://sports.williamhill.com/bet/EN/addtoslip?action=BuildSlip%26price=y%26ew=n%26sel=856190081%26ustake=[STAKE]%26url=http://sports.williamhill.com/bet/en/betting/e/7483966\"> <span class=\"result\"><img width=\"18\" height=\"18\" alt=\"Atletico Madrid\" src=\"http://secure.cache.images.core.optasports.com/soccer/teams/150x150/2020.png\" />ATM</span> <span class=\"amount\"></span> </a> <a class=\"bet draw\" target=\"\" href=\"http://ads2.williamhill.com/redirect.aspx?pid=39770151&amp;lpid=908300452&amp;bid=1092072397&amp;var3=en/nui/free-bet/%23http://sports.williamhill.com/bet/EN/addtoslip?action=BuildSlip%26price=y%26ew=n%26sel=856190082%26ustake=[STAKE]%26url=http://sports.williamhill.com/bet/en/betting/e/7483966\"> <span class=\"result\">Draw</span> <span class=\"amount\"></span> </a> <a class=\"bet away\" target=\"\" href=\"http://ads2.williamhill.com/redirect.aspx?pid=39770151&amp;lpid=908300452&amp;bid=1092072397&amp;var3=en/nui/free-bet/%23http://sports.williamhill.com/bet/EN/addtoslip?action=BuildSlip%26price=y%26ew=n%26sel=856190083%26ustake=[STAKE]%26url=http://sports.williamhill.com/bet/en/betting/e/7483966\"> <span class=\"result\"><img width=\"18\" height=\"18\" alt=\"Elche\" src=\"http://secure.cache.images.core.optasports.com/soccer/teams/150x150/2043.png\" />ELC</span> <span class=\"amount\"></span> </a> <a class=\"bet-logo\" target=\"\" href=\"http://ads2.williamhill.com/redirect.aspx?pid=39770151&amp;lpid=908300452&amp;bid=1092072397&amp;var3=en/nui/free-bet/%23http://sports.williamhill.com/bet/EN/addtoslip?action=BuildSlip%26price=y%26ew=n%26sel=856190081%26ustake=[STAKE]%26url=http://sports.williamhill.com/bet/en/betting/e/7483966\"><img alt=\"WilliamHill\" src=\"http://i2.goal.com/web/goal/2015.04.21-v1/images/betting/william-hill_w.png\" /></a> </div> <div class=\"hidden\" data-index=\"4\" data-bookmaker=\"Sportingbet\" data-bookmaker-url=\"http://partner.sbaffiliates.com/processing/clickthrgh.asp?btag=a_45684b_34802&amp;aid=\" data-role=\"bookmaker\"> <h4 class=\"fontface\">Bet</h4> <select> <option value=\"5\" data-value-away=\"£115\" data-value-draw=\"£35\" data-value-home=\"£5.85\"> £5</option> <option selected=\"selected\" value=\"10\" data-value-away=\"£230\" data-value-draw=\"£70\" data-value-home=\"£11.7\"> £10</option> <option value=\"20\" data-value-away=\"£460\" data-value-draw=\"£140\" data-value-home=\"£23.4\"> £20</option> <option value=\"50\" data-value-away=\"£1150\" data-value-draw=\"£350\" data-value-home=\"£58.5\"> £50</option> <option value=\"100\" data-value-away=\"£2300\" data-value-draw=\"£700\" data-value-home=\"£117\"> £100</option> </select> <span class=\"fontface\">=</span> <a class=\"bet home\" target=\"\" href=\"http://partner.sbaffiliates.com/processing/clickthrgh.asp?btag=a_45684b_34802&amp;aid=\"> <span class=\"result\"><img width=\"18\" height=\"18\" alt=\"Atletico Madrid\" src=\"http://secure.cache.images.core.optasports.com/soccer/teams/150x150/2020.png\" />ATM</span> <span class=\"amount\"></span> </a> <a class=\"bet draw\" target=\"\" href=\"http://partner.sbaffiliates.com/processing/clickthrgh.asp?btag=a_45684b_34802&amp;aid=\"> <span class=\"result\">Draw</span> <span class=\"amount\"></span> </a> <a class=\"bet away\" target=\"\" href=\"http://partner.sbaffiliates.com/processing/clickthrgh.asp?btag=a_45684b_34802&amp;aid=\"> <span class=\"result\"><img width=\"18\" height=\"18\" alt=\"Elche\" src=\"http://secure.cache.images.core.optasports.com/soccer/teams/150x150/2043.png\" />ELC</span> <span class=\"amount\"></span> </a> <a class=\"bet-logo\" target=\"\" href=\"http://partner.sbaffiliates.com/processing/clickthrgh.asp?btag=a_45684b_34802&amp;aid=\"><img alt=\"Sportingbet\" src=\"http://i1.goal.com/web/goal/2015.04.21-v1/images/betting/sportingbet_w.png\" /></a> </div> </div> By Peter McVitie<br /> <p>As the game wore on, the intensity became unbearable. Atletico and Real Madrid were approaching three hours of football without a goal being scored and the stakes got ever higher as a place in the Champions League semi-finals got ever closer. However, in one moment of recklessness late in the second half, Arda Turan had dashed his team’s hopes.</p> <p>In a way, it was fitting. Atleti’s ability to remain organised and strong while fighting on the edge of the rules is such an integral part of their style. That combativeness could not have been more crucial heading into the late stages of this tie. Make a mistake, though, and it was clear they would be on their way out of the competition.</p> <p>Sadly for Diego Simeone’s men, with their rough and ready nature, there is always the danger of that mistake coming in a moment of madness.</p> <p>And when Turan, already on a yellow card, jumped up to challenge for a ball just as Sergio Ramos cleared it, it seemed inevitable that one aspect which has made this Rojiblancos team so effective would contribute to their downfall in such a crucial game.</p> <p>Turan, in many ways, embodies Simeone’s style. Strong, bustling, intimidating, hardworking - but explosive. There was no need for him to heave himself towards the defender with his foot up. He was merely asking to be dismissed. <br /><br />The 28-year-old may be the subject of criticism from his own side's fans, but Simeone was unwilling to point the finger at him for the defeat. &quot;<span>There's no sense in talking about Arda's red card,&quot; he told reporters after the game, merely ignoring the turning point in a game he felt his side controlled.</span></p> <p>The team is always on the verge of greatness. Last season they achieved it in La Liga at least. They almost did so in Europe. Tonight they had done well to hold off Madrid despite facing unbelievable pressure over the course of both games.</p> <opta start_expanded=\"true\" navigation=\"accordion\" live=\"false\" split_red_cards=\"false\" narrow_limit=\"400\" opta_logo=\"true\" coverage=\"complete\" match=\"799716\" player=\"39441\" team=\"t175\" season=\"2014\" competition=\"5\" sport=\"football\" widget=\"playerstats\"></opta> <p>Having had a few nervous moments, only to be bailed out once more by the inspired Jan Oblak, they had just started to show some adventure later in the second half. As they began to attack more often, there was a real the hope that they might find a way beyond Carlo Ancelotti’s men. They are experts at pouncing on a solitary moment of weakness, but sadly it was their own which was exploited.</p> <p>With the adrenaline pumping, Turan twice fell victim to his strong desire to fight for every ball. He chopped down Toni Kroos in the Blancos' half on the half hour mark with a silly challenge to earn his first booking. His second game even closer to Madrid’s goal. It’s hard to criticise someone with such strong determination, but in both cases, it was the wrong ball to fight for. An unnecessary risk.</p> <p>As the referee flashed the second yellow card to the Turkey international, there was a sense of inevitability about the defeat.<br /> <br /> Turan's absence threw the rest of the team out of sync and it was no surprise that a quick attack caught them out completely, allowing Javier Hernandez to create enough space for himself in the box and dash the hopes of the away side, sending them out of the competition.</p> <p>While Simeone and his team pride themselves on their combative style, their emotional play and their intensity, they will feel it has cost them dearly at the worst possible time this season.</p> <p><strong><span><span style=\"font-size: medium;\">Follow Peter McVitie on</span> </span></strong><em><a target=\"\" href=\"https://twitter.com/petermcvitie\"><img width=\"93\" height=\"19\" alt=\"\" src=\"http://u.goal.com/93900/93900.jpg\" /></a></em></p> <div class=\"module module-bet-signup clearfix\"> <div class=\"hidden\" data-index=\"1\" data-bookmaker=\"Sportingbet\" data-bookmaker-url=\"http://partner.sbaffiliates.com/processing/clickthrgh.asp?btag=a_43725b_33171&amp;aid=\" data-role=\"bookmaker\"> <a class=\"bet-logo\" target=\"\" href=\"http://partner.sbaffiliates.com/processing/clickthrgh.asp?btag=a_43725b_33171&amp;aid=\"><img alt=\"Sportingbet\" src=\"http://i2.goal.com/web/goal/2015.04.21-v1/images/betting/sportingbet_w.png\" /></a> <a class=\"bet-title\" target=\"\" href=\"http://partner.sbaffiliates.com/processing/clickthrgh.asp?btag=a_43725b_33171&amp;aid=\">Open an account today and get up to £50 Matched Bet</a> </div> <div class=\"hidden\" data-index=\"2\" data-bookmaker=\"WilliamHill\" data-bookmaker-url=\"http://ads2.williamhill.com/redirect.aspx?bid=1478396555&amp;lpid=1478422550&amp;pid=39770151\" data-role=\"bookmaker\"> <a class=\"bet-logo\" target=\"\" href=\"http://ads2.williamhill.com/redirect.aspx?bid=1478396555&amp;lpid=1478422550&amp;pid=39770151\"><img alt=\"WilliamHill\" src=\"http://i1.goal.com/web/goal/2015.04.21-v1/images/betting/william-hill_w.png\" /></a> <a class=\"bet-title\" target=\"\" href=\"http://ads2.williamhill.com/redirect.aspx?bid=1478396555&amp;lpid=1478422550&amp;pid=39770151\">Sign up with William Hill for a free bet up to £25</a> </div> <div class=\"hidden\" data-index=\"3\" data-bookmaker=\"Bet365\" data-bookmaker-url=\"http://www.bet365.com/home/?affiliate=365_076056\" data-role=\"bookmaker\"> <a class=\"bet-logo\" target=\"\" href=\"http://www.bet365.com/home/?affiliate=365_076056\"><img alt=\"Bet365\" src=\"http://i2.goal.com/web/goal/2015.04.21-v1/images/betting/bet365_w.png\" /></a> <a class=\"bet-title\" target=\"\" href=\"http://www.bet365.com/home/?affiliate=365_076056\">Sign up with bet365 for a 100% deposit bonus up to £200</a> </div> <div class=\"hidden\" data-index=\"4\" data-bookmaker=\"PaddyPower\" data-bookmaker-url=\"http://ad.doubleclick.net/clk;258351075;82652039;k\" data-role=\"bookmaker\"> <a class=\"bet-logo\" target=\"\" href=\"http://ad.doubleclick.net/clk;258351075;82652039;k\"><img alt=\"PaddyPower\" src=\"http://i1.goal.com/web/goal/2015.04.21-v1/images/betting/paddypower_w.png\" /></a> <a class=\"bet-title\" target=\"\" href=\"http://ad.doubleclick.net/clk;258351075;82652039;k\">Sign up to Paddy Power for £250 in free bets</a> </div> <img alt=\"\" class=\"hidden\" src=\"http://ad.doubleclick.net/ad/N7312.128055.GOAL.COM/B6698976.10;sz=1x1;ord=1429774009?\" /> </div> </div>";

    status.success('Test done');
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
//
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

//		query.first({
//			success: function(object) {
//				if (object) {
//					response.success(true);
//				} else {
//					response.success(false);
//				}
//			},
//			error: function(error) {
//				console.log("Error: " + error.code + " " + error.message);
//				response.error('asooasosoaosoaas');
//			}
//		});
	} else {
		response.error('Wrong parameters');
	}

});

Parse.Cloud.define("unlike", function(request, response) {
	var Like = Parse.Object.extend("Like");
	var query = new Parse.Query("Like");

	var reqData = JSON.parse(request.body);

	if (reqData.userId && reqData.postId) {
//		query.equalTo("userId", {
//			__type: "Pointer",
//			className: "_User",
//			objectId: reqData.userId
//		});

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

//		query.first({
//			success: function(object) {
//				if (object) {
//					if(object.get("userId").id === reqData.userId)
//					{
//						object.destroy({
//							success: function(myObject) {
//								response.success("Like was deleted");
//							},
//							error: function(myObject, error) {
//								console.log("Error: " + error.code + " " + error.message);
//								response.error();
//							}
//						});
//					}
//
//				} else {
//					response.error("Like wasn't found");
//				}
//			},
//			error: function(error) {
//				console.log("Error: " + error.code + " " + error.message);
//				response.error();
//			}
//		});
	} else {
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

//			if(result){
//				response.success(result);
//			} else {

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