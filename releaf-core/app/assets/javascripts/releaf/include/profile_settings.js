jQuery(function(){

    var body = jQuery('body');

    var settings_url = jQuery('header .profile').data('settings-url');
    body.on('settingssave', function( event, key_or_settings, value )
    {
        if (!settings_url)
        {
            return;
        }

        var settings = key_or_settings;
        if (typeof settings === "string")
        {
            settings = {};
            settings[key_or_settings] = value;
        }

        jQuery.ajax
        ({
            url:  settings_url,
            data: { "settings": settings},
            type: 'POST',
            dataType: 'json'
        });
    });
});
