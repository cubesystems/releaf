//= require ../lib/url_builder

jQuery(function(){

    var body = jQuery('body');

    var settings_url = jQuery('header .profile').data('settings-url');
    body.on('settingssave', function( event, key_or_settings, value )
    {
        if (!settings_url)
        {
            return;
        }

        var settings = key_or_settings;
        if (typeof settings == "string")
        {
            settings = {};
            settings[key_or_settings] = value;
        }

        jQuery.ajax
        ({
            url:  settings_url,
            data: { "settings": settings},
            type: 'POST',
            dataType: 'json'
        });
    });

    var side_compact_overlay = jQuery('<div />').addClass('side-compact-overlay').appendTo(body);
    side_compact_overlay.bind('click', function()
    {
        body.trigger('sidecompactcloseall');
    });

    var first_level_side_items =  jQuery('body > .side > nav > ul > li');

    jQuery('body > .side > .compacter button').click(function()
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

    jQuery('body > .side > nav .collapser button').click(function(e)
    {
        var item = jQuery(this).closest('li');
        var collapsed;
        e.stopPropagation();

        item.toggleClass('collapsed');
        jQuery(this).blur();

        if (item.hasClass('collapsed'))
        {
            collapsed = true;
            item.find('.chevron').addClass('fa-chevron-down').removeClass('fa-chevron-up');
        }
        else
        {
            collapsed = false;
            item.find('.chevron').addClass('fa-chevron-up').removeClass('fa-chevron-down');
        }

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

    jQuery('body > .side > nav span.trigger').click(function(e)
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






    // define validation handlers
    jQuery( document ).on( 'validationinit', 'form', function( event )
    {
        if (event.isDefaultPrevented())
        {
            return;
        }

        var form = jQuery(event.target);

        if (form.data( 'validator' ))
        {
            // multiple validators on a single form are not supported
            // a validator already exists. return
            return;
        }


        // selector for field input matching
        var input_selector = 'input[type!="hidden"],textarea,select';

        form.data( 'validator', new Validator(form, { ui : false, submit_on_ok : false } ));

        form.on( 'validationstart', function( event, v, event_params )
        {
            form.attr( 'data-validation-id', event_params.validation_id );

			if (v.clicked_button)
			{
				v.clicked_button.trigger('loadingstart');
			}
        });

        form.on( 'validationclearerrors', function( event, v, event_params )
        {

            // trigger this to clear existing errors in form
            // optional event_params.except_validation_id can be used
            // to preserve errors created by that specific validation

            var except_validation_id = (event_params && ('except_validation_id' in event_params)) ? event_params.except_validation_id : null;

            // remove field errors
            form.find('.field.has_error').each(function()
            {
                var field = jQuery(this);

                // in case of i18n fields there may be multiple error boxes inside a single field
                var error_boxes = field.find( '.error_box' );

                error_boxes.each(function()
                {
                    var error_box = jQuery(this);

                    var error_node = error_box.find('.error');

                    if (
                        (!except_validation_id)
                        ||
                        (error_node.attr('data-validation-id') != except_validation_id)
                    )
                    {
                        if (field.is('.i18n'))
                        {
                            error_box.closest('.localization').removeClass('has_error');
                        }
                        error_box.remove();
                    }
                });

                // see if any error boxes are left in the field.
                var error_boxes = field.find( '.error_box' );

                if (error_boxes.length < 1)
                {
                    field.removeClass('has_error');
                }


            });


            // remove form errors
            if (form.hasClass('has_error'))
            {
                var form_error_box = form.find('.form_error_box');
                var form_errors_remain = false;

                form_error_box.find('.error').each(function()
                {
                    var error_node = jQuery(this);
                    if (
                        (!except_validation_id)
                        ||
                        (error_node.attr('data-validation-id') != except_validation_id)
                    )
                    {
                        error_node.remove();
                    }
                    else
                    {
                        form_errors_remain = true;
                    }
                });

                if (!form_errors_remain)
                {
                    form_error_box.remove();
                    form.removeClass('has_error');
                }
            }

        });

        form.on( 'validationend', function( event, v, event_params )
        {
            // remove all errors left from earlier validations

            var last_validation_id = form.attr( 'data-validation-id' );

            if (event_params.validation_id != last_validation_id)
            {
                // do not go further if this is not the last validation
                return;
            }

            event_params.except_validation_id = last_validation_id;

            form.trigger('validationclearerrors', [ v, event_params ]);


            // if error fields still exist, focus to first visible

            // locate first input inside visible error fields,
            // but for i18n fields exclude inputs inside .localization without .has_error

            var focus_target = form.find('.field.has_error').filter(':visible').find(input_selector).not('.localization:not(.has_error) *').first();

            focus_target.trigger('focusprepare');

            focus_target.focus();

        });


        form.bind( 'validationok', function( event, v, event_params )
        {
            var handler = form.attr('data-validation-ok-handler');

            if (handler != 'ajax')
            {
                // custom handler or undefined
                return;
            }

            if (!event_params || !event_params.response)
            {
                return;
            }

            if ('url' in event_params.response)
            {
                // json redirect url received

                event.preventDefault(); // prevent validator's built in submit_form on ok

                document.location.href = event_params.response.url;
            }
            else if ('getResponseHeader' in event_params.response)
            {
                // html content returned, replace main form if found in response

                var form_id = form.attr('id');
                if (!form_id)
                {
                    return;
                }

                var form_selector = 'form#' + form_id;

                event.preventDefault(); // prevent validator's built in submit_form on ok

                body.trigger('contentreplace', [ event_params.response, form_selector ])

            }

        });

        form.bind( 'validationerror', function( event, v, event_params )
		{
            var error  = event_params.error;
            var target = jQuery(event.target);
            var form   = (target.is('form')) ? target : target.closest('form');

            if (target.is(input_selector))
            {
                var field_box = target.parents('.field').first();
                if (field_box.length != 1)
                {
                    return;
                }

                var wrap = (field_box.is('.i18n')) ? target.closest('.localization') : field_box;

                var error_box = wrap.find('.error_box');

                if (error_box.length < 1)
                {
                    error_box = jQuery('<div class="error_box"><div class="error"></div></div>');
                    error_box.appendTo( wrap.find('.value').first() );
                }


                var error_node = error_box.find('.error');
                error_node.attr('data-validation-id', event_params.validation_id );
                error_node.text( error.message );

                field_box.addClass('has_error');

                if (field_box.is('.i18n'))
                {
                    wrap.addClass('has_error');
                }
            }
            else if (target.is('form'))
            {
                var form_error_box = form.find('.form_error_box');
                if (form_error_box.length < 1)
                {
                    var form_error_box_container = form.find('.body').first();
                    if (form_error_box_container.length < 1)
                    {
                        form_error_box_container = form;
                    }
                    form_error_box = jQuery('<div class="form_error_box"></div>');
                    form_error_box.prependTo( form_error_box_container );
                }

                var error_node = null;

                // reuse error node if it has the same text
                form_error_box.find('.error').each(function()
                {
                    if (error_node)
                    {
                        return;
                    }
                    if (jQuery(this).text() == error.message)
                    {
                        error_node = jQuery(this);
                    }
                });

                var new_error_node = !error_node;

                if (!error_node)
                {
                    error_node = jQuery('<div class="error"></div>');
                }

                error_node.attr('data-validation-id', event_params.validation_id);
                error_node.text( error.message );

                if (new_error_node)
                {
                    error_node.appendTo( form_error_box );
                }

                form.addClass('has_error');

                // Scroll to form_error_box
                form_error_box.parent().scrollTop(form_error_box.offset().top - form_error_box.parent().offset().top + form_error_box.parent().scrollTop());

            }

            form.find('.button.loading').trigger('loadingend');
        });




    });


    jQuery( document ).on( 'validate', 'form', function( event )
    {
        // use this to manually trigger form validation outside of a submit event

        if (event.isDefaultPrevented())
        {
            return;
        }

        var form = jQuery(event.target);

        if (!form.data('validator'))
        {
            return;
        }

        form.data('validator').validateForm();
        return;


    });

    // attach validation to any new default forms after any content load

    body.on('contentloaded', function(e)
    {
        var block = jQuery(e.target);
        var forms = (block.is('form[data-validation]')) ? block : block.find('form[data-validation]');

        forms.trigger('validationinit');
    });


});
