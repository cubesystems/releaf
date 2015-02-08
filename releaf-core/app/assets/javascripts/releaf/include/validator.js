var Validator = function( node_or_selector, options )
{
    // self
    var v = this;

    // form
    v.form = node_or_selector;

    if (!(v.form instanceof jQuery))
    {
        v.form = jQuery( v.form );
    }

    if (v.form.length > 1)
    {
        v.form = v.form.first();
        v.logError('Multiple forms are not supported for single validator instance.');
    }

    v.clicked_button = null;

    // set options, override defaults from argument if passed
    v.options = jQuery.extend( { ui : true }, options );


    // attach click events to submit elements
    v.form.delegate('input[type="submit"], input[type="image"], button', 'click', function(event)
    {
        var target = jQuery( event.target );

        // webkit sends inner button elements as event targets instead of the button
        // so catch if the click is inside a button element and change the target if needed
        var closest_button = target.closest('button');
        if (closest_button.length > 0)
        {
            target = closest_button;
        }

        // register only submit buttons - buttons with type="submit" or without type attribute at all
        // direct target[0].type property is used because of inconsistent attr() method return values
        // between older and newer jQuery versions
        if (target.is( 'button' ) && target[0].type !== 'submit' )
        {
            return;
        }
        v.clicked_button = target;
    });

    // submit
    v.form.submit(function( event )
    {
        if ( window.FormData !== undefined )
        {
            event.preventDefault();
            v.validate_form();
        }
    });

    v.form.on('validationstart', function( event, validator, event_params )
    {
        if (validator !== v || event.isDefaultPrevented() || !v.form[0])
        {
            return;
        }

        var url = v.form.attr('action');

        // TODO: possible to make only validation call
        //var validateUrl = v.form.data('validation-url');

        var formData = new FormData( v.form[0] );

        jQuery.ajax
        ({
            url:  url,
            type: v.form.attr( 'method' ),
            data: formData,
            //contentType: 'multipart/form-data',
            contentType: false,
            processData: false,
            cache : false,
            dataType: 'json',
            complete: function( response )
            {
                var json_response;
                switch (response.status)
                {
                    case 303:
                        // validation + saving ok
                        try {
                            json_response = jQuery.parseJSON(response.responseText);
                        }
                        catch(error)
                        {
                            v.form.trigger( 'validationfail', [ v, event_params ] );
                            break;
                        }
                        event_params.response = json_response;


                        v.form.trigger( 'validationok', [ v, event_params ] );
                        break;

                    case 200:
                        // validation ok
                        event_params.response = response;
                        v.form.trigger( 'validationok', [ v, event_params ] );
                        break;

                    case 422:
                        // validation returned errors
                        try {
                            json_response = jQuery.parseJSON(response.responseText);
                        }
                        catch(error)
                        {
                            v.form.trigger( 'validationfail', [ v, event_params ] );
                            break;
                        }
                        event_params.response = json_response;

                        var errors = [];
                        jQuery.each( json_response, function( fieldName, fieldErrors )
                        {
                            jQuery.each( fieldErrors, function( index, error )
                            {
                                var error_object = {
                                    message   : error.full_message,
                                    errorCode : error.error_code,
                                    fieldName : fieldName
                                };
                                if('data' in error)
                                {
                                    error_object.data = error.data;
                                }
                                errors.push(error_object);
                            });
                        });

                        jQuery.each( errors, function(index, error)
                        {
                            var field = null;

                            var eventTarget = null;

                            field = v.form.find( '[name="' + error.fieldName + '"]:not([type="hidden"])' ).first();

                            event_params.error = error;

                            if (field && field.length > 0)
                            {
                                eventTarget = field;
                            }
                            else
                            {
                                eventTarget = v.form;
                            }

                            eventTarget.trigger( 'validationerror', [ v, event_params ] );

                        });

                        break;

                    default:

                         // something wrong in the received response
                        v.form.trigger( 'validationfail', [ v, event_params ] );

                        break;
                }

                v.form.trigger( 'validationend', [ v, event_params ] );
                return;
            }
        });

    });

    jQuery( document ).on( 'validationok validationerror validationfail', 'form', function( event, validator, event_params )
    {
        if (validator !== v || event.isDefaultPrevented() || !v.form[0])
        {
            return;
        }

        switch (event.type)
        {
            case 'validationok':      // validation passed

                v.submit_form();

                break;

            case 'validationerror':   // validation error

                if (v.options.ui)
                {
                    window.alert( event_params.error.message );
                }

                v.clicked_button = null;

                break;

            case 'validationfail':      // fail (internal validation failure, not a user error)

                v.submit_form();

                break;
        }
    });

};

Validator.prototype.logError = function( msg )
{
    if (!('console' in window))
    {
        return;
    }

    var f = ('error' in console) ? 'error' : 'log';
    console[f](msg);

};

Validator.prototype.validate_form = function()
{
    var v = this;

    var event_params =
    {
        validation_id : 'v' + new Date().getTime() + Math.random()
    };

    v.form.trigger( 'beforevalidation', [ v, event_params ]);
    v.form.trigger( 'validationstart', [ v, event_params ]);
};

Validator.prototype.submit_form = function()
{
    var v = this;

    // append clicked button as a hidden field
    // because no button value will be sent when submitting the form via .submit()
    if ((v.clicked_button) && (v.clicked_button.length > 0) && v.clicked_button.attr('name'))
    {
        var input = jQuery('<input type="hidden" />');
        input.attr('name',  v.clicked_button.attr('name'));
        input.val( v.clicked_button.val() );
        input.appendTo(v.form);
    }
    v.form[0].submit();
};
