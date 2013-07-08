$(document).ready(function() {
    
    // Init tooltips
    leaf_init.tooltips();
    
    // Date pickers
    leaf_init.datepicker();
    
    
    // Menu collapse toggle click
    leaf_menu.collapse_click();
    
    // Toggle right chevron state on category close / open
    leaf_menu.toggle_categories();
    
    // Toggle windows resize
    leaf_menu.toggle_wrapper_resize();

});


leaf_init = {

    tooltips: function() {
        
        // Tooltips for inputs with title tag
        $('input[title]').tooltip({
            placement: 'right',
            container: 'body'
        });
        
    },
            
    datepicker: function() {

        $('#datetimepicker1').datetimepicker({
            pickTime: false
        });

    }    
    
};


leaf_menu = {

    // Sidebar collapse and hide onclick events
    collapse_click: function() {
        
        $('.sidebar-toggle-button').on('click', function(e){
            leaf_menu.collapse_handler(e);
        });
        $('.menu-collapse-link').on('click', function(e){
            leaf_menu.collapse_handler(e);
        });
        
    },
    
    // Changes chevron state and fires sidebar toggle switcher function
    collapse_handler: function(e) {
        e.preventDefault();
        
        // Change button chevron state
        $('.menu-collapse-link').find('.toggle-angle-icon').toggleClass('icon-double-angle-left');
        $('.menu-collapse-link').find('.toggle-angle-icon').toggleClass('icon-double-angle-right');
        
        // Expand or collapse sidebar
        leaf_menu.toggle_switcher();
        
        // Expand or collapse all open accordion categories
        leaf_menu.toggle_accordion_switcher();
    },
    
    // Toggles sidebar
    toggle_switcher: function() {

        $('.container-fluid:first').toggleClass('menu-hidden');
    },
    
    toggle_accordion_switcher: function() {
        
        if($('.accordion-body').hasClass('in')) {
            
            $('.accordion-body.open').collapse('hide');
            
        } else {
            
            $('.accordion-body.open').collapse('show');
            
        }
    },
    
    // Accordion and dropdown categories collapsing
    toggle_categories: function() {
        
        // On category link click event
        $('.accordion-toggle').on('click', function() {

            // Find ul element with menu
            var $group = $(this).closest('.accordion-group');

            // Get body element of clicked category
            var $body = $group.find('.accordion-body');

            $(this).find('.chevron').toggleClass('icon-chevron-down');
            $(this).find('.chevron').toggleClass('icon-chevron-up');

            // Toggle open class
            $body.toggleClass('open');
            
            // Toggle windows resize
            leaf_menu.toggle_wrapper_resize();

            // Prevent default open action if sidebar is in compact state
            if($('.container-fluid:first').hasClass('menu-hidden')) {

                $('.container-fluid:first').addClass('menu-activated');

                if($group.find('li').length > 0) {
                    return false;
                }
            }

        });
        
        // Remove active class if user clicked somewhere else on body element
        $('body').on('click', function() {
            $('.container-fluid:first').removeClass('menu-activated');
        });

    },
            
    toggle_wrapper_resize: function() {
        var $sidebar_height = ($('#menu-inner').height() + 140) + 'px';
        $('#wrapper').css('min-height', $sidebar_height);
    }
    
};