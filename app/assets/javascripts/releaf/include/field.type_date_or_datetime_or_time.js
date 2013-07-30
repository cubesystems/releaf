jQuery(document).ready(function() 
{
    var body = jQuery('body');
    
    var chevron_icons_show = function( instance ) 
    {
        // Set timeout to execute this after datepicker has been initialized
        setTimeout( function() {
            jQuery(instance.dpDiv[0]).find('.ui-datepicker-prev').html('<i class="icon-chevron-left"></i>');
            jQuery(instance.dpDiv[0]).find('.ui-datepicker-next').html('<i class="icon-chevron-right"></i>');
        }, 0);
    }

    // initialize date/datetime/time pickers
    body.on('calendarsinit', function(e) 
    {
        var block = jQuery(e.target);

        var options = 
        {
            timeFormat: 'HH:mm:ss',
            controlType: 'select',
            showHour: true,
            showMinute: true,
            changeMonth: true,
            changeYear: true,
            beforeShow: function(input, instance) {
                chevron_icons_show( instance );
            },
            onChangeMonthYear: function(year, month, instance)
            {
                chevron_icons_show( instance );
            }
            // showSecond: true,
            // showTimezone: true,
        }

        block.find('.date_picker').each(function() {
            var picker = jQuery(this);
            var opt = options;
            opt['dateFormat'] = picker.attr('data-date-format') || 'yy-mm-dd';
            picker.datepicker(opt);
        });

        block.find('.datetime_picker').each(function() {
            var picker = jQuery(this);
            var opt = options;
            opt['dateFormat'] = picker.attr('data-date-format') || 'yy-mm-dd';
            opt['pickerTimeFormat'] = picker.attr('data-time-format') || 'HH:mm'
            picker.datetimepicker(opt);
        });

        /*
         * block.find('.time_picker').each(function() {
         *     var picker = jQuery(this);
         *     var opt = options;
         *     opt['pickerTimeFormat'] = picker.attr('data-time-format') || 'HH:mm'
         *     picker.timepicker(options);
         * });
         */
    });


    body.on('contentloaded', function(e)
    {
        jQuery(e.target).trigger('calendarsinit');
    });
    

});
