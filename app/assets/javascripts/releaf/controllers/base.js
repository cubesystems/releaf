//= require ../3rd_party/jquery-cookie/jquery.cookie.js
//= require ../lib/request_url.js


jQuery(function()
{
    // define validation handlers 
    jQuery( document ).on( 'validationinit', 'form', function( event ) 
    {
        if (event.isDefaultPrevented())
        {
            return;
        }
        
        var form = jQuery(event.target);

        var firstErrorFocused = false;

        form.submit(function(event)
        {
            // clear errors
            firstErrorFocused = false;
            form.find('.hasError').each(function()
            {
                var fieldBox = jQuery(this);

                fieldBox[0].removeTimeout = setTimeout( function()
                {
                    fieldBox.removeClass('hasError');
                    fieldBox.find('.errorBox').remove();
                }, 200 );

            });            
            
            // :TODO: show loader
        });

        form.data( 'validator', new Validator(form, { ui : false } ));

        form.bind( 'error', function( event, v, error )
        {
            var target = jQuery(event.target);

            if (!target.is('input[type!="hidden"],textarea,select'))
            {
                return;
            }

            
            var fieldBox = target.parents('.field').first();
            if (fieldBox.length != 1)
            {
                return;
            }
            
            var previousErrorExists = fieldBox.hasClass('hasError');

            if (previousErrorExists && fieldBox[0].removeTimeout)
            {
                clearTimeout(fieldBox[0].removeTimeout);
            }

            var errorBox = fieldBox.find('.errorBox');

            if (errorBox.length == 0)
            {
                errorBox = jQuery('<div class="errorBox"><div class="error"></div></div>').appendTo(fieldBox);
            }

            errorBox.find('.error').text( error.message );

            fieldBox.addClass('hasError');


            if (!firstErrorFocused && target.focus)
            {
                target.focus();
                firstErrorFocused = true;
            }
            
            var input = fieldBox.find('input:first, select:first, textarea:first');
            errorBox.css('left', input.position().left + input.width());

        });

        form.bind( 'ok', function( event, v )
        {
            // :TODO: remove loader
        });

        form.bind( 'fail', function( event, v )
        {

        });
        
    });
    

    jQuery( document ).on( 'validate', 'form', function( event ) 
    {
        // use this to manually trigger form validation outside of a submit event

        if (event.isDefaultPrevented())
        {
            return;
        }
        var form = jQuery(event.target);
        
        if (!form.data('validator'))
        {
            return;
        }
        
        form.data('validator').validateForm();
        return;
        
    });
    
    // attach validation to default forms
    jQuery('form[data-validation-url]').trigger('validationinit');



    // list action switcher
    jQuery( '.action-index' ).on( 'click', '.list_action_switch button', function( event )
	{
		var button = jQuery( this );
		var action = button.attr( 'data-action' );
		button.siblings( '.active' ).removeClass( 'active' );
		button.addClass( 'active' );
		// store cookie
		jQuery.cookie( 'base_module:list_action', action, { path: '/', expires: 365 * 5 } );
		// modify current links
		var table = button.parents( '.panel_layout' ).find( '.body .releaf_table' );
		// collect ids
		var ids = [];
		var rows = table.find( '.tbody > .row' );
		rows.each(function()
		{
			ids.push( jQuery( this ).attr( 'data-id' ) );
		});
		var url = new RequestUrl();
		url.path += '/urls.json';
		jQuery.ajax
		({
			url: url.getUrl(),
			type: 'post',
			data: { ids: ids, to_action: action },
			success: function( json )
			{
				rows.each(function()
				{
					var row = jQuery( this );
					if( json[ row.attr( 'data-id' ) ] )
					{
						row.children( '.main' ).attr( 'href', json[ row.attr( 'data-id' ) ] );
						if( row.is( 'a' ) )
						{
							row.attr( 'href', json[ row.attr( 'data-id' ) ] );
						}
					}
				});
			}
		});
		// clear cache on continuous scroll tables
		table.trigger( 'flushcache' );
	});

	// ajax search

	jQuery( '.view-index' ).on( 'searchinit', function( event )
	{
		var form = jQuery( event.target );

		var input = form.find( '.search' );
		var timeout;
		var request;
		var last_search_query = input.val();

		var panel  = form.parents( '.primary_panel:first' )
		var body   = panel.children( '.body' );
		var footer = panel.children( '.footer' );

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
						var html = jQuery( response );
						body.html( html.filter( '.body' ).html() );
						footer.html( html.filter( '.footer' ).html() );
						// init continuous scroll
						body.find( '.releaf_table' ).trigger( 'scrollinit' );
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

	jQuery( '.view-index .search_form' ).trigger( 'searchinit' );
});
