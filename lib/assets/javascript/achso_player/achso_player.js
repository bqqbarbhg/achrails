
var AchSoPlayer = function(rootElement, data) {
    this.start(rootElement, data || { });
};

AchSoPlayer.prototype.start = function(rootElement, data) {
    this.startView(rootElement, data);
    this.startModel(data);
    this.startController();
    this.switchState(ManualPause);
};

AchSoPlayer.prototype.stop = function() {
    this.stopView();
};

