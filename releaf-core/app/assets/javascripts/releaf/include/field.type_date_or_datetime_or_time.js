jQuery(document).ready(function()
{
    var body = jQuery('body');

    var chevron_icons_show = function( instance )
    {
        // Set timeout to execute this after datepicker has been initialized
        setTimeout( function() {
            jQuery(instance.dpDiv[0]).find('.ui-datepicker-prev').html('<i class="fa fa-chevron-left"></i>');
            jQuery(instance.dpDiv[0]).find('.ui-datepicker-next').html('<i class="fa fa-chevron-right"></i>');
        }, 0);
    }

    var get_date_limit = function(value)
    {
        if (!value) return null;
        var offset_pattern = /^[+-]?\d+$/;
        if (offset_pattern.test(value))
        {
            return value;
        }
        return null;
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

            opt['minDate'] = get_date_limit(picker.attr('data-min-date'));
            opt['maxDate'] = get_date_limit(picker.attr('data-max-date'));

            picker.datepicker(opt);
        });

        block.find('.datetime_picker').each(function() {
            var picker = jQuery(this);
            var opt = options;
            opt['dateFormat'] = picker.attr('data-date-format') || 'yy-mm-dd';
            opt['pickerTimeFormat'] = picker.attr('data-time-format') || 'HH:mm'

            opt['minDate'] = get_date_limit(picker.attr('data-min-date'));
            opt['maxDate'] = get_date_limit(picker.attr('data-max-date'));

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
