if ((document) && (document.getElementById)) {
    var jsClassName = 'javascriptOn';
    if (document.body.className)
    {
        jsClassName = ' '.concat(jsClassName);
    }
    document.body.className = document.body.className.concat(jsClassName);
}
