function beClassy(schema) {
    return function(element, options) {
        var cl = element.classList;
        for (var key in schema) {
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
    }
}
