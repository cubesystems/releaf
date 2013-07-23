//= require ../lib/url_builder

jQuery(function(){

    var body = jQuery('body');

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
            jQuery.removeCookie('releaf.side.compact', { path: '/' });
            body.removeClass('side-compact');
            icon.addClass('icon-double-angle-left').removeClass('icon-double-angle-right');
        }
        else
        {
            jQuery.cookie( 'releaf.side.compact', 1, { path: '/', expires: 365 * 5 } );
            body.addClass('side-compact');
            icon.addClass('icon-double-angle-right').removeClass('icon-double-angle-left');
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
        console.log('wat');
        
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
            
        // selector for field input matching 
        var input_selector = 'input[type!="hidden"],textarea,select'; 
        
        var form = jQuery(event.target);

        form.data( 'validator', new Validator(form, { ui : false } ));

        form.on( 'validationstart', function( event, v, event_params )
        {
            form.attr( 'data-validation-id', event_params.validation_id );

            // :TODO: show loader
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


            // remove old field errors
            form.find('.field.has_error').each(function()
            {
                var field = jQuery(this);
                var error_box = field.find( '.error_box' );
                var error_node = error_box.find('.error');

                if (error_node.attr('data-validation-id') != last_validation_id)
                {
                    error_box.remove();
                    field.removeClass('has_error');
                    if (field.is('.i18n'))
                    {
                        field.find('.localization').removeClass('has_error');
                    }
                }

            });

            // remove old form errors
            if (form.hasClass('has_error'))
            {
                var form_error_box = form.find('.form_error_box');
                var form_errors_remain = false;

                form_error_box.find('.error').each(function()
                {
                    var error_node = jQuery(this);
                    if (error_node.attr('data-validation-id') != last_validation_id)
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

            // if error fields still exist, focus to first visible
            
            // locate first input inside visible error fields, 
            // but for i18n fields exclude inputs inside .localization without .has_error
            
            var focus_target = form.find('.field.has_error').filter(':visible').find(input_selector).not('.localization:not(.has_error) *').first();
            
            focus_target.focus(); 
            
            // :TODO: remove loader
        });


        form.bind( 'validationerror', function( event, v, event_params )
        {
            var error = event_params.error;
            var target = jQuery(event.target);
            
            if (target.is(input_selector))
            {
                var field_box = target.parents('.field').first();
                if (field_box.length != 1)
                {
                    return;
                }

                var error_box = field_box.find('.error_box');

                if (error_box.length < 1)
                {
                    error_box = jQuery('<div class="error_box"><div class="error"></div></div>');
                    error_box.appendTo( field_box.find('.value') );
                }

                var error_node = error_box.find('.error');
                error_node.attr('data-validation-id', event_params.validation_id );
                error_node.text( error.message );

                field_box.addClass('has_error');
                
                if (field_box.is('.i18n'))
                {
                    var localization_box = target.closest('.localization');
                    localization_box.addClass('has_error');
                }
                
            }
            else if (target.is('form'))
            {
                var form = target;

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
                })

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

    // attach validation to default forms
    jQuery('form[data-validation-url]').trigger('validationinit');


    //Override dialogs close button
    jQuery(document).on( "dialogcreate", '.ui-dialog', function( event, ui ) {
        jQuery(this).find('.ui-dialog-titlebar-close').html('<i class="icon-remove"></i>');
    });
});
