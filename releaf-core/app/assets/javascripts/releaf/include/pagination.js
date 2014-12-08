jQuery(function()
{
    var body = jQuery('body');
    body.on('contentloaded', function(e)
    {
        jQuery(e.target).find('#page_select').on('change', function()
        {
            var val = jQuery(this).val();
            if (val)
            {
                var url = new url_builder().add({page: val}).getUrl();
                window.location.href = url;
                console.log(url);
            }
        });
    });

});
