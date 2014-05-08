jQuery(function()
{
    var body = jQuery('body');


	// import
    var controller = jQuery( '.controller-releaf-translations' );
	var import_form            = controller.find( 'form.import' );
	var import_file            = import_form.find( 'input[type="file"]' );
	var import_button 		   = controller.find( 'button[name="import"]' );

	import_button.click(function(){ import_file.click() });

	import_file.change(function()
	{
        body.trigger('toolboxcloseall');
        import_form.submit();
	});
});
