var achso_player_actions = { };

var Playing = 0;
var ManualPause = 1;
var AnnotationPause = 2;
var AnnotationEdit = 3;

AchSoPlayer.prototype.startController = function() {
    this.previousTime = 0.0;
    this.actions = achso_player_actions[ManualPause];
    this.state = ManualPause;
    this.timeouts = [];
};

AchSoPlayer.prototype.stateTimeout = function(callback, timeout) {
    this.timeouts.push(window.setTimeout(callback.bind(this), timeout * 1000));
};

AchSoPlayer.prototype.switchState = function(newState) {
    for (var i = 0; i < this.timeouts.length; i++) {
        window.clearTimeout(this.timeouts[i]);
    }
    this.timeouts.length = 0;

    this.unselectAnnotation();
    this.stopWaitAnimation();

    this.actions = achso_player_actions[newState];
    if (this.actions.start) {
        this.actions.start.apply(this, Array.prototype.slice.call(arguments, 1));
    }
    this.state = newState;

    this.setPlayButton(newState == ManualPause);
    this.updateSeekBarView();
    return this;
};

AchSoPlayer.prototype.timeUpdate = function(time) {
    if (!this.isSeeking) {
        this.time = time;
        if (this.actions.timeUpdate)
            this.actions.timeUpdate.call(this, time, this.previousTime);
    }

    this.previousTime = time;
    this.isSeeking = false;
};

AchSoPlayer.prototype.userPlay = function() {
    if (this.actions.userPlay)
        this.actions.userPlay.call(this);
};

AchSoPlayer.prototype.userSeek = function(pos, mouseState) {
    if (this.actions.userSeek)
        this.actions.userSeek.call(this, pos, mouseState);
};

AchSoPlayer.prototype.editAnnotation = function(e) {
    if (this.actions.editAnnotation)
        this.actions.editAnnotation.call(this, e);
};

AchSoPlayer.prototype.doSeek = function(time) {
    this.isSeeking = true;
    this.time = time;
    this.seekVideo(time);
    this.setBarPosition(time);
};

AchSoPlayer.prototype.selectAnnotation = function(annotation) {
    this.oldSelectedAnnotation = this.selectedAnnotation;
    this.selectedAnnotation = annotation;
    this.showAnnotationEdit(annotation);
};

AchSoPlayer.prototype.unselectAnnotation = function() {
    this.selectedAnnotation = null;
    this.hideAnnotationEdit();
};

AchSoPlayer.prototype.doEditAnnotation = function(e) {

    if (e.state == MouseState.Down) {
        if (!this.batch) {
            this.setBatch(this.findOrCreateBatch(this.time));
        }
        var result = this.findOrCreateAnnotation(e.pos);
        var annotation = result.annotation;
        this.dragging = result.isNew;
        this.selectAnnotation(annotation);
        this.annotationDeadZoneBroken = false;

        this.dragPosDiff = {
            x: annotation.pos.x - e.pos.x,
            y: annotation.pos.y - e.pos.y
        };
        this.dragStartPos = {
            x: annotation.pos.x,
            y: annotation.pos.y,
        };

    } else {

        var annotation = this.selectedAnnotation;
        if (annotation) {
            if (e.state == MouseState.Up && !this.dragging
                    && annotation == this.oldSelectedAnnotation) {
                this.unselectAnnotation();
            }

            var newPos = {
                x: clamp(e.pos.x + this.dragPosDiff.x, 0.0, 1.0),
                y: clamp(e.pos.y + this.dragPosDiff.y, 0.0, 1.0),
            };

            var dx = (newPos.x - this.dragStartPos.x) * this.videoWidth;
            var dy = (newPos.y - this.dragStartPos.y) * this.videoHeight;
            if (dx * dx + dy * dy > Math.pow(this.annotationDragDeadZone, 2)) {
                if (!this.annotationDeadZoneBroken) {
                    this.annotationDragStart();
                }
                this.dragging = true;
                this.annotationDeadZoneBroken = true;
            }

            if (e.state == MouseState.Up) {
                this.annotationDragStop();
            }

            if (this.dragging) {
                annotation.pos.x = newPos.x;
                annotation.pos.y = newPos.y;
            }
        }
    }

    this.updateAnnotationView();
};

