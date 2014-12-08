jQuery(function()
{
    var body = jQuery('body');

    body.on('contentloaded', function(e)
    {
        console.log( jQuery(e.target).find('#page_select') );
        jQuery(e.target).find('#page_select').on('click', function()
        {
            console.log('wat');
            var val = jQuery(this).val();
            if (val)
            {
                var url = new url_builder().add({page: val}).getUrl();
                window.location.href = url;
                console.log(url);
            }
        });
        console.log( jQuery(e.target).find('#page_select') );
    });

});
