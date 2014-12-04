jQuery(function(){

    var body = jQuery('body');

    var side_compact_overlay = jQuery('<div />').addClass('side-compact-overlay').appendTo(body);
    side_compact_overlay.bind('click', function()
    {
        body.trigger('sidecompactcloseall');
    });

    var first_level_side_items =  jQuery('body > aside > nav > ul > li');

    jQuery('body > aside > .compacter button').click(function()
    {
        var button = jQuery(this);
        var icon = button.find('i').first();

        if (body.hasClass('side-compact'))
        {
            body.trigger('sidecompactcloseall');
            body.trigger( 'settingssave', [ "releaf.side.compact", false ] );
            body.removeClass('side-compact');
            icon.addClass('fa-angle-double-left').removeClass('fa-angle-double-right');
        }
        else
        {
            body.trigger( 'settingssave', [ "releaf.side.compact", true ] );
            body.addClass('side-compact');
            icon.addClass('fa-angle-double-right').removeClass('fa-angle-double-left');
        }
        body.trigger('sidecompactchange');
    });

    body.bind('sidecompactchange', function(e)
    {
        if (body.hasClass('side-compact'))
        {
            first_level_side_items.each(function()
            {
                var trigger = jQuery(this).children('.trigger');
                trigger.attr( 'title', trigger.children('.name').text() );
            });
        }
        else
        {
            first_level_side_items.children('.trigger').removeAttr('title');
        }
    });

    body.trigger('sidecompactchange');

    jQuery('body > aside > nav .collapser button').click(function(e)
    {
        var item = jQuery(this).closest('li');
        e.stopPropagation();

        item.toggleClass('collapsed');
        jQuery(this).blur();

        var collapser_icon = item.find('.collapser i');
        var collapsed = item.hasClass('collapsed');

        collapser_icon.toggleClass('fa-chevron-down', collapsed);
        collapser_icon.toggleClass('fa-chevron-up',  !collapsed);

        var setting_key = 'releaf.menu.collapsed.' + item.data('name');
        body.trigger( 'settingssave', [ setting_key, collapsed ]  );

    });

    first_level_side_items.bind('sidecompactitemopen', function(e)
    {
        body.trigger('sidecompactcloseall');
        jQuery(this).addClass('open');
        side_compact_overlay.show();
    });

    first_level_side_items.bind('sidecompactitemclose', function(e)
    {
        jQuery(this).removeClass('open');
        side_compact_overlay.hide();
    });


    first_level_side_items.bind('sidecompacttoggle', function(e)
    {
        var item   = jQuery(this);
        var event = (item.is('.open')) ? 'sidecompactitemclose' : 'sidecompactitemopen';
        item.trigger( event );
    });

    body.bind('sidecompactcloseall', function(e)
    {
        first_level_side_items.filter('.open').trigger('sidecompactitemclose');
    })

    jQuery('body > header').click(function()
    {
        // add additional trigger on header to close opened compact submenu
        // because header is above the side compact overlay
        if (
            (!body.hasClass('side-compact'))
            ||
            (first_level_side_items.filter('.open').length < 1)
        )
        {
            return;
        }

        body.trigger('sidecompactcloseall');
        return false;
    });

    jQuery('body > aside > nav span.trigger').click(function(e)
    {
        if (body.hasClass('side-compact'))
        {
            var item  = jQuery(this).closest('li');
            item.trigger('sidecompacttoggle');
        }
        else
        {
            jQuery(this).find('.collapser button').trigger('click');
        }
    });
});
