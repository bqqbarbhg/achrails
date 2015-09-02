
// Clamp a number to range [min, max]
function clamp(number, min, max) {
    return Math.min(Math.max(number, min), max);
}

// Escape string so that it can be set to innerHTML of a node.
function stringToHTMLSafe(str) {
    var escapes = {
        '<': '&lt;',
        '>': '&gt;',
        '&': '&amp;',
        '"': '&quot;',
        '\'': '&apos;',
        '\n': '<br>',
    };
    
    return str.replace(/[<>&"'\n]/g, function(match) {
        return escapes[match];
    });
}

// Turn decimal [0.0, 1.0] to CSS percent value [0%, 100%]
function cssPercent(value) {
    return (value * 100) + "%";
}

// Visualize data with DOM elements
// Data items are converted to DOM elements created by `newElement` and
// mutated by `toElement`.
function DomView(opts)
{
    this.elements = [];
    this.container = opts.container;
    this.newElement = opts.newElement;
    this.toElement = opts.toElement;
    return this;
}

// Provide array of data to visualize.
DomView.prototype.update = function(data)
{
    while (this.elements.length < data.length) {
        var element = this.newElement();
        element.style.visibility = "hidden";
        this.container.appendChild(element);
        this.elements.push(element);
    }

    for (var i = data.length; i < this.elements.length; i++) {
        this.elements[i].style.visibility = "hidden";
    }

    for (var i = 0; i < data.length; i++) {
        this.toElement(this.elements[i], data[i]);
        this.elements[i].style.visibility = "visible";
    }
};

function elemWithClasses(type) {
    var div = document.createElement(type);
    for (var i = 1; i < arguments.length; i++) {
        div.classList.add(arguments[i]);
    }
    return div;
}

function getTimeSeconds() {
    return new Date().getTime() / 1000.0;
}

/**
 * Retrieve the coordinates of the given event relative to the center
 * of the widget.
 *
 * @param event
 *   A mouse-related DOM event.
 * @param reference
 *   A DOM element whose position we want to transform the mouse coordinates to.
 * @return
 *    A hash containing keys 'x' and 'y'.
 */
function getRelativeCoordinates(event, reference) {
    var x, y;
    event = event || window.event;
    var el = event.target || event.srcElement;

    if (!window.opera && typeof event.offsetX != 'undefined') {
        // Use offset coordinates and find common offsetParent
        var pos = { x: event.offsetX, y: event.offsetY };

        // Send the coordinates upwards through the offsetParent chain.
        var e = el;
        while (e) {
            e.mouseX = pos.x;
            e.mouseY = pos.y;
            pos.x += e.offsetLeft;
            pos.y += e.offsetTop;
            e = e.offsetParent;
        }

        // Look for the coordinates starting from the reference element.
        var e = reference;
        var offset = { x: 0, y: 0 }
        while (e) {
            if (typeof e.mouseX != 'undefined') {
                x = e.mouseX - offset.x;
                y = e.mouseY - offset.y;
                break;
            }
            offset.x += e.offsetLeft;
            offset.y += e.offsetTop;
            e = e.offsetParent;
        }

        // Reset stored coordinates
        e = el;
        while (e) {
            e.mouseX = undefined;
            e.mouseY = undefined;
            e = e.offsetParent;
        }
    }
    else {
        // Use absolute coordinates
        var pos = getAbsolutePosition(reference);
        x = event.pageX  - pos.x;
        y = event.pageY - pos.y;
    }
    // Subtract distance to middle
    return { x: x, y: y };
}

var MouseState = {
    Up: 1,
    Move: 2,
    Down: 3,
};

function relativeClickHandler(element, callback) {
    var data = { down: false };
    var mouseCallback = function(state) {
        return function(e) {

            if (state == MouseState.Down) {
                if (data.down)
                    return false;
                data.down = true;
            } else if (state == MouseState.Up) {
                if (!data.down)
                    return false;
                data.down = false;
            } else if (state == MouseState.Move) {
                if (!data.down)
                    return;
            }

            var width = element.clientWidth || element.offsetWidth || 10000;
            var height = element.clientHeight || element.offsetHeight || 10000;

            var relative = getRelativeCoordinates(e, element);
            relative.x /= width;
            relative.y /= height;

            if (relative.x < 0) relative.x = 0;
            if (relative.y < 0) relative.y = 0;
            if (relative.x >= 1) relative.x = 1;
            if (relative.y >= 1) relative.y = 1;
            callback(state, relative);
        }
    };
    element.addEventListener('mousedown', mouseCallback(MouseState.Down));
    element.addEventListener('mousemove', mouseCallback(MouseState.Move));
    element.addEventListener('mouseup', mouseCallback(MouseState.Up));
    element.addEventListener('mouseout', mouseCallback(MouseState.Up));
}

