//= require ../3rd_party/jquery-cookie/jquery.cookie.js
//= require ../lib/request_url.js

jQuery(function()
{
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
				form.addClass( 'loading' );
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
						form.removeClass( 'loading' );
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



    // initialize date/datetime/time pickers
    jQuery(document.body).delegate('form', 'initcalendars', function() {
        var forms = jQuery(this);
        var options = {
            timeFormat: 'HH:mm:ss',
            controlType: 'select',
            showHour: true,
            showMinute: true,
            // showSecond: true,
            // showTimezone: true,
        }

        forms.find('.date_picker').each(function() {
            var picker = jQuery(this);
            var opt = options;
            opt['dateFormat'] = picker.attr('data-date-format') || 'yy-mm-dd';
            picker.datepicker(opt);
        });

        forms.find('.datetime_picker').each(function() {
            var picker = jQuery(this);
            var opt = options;
            opt['dateFormat'] = picker.attr('data-date-format') || 'yy-mm-dd';
            opt['pickerTimeFormat'] = picker.attr('data-time-format') || 'HH:mm'
            picker.datetimepicker(opt);
        });

        /*
         * forms.find('.time_picker').each(function() {
         *     var picker = jQuery(this);
         *     var opt = options;
         *     opt['pickerTimeFormat'] = picker.attr('data-time-format') || 'HH:mm'
         *     picker.timepicker(options);
         * });
         */
    });

    jQuery('form').trigger('initcalendars');


    jQuery('form').on('keyup', '.sync_field', function(e) {
        var input = jQuery(e.target);
        var value_div = input.parents('.value:first');
        var hidden_field = value_div.find('input[type="hidden"].sync_field');
        if (input.is('input')) {
            hidden_field.attr('value', input.attr('value'));
        }
        else if (input.is('textarea')) {
            hidden_field.attr('value', input.text());
        }
        else {
            console.error("Not implemented");
        }

    });

});
