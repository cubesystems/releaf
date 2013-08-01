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

        jQuery('.secondary_panel .tree_container').delegate('a.create', 'click', function(e) {
            e.stopPropagation();

            var a = jQuery(e.currentTarget);
            var p_li = a.parents('li:first');

            var y = p_li.offset().top;
            var x = p_li.offset().left + p_li.width() + 2;

            var x_offset = [ 'padding-left', 'padding-right', 'margin-left' ]
            for (var i = 0; i < x_offset.length; i++) {
                x += parseInt(p_li.css(x_offset[i]));
            }


            var url = new url_builder( a.attr('href') ).add({ajax: 1}).getUrl();
            var new_object_menu_anchor = jQuery('#new_object_menu_anchor')
            if (new_object_menu_anchor.length === 0) {
                new_object_menu_anchor = jQuery('<div id="new_object_menu_anchor"><div id="new_object_menu" style="display:none;"></div></div>');
                controller_body.append(new_object_menu_anchor);
            }

            new_object_menu = new_object_menu_anchor.find('#new_object_menu').css({top: y, left: x});
            new_object_menu.html(null).addClass('loading')
                new_object_menu.show();



            jQuery.ajax({
                type:       'GET',
                dataType:   'html',
                url:        url,
                timeout:    3000,
                success:    function (data, textStatus) {
                                new_object_menu.html(data).removeClass('loading');
                            },
                error:      function (xhr, textStatus, errorThrown) {
                                new_object_menu.text('Error').removeClass('loading');
                            }
            });

            return e.preventDefault();
        });


        $(document).click(function (e) {
            var container = jQuery('#new_object_menu');
            if ( container.has(e.target) ) {
                container.hide();
            }
        });

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
