jQuery(function(){
    var body = jQuery('body');
    var settings_path = body.data('settings-path');

    body.on('settingssave', function( event, key_or_settings, value )
    {
        if (!settings_path)
        {
            return;
        }

        var settings = key_or_settings;
        if (typeof settings === "string")
        {
            settings = {};
            settings[key_or_settings] = value;
        }

        LiteAjax.ajax({ url: settings_path, method: 'POST', data:  { "settings": settings}, json: true })
    });
});

