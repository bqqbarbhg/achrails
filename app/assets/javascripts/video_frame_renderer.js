
function VideoFrameRenderer(options) {
    this.options = options || { };
    this.video = document.createElement("video");

    this.errorListener = this.onError.bind(this);
    this.metadataListener = this.onMetadata.bind(this);
    this.seekedListener = this.onSeeked.bind(this);

    this.work = null;
    this.frames = [];
    this.frameIndex = 0;
}

VideoFrameRenderer.prototype.wakeUp = function(queue) {
    this.queue = queue;
    this.video.addEventListener("error", this.errorListener);
    this.video.addEventListener("loadedmetadata", this.metadataListener);
    this.video.addEventListener("seeked", this.seekedListener);
};

VideoFrameRenderer.prototype.sleep = function() {
    this.video.removeEventListener("error", this.errorListener);
    this.video.removeEventListener("loadedmetadata", this.metadataListener);
    this.video.removeEventListener("seeked", this.seekedListener);
    this.video.src = "";
};

VideoFrameRenderer.prototype.onError = function(work) {
    this.queue.findWork(this);
};

VideoFrameRenderer.prototype.doWork = function(work) {
    this.work = work;
    this.frameIndex = 0;
    this.video.src = this.work.video;
    this.canvases = this.work.canvases || [this.work.canvas];
};

VideoFrameRenderer.prototype.onMetadata = function() {
    var duration = this.video.duration;

    this.frames = this.work.timesCallback(this.work, duration);
    this.frameIndex = 0;

    this.renderNextFrame();
};

VideoFrameRenderer.prototype.renderNextFrame = function() {
    if (this.frameIndex >= this.frames.length) {
        this.queue.findWork(this);
        return;
    }

    this.frame = this.frames[this.frameIndex];
    this.canvas = this.canvases[this.frameIndex];

    this.frame.canvas = this.canvas;
    this.frame.index = this.frameIndex;

    this.frameIndex++;

    this.resolution = this.frame.resolution || this.work.resolution || this.options.resolution || 1280;

    var seekTime = this.frame.time;
    if (seekTime < 0.01)
        seekTime = 0.01;

    this.video.currentTime = seekTime;
};

VideoFrameRenderer.prototype.createAnnotationGradient = function(ctx, size) {
    var half = size / 2.0;
    var g = ctx.createRadialGradient(half, half, 0, half, half, half);

    g.addColorStop(0.37, 'rgba(255,255,255, 0.0)');
    g.addColorStop(0.40, 'rgba(255,255,255, 0.9)');
    g.addColorStop(0.45, 'rgba(255,255,255, 0.9)');
    g.addColorStop(0.47, 'rgba(68,153,136, 0.8)');
    g.addColorStop(0.53, 'rgba(68,153,136, 0.4)');
    g.addColorStop(0.55, 'rgba(68,153,136, 0.0)');
    g.addColorStop(0.56, 'rgba(68,153,136, 0.0)');
    g.addColorStop(0.60, 'rgba(85,204,153, 0.9)');
    g.addColorStop(0.62, 'rgba(85,204,153, 0.9)');
    g.addColorStop(0.66, 'rgba(85,204,153, 0.0)');

    return g;
};

VideoFrameRenderer.prototype.onSeeked = function() {

    var maxSize = Math.max(this.video.videoWidth, this.video.videoHeight);
    var scale = Math.min(1.0, this.resolution / maxSize);

    var canvas = this.canvas;
    canvas.width = Math.round(this.video.videoWidth * scale);
    canvas.height = Math.round(this.video.videoHeight * scale);

    var ctx = canvas.getContext("2d");

    ctx.drawImage(this.video, 0, 0, canvas.width, canvas.height);

    var annotations = this.frame.annotations;

    if (annotations) {
        var annotationSize = Math.min(canvas.width, canvas.height) * 0.2;
        var annotationGradient = this.createAnnotationGradient(ctx, annotationSize);

        for (var i = 0; i < annotations.length; i++) {
            var annotation = annotations[i];

            var x = annotation.position.x * canvas.width;
            var y = annotation.position.y * canvas.height;

            ctx.save();
            ctx.translate(x - annotationSize / 2.0, y - annotationSize / 2.0);
            ctx.fillStyle = annotationGradient;
            ctx.fillRect(0, 0, annotationSize, annotationSize);
            ctx.restore();
        }
    }

    this.work.doneCallback(this.work, this.frame);
    this.renderNextFrame();
};

