jQuery(function()
{
	// continuous scrolling //
	
	jQuery( document ).on( 'scrollinit', '.releaf_table[data-continuous="1"]', function()
	{
		var table = jQuery( this );
		var container = table.parent();
		var thead = table.find( '.thead' );
		var tbody = table.find( '.tbody' );
		var search_form = table.parents( '.primary_panel' ).find( '.search_form' );
		
		var noOfCols  = thead.children().children().length;
		var rowHeight = tbody.children().first().height();
		
		var rowLoadTolerance   = 15; // how many rows outside viewport to pre-load
		var rowRenderTolerance = 40; // how many rows outside viewport to render (could be loaded)
		
		var cachedRowLimit = 400 * 40;
		
		var viewportHeight;
		var noOfVisibleRows;
		
		var setupViewport = function()
		{
			viewportHeight = container.height();
			noOfVisibleRows = Math.ceil( viewportHeight / rowHeight );
		}
		setupViewport();
		jQuery( window ).resize(function()
		{
			setupViewport();
			container.scroll();
		});
		
        var total, itemsPerPage, noOfPages;
        var setupTotals = function()
        {
            total = table.attr( 'data-total' );
            itemsPerPage = table.attr( 'data-items_per_page' );
            noOfPages = Math.floor( total / itemsPerPage ) + 1;
        }
        setupTotals();        
		
		var timeout;
		var requests = {};
		
		var abortRequests = function()
		{
			for( var i in requests )
			{
				requests[i].abort();
			}
			requests = {};
		}
		
		var currentTopPageNo    = 1;
		var currentBottomPageNo = 1;
		
		var pages = {};
		
		// store current results as page 1
		pages[ currentTopPageNo ] = tbody.html();
		
		var clone;
		
		var emptyRowCells = '';
		var loadingRowCells = '';
		var thCellWidths = {};
		
		// freeze column widths
		var freeze = function()
		{
			// reset header width
			if( clone )
			{
				clone.remove();
			}
			thead.children().first().children().each(function()
			{
				var cell = jQuery( this );
				var width = cell.width() + 'px';
				cell.css( 'width', '' );
				cell.css( 'min-width', '' );
				cell.css( 'max-width', '' );
			});
			// freeze it
			thead.children().first().children().each(function()
			{
				var cell = jQuery( this );
				var width = cell.width() + 'px';
				cell.css( 'width', width );
				cell.css( 'min-width', width );
				cell.css( 'max-width', width );
			});
			
			// add fixed header
			clone = thead.clone().insertAfter( thead ).css({ position: 'fixed', zIndex: 100}).addClass('fixed');
			clone.css( 'margin-top', '-' + clone.height() + 'px' )
			
			emptyRowCells   = '';
			loadingRowCells = '';
			thCellWidths    = {};
			thead.children().children().each(function( i )
			{
				thCellWidths[ i ] = jQuery( this ).width();
			});
			for( var i = 0; i < noOfCols; i++ )
			{
				emptyRowCells += '<span>&nbsp;</span>';
				if( thCellWidths[i] >= 100 )
				{
					loadingRowCells += '<span>' + table.attr( 'data-loading' ) + '</span>';
				}
				else
				{
					loadingRowCells += '<span>&nbsp;</span>';
				}
			}
			emptyRow   = '<div class="unselectable">' + emptyRowCells + '</div>';
			loadingRow = '<div class="unselectable" style="height:' + rowHeight + 'px;">' + loadingRowCells + '</div>';
		}
		
		freeze();
		
		var getEmptyRows = function( no )
		{
			var rows = [];
			for( var i = 0; i < no; i++ )
			{
				rows.push( loadingRow );
			}
			return rows.join( '' );
		}
		
		// initial setup
		var postHeight = total * rowHeight - tbody.children().length * rowHeight;
		if( postHeight > 0 )
		{
			var post = jQuery( emptyRow ).addClass( 'post' ).appendTo( tbody );
			post.height( postHeight );
		}
		
		container.scroll(function()
		{
			clearTimeout( timeout );
			timeout = setTimeout(function()
			{
				var offsets =
				{
					visible:
					{
						top:    0,
						bottom: 0
					},
					load:
					{
						top:    0,
						bottom: 0
					},
					render:
					{
						top:    0,
						bottom: 0
					}
				};
				
				var pageNumbers =
				{
					load:
					{
						top:    0,
						bottom: 0
					},
					render:
					{
						top:    0,
						bottom: 0
					}
				}
				
				offsets.visible.top    = Math.floor( Math.max( 0, container.prop( 'scrollTop' ) - thead.height() ) / rowHeight );
				offsets.visible.bottom = offsets.visible.top + noOfVisibleRows;
				
				// adjust for loading tolerance
				offsets.load.top    = Math.max( 0, offsets.visible.top - rowLoadTolerance );
				offsets.load.bottom = Math.min( offsets.visible.bottom + rowLoadTolerance, total );
				
				// adjust for rendering tolerance
				offsets.render.top    = Math.max( 0, offsets.visible.top - rowRenderTolerance );
				offsets.render.bottom = Math.min( offsets.visible.bottom + rowRenderTolerance, total );
				
				pageNumbers.load.top    = Math.floor( offsets.load.top / itemsPerPage ) + 1;
				pageNumbers.load.bottom = Math.floor( offsets.load.bottom / itemsPerPage ) + 1;
				
				pageNumbers.render.top    = Math.floor( offsets.render.top / itemsPerPage ) + 1;
				pageNumbers.render.bottom = Math.floor( offsets.render.bottom / itemsPerPage ) + 1;
				
				var preOffset = ( pageNumbers.render.top - 1 ) * itemsPerPage;
				var postOffset = Math.max( 0, total - pageNumbers.render.bottom * itemsPerPage );
				
				if( pageNumbers.load.top != currentTopPageNo || pageNumbers.load.bottom != currentBottomPageNo )
				{
					abortRequests();
					
					var no = 0;
					for( var i in pages )
					{
						if( pages[i] )
						{
							no++;
						}
					}
					
					// clear memory
					if( no * itemsPerPage > cachedRowLimit )
					{
						pages = {};
					}
					
					var pagesToLoad = {};
					for( var i = 0; i <= pageNumbers.load.bottom - pageNumbers.load.top; i++ )
					{
						pagesToLoad[ pageNumbers.load.top + i ] = true;
					}
					
					var pagesToRender = {};
					for( var i = 0; i <= pageNumbers.render.bottom - pageNumbers.render.top; i++ )
					{
						pagesToRender[ pageNumbers.render.top + i ] = true;
					}
					
					var inject = function()
					{
						var rows = '';
						for( var i in pagesToRender )
						{
							if( pages[ i ] === undefined )
							{
								if( i == noOfPages ) // last page is likely to be smaller
								{
									rows += getEmptyRows( total - ( noOfPages - 1 ) * itemsPerPage );
								}
								else
								{
									rows += getEmptyRows( itemsPerPage );
								}
							}
							else
							{
								rows += pages[ i ];
							}
						}
						currentTopPageNo    = pageNumbers.load.top;
						currentBottomPageNo = pageNumbers.load.bottom;
						
						var pre = '';
						if( preOffset > 0 )
						{
							var pre = '<div class="unselectable pre" style="height:' + ( preOffset * rowHeight ) + 'px">' + emptyRowCells + '</div>';
						}
						var post = '';
						if( postOffset > 0 )
						{
							var post = '<div class="unselectable post" style="height:' + ( postOffset * rowHeight ) + 'px">' + emptyRowCells + '</div>';
						}
						tbody.html( pre + rows + post );
						
						// check if row width need to be recalculated
						if
						(
							container.prop( 'clientWidth' ) > 0
							&&
							container.prop( 'clientWidth' ) < container.prop( 'scrollWidth' )
						)
						{
							freeze();
						}
						
						return true;
					}
					
					for( var i in pagesToLoad )
					{
						if( pages[ i ] === undefined )
						{
							(function(){
								var pageNo = i;
								var key = Math.random() + '';
                                
                                var searchUrl = new RequestUrl();
                                searchUrl.add( search_form.serializeArray() );
                                searchUrl.add({ ajax: 1, page: pageNo });
								requests[key] = jQuery.ajax
								({
                                    url: searchUrl.getUrl(),
									success: function( html, status )
									{
										delete requests[key];
										pages[ pageNo ] = jQuery( html ).find( '.releaf_table .tbody' ).html();
										inject();
									}
								});	
							})();
						}
					}
					inject();
				}
			},20);
		});
		container.scroll();
		
		table.bind( 'flushcache', function()
		{
			pages = {};
            setupTotals();
		});
	});
	
	jQuery( '.releaf_table[data-continuous="1"]' ).trigger( 'scrollinit' );
});
