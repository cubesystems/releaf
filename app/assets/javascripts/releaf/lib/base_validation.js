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
                        errorBox = jQuery('<div class="errorBox"><div class="error"></div></div>').appendTo(fieldBox);
                    }

                    errorBox.find('.error').text( error.message );

                    fieldBox.addClass('hasError');

                    var input = fieldBox.find('input:first, select:first, textarea:first');
                    errorBox.css('left', input.position().left + input.width());
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
}
