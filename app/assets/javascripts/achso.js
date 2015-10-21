function createAnnotationGradient(ctx, size) {
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
}
