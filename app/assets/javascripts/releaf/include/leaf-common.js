jQuery(function(){

    var body = jQuery('body');

    //jQuery('body > header > .side-opener button').click(function()
    //{

        //if (body.hasClass('side-open'))
        //{
            //body.removeClass('side-open');
        //}
        //else
        //{
            //body.addClass('side-open').removeClass('side-compact');
        //}

    //});

    jQuery('body > .side > .compacter button').click(function()
    {
        if (body.hasClass('side-compact'))
        {
            $.removeCookie('releaf.side.compact');
            body.removeClass('side-compact');
            $('.toggle-angle-icon').addClass('icon-double-angle-left').removeClass('icon-double-angle-right');
        }
        else
        {
            $.cookie( 'releaf.side.compact', 1, { path: '/', expires: 365 * 5 } );
            body.addClass('side-compact').removeClass('side-open');
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
            $.removeCookie(cookieName);
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

    jQuery('body.view-index .table .tools button').click(function(e)
    {
        e.stopPropagation();
        // close all opened toolbox
        jQuery(this).closest('.table').find('.tools .wrapper').hide();

        var toolsContainer = jQuery(this).parent().find('.wrapper').first();
        toolsContainer.css('top', ( jQuery(this).parent().height() / 2 + 12 ) + 'px');
        toolsContainer.show();
        $('body').on('click', function(e) {
            toolsContainer.hide();
            $(this).unbind(e);
        });
    });

});
