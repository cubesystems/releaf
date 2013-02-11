jQuery(function()
{
	var controller = jQuery( '.controller-releaf_translations' );

	// adjust translations table head cell width

	var headCells = controller.find( '.translations_table_head .th' );
	//console.log( headCells );
	var adjustHeadCellWidth = function()
	{
        var row = jQuery( '.module-translations .translations_table thead tr:first th' );

		for( var i = 0; i < headCells.length; i++ )
		{
			jQuery( headCells[i] ).width( jQuery( row[i] ).outerWidth() - 2 );
		}
	};
	adjustHeadCellWidth();
	jQuery( window ).resize( adjustHeadCellWidth );

	// highlight selected entry

	if( location.hash )
	{
		jQuery( location.hash ).addClass( 'highlighted' );
	}

    controller.on('itemadd', function() {
        controller.find('table.translations tbody tr:last td.translation_name input[type="text"]').focus();
    });
});
