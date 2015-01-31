jQuery( document ).ready(function()
{
    var body = jQuery('body');

    jQuery(document).bind('booleanassociationinit', function( e )
    {
        var target_selector = '.field.type-boolean-group';
        var target = jQuery(e.target);
        if (!target.is(target_selector))
        {
            target = target.find(target_selector);
        }

        target.each(function()
        {
            var block = jQuery(this);
            var checkboxes = block.find('input.keep');
            checkboxes.bind('click', function( event, event_params )
            {
                var checkbox = $(this)
                var destroy = checkbox.siblings("input.destroy")
                destroy.val(checkbox.prop('checked') ? 'false' : 'true');
            });
        });

    });

    body.on('contentloaded', function(e, event_params)
    {
        jQuery(e.target).trigger('booleanassociationinit', event_params);
    });
});
