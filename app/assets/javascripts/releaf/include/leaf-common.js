jQuery(function(){

    var body = jQuery('body');

    jQuery('body > .side > .compacter button').click(function()
    {
        if (body.hasClass('side-compact'))
        {
            $.removeCookie('releaf.side.compact', { path: '/' });
            body.removeClass('side-compact');
            $('.toggle-angle-icon').addClass('icon-double-angle-left').removeClass('icon-double-angle-right');
        }
        else
        {
            $.cookie( 'releaf.side.compact', 1, { path: '/', expires: 365 * 5 } );
            body.addClass('side-compact');
            $('.toggle-angle-icon').addClass('icon-double-angle-right').removeClass('icon-double-angle-left');
        }
    });


    jQuery('body > .side > nav .collapser button').click(function(e)
    {
        var sectionLi = jQuery(this).parents('li').first();
        var cookieName = 'releaf.side.opened.' + sectionLi.data('name')
        e.stopPropagation();
        sectionLi.toggleClass('collapsed');
        jQuery(this).blur();
        if (sectionLi.hasClass('collapsed'))
        {
            $.removeCookie(cookieName, { path: '/' });
            sectionLi.find('.chevron').addClass('icon-chevron-down').removeClass('icon-chevron-up');
        }
        else
        {
            $.cookie(cookieName, 1, { path: '/', expires: 365 * 5 });
            sectionLi.find('.chevron').addClass('icon-chevron-up').removeClass('icon-chevron-down');
        }
    });

    jQuery('body > .side > nav span.trigger').click(function(e)
    {
        jQuery(this).find('.collapser button').trigger('click');

    });




    var toolsOverlay;

    jQuery('body.view-index .table .tools').bind('toolsopen', function()
    {
        var tools   = jQuery(this);
        
        // close all other open toolboxes
        body.find('.tools[data-toolbox-open]').trigger('toolsclose');
        
        var toolbox = tools.data('toolbox');
        if (!toolbox)
        {
            toolbox = tools.find('.toolbox').first();
            tools.data('toolbox', toolbox);
        }     
        tools.attr('data-toolbox-open', true);
        
        
        toolbox.appendTo( body );
        tools.trigger('toolsposition');
        toolbox.show();

        if (!toolsOverlay)
        {
            toolsOverlay = jQuery('<div />').addClass('toolsOverlay').appendTo(body);
            toolsOverlay.bind('click', function()
            {
                body.find('.tools[data-toolbox-open]').trigger('toolsclose');
            })
        }
        toolsOverlay.show();

        return;        
    });

    jQuery('body.view-index .table .tools').bind('toolsclose', function()
    {
        var tools   = jQuery(this);
      
        var toolbox = tools.data('toolbox');
        if (!toolbox)
        {
            return;
        }
        toolbox.hide().appendTo( tools );
        if (tools.is('[data-toolbox-open]'))
        {
            tools.removeAttr('data-toolbox-open');
        }
        toolsOverlay.hide();
        return;
    });

    jQuery('body.view-index .table .tools').bind('toolstoggle', function()
    {
        var tools = jQuery(this);
        var event = (tools.attr('data-toolbox-open')) ? 'toolsclose' : 'toolsopen';
        tools.trigger( event );
    });

    jQuery('body.view-index .table .tools').bind('toolsposition', function()
    {
        var tools = jQuery(this);
        if (!tools.attr('data-toolbox-open'))
        {
            return;
        }
        
        var toolbox = tools.data('toolbox');

        var trigger        = tools.find('.trigger');
        var triggerOffset  = trigger.offset();
        
        var triggerCenterX = triggerOffset.left + (trigger.width() / 2);
        
        var toolboxWidth  = toolbox.outerWidth();
        var openToRight = ((jQuery(document).width() - triggerCenterX - toolboxWidth - 50) > 0);

        var beak = toolbox.children('i').first();        
        
        if (openToRight)
        {
            toolbox.css
            ({
                left:  triggerCenterX - 23,
                top :  triggerOffset.top  + trigger.height(),
            });
            beak.css(
            {
                left : 16
            });
        }
        else
        {
            toolbox.css
            ({
                left:  triggerCenterX - toolboxWidth + 20,
                top :  triggerOffset.top  + trigger.height(),
            });         
            beak.css(
            {
                left : toolboxWidth - 27,
            });            
        }
       
    });
    
    jQuery('body.view-index .table .tools .trigger').click(function(e)
    {
        e.stopPropagation();
        jQuery(this).closest('.tools').trigger('toolstoggle');
    });
    
    jQuery(window).bind('resize', function()
    {
        jQuery('.tools[data-toolbox-open]').trigger('toolsposition');
    });
    

});
