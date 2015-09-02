
var AchSoPlayer = function(rootElement, data, user) {
    this.start(rootElement, data || { }, user || null);
};

AchSoPlayer.prototype.start = function(rootElement, data, user) {
    this.startView(rootElement, data);
    this.startModel(data, user);
    this.startController();
    this.switchState(ManualPause);
};

AchSoPlayer.prototype.stop = function() {
    this.stopView();
};

