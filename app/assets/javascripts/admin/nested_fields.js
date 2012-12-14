jQuery(function()
{
    var forms = jQuery('form');

	forms.each(function()
	{
		var form = jQuery( this );
		form.find( '.nested_wrap' ).each(function()
		{
			var nested = jQuery( this );
			var list = nested.find( '.list:first' );
            console.debug(list);
			var template = jQuery( '<div></div>' ).append( nested.find( '.template:first' ).clone().removeClass( 'template' ) ).html();

			nested.on( 'click', '.add', function()
			{
				var key = 'on-' + new Date().getTime();
				var item = jQuery( template.replace( /(".*?)(_template_)(.*?")/g, '$1' + key + '$3' ) );
				list.append( item );
				if( item.is('tr') )
				{
					item.fadeIn( 'normal' );
					item.trigger('itemadd');
				}
				else
				{
					item.css({ opacity: 0 });
					item.slideDown( 'fast', function()
					{
						item.css({ opacity: '' });
						item.find( 'input:first' ).focus();
						item.hide();
						item.fadeIn( 'fast' );
						item.trigger('itemadd');
					});
				}
			});

			nested.on( 'click', '.remove', function()
			{
				var item = jQuery( this ).parents( '.item' );
				var destroy = item.find( '.destroy' );
				var end = function()
				{
					item.hide();
					item.trigger('itemremoveend');
					if( destroy.length > 0 )
					{
						destroy.val( true );
					}
					else
					{
						item.remove();
					}
				}
				if( item.is('tr') )
				{
					item.fadeOut( 'fast', end );
				}
				else
				{
					item.fadeOut( 'fast', function()
					{
						item.css( 'opacity', 0 ).show().slideUp( 'fast', end );
					});
				}
                item.trigger('itemremove');
			});
		});
	});

});
