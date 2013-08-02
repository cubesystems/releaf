jQuery(function()
{
    var body = jQuery('body.controller-releaf-content');

    body.on('contentloaded', function(e)
    {
        var block = jQuery(e.target);

        // row collapse / expand

        var get_children = function( row )
        {
            var children = row.data('children');

            if (typeof children == 'undefined')
            {
                var table = row.closest('table.resources');
                var ancestry = row.attr('data-ancestry');
                var ancestry_parts = (ancestry) ? ancestry.split('-') : [];
                ancestry_parts.push( row.attr('data-id') );
                var children_ancestry = ancestry_parts.join('-');
                children = table.find('tr[data-ancestry="' + children_ancestry + '"]');
                row.data('children', children);
            }

            return children;
        }

        block.find('tr.node .collapser').click(function()
        {
            var row   = jQuery(this).closest('tr.node');

            var event_name = (row.is('.collapsed')) ? 'noderowexpand' : 'noderowcollapse';

            row.trigger(event_name);

        });


        block.find('tr.node').bind('noderowcollapse', function()
        {
            var row = jQuery(this);
            row.addClass('collapsed');
            row.find('.collapser i').removeClass('icon-chevron-up').addClass('icon-chevron-right');

            var children = get_children( row );
            children.trigger('noderowhide');
        });


        block.find('tr.node').bind('noderowexpand', function()
        {
            var row = jQuery(this);
            row.removeClass('collapsed');
            row.find('.collapser i').removeClass('icon-chevron-right').addClass('icon-chevron-up');

            var children = get_children( row );
            children.trigger('noderowshow');
        });


        block.find('tr.node').bind('noderowshow', function()
        {
            var row = jQuery(this);

            row.show();

            if (row.is('.collapsed'))
            {
                return; // collapsed row, do not show children
            }

            var children = get_children( row );
            children.trigger('noderowshow');

        });


        block.find('tr.node').bind('noderowhide', function()
        {
            var row = jQuery(this);
            row.hide();

            var children = get_children( row );
            children.trigger('noderowhide');
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
