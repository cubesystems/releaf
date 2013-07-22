//= require ../3rd_party/jquery.fancybox.js
//= require ./url_builder.js

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
            modal           : modal,
            autoDimensions  : true,
            autoScale       : true,
            centerOnScroll  : true,
            scrolling       : 'no',
            padding         : 0,
            overlayColor    : '#000000',
            overlayOpacity  : 0.6
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
                    }
                });

            }
            ajax_xhr = null;
            return false;
        });


    });

    jQuery(document.body).trigger('init_ajax_view');
});

