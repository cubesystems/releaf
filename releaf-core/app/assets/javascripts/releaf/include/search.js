/* global UrlBuilder */
//= require ../lib/url_builder

jQuery(function()
{
    var body = jQuery('body');

    body.on('searchinit', 'form', function( e )
    {
        var form = jQuery(e.target);

        var text_input_selector  = 'input[type="text"]';
        var other_input_selector = 'input:not([type="text"]), select';

        var text_inputs  = form.find( text_input_selector  );
        var other_inputs = form.find( other_input_selector );

        var all_inputs   = jQuery().add(text_inputs).add(other_inputs);

        text_inputs.each(function() {
            var input = jQuery(this);
            input.data('previous-value', input.val() || '');
        });

        var submit_buttons = form.find('button[type="submit"]');

        var request;
        var timeout;


        var options = form.data('search-options');

        if (typeof options === 'undefined')
        {
            options = {};
        }

        if (typeof options.result_blocks === 'undefined')
        {
            // define default html blocks that will be fetched from search response
            // and placed in page body
            options.result_blocks =
            {
                main_section :
                {
                    result_selector : 'section',
                    target : jQuery('main > section').first()
                }
            };
        }


        form.on( 'searchstart', function()
        {
            // cancel previous timeout
            clearTimeout( timeout );

            // store previous values for all inputs
            all_inputs.each(function()
            {
                var input = jQuery(this);
                if (input.is('input[type="checkbox"]:not(:checked)'))
                {
                    input.data('previous-value', '');
                }
                else if(!(input.is('input[type="checkbox"]:checked')))
                {
                    input.data('previous-value', input.val());
                }
            });

            // cancel previous unfinished request
            if (request)
            {
                request.abort();
            }

            timeout = setTimeout(function()
            {
                submit_buttons.trigger('loadingstart');

                // construct url
                var form_url = form.attr( 'action' );
                var url = new UrlBuilder( {baseUrl: form_url} );
                url.add( form.serializeArray() );

                if ('replaceState' in window.history)
                {
                    window.history.replaceState( window.history.state, window.title, url.getUrl());
                }

                url.add({ ajax: 1 });

                // send request
                request = jQuery.ajax
                ({
                    url: url.getUrl(),
                    success: function( response )
                    {
                        form.trigger('searchresponse', response);

                        form.trigger('searchend');
                    }
                });
            }, 200 );
        });


        form.on( 'searchresponse', function(e, response)
        {
            response = jQuery('<div />').append( response );

            // for each result block find its content in response
            // and copy it to its target container

            for (var key in options.result_blocks)
            {
                var block = options.result_blocks[ key ];

                var content = response.find( block.result_selector ).first().html();

                jQuery( block.target ).html( content );

                block.target.trigger('contentloaded');

            }
        });

        form.on( 'searchend', function()
        {
            submit_buttons.trigger('loadingend');
        });

        var start_search_if_value_changed = function()
        {
            var input = jQuery(this);

            var previous_value = input.data('previous-value');

            if (input.val() === previous_value)
            {
                return;
            }

            form.trigger( 'searchstart' );
        };

        text_inputs.on( 'keyup',  start_search_if_value_changed);
        all_inputs.on(  'change', start_search_if_value_changed);

    });

    setTimeout( function ()
    {
        // initialize search via timeout
        // to allow any custom code to set custom form search options

        jQuery( '.view-index form.search' ).trigger( 'searchinit' );

    }, 0);

});
