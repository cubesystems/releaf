jQuery( document ).ready(function()
{
    
    jQuery(document).bind('nestedfieldsinit', function( e )
    {
        var target = jQuery(e.target);
        if (!target.is('.nested_wrap'))
        {
            target = target.find('.nested_wrap');
        }
        
        target.each(function()
        {
            var block = jQuery(this);
            var list   = block.find('.list').first();
            
            var block_name               = block.attr('data-name');
            var template_selector        = '.item[data-name="' + block_name + '"].template';            
            var item_selector            = '.item[data-name="' + block_name + '"]:not(.template)';
            
            var new_item_selector        = '.item[data-name="' + block_name + '"].new';
            var existing_item_selector   = '.item[data-name="' + block_name + '"]:not(.template,.new)';

            
            block.click( function( event )
            {
                var trigger = jQuery( event.target );     
                
                // webkit browsers go beyond button node when setting click target
                if (!trigger.is('button'))
                {
                    trigger = trigger.parents( 'button' ).first();
                }
                
                if (
                    (!trigger.is('button.add_nested_item'))
                    &&
                    (!trigger.is('button.remove_nested_item'))
                )
                {
                    // irrelevant click
                    return;
                }
                
                var target_block = trigger.parents('.nested_wrap').first();
                                    
                if (target_block.attr('data-name') != block_name)
                {
                    return;   // only react to own clicks
                }

                if (trigger.is('.add_nested_item'))
                {
                    var template = target_block.find( template_selector ).first();
                    if (template.length != 1)
                    {
                        if (typeof console != 'undefined' && 'log' in console)
                        {
                            console.log('Nested field template not found.');
                        }
                        return null;
                    }

                    var new_item = template.clone( false );

                    new_item.removeClass( 'template' ).addClass('new');
                    
                    // insert new item at the end of the list but before any removed items
                    var first_removed_item = list.find(item_selector).filter('.removed');
                    
                    if (first_removed_item.length > 0)
                    {
                        new_item.insertBefore( first_removed_item );
                    }
                    else
                    {
                        new_item.appendTo( list );                        
                    }
                    
                    new_item.trigger( 'nestedfieldsreindex' );
                    
                    if (new_item.is('tr, td') )
                    {
                        new_item.fadeIn( 'normal', function()
                        {
                            new_item.trigger( 'nestedfieldsitemadd' );
                        });
                        new_item.trigger( 'nestedfieldsinit' );                        
                    }
                    else
                    {
                        
                        new_item.css({ opacity: 0 });
                        new_item.slideDown( 'fast', function()
                        {
                            new_item.css({ opacity: 1 }).hide();
                            new_item.fadeIn( 'fast', function()
                            {
                                new_item.trigger( 'nestedfieldsitemadd' );
                            });
                            new_item.trigger( 'nestedfieldsinit' );                            
                        });
                    }
    
                }
                else if (trigger.is('.remove_nested_item'))
                {
                    var item = trigger.parents(item_selector).first();

                    var removeItem = function( item )
                    {
                        var destroy_inputs = item.find('input.destroy');
                        
                        if (destroy_inputs.length > 0)
                        {
                            // mark as destroyable, hide and move to end of list
                            destroy_inputs.val( true );
                            
                            item.hide();
                        }
                        else
                        {
                            item.remove();
                        }

                        target_block.trigger( 'nestedfieldsreindex' );
                    }
                    
                    item.addClass( 'removed' );
                    
                    item.trigger( 'nestedfieldsitemremove' );                    
                    
                    item.fadeOut( 'fast', function()
                    {
                        if (item.is('tr,td'))
                        {
                            removeItem( item );
                        }
                        else
                        {
                            item.css({ opacity: 0 }).show().slideUp( 'fast', function()
                            {
                                removeItem( item );
                            });
                        }
                    });
                    
                }

                return;
            });            

            
            // :TODO: trigger nestedfieldsreindex ofter sorting in case of sortable_objects 
            
            block.on('nestedfieldsreindex', function( e )
            {
                // update data-index attributes and names/ids for all fields inside a block
                
                // in case of nested blocks, this bubbles up and gets called for each parent block also
                // so that each block can update it's own index in the names

                // only new items are changed. 
                // existing items always preserve their original indexes
                // new item indexes start from largest of existing item indexes + 1
                
                var first_available_new_index = 0;
                
                var existing_items = block.find( existing_item_selector );
                existing_items.each(function()
                {
                    var index = jQuery(this).attr('data-index');
                    if (typeof index == 'undefined')
                    {
                        return;
                    }
                    index = index * 1;
                    
                    if (index >= first_available_new_index)
                    {
                        first_available_new_index = index + 1;
                    }
                })

                var new_items = block.find(new_item_selector);
                
                console.log( block_name + ': ' + first_available_new_index );
                
                var index = first_available_new_index;
                

                new_items.each(function()
                {   
                    var item = jQuery(this);
                    item.attr('data-index', index);


                    // this matches both of these syntaxes in attribute values:
                    //
                    //  resource[foo_attributes][0][bar]  /  resource[foo_attributes][_template_][bar]
                    //  resource_foo_attributes_0_bar     /  resource_foo_attributes__template__bar
                    //   
                       
                    var matchPattern  = new RegExp('(\\[|_)' + block_name + '_attributes(\\]\\[|_)(\\d*|_template_)?(\\]|_)')
                    var searchPattern = new RegExp('((\\[|_)' + block_name + '_attributes(\\]\\[|_))(\\d*|_template_)?(\\]|_)', 'g');            
                    var attrs = ['name', 'id', 'for'];            

                    item.find('input,select,textarea,button,label').each(function()
                    {
                        for (var i=0; i<attrs.length; i++)
                        {
                            var attr = jQuery(this).attr(attrs[i]);
                            if (attr && attr.match(matchPattern))
                            {
                                jQuery(this).attr(attrs[i], attr.replace(searchPattern, '$1' + index + '$5'));
                            }                    
                        }
                    }); 

                    index++;
                });
                
            });
            
            block.on('nestedfieldsitemadd', function( e )
            {
                var item = jQuery( e.target );
                
                if (item.attr('data-name') != block_name)
                {
                    return; // the added item does not belong to this block
                }
                
                // focus first visibile field in item
                item.find( 'input, select, textarea' ).filter(':visible').first().focus();

            });
            

        });
        
	});
    
    jQuery(document).trigger('nestedfieldsinit');
      
    
});
