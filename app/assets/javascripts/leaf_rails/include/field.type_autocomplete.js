//= require yui
//= require ../lib/request_url

YUI().use('node', 'event', 'autocomplete', 'autocomplete-highlighters', function (Y) {
    var init_autocomplete = function(scope) {
        Y.all(scope).each(function(element) {
            element.all('.field.type_autocomplete:not(.initialized)').each(function(field_wrap) {
                field_wrap.addClass('initialized');
                var field = field_wrap.one('input[type="text"]');
                var hidden = field_wrap.one('input[type="hidden"]');
                var expand_icon = field_wrap.one('.autocomplete_expand_icon');

                field.plug(Y.Plugin.AutoComplete, {
                    resultHighlighter: 'subWordMatch',
                    resultListLocator: 'results',
                    resultTextLocator: 'text',
                    minQueryLength: 1,
                    source: new RequestUrl(field.getData('autocomplete-url')).add({'q': '{query}'}).getUrl(),
                    on: {
                        select: function (itemNode, object) {
                            hidden.set('value', itemNode.result.raw.id);
                        }
                    }
                    /*
                    * after: {
                    *     resultsChange: function (e) {
                    *         console.debug(e);
                    *     }
                    * }
                    */
                });

                field.on('change', function() {
                    hidden.set('value', null);
                });

                var autocomplete_click = function() {
                    if (field.ac.get('visible')) {
                        field.ac.hide();
                    }
                    else {
                        field.ac.sendRequest(field.value);
                    }
                }

                expand_icon.on('click', autocomplete_click);
                field.on('focus', autocomplete_click);
            });
        });
    }

    Y.on('click', function(e) {
        init_autocomplete(e.target);
    }, 'body');

    init_autocomplete('body');

});
