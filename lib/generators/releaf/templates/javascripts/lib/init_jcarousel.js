//= require ../3rd_party/jquery.jcarousel

jQuery(document).ready(function() {

    jQuery(document.body).on('initcarousel', function(e) {
        var target = jQuery(e.target);

        target.find('.carousel_wrap').each(function() {
            var carousel_wrap = jQuery(this);
            var carousel_controls_wrap = carousel_wrap.find('.carousel_controls');
            var carousel_controls = carousel_controls_wrap.find('a[data-nr], button[data-nr]');

            carousel_wrap.find('.jcarousel').jcarousel({
                wrap: 'circular',
                vertical: false,
                scroll: 1,
                buttonNextHTML: null,
                buttonPrevHTML: null,
                auto: 5,
                itemVisibleInCallback: {
                    onBeforeAnimation: function (carousel, item, idx, state) {
                        var jitem = jQuery(item);
                        carousel_controls.removeClass('active');
                        jQuery(carousel_controls[jitem.attr('data-nr')]).addClass('active');
                    }
                },
                initCallback: function(carousel) {
                    carousel_controls_wrap.on('click', 'a[data-nr], button[data-nr]', function() {
                        var link = jQuery(this);
                        carousel.scroll(jQuery.jcarousel.intval(link.attr('data-nr')));
                    });
                }
            });
        });
    });

    jQuery(document.body).trigger('initcarousel');

});

