jQuery(function(){

    var body = jQuery('body');

    var side_compact_overlay = jQuery('<div />').addClass('side-compact-overlay').appendTo(body);
    side_compact_overlay.bind('click', function()
    {
        body.trigger('sidecompactcloseall');
    });

    var first_level_side_items = jQuery();

    body.on('sidecompactcloseall', function()
    {
        first_level_side_items.filter('.open').trigger('sidecompactitemclose');
    });

    body.on('sidecompactchange', function()
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

    body.on('contentloaded', function(e)
    {
        var header = jQuery(e.target).find('header').addBack().filter('body > header');
        if (header.length < 1)
        {
            return;
        }

        header.on('click', function()
        {
            // add additional trigger on header to close opened compact submenu
            // because header is above the side compact overlay
            if (!body.hasClass('side-compact') || first_level_side_items.filter('.open').length < 1)
            {
                return;
            }

            body.trigger('sidecompactcloseall');
            return false;
        });
    });

    body.on('contentloaded', function(e)
    {
        var sidebar = jQuery(e.target).find('aside').addBack().filter('body > aside');
        if (sidebar.length < 1)
        {
            return;
        }

        first_level_side_items = sidebar.find('nav > ul > li');

        first_level_side_items.on('sidecompactitemopen', function()
        {
            body.trigger('sidecompactcloseall');
            jQuery(this).addClass('open');
            side_compact_overlay.show();
        });

        first_level_side_items.on('sidecompactitemclose', function()
        {
            jQuery(this).removeClass('open');
            side_compact_overlay.hide();
        });

        first_level_side_items.on('sidecompacttoggle', function()
        {
            var item   = jQuery(this);
            var event = (item.is('.open')) ? 'sidecompactitemclose' : 'sidecompactitemopen';
            item.trigger( event );
        });

        sidebar.find('.compacter button').on('click', function()
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

        body.trigger('sidecompactchange');

        sidebar.find('> nav .collapser button').on('click', function(e)
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

        sidebar.find('> nav span.trigger').click(function()
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
});
