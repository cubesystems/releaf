jQuery(document).ready(function() {

    $('[data-sortable]').each(function() {
        var sortable_list = jQuery(this);

        sortable_list.sortable({
            axes:       'y',
            items:      '[id]',
            helper:     function(e, ui){
                ui.children().each(function(){
                    var item = jQuery(this);
                    item.width(item.width());
                    item.children().each(function(){
                        var subitem = jQuery(this);
                        subitem.width(subitem.width());
                    });
                });
                jQuery(ui).closest('table').find('th').each(function(){
                    var item = jQuery(this);
                    item.width(item.width());
                });
                return ui;
            },
            update:     function(){
                jQuery.post(sortable_list.attr('data-sortable'), sortable_list.sortable('serialize') + '&_method=post');
            }
        }).disableSelection();
    });
});
