/* global UrlBuilder */

jQuery(function ($) {
    'use strict';

    var $body = $('body');

    $body.on('searchinit', 'form', function (e) {
        var request;
        var timeout;
        var $form = $(e.target);

        // Set up options.
        var options = $form.data('search-options');
        var defaults = {
            resultBlocks: {
                mainSection: {
                    resultSelector : 'section',
                    target : 'main > section:first'
                }
            },
            rebind: false
        };

        options = $.extend(true, defaults, options);

        var allSelector  = 'input, select';

        var elements = {
            inputs: $(),
            submit: $()
        };

        var collectAllElements = function () {
            elements.$inputs = $(allSelector);
            elements.$submit = $form.find('button[type="submit"]');
        };

        var doSearch = function () {
            // Cancel previous timeout.
            clearTimeout(timeout);

            // Store previous values for all inputs.
            elements.$inputs.each(function () {
                var $input = $(this);
                if ($input.is('input[type="checkbox"]:not(:checked)')) {
                    $input.data('previous-value', '');
                }
                else if(!($input.is('input[type="checkbox"]:checked'))) {
                    $input.data('previous-value', $input.val());
                } else {
                    $input.data('previous-value', $input.val() || '');
                }
            });

            // Cancel previous unfinished request.
            if (request) {
                request.abort();
            }

            timeout = setTimeout(function () {
                elements.$submit.trigger('loadingstart');

                // Construct url.
                var formUrl = $form.attr('action');
                var url = new UrlBuilder({ baseUrl: formUrl });
                url.add($form.serializeArray());

                if ('replaceState' in window.history) {
                    window.history.replaceState(window.history.state, window.title, url.getUrl());
                }

                url.add({ ajax: 1 });

                // Send request.
                request = $.ajax({
                    url: url.getUrl(),
                    success: function (response) {
                        $form.trigger('searchresponse', response);
                        $form.trigger('searchend');
                    }
                });
            }, 200);
        };

        var startSearchIfValueChanged = function () {
            var $input = $(this);
            var previousValue = $input.data('previous-value');

            if ($input.val() === previousValue) {
                return;
            }

            doSearch();
        };


        $form.on('searchresponse', function (e, response) {
            var $response = $('<div />').append(response);

            // For each result block find its content in response and copy it
            // to its target container.

            for (var key in options.resultBlocks)
            {
                if (options.resultBlocks.hasOwnProperty(key))
                {
                    var block = options.resultBlocks[key];
                    var content = $response.find(block.resultSelector).first().html();

                    $(block.target).html(content);
                    $(block.target).trigger('contentloaded');
                }
            }

            collectAllElements();
        });

        $form.on('searchend', function () {
            elements.$submit.trigger('loadingend');
        });

        $form.on('change keyup', allSelector, startSearchIfValueChanged);

        collectAllElements();
    });

    $('.view-index form.search').trigger('searchinit');
});
