
function VideoFrameRenderer(options) {
    this.viewWidth = options.width;
    this.viewHeight = options.height;
    this.viewAspect = this.viewWidth / this.viewHeight;

    this.video = document.createElement("video");

    this.metadataListener = this.onMetadata.bind(this);
    this.seekedListener = this.onSeeked.bind(this);

    this.work = null;
    this.times = [];
    this.frameIndex = 0;
}

VideoFrameRenderer.prototype.wakeUp = function(queue) {
    this.queue = queue;
    this.video.addEventListener("loadedmetadata", this.metadataListener);
    this.video.addEventListener("seeked", this.seekedListener);
};

VideoFrameRenderer.prototype.sleep = function() {
    this.video.removeEventListener("loadedmetadata", this.metadataListener);
    this.video.removeEventListener("seeked", this.seekedListener);
    this.video.src = "";
};

VideoFrameRenderer.prototype.doWork = function(work) {
    this.work = work;
    this.frameIndex = 0;
    this.video.src = this.work.manifest.videoUri;
};

VideoFrameRenderer.prototype.onMetadata = function() {
    var videoWidth = this.video.videoWidth;
    var videoHeight = this.video.videoHeight;
    var videoAspect = videoWidth / videoHeight;

    if (videoAspect > this.viewAspect) {
        this.drawWidth = this.viewWidth;
        this.drawHeight = this.viewWidth / videoAspect;
    } else {
        this.drawHeight = this.viewHeight;
        this.drawWidth = this.viewHeight * videoAspect;
    }

    var duration = this.video.duration;

    this.times = findAnnotationMatches(this.work.manifest, query, duration);
    this.index = 0;

    this.renderNextFrame();
};

VideoFrameRenderer.prototype.renderNextFrame = function() {
    if (this.frameIndex >= this.work.count) {
        this.queue.findWork(this);
        return;
    }

    this.time = this.times[this.work.start + this.frameIndex];
    this.container = this.work.containers[this.frameIndex];
    this.frameIndex++;

    var seekTime = this.time;
    if (seekTime < 0.01)
        seekTime = 0.01;

    this.video.currentTime = seekTime;
};

VideoFrameRenderer.prototype.onSeeked = function() {

    var container = this.container;

    var posX = this.viewWidth * 0.5 - this.drawWidth * 0.5;
    var posY = this.viewHeight * 0.5 - this.drawHeight * 0.5;

    var canvas = document.createElement("canvas");
    canvas.width = this.drawWidth;
    canvas.height = this.drawHeight;
    canvas.style.left = Math.round(posX) + "px";
    canvas.style.top = Math.round(posY) + "px";
    canvas.classList.add("search-canvas");
    canvas.classList.add("search-invisible");

    var subtitles = document.createElement('div');
    subtitles.classList.add('search-subtitles');
    subtitles.classList.add("search-invisible");

    var manifest = this.work.manifest;

    var ctx = canvas.getContext("2d");
    var annotationGradient = createAnnotationGradient(ctx);

    ctx.drawImage(this.video, 0, 0, this.drawWidth, this.drawHeight);

    var subtitleList = [];

    for (var i = 0; i < manifest.annotations.length; i++) {
        var annotation = manifest.annotations[i];
        var time = annotation.time / 1000.0;

        if (Math.abs(time - this.time) > 0.1)
            continue;

        var ax = annotation.position.x;
        var ay = annotation.position.y;

        var x = ax * this.drawWidth;
        var y = ay * this.drawHeight;

        ctx.save();
        ctx.translate(x - 25, y - 25);
        ctx.fillStyle = annotationGradient;
        ctx.fillRect(0, 0, 50, 50);
        ctx.restore();

        var text = annotation.text;

        var content = '';
        var startIndex = annotation.text.toLowerCase().indexOf(query.toLowerCase());

        if (startIndex >= 0) {
            var endIndex = startIndex + query.length;
            content += text.substring(0, startIndex);
            content += '<span class="search-subtitles-marked">';
            content += text.substring(startIndex, endIndex);
            content += '</span>';
            content += text.substring(endIndex);
        } else {
            content = text;
        }

        subtitleList.push(content);
    }

    subtitles.innerHTML = subtitleList.join('<br>');

    container.appendChild(canvas);
    container.appendChild(subtitles);
    container.parentElement.href = ('/videos/' + this.work.manifest.id
        + '#t=' + this.time.toFixed(2) + 's');

    window.setTimeout(function() {
        canvas.classList.remove("search-invisible");
        subtitles.classList.remove("search-invisible");
    }, 10);

    this.renderNextFrame();
};

