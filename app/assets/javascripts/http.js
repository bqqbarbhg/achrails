
function HTTP() {
    this.globalHeaders = [];
}

HTTP.prototype.request = function(method, url, body, options) {
    options = options || { };
    var success = options.success || _.noop;
    var error = options.error || _.noop;
    var headers = options.headers || { };
    var auth = options.auth || { user: '', password: '' };

    var xhr = new XMLHttpRequest();

    xhr.open(method, url, true, auth.user, auth.password);

    _.forOwn(headers, function (value, key) {
        if (_.isArray(value)) {
            _.forEach(value, function(val) {
                xhr.setRequestHeader(key, val);
            });
        } else {
            xhr.setRequestHeader(key, value);
        }
    });

    _.forEach(this.globalHeaders, function(header) {
        xhr.setRequestHeader(header[0], header[1]);
    });

    xhr.onreadystatechange = function() {
        if (xhr.readyState != 4) {
            return;
        }
        if (xhr.status >= 200 && xhr.status < 300) {
            success(xhr);
        } else {
            error(xhr);
        }
    };

    if (body) {
        xhr.send(body);
    } else {
        xhr.send();
    }

    return xhr;
};

HTTP.prototype.get = function(url, options) {
    this.request('GET', url, null, options);
};
HTTP.prototype.post = function(url, body, options) {
    this.request('POST', url, body, options);
};
HTTP.prototype.put = function(url, body, options) {
    this.request('PUT', url, body, options);
};
HTTP.prototype.patch = function(url, body, options) {
    this.request('PATCH', url, body, options);
};
HTTP.prototype.delete_ = function(url, options) {
    this.request('DELETE', url, null, options);
};

HTTP.prototype.getJson = function(url, body, options) {
    options = options || { };
    options.headers = _.assign(options.headers || { }, {
       "Accept": "application/json",
    });
    this.get(url, options);
};
HTTP.prototype.postJson = function(url, body, options) {
    options = options || { };
    options.headers = _.assign(options.headers || { }, {
       "Content-Type": "application/json",
       "Accept": "application/json",
    });
    this.post(url, JSON.stringify(body), options);
};
HTTP.prototype.putJson = function(url, body, options) {
    options = options || { };
    options.headers = _.assign(options.headers || { }, {
       "Content-Type": "application/json",
       "Accept": "application/json",
    });
    this.put(url, JSON.stringify(body), options);
};
HTTP.prototype.patchJson = function(url, body, options) {
    options = options || { };
    options.headers = _.assign(options.headers || { }, {
       "Content-Type": "application/json",
       "Accept": "application/json",
    });
    this.patch(url, JSON.stringify(body), options);
};
HTTP.prototype.deleteJson = function(url, options) {
    options = options || { };
    options.headers = _.assign(options.headers || { }, {
       "Accept": "application/json",
    });
    this.delete_(url, options);
};

HTTP.prototype.globalHeader = function(header, value) {
    this.globalHeaders.push([header, value]);
}

