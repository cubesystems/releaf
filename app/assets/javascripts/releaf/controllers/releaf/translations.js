jQuery(function()
{
	// highlight selected entry
	if( location.hash )
	{
		jQuery( location.hash ).addClass( 'highlighted' );
	}


	// import
    var controller = jQuery( '.controller-releaf-translations' );
	var import_form            = controller.find( 'form.import' );
	var import_file            = import_form.find( 'input[type="file"]' );
	var import_button 		   = controller.find( 'button[name="import"]' );
	var scope_input   		   = controller.find( 'input[name="resource[scope]"]' );
	var translations_container = controller.find( '.nested_wrap[data-name="translations"]' );

	var regular_button_text = import_button.html();

	import_button.click(function(){ import_file.click() });

	import_file.change(function()
	{
		import_button.html( import_button.attr( 'data-loading' ) );
		import_button.attr( 'disabled', true );

		jQuery.ajax
		({
			url: import_form.attr( 'action' ),
			data: new FormData( import_form[0] ),
			dataType: 'json',
			type: 'post',
			success: function( json )
			{
				import_button.html( regular_button_text );
				import_button.removeAttr( 'disabled' );

				var inputs = controller.find( 'tr:not(.template) .translation_name input[type="text"]' );
				var find = function( value )
				{
					for( var i = 0; i < inputs.length; i++ )
					{
						if( inputs[i].value == value )
						{
							return jQuery( inputs[i] );
						}
					}
					return null;
				}

				if( 'sheets' in json && json['sheets'][ scope_input.val() ] )
				{
					var sheet = json['sheets'][ scope_input.val() ];
					for( var key in sheet )
					{
						// try to find appropriate input - css selectors cannot be used because they don't reflect
						// changes made after pageload
						var input = find( key );
						var row;
						// construct new row if it does not exist
						if( !input )
						{
							translations_container.trigger( 'nestedfieldscreateitem', [function( new_row )
							{
								row = new_row;
								input = row.find( '.translation_name input' );
								input.val( key );
							}] );
						}
						else
						{
							row = input.parents( 'tr:first' );
						}
						if( input )
						{
							for( var locale in sheet[key] )
							{
								if( sheet[key][locale] )
								{
									var cell = row.find( 'td[data-locale="' + locale + '"]' );
									var value_input = cell.find( 'input[type="text"]' );
									if( value_input.val() != sheet[key][locale] )
									{
										value_input.val( sheet[key][locale] );
										cell.css
										({
											'-webkit-transition': 'none',
											'-moz-transition':    'none',
											'transition':         'none'
										});
										cell.addClass( 'flash' );
									}
								}
							}
						}
					}
					setTimeout(function()
					{
						var cells = controller.find( 'td.flash' );
						cells.css
						({
							'-webkit-transition': '',
							'-moz-transition':    '',
							'transition':         ''
						});
						setTimeout(function()
						{
							cells.removeClass( 'flash' );
						},100);
					},0);
				}
			},
			error: function()
			{
				import_button.html( regular_button_text );
				import_button.removeAttr( 'disabled' );
			},
			// tell jQuery not to process data or worry about content-type
			cache: false,
			contentType: false,
			processData: false
		});

		import_file.val( '' );
	});
});
