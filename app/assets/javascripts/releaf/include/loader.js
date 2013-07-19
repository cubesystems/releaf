jQuery(function()
{

    jQuery('body').on('loadingstart', '.button', function(e)
    {
        var button = jQuery(e.target);

        if (button.hasClass('loading'))
        {
            return;
        }

        var original_color = button.css('color');
        
        button.data('loading-original-color', original_color);
        
        button.addClass('loading');
        
        button.css('color', 'transparent');
        
        var loader = jQuery('<i />').addClass('loader icon-spin icon-spinner');
        
        loader.css( 'color', original_color );
            
        button.append( loader );
    });
    
    
    jQuery('body').on('loadingend', '.button', function(e)
    {
        
        var button = jQuery(e.target);
        
        var original_color = button.data('loading-original-color');
        if (original_color)
        {
            button.css('color', original_color);
        }
        
        button.find('.loader').remove();

        button.removeClass('loading');
        
    });            
    
    
            
});
