
AchSoPlayer.prototype.startModel = function(data) {
    this.batches = [];
    this.data = data;
    this.time = 0.0;
    this.annotationSelectRadius = 50.0;
    this.annotationDragDeadZone = 10.0;

    if (data.annotations) {
        for (var i = 0; i < data.annotations.length; i++) {
            this.addAnnotation(this.importAnnotation(data.annotations[i]));
        }
    }
};

AchSoPlayer.prototype.importAnnotation = function(annotation) {
    return {
        pos: annotation.position,
        text: annotation.text,
        time: annotation.time / 1000.0,
    };
};

AchSoPlayer.prototype.allowEdit = function() {
    return true;
};

AchSoPlayer.prototype.batchAt = function(time) {
    var closest = null;
    var dist = 0.5;
    for (var i = 0; i < this.batches.length; i++) {
        var diff = Math.abs(this.batches[i].time - time);
        if (diff < dist) {
            dist = diff;
            closest = this.batches[i];
        }
    }
    return closest;
};

AchSoPlayer.prototype.batchBetween = function(start, end) {
    for (var i = 0; i < this.batches.length; i++) {
        var time = this.batches[i].time;
        if (start < time && time <= end) {
            return this.batches[i];
        } else if (end < time) {
            break;
        }
    }
    return null;
};

AchSoPlayer.prototype.createBatch = function(time) {
    var i;
    for (i = 0; i < this.batches.length; i++) {
        if (this.batches[i].time > time)
            break;
    }
    var batch = {
        time: time,
        annotations: [],
    };
    this.batches.splice(i, 0, batch);

    this.updateSeekBarView();
    return batch;
};

AchSoPlayer.prototype.setBatch = function(batch) {
    this.batch = batch;
    this.updateAnnotationView();
};

AchSoPlayer.prototype.findOrCreateAnnotation = function(pos) {
    var batch = this.batch;
    var annotations = batch.annotations;

    var closest = null;
    var closestDist = Math.pow(this.annotationSelectRadius, 2);
    for (var i = 0; i < annotations.length; i++) {
        var annotation = annotations[i];

        var dx = (annotation.pos.x - pos.x) * this.videoWidth;
        var dy = (annotation.pos.y - pos.y) * this.videoHeight;
        var dist = dx * dx + dy * dy;

        if (dist < closestDist) {
            closestDist = dist;
            closest = annotation;
        }
    }

    if (closest) {
        return { annotation: closest, isNew: false };
    }

    var newAnnotation = {
        pos: { x: pos.x, y: pos.y },
        time: batch.time,
        text: '',
    };
    batch.annotations.push(newAnnotation);
    return { annotation: newAnnotation, isNew: true };
};

AchSoPlayer.prototype.findOrCreateBatch = function(time) {
    var batch = this.batchAt(time);
    if (!batch) {
        batch = this.createBatch(time);
    }
    return batch;
};

AchSoPlayer.prototype.addAnnotation = function(annotation) {
    var batch = this.findOrCreateBatch(annotation.time);
    batch.annotations.push(annotation);
};

AchSoPlayer.prototype.deleteAnnotation = function(annotation) {
    var batch = this.batchAt(annotation.time);
    if (!batch) return;
    var index = batch.annotations.indexOf(annotation);
    if (index < 0) return;
    batch.annotations.splice(index, 1);

    if (batch.annotations.length > 0)
        return;
    
    var batchIndex = this.batches.indexOf(batch);
    if (batchIndex < 0) return;
    this.batches.splice(batchIndex, 1);

    if (this.batch == batch)
        this.batch = null;
};

AchSoPlayer.prototype.calculateAnnotationWaitTime = function(annotations)
{
    // Time constants in seconds.
    var timeAlways = 2.0;
    var timePerAnnotation = 0.5;
    var timePerSubtitle = 1.0;
    var timePerLetter = 0.03;
    var timeMaximum = 10.0;

    var waitTime = timeAlways;

    for (var i = 0; i < annotations.length; i++) {
        waitTime += timePerAnnotation;
        var text = annotations[i].text.replace(/\s+/g, '');
        if (text.length > 0) {
            waitTime += timePerSubtitle;
            waitTime += text.length * timePerLetter;
        }
    }

    waitTime = Math.min(waitTime, timeMaximum);
    
    return waitTime;
}

AchSoPlayer.prototype.calculateWaitTime = function(batch)
{
    if (!batch || batch.annotations.length == 0)
        return 1;

    return this.calculateAnnotationWaitTime(batch.annotations);
}
