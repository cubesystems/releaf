// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require 3rd_party/jquery-ui

jQuery(document).ready(function() {
    jQuery('form').on('click', 'button.destroy_nested', function(){
        var button = jQuery(this);
        var hidden_field = button.siblings('input.destroy_nested[type="hidden"]');
        button.parents('.nested').first().animate({ height: 'hide', opacity: 'hide' }, 'fast', '', function(){
            jQuery(this).hide();
        });
        hidden_field.attr('value', 'true');
        return false;
    }).on('click', 'button.remove_new', function(){
        var button = jQuery(this);
        button.parents('.nested').first().animate({ height: 'hide', opacity: 'hide' }, 'fast', '', function(){
            jQuery(this).remove();
        });
        return false;
    }).on('click', '.add_nested_fields', function(){
        var time = new Date().getTime();
        var regexp = new RegExp(jQuery(this).data('id'), 'g');
        var template = jQuery(jQuery(this).data('fields').replace(regexp, time));
        template.hide();
        jQuery(this).before(template);
        template.animate({ height: "show", opacity: "show" }, 'fast');
        return false;
    });
});


