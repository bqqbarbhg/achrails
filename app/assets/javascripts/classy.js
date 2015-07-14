/*
 * Helper for managing classes.
 *
 * Creating a schema:
 *    var classyForSchema = beClassy({
 *         flag: "flagTrue",
 *         toggle: ["toggleFalse", "toggleTrue"],
 *         select: ["select0", "select1", "select2"],
 *     });
 *
 * Setting classes:
 *     classyForSchema(element, { flag: true, toggle: false, select: 2 });
 * or
 *     classyForSchema.flag(element, false)
 *
 *
 * Getting classes:
 *     classyForSchema(element).flag // checks all the classes
 * or
 *     classyForSchema.flag(element) // checks one class
 */

function beClassy(schema) {

    var getClass = function(cl, classes) {
        if (Array.isArray(classes)) {
            for (var i = 0; i < classes.length; i++) {
                if (cl.contains(classes[i])) return i;
            }
            return -1;
        } else {
            return cl.contains(classes);
        }
    }

    var setClass = function(cl, classes, value) {
        if (Array.isArray(classes)) {
            var index = value | 0;
            for (var i = 0; i < classes.length; i++) {
                if (i == index) cl.add(classes[i]);
                else            cl.remove(classes[i]);
            }
        } else {
            if (value) cl.add(classes);
            else       cl.remove(classes);
        }
    }

    var attr = function(key) {
        return function(element, value) {
            if (value !== undefined) {
                setClass(element.classList, schema[key], value);
            } else {
                return getClass(element.classList, schema[key]);
            }
        }
    }

    var func = function(element, options) {
        var cl = element.classList;

        if (options !== undefined) {
            for (var key in options) {
                if (!schema.hasOwnProperty(key)) continue;
                setClass(cl, schema[key], options[key]);
            }
        } else {
            var ret = { };
            for (var key in schema) {
                if (!schema.hasOwnProperty(key)) continue;
                ret[key] = getClass(cl, schema[key]);
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
