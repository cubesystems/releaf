//= require ../3rd_party/jquery.fancybox.js
//= require ../lib/url_builder

jQuery(document).ready( function()
{
    var ajaxbox_link_selector = 'a.ajaxbox';
        
    var xhr;
    
    var body = jQuery('body');        

    body.on('ajaxboxinit', function(e)
    {
        var target = jQuery(e.target);

        // init links 
        var links = (target.is(ajaxbox_link_selector)) ? target : target.find(ajaxbox_link_selector);
        
        if (links.length < 1)
        {
            return;
        }

        links.on('click', function()
        {
            if (xhr)
            {
                xhr.abort();
            }

            var link = jQuery(this);
            
            // Expects data-modal to be 0 or 1
            var modal = (link.attr('data-ajaxbox-modal') == '1');
            
            var params = 
            {
                autoDimensions    : true,
                autoScale         : true,
                centerOnScroll    : true,
                scrolling         : 'no',
                padding           : 0,
                overlayColor      : '#000000',
                overlayOpacity    : 0.5,
                afterShow        : function()
                {
                    this.inner.trigger('contentreplaced');
                    
                    var cancel_button = this.inner.find('.button[data-type="cancel"]').first();
                    if (cancel_button.length < 1)
                    {
                        return;
                    }
                    cancel_button.bind('click', function()
                    {
                        jQuery.fancybox.close();
                        return false;
                    });
                    cancel_button.focus();
                }
            }

            // If modal, disable closeClicks and closeButton
            if (modal)
            {
                params.closeBtn     = false;
                params.closeClick   = false;
                params.helpers     = { overlay: {closeClick: false} };
            }
            
            var url = new url_builder( link.attr('href') ).add( {ajax: 1} ).getUrl();

            xhr = jQuery.ajax(
            {
                url: url,
                type: 'get',
                success: function( data ) 
                {
                    params.content = data;
                    jQuery.fancybox( params );
                }
            });

            return false;
        });


    });

    body.trigger('ajaxboxinit');
    
    body.on('contentreplaced', function(e)
    { 
        // reinit ajaxbox for all content that gets replaced via ajax
        jQuery(e.target).trigger('ajaxboxinit');
    });
    
});

