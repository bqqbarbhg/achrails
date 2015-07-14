function beClassy(schema) {
    var attr = function(key) {
        return function(element, value) {
            var cl = element.classList;
            var classes = schema[key];

            if (value !== undefined) {
                if (Array.isArray(classes)) {
                    var index = value | 0;
                    for (var i = 0; i < classes.length; i++) {
                        if (i == index) {
                            cl.add(classes[i]);
                        } else {
                            cl.remove(classes[i]);
                        }
                    }
                } else {
                    if (value) {
                        cl.add(classes);
                    } else {
                        cl.remove(classes);
                    }
                }
            } else {
                if (Array.isArray(classes)) {
                    for (var i = 0; i < classes.length; i++) {
                        if (cl.contains(classes[i])) {
                            return i;
                        }
                    }
                    return -1;
                } else {
                    return cl.contains(classes);
                }
            }
        }
    }

    var func = function(element, options) {
        var cl = element.classList;

        if (options !== undefined) {
            for (var key in options) {
                if (!schema.hasOwnProperty(key)) continue;

                var classes = schema[key];
                var val = options[key] || 0;
                if (Array.isArray(classes)) {
                    var index = val | 0;
                    for (var i = 0; i < classes.length; i++) {
                        if (i == index) {
                            cl.add(classes[i]);
                        } else {
                            cl.remove(classes[i]);
                        }
                    }
                } else {
                    if (val) {
                        cl.add(classes);
                    } else {
                        cl.remove(classes);
                    }
                }
            }
        } else {
            var ret = { };
            for (var key in schema) {
                if (!schema.hasOwnProperty(key)) continue;

                var classes = schema[key];
                if (Array.isArray(classes)) {
                    ret[key] = -1;
                    for (var i = 0; i < classes.length; i++) {
                        if (cl.contains(classes[i])) {
                            ret[key] = i;
                        }
                    }
                } else {
                    ret[key] = cl.contains(classes);
                }
            }
            return ret;
        }
    }

    for (var key in schema) {
        if (!schema.hasOwnProperty(key)) continue;
        func[key] = attr(key);
    }

    return func;
}
