//= require ../../lib/request_url

jQuery(document).ready(function() {
    // var controller_body = jQuery(document.body);
    var controller_body = jQuery('.controller-leaf_content');

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


        var url = new RequestUrl( a.attr('href') ).add({ajax: 1}).getUrl();
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
        if ( container.has(e.target).length === 0) {
            container.hide();
        }
    });

});
