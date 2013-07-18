jQuery(function()
{
    var body = jQuery('body');    
    
    var overlay = jQuery('<div />').addClass('toolbox-overlay').appendTo(body);
    overlay.bind('click', function()
    {
        body.trigger('toolboxcloseall');
    });

    
    jQuery('.toolbox').bind('toolboxopen', function()
    {
        var toolbox   = jQuery(this);
        
        // close all other open toolboxes
        body.trigger('toolboxcloseall');
        
        var menu = toolbox.data('toolbox-menu');
        if (!menu)
        {
            menu = toolbox.find('menu').first();
            toolbox.data('toolbox-menu', menu);
        }     
        toolbox.attr('data-toolbox-open', true);
        
        menu.appendTo( body );
        toolbox.trigger('toolboxposition');

        overlay.show();
        
        menu.show();
        
        return;        
    });

    jQuery('.toolbox').bind('toolboxclose', function()
    {
        var toolbox   = jQuery(this);
      
        var menu = toolbox.data('toolbox-menu');
        if (!menu)
        {
            return;
        }
        
        menu.hide().appendTo( toolbox );

        overlay.hide();
        
        toolbox.removeAttr('data-toolbox-open');
        
        return;
    });

    jQuery('.toolbox').bind('toolboxtoggle', function()
    {
        var toolbox   = jQuery(this);
        var event = (toolbox.attr('data-toolbox-open')) ? 'toolboxclose' : 'toolboxopen';
        toolbox.trigger( event );
    });

    jQuery('.toolbox').bind('toolboxposition', function()
    {
        var toolbox   = jQuery(this);
        if (!toolbox.attr('data-toolbox-open'))
        {
            return;
        }
        
        var menu = toolbox.data('toolbox-menu');

        var trigger        = toolbox.find('.trigger');
        var triggerOffset  = trigger.offset();
        
        var triggerCenterX = triggerOffset.left + (trigger.outerWidth() / 2);
        
        var menuWidth   = menu.outerWidth();
        var openToRight = ((jQuery(document).width() - triggerCenterX - menuWidth - 50) > 0);

        var beak = menu.children('i').first();        
        
        if (openToRight)
        {
            menu.css
            ({
                left:  triggerCenterX - 23,
                top :  triggerOffset.top  + trigger.outerHeight(),
            });
            beak.css(
            {
                left : 16
            });
        }
        else
        {
            menu.css
            ({
                left:  triggerCenterX - menuWidth + 20,
                top :  triggerOffset.top  + trigger.outerHeight(),
            });         
            beak.css(
            {
                left : menuWidth - 27,
            });            
        }
       
    });
    
    jQuery('.toolbox .trigger').click(function(e)
    {
        jQuery(this).closest('.toolbox').trigger('toolboxtoggle');
    });
    
    jQuery(window).bind('resize', function()
    {
        jQuery('.toolbox[data-toolbox-open]').trigger('toolboxposition');
    });
   
    
    body.bind('toolboxcloseall', function()
    {
        body.find('.toolbox[data-toolbox-open]').trigger('toolboxclose');        
    });
    
    
});