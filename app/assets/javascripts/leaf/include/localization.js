jQuery(document).ready(function() {
    jQuery('form').on('click', 'button[data-locale]', function(e) {
        var form = jQuery(e.delegateTarget);
        var button = jQuery(e.currentTarget);
        var locale = button.attr('data-locale')

        form.find('.localization[data-locale]').hide();
        form.find('button[data-locale]').removeClass('active');
        form.find('button[data-locale="' + locale + '"]').addClass('active');
        form.find('.localization[data-locale="' + locale + '"]').show();
    });
});
