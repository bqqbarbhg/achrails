
function applyDeferredStyles()
{
    $("[data-defer-style]").each(function() {
        var $elem = $(this);
        var deferStyle = $elem.attr("data-defer-style");

        var css = this.style.cssText;
        if (css.length > 0 && css.endsWith(';')) {
            css += ';';
        }
        css += deferStyle;
        this.style.cssText = css;
    });
}

window.addEventListener('load', applyDeferredStyles);

