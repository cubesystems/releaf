jQuery(document).ready(function()
{

    jQuery(document.body).on('click', '.nested_wrap .add', function(e) {
        e.stopPropagation;
        var button = jQuery(e.target);
        var nested_wrap = button.parents('.nested_wrap:first');
        var key = 'on-' + new Date().getTime();
        var template = jQuery( '<div></div>' ).append( nested_wrap.find( '.template:first' ).clone().removeClass( 'template' ) ).html();
        var item = jQuery( template.replace( /(".*?)(_template_)(.*?")/g, '$1' + key + '$3' ) );
        var list = nested_wrap.find( '.list:first' );
        list.append( item );


        if( item.is('tr') )
        {
            item.fadeIn( 'normal' );
            item.trigger('itemadd');
        }
        else
        {
            item.css({ opacity: 0 });
            item.slideDown( 'fast', function()
            {
                item.css({ opacity: '' });
                item.find( 'input:first' ).focus();
                item.hide();
                item.fadeIn( 'fast' );
                item.trigger('itemadd');
            });
        }

    });


    jQuery(document.body).on('click', '.nested_wrap .remove', function(e) {
        e.stopPropagation;
        var button = jQuery(e.target);
        var item = button.parents('.item:first');
        var destroy = item.find('input.destroy');

        var remove_item = function()
        {
            item.css('display', 'none');
            item.trigger('itemremoveend');
            if ( destroy.length > 0 )
            {
                destroy.val( true );
            }
            else
            {
                item.remove();
            }
        }


        item.css('overflow', 'hidden');
        item.animate({opacity: 0, height: 0}, 'fast', 'swing', remove_item)

        item.trigger('itemremove');

    });

});
