jQuery(function()
{
	var controller = jQuery( '.controller-leaf_rails_aliases' );

	// adjust alias table head cell width

	var headCells = controller.find( '.aliasesTableHead .th' );
	//console.log( headCells );
	var adjustHeadCellWidth = function()
	{
        var row = jQuery( '.module-aliases .aliasesTable thead tr:first th' );

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
        controller.find('table.aliases tbody tr:last td.translation_name input[type="text"]').focus();
    });
});
