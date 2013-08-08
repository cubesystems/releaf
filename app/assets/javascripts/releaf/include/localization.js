jQuery(function()
{
    var body = jQuery('body');

    var overlay = jQuery('<div />').addClass('localization-menu-overlay').appendTo(body);
    overlay.bind('click', function()
    {
        body.trigger('localizationmenucloseall');
    });

    body.bind('localizationinit', function(e)
    {
        var block = jQuery(e.target);

        e.stopPropagation();

        var fields;
        if (block.is('.field.i18n'))
        {
            fields = block;
        }
        else
        {
            fields = block.find('.field.i18n');
        }

        if (fields.length < 1)
        {
            return;
        }

        fields.bind('localizationmenuopen', function()
        {
            var field  = jQuery(this);

            // close all other open menus
            body.trigger('localizationmenucloseall');

            var menu = field.data('localization-menu');

            field.attr('data-localization-menu-open', true);

            menu.appendTo( body );

            field.trigger('localizationmenuposition');

            overlay.show();

            menu.show();

            return;
        });

        fields.bind('localizationmenuclose', function()
        {
            var field   = jQuery(this);

            var menu = field.data('localization-menu');

            var localization_switch = field.data('localization-switch');

            menu.hide().appendTo( localization_switch );

            overlay.hide();

            field.removeAttr('data-localization-menu-open');

            return;
        });

        fields.bind('localizationmenutoggle', function()
        {
            var field  = jQuery(this);
            var event = (field.attr('data-localization-menu-open')) ? 'localizationmenuclose' : 'localizationmenuopen';
            field.trigger( event );
        });

        fields.bind('localizationmenuposition', function()
        {
            var field   = jQuery(this);
            if (!field.attr('data-localization-menu-open'))
            {
                return;
            }

            var menu = field.data('localization-menu');

            var trigger        = field.data('localization-switch-trigger');

            var triggerOffset  = trigger.offset();

            menu.css
            ({
                left:  triggerOffset.left + trigger.outerWidth() - menu.outerWidth() ,
                top :  triggerOffset.top + trigger.outerHeight(),
            });

        });

        fields.find('.localization-switch .trigger').click(function(e)
        {
            jQuery(this).closest('.field.i18n').trigger('localizationmenutoggle');
        });


        fields.find('.localization-menu-items button').click(function(e)
        {
            var button = jQuery(this);
            var locale  = button.attr('data-locale');
            var menu    = button.closest('.localization-menu-items');
            var field   = menu.data('field');
            var localization_box = field.find('.localization[data-locale="' + locale + '"]');

            body.trigger('localizationmenucloseall');

            localization_box.trigger('localizationlocaleactivate');

        });


        fields.bind('localizationlocaleset', function( e, params )
        {
            var field = jQuery(this);

            var locale = params.locale;

            var localization_boxes = field.find('.localization[data-locale]');

            var target_box  = localization_boxes.filter('[data-locale="' + locale + '"]');
            var other_boxes = localization_boxes.not( target_box );

            target_box.addClass('active');
            other_boxes.removeClass('active');

            var trigger_label = field.find('.localization-switch .trigger .label');

            trigger_label.text( locale );

            var form = field.closest('form');

            form.trigger('localizationlocalestore', { locale : locale } );

        });


        fields.find('.localization').bind('localizationlocaleactivate', function(e)
        {
            var localization_box = jQuery(this);
            var locale = localization_box.attr('data-locale');

            var form   = localization_box.closest('form');

            form.find('.field.i18n').trigger('localizationlocaleset', { locale : locale });

        });


        var input_selector = 'input[type!="hidden"],textarea,select';
        fields.find(input_selector).bind('focusprepare', function(e)
        {
            var localization_box = (jQuery(e.target).closest('.localization'));
            if (localization_box.length < 1)
            {
                return;
            }

            // focus target is inside a i18n localization box
            if (!localization_box.is('.active'))
            {
                localization_box.trigger('localizationlocaleactivate');
            }
        });


        fields.each(function()
        {
            var field = jQuery(this);

            var localization_switch = field.find('.localization-switch').first();

            field.data('localization-switch', localization_switch );

            field.data('localization-switch-trigger', localization_switch.find('.trigger').first() );

            var menu = localization_switch.find('menu').first();

            field.data('localization-menu', menu);

            menu.data('field', field);

        });


        block.trigger('localizationlocalesrestore');

    });

    body.bind('localizationmenucloseall', function()
    {
        body.find('.field.i18n[data-localization-menu-open]').trigger('localizationmenuclose');
    });

    body.on('localizationlocalestore', 'form', function(e, params)
    {
        if (!params || (!('locale' in params)))
        {
            return;
        }

        // define a selector by which to locate the form in the body after it gets replaced
        var form = jQuery(e.target);
        var form_id = form.attr('id');
        if (!form_id)
        {
            return;
        }

        var stored_locales = body.data('localizationactivelocales') || {};

        selector = 'form#' + form_id;
        var locale = params.locale;

        stored_locales[ selector ] = locale;
        body.data('localizationactivelocales', stored_locales );

    });

    body.on('localizationlocalesrestore', function(e)
    {
        // restore previously stored locales for elements that have them

        var block = jQuery(e.target);

        var stored_locales = body.data('localizationactivelocales') || {};

        jQuery.each( stored_locales, function( selector, locale )
        {
            var target = block.is( selector ) ? block : block.find( selector );
            if (target.length < 1)
            {
                return;
            }

            // remove stored locale from cache. will be set again if needed
            delete stored_locales[ selector ];

            target.find('.field.i18n').trigger('localizationlocaleset', { locale : locale });
        });

    });



    // attach localizationinit to all loaded content
    body.on('contentloaded', function(e)
    {
        // reinit localization for all content that gets replaced via ajax
        jQuery(e.target).trigger('localizationinit');

    });

});


