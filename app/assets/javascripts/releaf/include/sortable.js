jQuery(document).ready(function() {

    jQuery(document.body).on('initsortable', function(e) {
        jQuery(e.target).find('.list[data-sortable]').sortable({
            axis: "y",
            ontainment: "parent",
            cursor: "move",
            delay: 150,
            distance: 5,
            handle: '> .handle',
            items: "> .item",
            scroll: true,
            update: function( event, ui ) {
                jQuery(this).trigger('sortableupdate');
            }
        });
    });

    jQuery(document.body).trigger('initsortable');

    jQuery( document.body ).on('itemadd', function (e) {
        jQuery(e.target).trigger('initsortable');
    });

    jQuery( document.body ).on('itemadd', '.list[data-sortable]', function (e) {
        jQuery(e.target).trigger('sortableupdate');
    });

});
