//= require ../3rd_party/jquery.fancybox.js
//= require ./url_builder

/** init **/
jQuery(document).ready( function(){
    var ajax_xhr = null;

    jQuery(document.body).on('init_ajax_view', function(e)
    {
        var target = jQuery(e.target);

        if (target.find('.ajax_view').length < 1)
        {
            return;
        }

        var ajax_view_link = jQuery(target.find('.ajax_view'));

        // Expects data-modal to be 0 or 1
        var modal = ajax_view_link.data('modal');
        modal = (typeof modal != 'undefined' && modal == "1") ? true : false;

        var params = {
            autoDimensions    : true,
            autoScale         : true,
            centerOnScroll    : true,
            scrolling         : 'no',
            padding           : 0,
            overlayColor      : '#000000',
            overlayOpacity    : 0.5
        }

        // If modal, disable closeClicks and closeButton
        if (modal)
        {
            params['closeBtn'] = false;
            params['closeClick'] = false;
            params['helpers'] = {overlay: {closeClick: false}};
        }

        ajax_view_link.on('click', function(){
            ajax_xhr ? ajax_xhr.abort() : null;

            if (jQuery(this).attr('href'))
            {
                var url = new url_builder( jQuery(this).attr('href') ).add({ajax: 1}).getUrl();

                ajax_xhr = jQuery.ajax({
                    url: url,
                    type: 'get',
                    success: function( data ) {
                        params.content = data;
                        jQuery.fancybox( params );
                        jQuery(document).on('click', '.fancybox-opened button[data-type="cancel"]', function(){
                            jQuery.fancybox.close();
                            return false;
                        });
                    }
                });

            }
            ajax_xhr = null;
            return false;
        });


    });

    jQuery(document.body).trigger('init_ajax_view');
});

