jQuery(function()
{
    var body = jQuery('body');


	// import
    var controller = jQuery( '.controller-releaf-translations' );
	var import_form            = controller.find( 'form.import' );
	var import_file            = import_form.find( 'input[type="file"]' );
	var import_button 		   = controller.find( 'button[name="import"]' );
	var scope_input   		   = controller.find( 'input[name="resource[scope]"]' );
	var translations_container = controller.find( '.nested-wrap[data-name="translations"]' );
    var add_item_button        = controller.find( 'button.add-nested-item');


    var unflash_timer;

    var unflash_changed_cells = function()
    {
        var cells = controller.find( 'td.changed' );

        cells.find('input').css({
            '-webkit-transition': 'background-color .3s linear',
            '-moz-transition':    'background-color .3s linear',
            'transition' :        'background-color .3s linear'
        });
        cells.removeClass( 'changed' );
    }

    var set_row_values = function( row, key, locale_values )
    {
        row.find('.translation_name input[type="text"]').val( key );

        for (var locale in locale_values )
        {
            var new_value = ('' + locale_values[ locale ]).trim();

            var cell = row.find( 'td[data-locale="' + locale + '"]' );
            var value_input = cell.find( 'input[type="text"]' );
            if( value_input.length == 0 )
            {
                continue;
            }

            value_input.css(
            {
                '-webkit-transition': '',
                '-moz-transition':    '',
                'transition' :        ''
            });

            var current_value = value_input.val().trim();

            if (current_value != new_value)
            {
                value_input.val( new_value );
                cell.addClass( 'changed' );
                unflash_timer = setTimeout( unflash_changed_cells, 200);
            }
        }
    }

    translations_container.on('nestedfieldsitemadd', '.item[data-name="translations"]', function(e, event_params)
    {
        if (
            (!event_params)
            ||
            (!('translation_key' in event_params))
            ||
            (!('translation_values' in event_params))
        )
        {
            return;
        }

        var row = jQuery(e.target);
        set_row_values( row, event_params.translation_key, event_params.translation_values, true);
    });


	import_button.click(function(){ import_file.click() });

	import_file.change(function()
	{
        body.trigger('toolboxcloseall');

		jQuery.ajax
		({
			url: import_form.attr( 'action' ),
			data: new FormData( import_form[0] ),
			dataType: 'json',
			type: 'post',
			success: function( json )
			{
                var key_inputs = controller.find( 'tr.item[data-name="translations"]:not(.template,.removed) .translation_name input[type="text"]' );

				var find_key_input = function( value )
				{
                    value = ('' + value).trim();
					for( var i = 0; i < key_inputs.length; i++ )
					{
                        if (key_inputs[i].value.trim() == value)
						{
							return jQuery( key_inputs[i] );
						}
					}
					return null;
				}

				if ( 'sheets' in json && json['sheets'][ scope_input.val() ] )
				{
					var sheet = json['sheets'][ scope_input.val() ];
					for( var key in sheet )
					{
						// try to find appropriate input - css selectors cannot be used because they don't reflect
						// changes made after pageload
						var key_input = find_key_input( key );
                        var row;

                        if (key_input)
                        {
                            set_row_values( key_input.closest('tr'), key, sheet[key], false );
                        }
                        else
                        {
                            var event_params =
                            {
                                no_animation        : true,
                                translation_key     : key,
                                translation_values  : sheet[key]
                            };
                            add_item_button.trigger('click', event_params);
                        }
					}

				}
			},
			error: function()
			{

			},
			// tell jQuery not to process data or worry about content-type
			cache: false,
			contentType: false,
			processData: false
		});

		import_file.val( '' );
	});
});
