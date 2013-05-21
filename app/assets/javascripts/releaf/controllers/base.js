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

        form.data( 'validator', new Validator(form, { ui : false } ));
        
        form.on( 'validationstart', function( event, v, event_params ) 
        {
            form.attr( 'data-validation-id', event_params.validation_id );
          
            // :TODO: show loader            
        });
        
        
        form.on( 'validationend', function( event, v, event_params )
        {
            // remove all errors left from earlier validations
            var last_validation_id = form.attr( 'data-validation-id' );

            if (event_params.validation_id != last_validation_id)
            {
                // do not go further if this is not the last validation
                return;
            }
            
            
            // remove old field errors
            form.find('.field.has_error').each(function()
            {
                var field = jQuery(this);
                var error_box = field.find( '.error_box' );
                var error_node = error_box.find('.error');
                
                if (error_node.attr('data-validation-id') != last_validation_id)
                {
                    error_box.remove();
                    field.removeClass('has_error');
                }
                
            });
            
            // remove old form errors
            if (form.hasClass('has_error'))
            {
                var form_error_box = form.find('.form_error_box');
                var form_errors_remain = false;
                
                form_error_box.find('.error').each(function()
                {
                    var error_node = jQuery(this);
                    if (error_node.attr('data-validation-id') != last_validation_id)
                    {
                        error_node.remove();
                    }
                    else
                    {
                        form_errors_remain = true;
                    }
                });
                
                if (!form_errors_remain)
                {
                    form_error_box.remove();
                    form.removeClass('has_error');
                }
            }
            
            

            // if error fields still exist, focus to first visible
            var focus_target = form.find('.field.has_error').find('input[type!="hidden"],textarea,select').filter(':visible').first();
            
            focus_target.focus();
                
            // :TODO: remove loader
        });
        
        
        form.bind( 'validationerror', function( event, v, event_params )
        {
  
            var error = event_params.error;
            
            var target = jQuery(event.target);

            if (target.is('input[type!="hidden"],textarea,select'))
            {
                var field_box = target.parents('.field').first();
                if (field_box.length != 1)
                {
                    return;
                }

                var error_box = field_box.find('.error_box');
                
                if (error_box.length < 1)
                {
                    error_box = jQuery('<div class="error_box"><div class="error"></div></div>');
                    error_box.appendTo( field_box.find('.value') );
                }

                var error_node = error_box.find('.error');
                error_node.attr('data-validation-id', event_params.validation_id );
                error_node.text( error.message );

                field_box.addClass('has_error');
                
            }
            else if (target.is('form'))
            {
                var form = target;

                var form_error_box = form.find('.form_error_box');
                if (form_error_box.length < 1)
                {
                    var form_error_box_container = form.find('.body').first();
                    if (form_error_box_container.length < 1)
                    {
                        form_error_box_container = form;
                    }
                    form_error_box = jQuery('<div class="form_error_box"></div>');
                    form_error_box.prependTo( form_error_box_container );
                }
                
                var error_node = null;
                
                // reuse error node if it has the same text
                form_error_box.find('.error').each(function()
                {
                    if (error_node)
                    {
                        return;
                    }
                    if (jQuery(this).text() == error.message)
                    {
                        error_node = jQuery(this);
                    }
                })
                
                var new_error_node = !error_node;
                
                if (!error_node)
                {
                    error_node = jQuery('<div class="error"></div>');
                }
                
                error_node.attr('data-validation-id', event_params.validation_id);
                error_node.text( error.message );                
                
                if (new_error_node)
                {
                    error_node.appendTo( form_error_box );
                }
                
                form.addClass('has_error');
            }
          

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
