jQuery(function()
{

    jQuery('body').on('loadingstart', '.button', function(e)
    {
        var button = jQuery(e.target);

        if (button.hasClass('loading'))
        {
            return;
        }
        button.addClass('loading');
        
        var loader = jQuery('<i />').addClass('loader icon-spin icon-spinner');
            
        button.append( loader );
    });
    
    
    jQuery('body').on('loadingend', '.button', function(e)
    {
        var button = jQuery(e.target);
        
        button.find('.loader').remove();

        button.removeClass('loading');

    });            
    
    
            
});
