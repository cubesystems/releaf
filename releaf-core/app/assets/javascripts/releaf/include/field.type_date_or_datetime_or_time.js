jQuery(document).ready(function()
{
    var body = jQuery('body');

    var chevron_icons_show = function( instance )
    {
        // Set timeout to execute this after datepicker has been initialized
        setTimeout( function() {
            jQuery(instance.dpDiv[0]).find('.ui-datepicker-prev').removeClass().addClass('button only-icon previous').html('<i class="fa fa-chevron-left"></i>');
            jQuery(instance.dpDiv[0]).find('.ui-datepicker-next').removeClass().addClass('button only-icon next').html('<i class="fa fa-chevron-right"></i>');
        }, 0);
    };

    // initialize date/datetime/time pickers
    body.on('calendarsinit', function(e)
    {
        var block = jQuery(e.target);

        var options =
        {
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
        };

        block.find('.date-picker, .datetime-picker, .time-picker').each(function()
        {
            var picker = jQuery(this);
            var opt = options;

            opt.dateFormat = picker.data('date-format') || 'yy-mm-dd';
            opt.pickerTimeFormat = picker.data('time-format') || 'HH:mm';
            opt.minDate = picker.data('min-date');
            opt.maxDate = picker.data('max-date');
            var yearRange = picker.data('year-range');
            if (yearRange)
            {
                opt.yearRange = yearRange;
            }

            if (picker.is('.date-picker'))
            {
                picker.datepicker(opt);
            }
            else if (picker.is('.datetime-picker'))
            {
                picker.datetimepicker(opt);
            }
            else if (picker.is('.time-picker'))
            {
                picker.timepicker(opt);
            }
        });

    });

    body.on('contentloaded', function(e)
    {
        jQuery(e.target).trigger('calendarsinit');
    });

});
