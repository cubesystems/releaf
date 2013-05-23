//= G
jQuery(function()
{
	// richtext config
	var plugins = [ 'inlinepopups', 'iespell', 'insertdatetime', 'preview', 'searchreplace', 'contextmenu', 'safari', 'uploadimage' ];

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
		theme_advanced_buttons1 : 'bold,italic,formatselect,justifyleft,justifycenter,justifyright,justifyfull,|,sub,sup,|,bullist,numlist,|,link,unlink,uploadimage,image,embed,|,code,cleanup,removeformat',
		theme_advanced_blockformats : 'p,address,pre,h2,h3,h4,h5,h6',
		theme_advanced_buttons2 : '',
		theme_advanced_buttons3 : '',
		theme_advanced_toolbar_location : 'top',
		theme_advanced_toolbar_align : 'left',
		theme_advanced_statusbar_location : 'bottom',
		plugin_insertdate_dateFormat : '%Y-%m-%d',
		plugin_insertdate_timeFormat : '%H:%M:%S',
		extended_valid_elements : 'a[name|href|target|title|onclick],img[class|src|border=0|alt|title|hspace|vspace|width|height|align|onmouseover|onmouseout|name],hr[class|width|size|noshade],font[face|size|color|style],span[class|align|style]',
		relative_urls : false,
		theme_advanced_resizing : true,
		object_resizing : false,
		//content_css: '/styles/textFormat.css',
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
	}

	jQuery( document ).on( 'richtextinit', function( event, extra_config )
	{
        var config = tinymce_config;
        if (extra_config)
        {
            jQuery.each(extra_config, function(index, value){
                config[index] = value;
            });
        }

		var textarea = jQuery( event.target );
		if( !textarea.attr( 'id' ) )
		{
			textarea.attr( 'id', 'richtext_' + String((new Date()).getTime()).replace(/\D/gi,'') );
		}
        if (textarea.attr('data-tinymce-image-upload-url'))
        {
            config['uploadimage_form_url'] = textarea.attr('data-tinymce-image-upload-url');
        }
        textarea.tinymce(config);
	});

    jQuery(document).on('itemadd', function(e) {
        jQuery(e.target).find('.field.type_richtext textarea.richtext' ).trigger( 'richtextinit');
    })

    jQuery( '.field.type_richtext textarea' ).trigger( 'richtextinit' );
});