AchSoPlayer.prototype.annotationTextInput = function(text) {
    if (!this.selectedAnnotation)
        return;
    this.selectedAnnotation.text = text;
    this.updateAnnotationView();
};

AchSoPlayer.prototype.annotationSaveButton = function() {
    this.unselectAnnotation();
    this.updateAnnotationView();
};

AchSoPlayer.prototype.annotationDeleteButton = function() {
    if (!this.selectedAnnotation)
        return;

    this.deleteAnnotation(this.selectedAnnotation);
    this.unselectAnnotation();

    this.updateAnnotationView();
};

achso_player_actions[Playing] = {
    
    start: function(ignoreBatch) {
        this.playVideo();
        this.ignoreBatch = this.batch;
        this.setBatch(null);
    },

    timeUpdate: function(time, lastTime) {
        var delta = time - lastTime;
        var nextTime = time + delta;

        var batch = this.batchBetween(lastTime, nextTime);
        if (batch && batch != this.ignoreBatch) {
            if (batch.time > time) {
                var delay = batch.time - time;
                this.stateTimeout(function() {
                    this.setBatch(batch);
                    this.setBarPosition(this.batch.time);
                    this.switchState(AnnotationPause);
                }, delay);
            } else {
                this.setBatch(batch);
                this.updateAnnotationView();
                this.switchState(AnnotationPause);
            }
        }
        this.setBarPosition(time);
    },

    userSeek: function(time, mouseState) {
        if (mouseState == MouseState.Down) {
            this.pauseVideo();
        }

        var batch = this.batchAt(time);
        if (batch) {
            time = batch.time;
        }
        this.setBatch(batch);
        ignoreBatch = batch;

        this.doSeek(time);

        if (mouseState == MouseState.Up) {
            if (this.batch) {
                this.switchState(ManualPause);
            } else {
                this.playVideo();
            }
        }
    },

    userPlay: function() {
        this.switchState(ManualPause);
    },

    editAnnotation: function(e) {
        if (this.allowEdit()) {
            this.switchState(AnnotationEdit).editAnnotation(e);
        }
    },
};

achso_player_actions[ManualPause] = {
    start: function() {
        this.pauseVideo();
    },

    timeUpdate: function(time) {
        this.setBarPosition(time);
    },

    userPlay: function() {
        this.switchState(Playing);
    },

    userSeek: function(time) {
        var batch = this.batchAt(time);
        if (batch) {
            time = batch.time;
        }
        this.setBatch(batch);
        this.doSeek(time);
    },

    editAnnotation: function(e) {
        if (this.allowEdit()) {
            this.switchState(AnnotationEdit).editAnnotation(e);
        }
    },
};

achso_player_actions[AnnotationPause] = {
    start: function(time) {

        var waitTime = this.calculateWaitTime(this.batch);
        this.pauseVideo();
        this.doWaitAnimation(waitTime);
        this.stateTimeout(function() {
            this.switchState(Playing);
        }, waitTime);
    },

    userSeek: function(e) {
        this.switchState(Playing).userSeek(e);
    },

    userPlay: function() {
        this.switchState(ManualPause);
    },

    editAnnotation: function(e) {
        if (this.allowEdit()) {
            this.switchState(AnnotationEdit).editAnnotation(e);
        }
    },
};

achso_player_actions[AnnotationEdit] = {
    start: function() {
        this.pauseVideo();
    },

    userSeek: function(time) {
        this.switchState(ManualPause).userSeek(time);
    },

    userPlay: function() {
        this.switchState(Playing);
    },

    editAnnotation: function(e) {
        this.doEditAnnotation(e);
    },
};

