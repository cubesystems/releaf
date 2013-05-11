/*

    attaches onsubmit form validation

    usage:
    1) each form needs to have its data-validation value set to "on"

    no additional scripting is needed.
    the script will scan the page and attach onsubmit event handlers to FORMs where necessary.

*/

/*
    attach the init call to the main onload event
    preserving any existing handlers already present
*/


var baseValidation = function(){}

baseValidation.attachValidation = function( targets )
{
    jQuery(targets).each(function()
    {
        var form = jQuery(this);

        form.submit(function(event)
        {
            clearErrors( this );
        });

        new Validation(form, { ui : false });

        form.bind( 'error', function( event, v, error )
        {

            var target = jQuery(event.target);

            if (target.is('input[type!="hidden"],textarea,select'))
            {
                var fieldBox = target.parents('.field');
                if (fieldBox.length == 1)
                {
                    var previousErrorExists = fieldBox.hasClass('hasError');

                    if (previousErrorExists && fieldBox[0].removeTimeout)
                    {
                        clearTimeout(fieldBox[0].removeTimeout);
                    }

                    var errorBox = fieldBox.find('.errorBox');


                    if (errorBox.length == 0)
                    {
                        errorBox = jQuery('<div class="errorBox"><p class="error"></p></div>').appendTo(fieldBox);
                    }

                    errorBox.find('.error').text( error.message );

                    fieldBox.addClass('hasError');

                    var attention = fieldBox.find('.attention');


                    if (attention.length == 0)
                    {
                        attention = jQuery('<div class="attention"></div>').appendTo(fieldBox);
                    }

                    var input = fieldBox.find('input:first, select:first');
                    attention.css('left', input.position().left + input.width());
                    errorBox.css('left', attention.css('left'));
                }
            }

        });

    });


    function clearErrors(form)
    {

        form = jQuery(form);
        form.find('.hasError').each(function()
        {
            var fieldBox = jQuery(this);

            fieldBox[0].removeTimeout = setTimeout( function()
            {
                fieldBox.removeClass('hasError');
                fieldBox.find('.errorBox').remove();
            }, 200 );

        });
    }


    // ON focus
    jQuery('form').on('focus', '.hasError input, .hasError textarea, .hasError select', function()
    {
        jQuery(this).parents('.hasError').find('.errorBox').addClass('show');
    });

    jQuery('form').on('blur', '.hasError input, .hasError textarea, .hasError select', function()
    {
        jQuery(this).parents('.hasError').find('.errorBox').removeClass('show');
    });
    ////////

    //For error box
    jQuery('form').on('mouseover', '.hasError .attention, .hasError input, .hasError textarea, .hasError select', function() {
	    jQuery(this).parents('.hasError').find('.errorBox').addClass('show');
    });

    jQuery('form').on('mouseout', '.hasError .attention, .hasError input, .hasError textarea, .hasError select', function() {
	    jQuery(this).parents('.hasError').find('.errorBox').removeClass('show');
    });
}
