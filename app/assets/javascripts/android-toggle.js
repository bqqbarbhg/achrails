;$(document).ready(function() {
    if (typeof Android !== 'undefined') {
        $('.hide-on-android').hide();
        $('.show-on-android').show();
    } else {
        $('.hide-on-android').show();
        $('.show-on-android').hide();
    }
});