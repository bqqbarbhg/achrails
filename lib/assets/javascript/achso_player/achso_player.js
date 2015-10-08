
var AchSoPlayer = function(rootElement, data, user, options) {
    this.start(rootElement, data || { }, user || null, options || { });
};

AchSoPlayer.prototype.start = function(rootElement, data, user, options) {
    this.loaded = false;
    this.options = options;
    this.startModel(data, user);
    this.startView(rootElement, data);
    this.startController();
    this.switchState(ManualPause);
    this.loaded = true;
};

AchSoPlayer.prototype.stop = function() {
    this.stopView();
};

