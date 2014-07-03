jQuery(function()
{
    var body = jQuery('body');

    var ckeditor_config = {
        language: 'en',
        entities_latin: false,
        forcePasteAsPlainText: true,
        height: '400px',
        allowedContent: true,
        format_tags: 'p;h2;h3',
        toolbar: [['Bold', 'Italic'], ['Format'], ['JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock'], ['Subscript', 'Superscript'], ['NumberedList', 'BulletedList'], ['Image', 'Link', 'Unlink'], ['Source', 'Maximize', 'ShowBlocks']]
    };


    body.on( 'richtextinit', 'textarea.richtext', function( event, extra_config )
    {
        var textarea = jQuery(this);


        textarea.closest("form").on( 'beforevalidation', function( event, extra_config )
        {
            for ( instance in CKEDITOR.instances )
            {
                CKEDITOR.instances[instance].updateElement();
            }
        });


        var config = ckeditor_config;
        config.width = textarea.outerWidth();
        config.height = textarea.outerHeight();

        if (extra_config)
        {
            jQuery.each(extra_config, function(index, value){
                config[index] = value;
            });
        }

        if( !textarea.attr( 'id' ) )
        {
            textarea.attr( 'id', 'richtext_' + String((new Date()).getTime()).replace(/\D/gi,'') );
        }

        if (textarea.data('attachment-upload-url'))
        {
            config.filebrowserUploadUrl = textarea.data('attachment-upload-url');
        }

        if (textarea.data('external-stylesheet'))
        {
            config.contentsCss = textarea.data('external-stylesheet');
        }

        textarea.ckeditor(config);

        textarea.on('richtextsuspend', function(e)
        {
            if (textarea.data('richtext-suspended'))
            {
                return;
            }

            CKEDITOR.instances[ textarea.attr('id') ].destroy();
            textarea.hide();
            textarea.data('richtext-suspended', true);
        });

        textarea.on('richtextresume', function(e)
        {
            if (!textarea.data('richtext-suspended'))
            {
                return;
            }

            textarea.show();
            textarea.trigger('richtextinit');
            textarea.data('richtext-suspended', false);
        });
    });

    // initialize richtext editor for any new richtext textarea after any content load
    body.on('contentloaded', function(e)
    {
        var block = jQuery(e.target);
        var textareas = block.is('textarea.richtext') ? block : block.find( 'textarea.richtext' );

        // remove textareas that need not be initialized automatically
        textareas = textareas.not('.template textarea, textarea.manual-init');

        textareas.trigger('richtextinit');

    });

    body.on('contentbeforeremove', function(e)
    {
        // remove ckeditor instances when removing fields

        var removable_item = jQuery(e.target);
        var textareas = removable_item.is('textarea.richtext') ? removable_item : removable_item.find( 'textarea.richtext' );

        textareas.each(function()
        {
            jQuery(this).trigger('richtextsuspend');
        });

    });


    // to avoid losing content ckeditor needs to be disabled and reenabled when used inside a sortable list
    body.on('sortablestart', function( event )
    {
        jQuery(event.target).find('textarea.richtext').each(function()
        {
            jQuery(this).trigger('richtextsuspend');
        });
    });

    body.on('sortablestop sortableupdate', function( event )
    {
        // restore ckeditor on either sortablestop or sortableupdate, whichever comes first
        // (sortable plugin actually calls update before stop)
        jQuery(event.target).find('textarea.richtext').each(function()
        {
            jQuery(this).trigger('richtextresume');
        });
    });

    // if id of the textarea gets changed, ckeditor needs to be reinitialized
    body.on('beforeattributechange', 'textarea.richtext', function(event, event_params)
    {
        if (event_params.attribute != 'id')
        {
            return;
        }
        jQuery(this).trigger('richtextsuspend');
    });

    body.on('attributechanged', 'textarea.richtext', function(event, event_params)
    {
        if (event_params.attribute != 'id')
        {
            return;
        }
        jQuery(this).trigger('richtextresume');
    });
});
