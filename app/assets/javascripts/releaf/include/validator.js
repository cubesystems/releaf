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
		event.preventDefault();
		v.validateForm();
	});

    jQuery( document ).bind( 'ok error fail', function( event, targetValidator, eventParams )
    {
		if (targetValidator !== v || event.isDefaultPrevented() || !v.form[0])
		{
			return;
		}
        
        switch (event.type)
        {
            case 'ok':      // validation passed
                
                if (eventParams && eventParams.redirectUrl)
                {
                    document.location.href = eventParams.redirectUrl;
                }
                else
                {
                    v.submitForm();                    
                }
                
                break;

            case 'error':   // validation error
                
                if (v.options.ui)
                {
                    alert( eventParams.message );
                }
                
                v.clickedButton = null;

                
                break;

            case 'fail':  	// fail (internal validation failure, not a user error)
                
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
    var url;

	var data = v.form.serializeArray();
    var files = v.form.find('input[type=file]');

    // just validate and do not save if we have file fields
    if( files.length )
    {
        url = v.form.data('validation-url');
    }
    else
    {
        url = v.form.attr('action');
    }

	jQuery.ajax
	({
		url:  url,
		type: v.form.attr( 'method' ),
		data: data,
        dataType: 'json',
        cache : false,
		complete: function( response, textStatus, jqXHR )
		{
            switch (response.status)
            {
                case 303:
                    // validation + saving ok
                    var eventParams = 
                    {
                        redirectUrl : $.parseJSON( response.responseText )["url"]
                    };
                    v.form.trigger( 'ok', [ v, eventParams ] );                    
                    return;
                    
                case 200:
                    // validation ok
                    v.form.trigger( 'ok', [ v, null ] );
                    return;                    
                 
                case 422:   
                    // validation returned errors
                    
                    var errors = [];
                    $.each( $.parseJSON(response.responseText), function( fieldName, fieldErrors )
                    {
                        $.each( fieldErrors, function( index, error )
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

                        // TODO: better field finding!!
                        field = v.form.find( '#resource_' + error.fieldName + '' ).first();

                        if (field && field.length > 0)
                        {
                            eventTarget = field;
                        }
                        else
                        {
                            eventTarget = v.form;
                        }
                        
                        eventTarget.trigger( 'error', [ v, error ] );
                    });
                
                    return;
                    
                default:
                    
                     // something wrong in the received response
                     v.form.trigger( 'fail', [ v ] );
                     return;
            }
		},
	});
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
