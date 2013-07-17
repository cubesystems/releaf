jQuery(document).ready(function() {

    var chevronIconsShow = function( instance ) {
        // Set timeout to execute this after datepicker has been initialized
        setTimeout( function() {
            jQuery(instance.dpDiv[0]).find('.ui-datepicker-prev').html('<i class="icon-chevron-left"></i>');
            jQuery(instance.dpDiv[0]).find('.ui-datepicker-next').html('<i class="icon-chevron-right"></i>');
        }, 0);
    }

    // initialize date/datetime/time pickers
    jQuery(document.body).delegate('form', 'initcalendars', function() {
        var forms = jQuery(this);
        var options = {
            timeFormat: 'HH:mm:ss',
            controlType: 'select',
            showHour: true,
            showMinute: true,
            changeMonth: true,
            changeYear: true,
            beforeShow: function(input, instance) {
                chevronIconsShow( instance );
            },
            onChangeMonthYear: function(year, month, instance)
            {
                chevronIconsShow( instance );
            }
            // showSecond: true,
            // showTimezone: true,
        }

        forms.find('.date_picker').each(function() {
            var picker = jQuery(this);
            var opt = options;
            opt['dateFormat'] = picker.attr('data-date-format') || 'yy-mm-dd';
            picker.datepicker(opt);
        });

        forms.find('.datetime_picker').each(function() {
            var picker = jQuery(this);
            var opt = options;
            opt['dateFormat'] = picker.attr('data-date-format') || 'yy-mm-dd';
            opt['pickerTimeFormat'] = picker.attr('data-time-format') || 'HH:mm'
            picker.datetimepicker(opt);
        });

        /*
         * forms.find('.time_picker').each(function() {
         *     var picker = jQuery(this);
         *     var opt = options;
         *     opt['pickerTimeFormat'] = picker.attr('data-time-format') || 'HH:mm'
         *     picker.timepicker(options);
         * });
         */
    });


    jQuery('form').trigger('initcalendars');

});
