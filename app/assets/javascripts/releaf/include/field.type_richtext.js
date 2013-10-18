//= require_tree ../lib/tinymce
jQuery(function()
{
    var body = jQuery('body');

	// richtext config
	var plugins = [ 'inlinepopups', 'iespell', 'insertdatetime', 'preview', 'searchreplace', 'contextmenu', 'safari', 'fullscreen', 'paste', 'attachment_upload' ];

	// remove inlinepopups plugin for Opera 10
	if( typeof BrowserDetect != 'undefined' )
	{
		if( BrowserDetect.browser == 'Opera' && BrowserDetect.version == 9.8 )
		{
			for( var i = 0; i < plugins.length; i++ )
			{
				if( plugins[i] == 'inlinepopups' )
				{
					delete plugins[i];
				}
			}
		}
	}

	var tinymce_config =
	{
		mode:     'exact',
		elements: '',
		theme : 'advanced',
		entities : '160,nbsp,38,amp,60,lt,62,gt',
		body_class : 'content',
		plugins : plugins.join(','),
		paste_auto_cleanup_on_paste : true,
		theme_advanced_buttons1 : 'bold,italic,formatselect,justifyleft,justifycenter,justifyright,justifyfull,|,sub,sup,|,bullist,numlist,|,link,unlink,attachment_upload,image,embed,|,code,cleanup,removeformat|,fullscreen',
		theme_advanced_blockformats : 'p,address,pre,h2,h3,h4,h5,h6',
		theme_advanced_buttons2 : '',
		theme_advanced_buttons3 : '',
		theme_advanced_toolbar_location : 'top',
		theme_advanced_toolbar_align : 'left',
		theme_advanced_statusbar_location : 'bottom',
		plugin_insertdate_dateFormat : '%Y-%m-%d',
		plugin_insertdate_timeFormat : '%H:%M:%S',
		extended_valid_elements : 'a[name|href|target|title|onclick|class],img[rel|class|src|border=0|alt|title|hspace|vspace|width|height|align|onmouseover|onmouseout|name],hr[class|width|size|noshade],font[face|size|color|style],span[class|align|style]',
		relative_urls : false,
		theme_advanced_resizing : false,
		object_resizing : false,
		init_instance_callback: function( instance )
		{
			jQuery( instance.contentAreaContainer ).trigger( 'tinymceinit', [ instance ] );
		}
	};

	tinymce_config.setup = function( editor )
	{
		// skip first onBeforeGetContent call because textFormat.css has not loaded yet
		editor.onInit.add( function( editor )
		{
			// richtext focus effect
			tinymce.dom.Event.add
			(
				editor.settings.content_editable ? editor.getBody() : (tinymce.isGecko ? editor.getDoc() : editor.getWin()), 'focus', function()
				{
					// jQuery's internal selector engine requires colons and periods to be escaped
					jQuery( ( '#' + editor.editorContainer ).replace(/(:|\.)/g, '\\$1') ).children('.mceLayout').addClass('focus');
				}
			);
			tinymce.dom.Event.add
			(
				editor.settings.content_editable ? editor.getBody() : (tinymce.isGecko ? editor.getDoc() : editor.getWin()), 'blur', function()
				{
					// jQuery's internal selector engine requires colons and periods to be escaped
					jQuery( ( '#' + editor.editorContainer ).replace(/(:|\.)/g, '\\$1') ).children('.mceLayout').removeClass('focus');
					tinyMCE.triggerSave(); // update textarea contents
				}
			);
		});
	};

    body.on( 'richtextinit', 'textarea.richtext', function( event, extra_config )
    {
        var textarea = jQuery(this);

        var config = tinymce_config;
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

        if (textarea.attr('data-tinymce-attachment-upload-url'))
        {
            config['attachment_upload_url'] = textarea.attr('data-tinymce-attachment-upload-url');
        }
        textarea.tinymce(config);

        textarea.on('richtextsuspend', function(e)
        {
            if (textarea.data('richtext-suspended'))
            {
                return;
            }
            tinyMCE.execCommand( 'mceRemoveControl', false, textarea.attr('id') );
            textarea.data('richtext-suspended', true);
        });

        textarea.on('richtextresume', function(e)
        {
            if (!textarea.data('richtext-suspended'))
            {
                return;
            }
            tinyMCE.execCommand( 'mceAddControl', false, textarea.attr('id') );
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
        // remove tinymce instances when removing fields

        var removable_item = jQuery(e.target);
        var textareas = removable_item.is('textarea.richtext') ? removable_item : removable_item.find( 'textarea.richtext' );

        textareas.each(function()
        {
            jQuery(this).trigger('richtextsuspend');
        });

    });


    // to avoid losing content tinymce needs to be disabled and reenabled when used inside a sortable list
    body.on('sortablestart', function( event )
    {
        jQuery(event.target).find('textarea.richtext').each(function()
        {
            jQuery(this).trigger('richtextsuspend');
        });
    });

    body.on('sortablestop sortableupdate', function( event )
    {
        // restore tinymce on either sortablestop or sortableupdate, whichever comes first
        // (sortable plugin actually calls update before stop)
        jQuery(event.target).find('textarea.richtext').each(function()
        {
            jQuery(this).trigger('richtextresume');
        });
    });

    // if id of the textarea gets changed, tinymce needs to be reinitialized
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
