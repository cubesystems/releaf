var Validator = function( nodeOrSelector, options )
{
	// self
	var v = this;

	// check dependencies
	v.checkDependencies();

	// form
	v.form = nodeOrSelector;

	if (!(v.form instanceof jQuery))
	{
		v.form = jQuery( v.form );
	}

    if (v.form.length > 1)
    {
        v.form = v.form.first();
        v.logError('Multiple forms are not supported for single validator instance.');
    }

    v.clickedButton = null;

    // set options, override defaults from argument if passed
    v.options = jQuery.extend( { ui : true }, options );


	// attach click events to submit elements
    v.form.delegate('input[type="submit"], input[type="image"], button', 'click', function(event)
    {
		var target = jQuery( event.target );
		// register only submit buttons - buttons with type="submit" or without type attribute at all
		// direct target[0].type property is used because of inconsistent attr() method return values
		// between older and newer jQuery versions
        if( target.is( 'button' ) && target[0].type != 'submit' )
		{
			return;
		}
		v.clickedButton = target;
    });

	// submit
	v.form.submit(function( event )
	{
        if ( window.FormData !== undefined )
        {
            event.preventDefault();
            v.validateForm(); 
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
            complete: function( response, textStatus, jqXHR )
            {
                switch (response.status)
                {
                    case 303:
                        // validation + saving ok
                        try {
                            var jsonResponse = jQuery.parseJSON(response.responseText);
                        }
                        catch(error)
                        {
                            v.form.trigger( 'validationfail', [ v, event_params ] );
                            break;
                        }
                        event_params.redirect_url = jsonResponse["url"]

                        v.form.trigger( 'validationok', [ v, event_params ] );
                        break;

                    case 200:
                        // validation ok
                        v.form.trigger( 'validationok', [ v, event_params ] );
                        break;

                    case 422:
                        // validation returned errors
                        try {
                            var jsonResponse = jQuery.parseJSON(response.responseText);
                        }
                        catch(error)
                        {
                            v.form.trigger( 'validationfail', [ v, event_params ] );
                            break;
                        }

                        var errors = [];
                        jQuery.each( jsonResponse, function( fieldName, fieldErrors )
                        {
                            jQuery.each( fieldErrors, function( index, error )
                            {
                                errors.push(
                                {
                                    message   : error.full_message,
                                    errorCode : error.error,
                                    fieldName : fieldName
                                });
                            });
                        });

                        jQuery.each( errors, function(index, error)
                        {
                            var field = null;

                            var eventTarget = null;

                            field = v.form.find( '[name="' + error.fieldName + '"]' ).first();

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

                if (event_params && event_params.redirect_url)
                {
                    document.location.href = event_params.redirect_url;
                }
                else
                {
                    v.submitForm();
                }

                break;

            case 'validationerror':   // validation error

                if (v.options.ui)
                {
                    alert( event_params.error.message );
                }

                v.clickedButton = null;

                break;

            case 'validationfail':  	// fail (internal validation failure, not a user error)

                v.submitForm();

                break;
        }
    });

}

Validator.prototype.logError = function( msg )
{
    if (!('console' in window))
    {
        return;
    }

    var f = ('error' in console) ? 'error' : 'log';
    console[f](msg);

}

// dependencies
Validator.prototype.checkDependencies = function()
{
	// jQuery
	if( window.jQuery === undefined )
	{
        v.logError('Validator requires jQuery.');
		return false;
	}
	return true;
}

Validator.prototype.validateForm = function()
{
    var v = this;
    
    var event_params = 
    {
        validation_id : 'v' + new Date().getTime() + Math.random()
    };
    
    v.form.trigger( 'validationstart', [ v, event_params ]);
}

Validator.prototype.submitForm = function()
{
	var v = this;

    // append clicked button as a hidden field
    // because no button value will be sent when submitting the form via .submit()
    if ((v.clickedButton) && (v.clickedButton.length > 0) && v.clickedButton.attr('name'))
    {
        var input = jQuery('<input type="hidden" />');
        input.attr('name',  v.clickedButton.attr('name'));
        input.val( v.clickedButton.val() );
        input.appendTo(v.form);
    }
    v.form[0].submit();
}
