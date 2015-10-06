
var AchSoPlayer = function(rootElement, data, user) {
    this.start(rootElement, data || { }, user || null);
};

AchSoPlayer.prototype.start = function(rootElement, data, user) {
    this.loaded = false;
    this.startModel(data, user);
    this.startView(rootElement, data);
    this.startController();
    this.switchState(ManualPause);
    this.loaded = true;
};

AchSoPlayer.prototype.stop = function() {
    this.stopView();
};

