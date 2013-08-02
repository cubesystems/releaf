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



    });


/*
    // var controller_body = jQuery(document.body);
    var controller_body = jQuery('.controller-releaf-content');
    if (controller_body.length) {

        var name_input = jQuery('#releaf_node_name');
        if (name_input.length) {
            var slug_input = jQuery('#releaf_node_slug');
            var generate_slug_button = jQuery('button.generate_slug');

            var generate_slug = function () {
                var url = new url_builder( generate_slug_button.attr('data-new_slug_url') ).add({name: name_input.attr('value')}).getUrl();

                jQuery.ajax({
                    type:       'GET',
                    dataType:   'text',
                    url:        url,
                    timeout:    3000,
                    success:    function (data, textStatus) {
                                    slug_input.attr('value', data);
                                },
                    error:      function (xhr, textStatus, errorThrown) {
                                    // FIXME
                                    alert("Failed to generate slug");
                                }
                });
            }
            generate_slug_button.on('click', generate_slug)

            if (name_input.attr('value').length === 0) {
                name_input.one('change', generate_slug);
            }
        }

    }
*/

});
