$(function() {	
	var authEl = $('#authEl'),
		tableEl = $('#table_wrapper'),
		appId = "7iYJMHDqqHJ2xmIiimYjDSBOeia4IcKz6cUJluqB",
		RestApiKey = "UpccrCqCbkry2HUgy6HNEMC1za1O1KLQocAqAACM";

	$('#signOut').hide();
	$('#send').on('click', signIn);	
	$('#signOut').on('click', signOut);
	switchPages();
	tableInit();

	function tableInit() {

		var table = $('#dateTable').DataTable({
    		serverSide: true,
    		bProcessing: true,  
    		aaSorting: [6,'desc'],		
		    ajax: {
		        url: 'https://api.parse.com/1/functions/getPosts',
		        type: 'POST',
		        headers: {
				  	"X-Parse-Application-Id" : appId,
				  	"X-Parse-REST-API-Key" : RestApiKey
				},				
		    },
		    "columns": [
	            { "data": "title" },
	            { "data": "category" },
	            { "data": "source" },
	            { "data": null, render: function ( data, type, row ) {                	
	                return "<a href='" + data.link + "''>" + data.link + "</a>";
	            }},
	            { "data": "content" },
	            { "data": "author" },
	            { "data": "createdAt" },
	            { "data": null, render: function ( data, type, row ) {                	
	                return "<button class='btn' data-postid='" + data.objectId + "'>Send push</button>";
	            }}
	        ]
		});

		table.on( 'draw', function () {		    
		    $('[data-postid]').each(function(index, btn) {
		    	$(btn).on('click', {postId: btn.dataset.postid}, function(e) {
		    		// alert(e.data.postId);
		    		var postId = e.data.postId;
		    		var message = prompt('Send push\nEnter your message: ', '');
		    		if (message != null) {
		    			if (message) {

		    				var request = $.ajax({
							    url: "https://api.parse.com/1/functions/sendPostByPush",
							    method: "POST",
							    headers: {
							  		"X-Parse-Application-Id" : appId,
							  		"X-Parse-REST-API-Key" : RestApiKey
							    },
							    data: { 
							  	    postId : postId,
							  		message: message
							    },
							    dataType: "json"
							});

							request.done(function( msg ) {
							  	alert('Push was sent');
							});
							 
							request.fail(function( jqXHR, textStatus ) {
							    alert('Push failed');
							});		    				
		    			} else {
		    				alert('Empty message!\nPush wasn\'t send');
		    			}
		    			
		    		}

		    	});
		    });
		});
	}		

	function signIn() {
		var request = $.ajax({
		  url: "https://api.parse.com/1/functions/signIn",
		  method: "POST",
		  headers: {
		  	"X-Parse-Application-Id" : appId,
		  	"X-Parse-REST-API-Key" : RestApiKey
		  },
		  data: { 
		  	email : $('#email').val(),
		  	pass: $('#pass').val()
		  },
		  dataType: "json"
		});
		 
		request.done(function( msg ) {
		  	console.dir(msg);
		  	localStorage.setItem("auth", "true");
		  	switchPages();
		});
		 
		request.fail(function( jqXHR, textStatus ) {
		  alert( "Request failed: " + (JSON.parse(jqXHR.responseText)).error );		  
		});
	}

	function signOut() {
		localStorage.removeItem("auth");
		switchPages()
	}

	function switchPages() {
		if (localStorage.getItem("auth")) {
			authEl.hide();
			$('#signOut').show();
			tableEl.show();
		} else {
			authEl.show();
			$('#signOut').hide();
			tableEl.hide();
		}
	}
	
});