jQuery(function()
{
    var body = jQuery('body.controller-releaf-content');

    body.on('contentloaded', function(e)
    {
        var block = jQuery(e.target);

        // row collapse / expand
        block.find('.row .collapser').click(function()
        {
            var row             = jQuery(this).closest('.row');
            var should_expand   = row.is('.collapsed');
            var event_name      = should_expand ? 'noderowexpand' : 'noderowcollapse';

            row.trigger(event_name);

            var setting_key = 'content.tree.expanded.' + row.data('id');
            body.trigger( 'settingssave', [ setting_key, should_expand ] );
        });

        block.find('.row').bind('noderowcollapse', function( e )
        {
            e.stopPropagation();

            var row = jQuery(e.target);
            row.addClass('collapsed');
            row.children('.collapser-cell').find('.collapser i').removeClass('fa-chevron-down').addClass('fa-chevron-right');

        });

        block.find('.row').bind('noderowexpand', function( e )
        {
            e.stopPropagation();

            var row = jQuery(e.target);
            row.removeClass('collapsed');
            row.children('.collapser-cell').find('.collapser i').removeClass('fa-chevron-right').addClass('fa-chevron-down');

        });



        // slug generation
        var name_input  = block.find('.node-fields .field[data-name="name"] input');
        var slug_field  = block.find('.node-fields .field[data-name="slug"]');

        if (name_input.length && slug_field.length)
        {
            var slug_input  = slug_field.find('input');
            var slug_button = slug_field.find('.generate')
            var slug_link   = slug_field.find('a');

            slug_input.on('sluggenerate', function(e)
            {
                var url = slug_input.attr('data-generator-url');

                slug_button.trigger('loadingstart');
                jQuery.get( url, { name: name_input.val() }, function( slug )
                {
                    slug_input.val( slug );
                    slug_link.find('span').text( encodeURIComponent( slug ) );
                    slug_button.trigger('loadingend');
                }, 'text');
            });

            slug_button.click(function()
            {
                slug_input.trigger('sluggenerate');
            });

            if (name_input.val() == '')
            {
                // bind onchange slug generation only if starting out with an empty name
                name_input.change(function()
                {
                    slug_input.trigger('sluggenerate');
                });
            }
        }

    });

});
