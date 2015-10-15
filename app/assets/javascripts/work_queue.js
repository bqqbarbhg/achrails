
function WorkQueue() {
    this.idleWorkers = [];
    this.workQueue = [];
}

WorkQueue.prototype.addWorker = function(worker) {
    this.idleWorkers.push(worker);
};

WorkQueue.prototype.addWork = function(work) {
    this.workQueue.push(work);

    if (this.idleWorkers.length > 0) {
        var worker = this.idleWorkers.pop();
        worker.wakeUp(this);
        this.findWork(worker);
    }
};

WorkQueue.prototype.findWork = function(worker) {
    if (this.workQueue.length == 0) {
        worker.sleep(this);
        this.idleWorkers.push(worker);
    } else {
        var work = this.workQueue.shift();
        worker.doWork(work, this);
    }
};

