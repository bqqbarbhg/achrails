// Since we are not providing an action, this is called a toast.
function createToast(message) {
  'use strict';
  if (typeof Android != "undefined"){
    Android.showToast(toast);
    return;
  }
  var snackbar = document.createElement('div'),
      text = document.createElement('div');
  snackbar.classList.add('mdl-snackbar');
  text.classList.add('mdl-snackbar__text');
  text.innerText = message;
  snackbar.appendChild(text);
  document.body.appendChild(snackbar);
  // Remove after 10 seconds
  setTimeout(function(){
    $(snackbar).fadeOut("normal", function() {
        $(this).remove();
    });
  }, 3000);
}

function closeActivity() {
    if (typeof Android != "undefined") {
        Android.closeActivity();
    }
}

function iosLoaded() {
  // The iOS embedded environment has a header already, so hide the page one.
  $('header').hide();
  $('.hide-on-ios').hide();

  // The title to display in the iOS NavigationController.
  var title = $('.mdl-layout-title').text().trim();
  window.webkit.messageHandlers.setTitle.postMessage(title);
}

function fitInParent(element, focus, doFill, aspect, state) {

    var parentElement = element.parentElement;
    var parentWidth = parentElement.clientWidth;
    var parentHeight = parentElement.clientHeight;

    if (state) {
        if (state.oldWidth == parentWidth && state.oldHeight == parentHeight)
            return;
        state.oldWidth = parentWidth;
        state.oldHeight = parentHeight;
    }

    var parentAspect = parentWidth / parentHeight;

    var resultWidth, resultHeight;
    if ((parentAspect > aspect) == doFill) {
        resultWidth = parentWidth;
        resultHeight = parentWidth / aspect;
    } else {
        resultHeight = parentHeight;
        resultWidth = parentHeight * aspect;
    }

    focus = focus || { x: 0.5, y: 0.5 };
    var offsetX = (resultWidth - parentWidth) * focus.x;
    var offsetY = (resultHeight - parentHeight) * focus.y;

    element.style.width = resultWidth + "px";
    element.style.height = resultHeight + "px";
    element.style.left = -offsetX + "px";
    element.style.top = -offsetY + "px";
}

function containInParentWithAspect(element, aspect, focus, state) {
  fitInParent(element, focus, false, aspect, state);
}

function fillParentWithAspect(element, aspect, focus, state) {
  fitInParent(element, focus, true, aspect, state);
}

function containInParent(element, focus, state) {
  var aspect = element.clientWidth / element.clientHeight;
  containInParentWithAspect(element, aspect, focus, state);
}

function fillParent(element, focus, state) {
  var aspect = element.clientWidth / element.clientHeight;
  fillParentWithAspect(element, aspect, focus, state);
}

var global_get_http = null;

function getHTTP() {

  if (!global_get_http) {
    var token = $('meta[name=csrf-token]').attr('content');
    global_get_http = new HTTP();
    global_get_http.globalHeader("X-CSRF-Token", token);
  }

  return global_get_http;
}

function replaceContentWithXHR(xhr) {
  document.open();
  document.write(xhr.response);
  document.close();
}

