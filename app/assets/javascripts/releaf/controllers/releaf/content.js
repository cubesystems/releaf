//= require ../../lib/url_builder

jQuery(document).ready(function() {
    // var controller_body = jQuery(document.body);
    var controller_body = jQuery('.controller-releaf-content');
    if (controller_body.length) {

        jQuery('.secondary_panel .tree_container').on('click', '.node button.toggle', function() {
            jQuery(this).toggleClass('open');
            jQuery(this).parents('.node:first').next().toggleClass('hide');
        });

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
});
