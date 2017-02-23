var RemoteValidator = function( form )
{
    // self
    var v = this;
    var body = jQuery('body');
    // selector for field input matching
    var input_selector = 'input[type!="hidden"],textarea,select';
    var submit_elements_selector = 'input[type="submit"], input[type="image"], button';

    v.form = form;
    v.clicked_button = null;

    v.form.on('click', submit_elements_selector, function( event ) {
        var target = jQuery( event.target );

        // webkit sends inner button elements as event targets instead of the button
        // so catch if the click is inside a button element and change the target if needed
        var closest_button = target.closest('button');
        if (closest_button.length > 0)
        {
            target = closest_button;
        }

        // register only submit buttons - buttons with type="submit" or without type attribute at all.
        // direct target[0].type property is used because of inconsistent attr() method return values
        // between older and newer jQuery versions
        if (target.is( 'button' ) && target[0].type !== 'submit' )
        {
            return;
        }

        v.register_clicked_button( target );
    });

    v.form.on( 'ajax:before', function( event )
    {
        var xhr = event.detail;
        xhr.validation_id = 'v' + new Date().getTime() + Math.random();
        xhr.setRequestHeader('Accept', '*/*;q=0.5, application/json');

        v.form.attr( 'data-validation-id', xhr.validation_id );

        if (v.clicked_button)
        {
            v.clicked_button.trigger('loadingstart');
        }
    });

    v.form.on( 'ajax:complete', function( event )
    {
        var xhr = event.detail;
        var json_response;
        var event_params =
        {
            validation_id: xhr.validation_id
        };

        switch (xhr.status)
        {
            case 200:
                // validation ok
                event_params.response = xhr;
                v.form.trigger( 'validation:ok', [ v, event_params ] );
                break;

            case 422:
                // validation returned errors
                try {
                    json_response = jQuery.parseJSON(xhr.responseText);
                }
                catch(error)
                {
                    v.form.trigger( 'validation:fail', [ v, event_params ] );
                    break;
                }
                event_params.response = json_response;

                var errors = [];
                jQuery.each( json_response.errors, function( fieldName, fieldErrors )
                {
                    jQuery.each( fieldErrors, function( index, error )
                    {
                        var error_object = {
                            message         : error.message,
                            errorCode       : error.error_code,
                            fieldName       : fieldName
                        };
                        if('data' in error)
                        {
                            error_object.data = error.data;
                        }
                        errors.push(error_object);
                    });
                });

                jQuery.each( errors, function( index, error )
                {
                    var field = null;

                    var eventTarget = null;

                    field = v.form.find( '[name="' + error.fieldName + '"],[name="' + error.fieldName + '[]"]' ).filter(':not([type="hidden"])').first();

                    event_params.error = error;

                    if (field && field.length > 0)
                    {
                        eventTarget = field;
                    }
                    else
                    {
                        eventTarget = v.form;
                    }

                    eventTarget.trigger( 'validation:error', [ v, event_params ] );

                });

                break;

            default:
                // something wrong in the received response
                v.form.trigger( 'validation:fail', [ v, event_params ] );
                break;
        }
        v.form.trigger( 'validation:end', [ v, event_params ] );
    });

    v.form.on( 'validation:ok', function( event, v, event_params )
    {
        if (!event_params || !event_params.response)
        {
            return;
        }

        event.preventDefault(); // prevent validator's built in submit_form on ok

        // use new url
        if(document.location.href !== event_params.response.responseURL)
        {
            history.pushState(null, null, event_params.response.responseURL);
        }

        body.trigger('contentreplace', [ event_params.response, "> header" ]);
        body.trigger('contentreplace', [ event_params.response, "> aside" ]);
        body.trigger('contentreplace', [ event_params.response, "> main" ]);
    });

    v.form.on( 'validation:error', function( event, v, event_params )
    {
        var error_node = null;
        var error  = event_params.error;
        var target = jQuery(event.target);
        var form   = (target.is('form')) ? target : target.closest('form');

        if (target.is(input_selector))
        {
            var field_box = target.parents('.field').first();
            if (field_box.length !== 1)
            {
                return;
            }

            var wrap = (field_box.is('.i18n')) ? target.closest('.localization') : field_box;

            var error_box = wrap.find('.error-box');

            if (error_box.length < 1)
            {
                error_box = jQuery('<div class="error-box"><div class="error"></div></div>');
                error_box.appendTo( wrap.find('.value').first() );
            }


            error_node = error_box.find('.error');
            error_node.attr('data-validation-id', event_params.validation_id );
            error_node.text( error.message );

            field_box.addClass('has-error');

            if (field_box.is('.i18n'))
            {
                wrap.addClass('has-error');
            }
        }
        else if (target.is('form'))
        {
            var form_error_box = form.find('.form-error-box');
            if (form_error_box.length < 1)
            {
                var form_error_box_container = form.find('.body').first();
                if (form_error_box_container.length < 1)
                {
                    form_error_box_container = form;
                }
                form_error_box = jQuery('<div class="form-error-box"></div>');
                form_error_box.prependTo( form_error_box_container );
            }

            // reuse error node if it has the same text
            form_error_box.find('.error').each(function()
            {
                if (error_node)
                {
                    return;
                }
                if (jQuery(this).text() === error.message)
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

            form.addClass('has-error');

            // Scroll to form_error_box
            form_error_box.parent().scrollTop(form_error_box.offset().top - form_error_box.parent().offset().top + form_error_box.parent().scrollTop());

        }

        form.find('.button.loading').trigger('loadingend');
    });

    v.form.on( 'validation:end', function( event, v, event_params )
    {
        // remove all errors left from earlier validations

        var last_validation_id = form.attr( 'data-validation-id' );

        if (event_params.validation_id !== last_validation_id)
        {
            // do not go further if this is not the last validation
            return;
        }

        event_params.except_validation_id = last_validation_id;

        form.trigger('validation:clearerrors', [ v, event_params ]);


        // if error fields still exist, focus to first visible

        // locate first input inside visible error fields,
        // but for i18n fields exclude inputs inside .localization without .has-error

        var focus_target = form.find('.field.has-error').filter(':visible').find(input_selector).not('.localization:not(.has-error) *').first();

        focus_target.trigger('focusprepare');

        focus_target.focus();

    });

    v.form.on( 'validation:clearerrors', function( event, v, event_params )
    {

        // trigger this to clear existing errors in form
        // optional event_params.except_validation_id can be used
        // to preserve errors created by that specific validation

        var except_validation_id = (event_params && ('except_validation_id' in event_params)) ? event_params.except_validation_id : null;

        // remove field errors
        form.find('.field.has-error').each(function()
        {
            var error_boxes;
            var field = jQuery(this);

            // in case of i18n fields there may be multiple error boxes inside a single field
            error_boxes = field.find( '.error-box' );

            error_boxes.each(function()
            {
                var error_box = jQuery(this);

                var error_node = error_box.find('.error');

                if (!except_validation_id || error_node.attr('data-validation-id') !== except_validation_id)
                {
                    if (field.is('.i18n'))
                    {
                        error_box.closest('.localization').removeClass('has-error');
                    }
                    error_box.remove();
                }
            });

            // see if any error boxes are left in the field.
            error_boxes = field.find( '.error-box' );

            if (error_boxes.length < 1)
            {
                field.removeClass('has-error');
            }
        });


        // remove form errors
        if (form.hasClass('has-error'))
        {
            var form_error_box = form.find('.form-error-box');
            var form_errors_remain = false;

            form_error_box.find('.error').each(function()
            {
                var error_node = jQuery(this);
                if (!except_validation_id || error_node.attr('data-validation-id') !== except_validation_id)
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
                form.removeClass('has-error');
            }
        }
    });

    jQuery( document ).on( 'validation:ok validation:error validation:fail', 'form', function( event, validator )
    {
        if (validator !== v || event.isDefaultPrevented() || !v.form[0])
        {
            return;
        }

        switch (event.type)
        {
            case 'validation:ok':      // validation passed

                v.submit_form();

                break;

            case 'validation:error':   // validation error

                v.clear_clicked_button();

                break;

            case 'validation:fail':      // fail (internal validation failure, not a user error)

                v.submit_form();

                break;
        }
    });
};

RemoteValidator.prototype.register_clicked_button = function(button)
{
    var v = this;
    v.clicked_button = button;

    // when sending form values with FormData, the clicked button value is not included in the data
    // (except on Safari, and therefore also on PhantomJS - that's why the tests worked fine even without this).

    // since releaf sometimes uses the clicked button value to modify the action on the server side,
    // (e.g. for "Save and create another" feature), the value of the clicked button must be appended
    // to the form as a hidden field before the validation / submission starts.

    // longer description:
    // the algorithm to construct the form data set for a form optionally in the context
    // of a submitter is as follows:
    // https://www.w3.org/TR/html5/forms.html#constructing-form-data-set
    // https://xhr.spec.whatwg.org/#dom-formdata
    // If not specified otherwise, submitter is null.
    // when this algorithm is executed from the FormData constructor, no submitter is specified,
    // so no buttons are included in the form data set automatically.

    var form = button.closest('form');
    var hidden_field = form.find('input.submit-button-value').first();
    if (hidden_field.length < 1)
    {
        hidden_field = jQuery('<input type="hidden" class="submit-button-value" />');
        hidden_field.appendTo(form);
    }
    var name = button.attr('name');
    if (name)
    {
        hidden_field.attr('name', name);
        hidden_field.val(button.val());
    }
    else
    {
        // no need for the hidden field in case of nameless buttons
        hidden_field.remove();
    }
};

RemoteValidator.prototype.clear_clicked_button = function()
{
    var v = this;
    v.clicked_button = null;
    v.form.find('input.submit-button-value').remove();
};

RemoteValidator.prototype.submit_form = function()
{
    this.form[0].submit();
};

jQuery(function(){
    // define validation handlers
    jQuery( document ).on( 'validation:init', 'form', function( event )
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

        form.data( 'validator', new RemoteValidator(form));

        // validation initalized finished, add data attribute for it (used by automatized test, etc)
        form.attr("data-remote-validation-initialized", true);

    });

    // attach remote validation to any new default forms after any content load
    jQuery('body').on('contentloaded', function( event )
    {
        var block = jQuery(event.target);
        var forms = (block.is('form[data-remote-validation]')) ? block : block.find('form[data-remote-validation]');

        forms.trigger('validation:init');
    });
});
