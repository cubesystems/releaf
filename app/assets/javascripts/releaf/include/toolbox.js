jQuery(function()
{
    var body = jQuery('body');    
    
    var overlay = jQuery('<div />').addClass('toolbox-overlay').appendTo(body);
    overlay.bind('click', function()
    {
        body.trigger('toolboxcloseall');
    });

    body.bind('toolboxinit', function(e)
    {
        var target = jQuery(e.target);

        e.stopPropagation();
        
        var toolboxes;
        if (target.is('.toolbox'))
        {
            toolboxes = target;
        }
        else
        {
            toolboxes = target.find('.toolbox');
        }

        if (toolboxes.length < 1)
        {
            return;
        }
    
        toolboxes.bind('toolboxopen', function()
        {
            var toolbox   = jQuery(this);

            // close all other open toolboxes
            body.trigger('toolboxcloseall');

            var menu = toolbox.data('toolbox-menu');
  
            toolbox.attr('data-toolbox-open', true);

            menu.appendTo( body );
            toolbox.trigger('toolboxposition');

            overlay.show();

            menu.show();

            return;        
        });

        toolboxes.bind('toolboxclose', function()
        {
            var toolbox   = jQuery(this);

            var menu = toolbox.data('toolbox-menu');

            menu.hide().appendTo( toolbox );

            overlay.hide();

            toolbox.removeAttr('data-toolbox-open');

            return;
        });

        toolboxes.bind('toolboxtoggle', function()
        {
            var toolbox   = jQuery(this);
            var event = (toolbox.attr('data-toolbox-open')) ? 'toolboxclose' : 'toolboxopen';
            toolbox.trigger( event );
        });

        toolboxes.bind('toolboxposition', function()
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
    
        toolboxes.find('.trigger').click(function(e)
        {
            jQuery(this).closest('.toolbox').trigger('toolboxtoggle');
        });
        
        
        toolboxes.each(function()
        {
            var toolbox = jQuery(this);

            var menu = toolbox.find('menu').first();
            toolbox.data('toolbox-menu', menu);
            
            var items = menu.find('li');
            
            toolbox.toggleClass('empty', (items.length < 1));
            
        });
         
    }); 
    
    
    jQuery(window).bind('resize', function()
    {
        jQuery('.toolbox[data-toolbox-open]').trigger('toolboxposition');
    });

    body.bind('toolboxcloseall', function()
    {
        body.find('.toolbox[data-toolbox-open]').trigger('toolboxclose');        
    });
    
    body.trigger('toolboxinit');
    
    body.on('contentreplaced', function(e)
    { 
        // reinit toolboxes for all content that gets replaced via ajax
        jQuery(e.target).trigger('toolboxinit');
        
    });
    
});