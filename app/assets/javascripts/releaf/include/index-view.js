jQuery(function()
{
    jQuery('body').on('searchinit', 'form', function( e ) 
    {
        var form = jQuery(e.target);

        var input   = form.find('[name="search"]');
                
        var request;
        var timeout;

        var last_query  = input.val();
        
        var options = form.data('search-options');

        if (typeof options == 'undefined')
        {
            options = {};
        }
        
        if (typeof options.result_blocks == 'undefined')
        {
            // define default html blocks that will be fetched from search response
            // and placed in page body
            options.result_blocks = 
            {
                header : 
                { 
                    result_selector : '.header',
                    target : jQuery('body > .main .header').first()
                },

                table :
                {
                    result_selector : '.table',
                    target : jQuery('body > .main .table').first()
                },

                footer :
                {
                    result_selector : 'footer',
                    target : jQuery('body > .main footer').first()
                }
            };
        }
        
 
        form.on( 'searchstart', function()
        {
            // cancel previous timeout
            clearTimeout( timeout );

            // cancel previous unfinished request
            if (request)
            {
                request.abort();
            }

            timeout = setTimeout(function()
            {
                form.addClass( 'loading' );
                
                // construct url
                var url = new RequestUrl( false );
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
                        // remove loading icon
                        form.removeClass( 'loading' );

                        form.trigger('searchresponse', response);

                        form.trigger('searchend');
                    }
                });
            }, 200 );
        }); 

        
        form.on( 'searchresponse', function(e, response)
        {
            var response = jQuery('<div />').append( response );
            
            // for each result block find its content in response 
            // and copy it to its target container
            
            for (var key in options.result_blocks)
            {
                var block = options.result_blocks[ key ];
                
                var content = response.find( block.result_selector ).first().html();

                jQuery( block.target ).html( content );
                
                block.target.trigger('contentreplaced');
            }
        });
        
        form.on( 'searchend', function( e )
        {
            form.removeClass( 'loading' );
        });


        input.on( 'keyup',  function()
        {
            if (input.val() == last_query )
            {
                return;
            }
            last_query = input.val();

            form.trigger( 'searchstart' );
        });


        form.on('change', 'input, select', function( e)
        {
            if (
                (input[0] == e.target)
                &&
                (input.val() == last_query )
            )
            {
                // do not trigger searchstart on main input change
                // if last query is the same
                return;
            }
            
            form.trigger('searchstart');
        });


    });

    setTimeout( function () 
    {
        // initialize search via timeout 
        // to allow any custom code to set custom form search options
        
        jQuery( '.view-index form.search' ).trigger( 'searchinit' );
        
    }, 0);





    jQuery('#page_select').on('change', function(){
        var val=jQuery(this).val();
        if(val)
        {
            var request_url = new RequestUrl().add({page: val}).getUrl();
            window.location.href = request_url;
        }
    });
    
});
