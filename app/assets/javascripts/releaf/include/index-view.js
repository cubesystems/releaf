jQuery(function()
{
	// ajax search
	jQuery( '.view-index' ).on( 'searchinit', function( event )
	{
		var form = jQuery( event.target );

		var input = form.find( 'input[name="search"]' );
		var timeout;
		var request;
		var last_search_query = input.val();

		var main  = form.parents( 'body > .main' );
		var header   = main.children( '.header' );
        // sometime all index can be inside form (because of checkbox/etc),
        // so use "find" method
		var table   = main.find( '.table' );
		var footer = main.children( 'footer' );

		// custom "lookup" event allows to issue extra reloads from the outside

		form.bind( 'lookup', function()
		{
			// cancel previous timeout
			clearTimeout( timeout );
			// cancel previous unfinished request
			if( request !== undefined )
			{
				request.abort();
			}
			timeout = setTimeout(function()
			{
				// set loading icon
				var submit_button = form.find('button[type="submit"]');
                submit_button.addClass( 'loading' );
				// construct url
				var url = new RequestUrl( form.attr( 'action' ) );
				url.add( form.serializeArray() );
				url.add({ ajax: 1 });
				// send request
				request = jQuery.ajax
				({
					url: url.getUrl(),
					success: function( response )
					{
						// remove loading icon
						submit_button.removeClass( 'loading' );

						// create html holder
                        var html = jQuery( '<div />' ).append( response );

                        header.html( html.find( '.header' ).html() );
                        table.html( html.find( '.table' ).html() );
                        footer.html( html.find( 'footer' ).html() );

                        table.trigger('toolboxinit');
					}
				});
			}, 200 );
		});

		// attach keypress event
		input.keyup( function()
		{
			if( input.val() == last_search_query )
			{
				return;
			}
			last_search_query = input.val();
			form.trigger( 'lookup' );
		});
	});

    // init default form
    jQuery( '.view-index form.search' ).trigger( 'searchinit' );

    jQuery('#page_select').on('change', function(){
        var val=jQuery(this).val();
        if(val)
        {
            var request_url = new RequestUrl().add({page: val}).getUrl();
            window.location.href = request_url;
        }
    });
});
