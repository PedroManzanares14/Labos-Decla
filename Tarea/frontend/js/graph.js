// grafico del canvas, con zoom y arrastre

class IntegralGrapher {
    constructor(canvasId) {
        this.canvas = document.getElementById(canvasId);
        if (!this.canvas) return;
        this.ctx = this.canvas.getContext('2d');

        // lo que se esta graficando
        this.func = null;
        this.limitA = null;
        this.limitB = null;

        // vista inicial
        this.xMin = -5;
        this.xMax = 5;
        this.yMin = -5;
        this.yMax = 5;

        // para volver al inicio
        this.defaultView = { xMin: -5, xMax: 5, yMin: -5, yMax: 5 };

        // datos del arrastre
        this.isDragging = false;
        this.dragStartX = 0;
        this.dragStartY = 0;
        this.initialXMin = 0;
        this.initialXMax = 0;
        this.initialYMin = 0;
        this.initialYMax = 0;

        // cartelito con coordenadas
        this.tooltip = document.getElementById('graphTooltip');

        this.init();
    }

    init() {
        this.setupHighDPI();
        this.attachEventListeners();
        window.addEventListener('resize', () => {
            this.setupHighDPI();
            this.render();
        });
        this.render();
    }

    setupHighDPI() {
        const dpr = window.devicePixelRatio || 1;
        const rect = this.canvas.getBoundingClientRect();
        const displayWidth = rect.width || 800;
        const displayHeight = 420;

        this.canvas.width = Math.round(displayWidth * dpr);
        this.canvas.height = Math.round(displayHeight * dpr);

        this.canvas.style.width = `${displayWidth}px`;
        this.canvas.style.height = `${displayHeight}px`;

        this.ctx.setTransform(1, 0, 0, 1, 0, 0);
        this.ctx.scale(dpr, dpr);

        this.width = displayWidth;
        this.height = displayHeight;
    }

    attachEventListeners() {
        // arrastrar
        this.canvas.addEventListener('mousedown', (e) => {
            this.isDragging = true;
            const pos = this.getCanvasPos(e);
            this.dragStartX = pos.x;
            this.dragStartY = pos.y;
            this.initialXMin = this.xMin;
            this.initialXMax = this.xMax;
            this.initialYMin = this.yMin;
            this.initialYMax = this.yMax;
            this.canvas.style.cursor = 'grabbing';
        });

        window.addEventListener('mouseup', () => {
            if (this.isDragging) {
                this.isDragging = false;
                this.canvas.style.cursor = 'crosshair';
            }
        });

        this.canvas.addEventListener('mousemove', (e) => {
            const pos = this.getCanvasPos(e);

            if (this.isDragging) {
                const dxCanvas = pos.x - this.dragStartX;
                const dyCanvas = pos.y - this.dragStartY;

                const mathWidth = this.initialXMax - this.initialXMin;
                const mathHeight = this.initialYMax - this.initialYMin;

                const dxMath = (dxCanvas / this.width) * mathWidth;
                const dyMath = (dyCanvas / this.height) * mathHeight;

                this.xMin = this.initialXMin - dxMath;
                this.xMax = this.initialXMax - dxMath;
                this.yMin = this.initialYMin + dyMath;
                this.yMax = this.initialYMax + dyMath;

                this.render();
            } else {
                this.handleHover(pos);
            }
        });

        this.canvas.addEventListener('mouseleave', () => {
            if (this.tooltip) this.tooltip.style.display = 'none';
        });

        // zoom con la rueda
        this.canvas.addEventListener('wheel', (e) => {
            e.preventDefault();
            const pos = this.getCanvasPos(e);
            const mathPos = this.toMath(pos.x, pos.y);

            const zoomFactor = e.deltaY < 0 ? 0.85 : 1.15;
            this.zoomAt(mathPos.x, mathPos.y, zoomFactor);
        }, { passive: false });
    }

    getCanvasPos(e) {
        const rect = this.canvas.getBoundingClientRect();
        return {
            x: e.clientX - rect.left,
            y: e.clientY - rect.top
        };
    }

    handleHover(pos) {
        if (!this.tooltip || !this.func) {
            if (this.tooltip) this.tooltip.style.display = 'none';
            return;
        }

        const math = this.toMath(pos.x, pos.y);
        const yVal = this.evalFunc(math.x);

        if (yVal !== null && !isNaN(yVal) && isFinite(yVal)) {
            const canvasY = this.toCanvasY(yVal);
            const isNearCurve = Math.abs(pos.y - canvasY) < 25;

            this.tooltip.style.display = 'block';
            this.tooltip.style.left = `${Math.min(this.width - 130, Math.max(10, pos.x + 12))}px`;
            this.tooltip.style.top = `${Math.min(this.height - 50, Math.max(10, pos.y - 35))}px`;
            this.tooltip.innerHTML = `x: <strong>${math.x.toFixed(2)}</strong><br>f(x): <strong>${yVal.toFixed(2)}</strong>`;
        } else {
            this.tooltip.style.display = 'none';
        }
    }

    toCanvasX(x) {
        return ((x - this.xMin) / (this.xMax - this.xMin)) * this.width;
    }

    toCanvasY(y) {
        return this.height - ((y - this.yMin) / (this.yMax - this.yMin)) * this.height;
    }

    toMath(canvasX, canvasY) {
        const x = this.xMin + (canvasX / this.width) * (this.xMax - this.xMin);
        const y = this.yMin + ((this.height - canvasY) / this.height) * (this.yMax - this.yMin);
        return { x, y };
    }

    zoomAt(centerX, centerY, factor) {
        const newWidth = (this.xMax - this.xMin) * factor;
        const newHeight = (this.yMax - this.yMin) * factor;

        if (newWidth < 0.05 || newWidth > 2000) return;

        const ratioX = (centerX - this.xMin) / (this.xMax - this.xMin);
        const ratioY = (centerY - this.yMin) / (this.yMax - this.yMin);

        this.xMin = centerX - ratioX * newWidth;
        this.xMax = centerX + (1 - ratioX) * newWidth;
        this.yMin = centerY - ratioY * newHeight;
        this.yMax = centerY + (1 - ratioY) * newHeight;

        this.render();
    }

    zoomIn() {
        const midX = (this.xMin + this.xMax) / 2;
        const midY = (this.yMin + this.yMax) / 2;
        this.zoomAt(midX, midY, 0.8);
    }

    zoomOut() {
        const midX = (this.xMin + this.xMax) / 2;
        const midY = (this.yMin + this.yMax) / 2;
        this.zoomAt(midX, midY, 1.25);
    }

    resetView() {
        this.xMin = this.defaultView.xMin;
        this.xMax = this.defaultView.xMax;
        this.yMin = this.defaultView.yMin;
        this.yMax = this.defaultView.yMax;
        this.render();
    }

    evalFunc(x) {
        if (!this.func) return null;
        try {
            return this.func(x);
        } catch (e) {
            return null;
        }
    }

    // poner funcion y limites
    setProblem(funcEvaluator, limitA, limitB) {
        this.func = funcEvaluator;
        this.limitA = (limitA !== null && !isNaN(limitA)) ? Number(limitA) : null;
        this.limitB = (limitB !== null && !isNaN(limitB)) ? Number(limitB) : null;

        // acomodar la escala
        if (this.limitA !== null && this.limitB !== null) {
            const minLim = Math.min(this.limitA, this.limitB);
            const maxLim = Math.max(this.limitA, this.limitB);
            const spanX = Math.max(2, maxLim - minLim);
            const padX = spanX * 0.45;

            this.xMin = minLim - padX;
            this.xMax = maxLim + padX;

            // mirar varios puntos para saber hasta donde llega
            let sampledMinY = Infinity;
            let sampledMaxY = -Infinity;
            const steps = 60;
            for (let i = 0; i <= steps; i++) {
                const x = this.xMin + (i / steps) * (this.xMax - this.xMin);
                const y = this.evalFunc(x);
                if (y !== null && !isNaN(y) && isFinite(y)) {
                    sampledMinY = Math.min(sampledMinY, y);
                    sampledMaxY = Math.max(sampledMaxY, y);
                }
            }

            if (isFinite(sampledMinY) && isFinite(sampledMaxY)) {
                // que se vea el eje
                sampledMinY = Math.min(0, sampledMinY);
                sampledMaxY = Math.max(0, sampledMaxY);
                const spanY = Math.max(2, sampledMaxY - sampledMinY);
                const padY = spanY * 0.35;
                this.yMin = sampledMinY - padY;
                this.yMax = sampledMaxY + padY;
            } else {
                this.yMin = -5;
                this.yMax = 5;
            }
        } else {
            this.xMin = -5;
            this.xMax = 5;
            this.yMin = -5;
            this.yMax = 5;
        }

        this.defaultView = {
            xMin: this.xMin,
            xMax: this.xMax,
            yMin: this.yMin,
            yMax: this.yMax
        };

        this.render();
    }

    render() {
        if (!this.ctx) return;
        const ctx = this.ctx;
        const w = this.width;
        const h = this.height;

        // limpiar canvas
        ctx.clearRect(0, 0, w, h);

        const isDark = document.documentElement.getAttribute('data-theme') !== 'light';
        const gridColor = isDark ? 'rgba(71, 85, 105, 0.22)' : 'rgba(203, 213, 225, 0.6)';
        const axisColor = isDark ? '#475569' : '#94a3b8';
        const textColor = isDark ? '#94a3b8' : '#64748b';
        const curveColor = isDark ? '#38bdf8' : '#0284c7';
        const areaColor = isDark ? 'rgba(56, 189, 248, 0.28)' : 'rgba(2, 132, 199, 0.24)';
        const limitLineColor = isDark ? '#f43f5e' : '#e11d48';

        // cuadricula y numeros
        this.drawGrid(ctx, gridColor, textColor);

        // ejes
        this.drawAxes(ctx, axisColor, textColor);

        // area bajo la curva
        if (this.func && this.limitA !== null && this.limitB !== null) {
            this.drawShadedArea(ctx, areaColor);
            this.drawLimitLines(ctx, limitLineColor);
        }

        // curva
        if (this.func) {
            this.drawCurve(ctx, curveColor);
        }
    }

    drawGrid(ctx, gridColor, textColor) {
        ctx.save();
        ctx.strokeStyle = gridColor;
        ctx.lineWidth = 1;
        ctx.font = '11px "Fira Code", monospace';
        ctx.fillStyle = textColor;
        ctx.textAlign = 'center';
        ctx.textBaseline = 'top';

        const stepX = this.getGridStep(this.xMax - this.xMin);
        const startX = Math.floor(this.xMin / stepX) * stepX;

        const originY = this.toCanvasY(0);
        const yLabelPos = Math.max(15, Math.min(this.height - 15, originY + 6));

        for (let x = startX; x <= this.xMax; x += stepX) {
            if (Math.abs(x) < 1e-9) continue;
            const cx = this.toCanvasX(x);
            ctx.beginPath();
            ctx.moveTo(cx, 0);
            ctx.lineTo(cx, this.height);
            ctx.stroke();

            // numero en x
            const label = Number(x.toFixed(4)).toString();
            ctx.fillText(label, cx, yLabelPos);
        }

        const stepY = this.getGridStep(this.yMax - this.yMin);
        const startY = Math.floor(this.yMin / stepY) * stepY;

        const originX = this.toCanvasX(0);
        const xLabelPos = Math.max(25, Math.min(this.width - 25, originX - 8));
        ctx.textAlign = 'right';
        ctx.textBaseline = 'middle';

        for (let y = startY; y <= this.yMax; y += stepY) {
            if (Math.abs(y) < 1e-9) continue;
            const cy = this.toCanvasY(y);
            ctx.beginPath();
            ctx.moveTo(0, cy);
            ctx.lineTo(this.width, cy);
            ctx.stroke();

            // numero en y
            const label = Number(y.toFixed(4)).toString();
            ctx.fillText(label, xLabelPos, cy);
        }

        ctx.restore();
    }

    getGridStep(range) {
        const roughStep = range / 8;
        const magnitude = Math.pow(10, Math.floor(Math.log10(roughStep)));
        const normalized = roughStep / magnitude;

        let step;
        if (normalized < 1.5) step = 1;
        else if (normalized < 3.5) step = 2;
        else if (normalized < 7.5) step = 5;
        else step = 10;

        return step * magnitude;
    }

    drawAxes(ctx, axisColor, textColor) {
        ctx.save();
        ctx.strokeStyle = axisColor;
        ctx.lineWidth = 1.5;

        const originX = this.toCanvasX(0);
        const originY = this.toCanvasY(0);

        // eje x
        if (originY >= 0 && originY <= this.height) {
            ctx.beginPath();
            ctx.moveTo(0, originY);
            ctx.lineTo(this.width, originY);
            ctx.stroke();

            // flecha
            ctx.beginPath();
            ctx.moveTo(this.width - 8, originY - 4);
            ctx.lineTo(this.width, originY);
            ctx.lineTo(this.width - 8, originY + 4);
            ctx.fillStyle = axisColor;
            ctx.fill();

            // letra
            ctx.font = 'bold 12px "Inter", sans-serif';
            ctx.fillText('x', this.width - 14, originY - 14);
        }

        // eje y
        if (originX >= 0 && originX <= this.width) {
            ctx.beginPath();
            ctx.moveTo(originX, 0);
            ctx.lineTo(originX, this.height);
            ctx.stroke();

            // flecha
            ctx.beginPath();
            ctx.moveTo(originX - 4, 8);
            ctx.lineTo(originX, 0);
            ctx.lineTo(originX + 4, 8);
            ctx.fillStyle = axisColor;
            ctx.fill();

            // letra
            ctx.font = 'bold 12px "Inter", sans-serif';
            ctx.textAlign = 'left';
            ctx.fillText('y', originX + 8, 14);
        }

        ctx.restore();
    }

    drawShadedArea(ctx, areaColor) {
        const a = Math.min(this.limitA, this.limitB);
        const b = Math.max(this.limitA, this.limitB);
        if (a === b) return;

        ctx.save();
        ctx.fillStyle = areaColor;

        const canvasA = this.toCanvasX(a);
        const canvasB = this.toCanvasX(b);
        const originY = this.toCanvasY(0);

        ctx.beginPath();
        ctx.moveTo(canvasA, originY);

        const sampleCount = Math.max(100, Math.round((canvasB - canvasA) * 2));
        for (let i = 0; i <= sampleCount; i++) {
            const x = a + (i / sampleCount) * (b - a);
            const y = this.evalFunc(x);
            if (y === null || isNaN(y) || !isFinite(y)) continue;
            const cx = this.toCanvasX(x);
            const cy = this.toCanvasY(y);
            ctx.lineTo(cx, cy);
        }

        ctx.lineTo(canvasB, originY);
        ctx.closePath();
        ctx.fill();

        ctx.restore();
    }

    drawLimitLines(ctx, limitColor) {
        const limits = [
            { val: this.limitA, label: `a = ${this.limitA}` },
            { val: this.limitB, label: `b = ${this.limitB}` }
        ];

        ctx.save();
        ctx.setLineDash([5, 4]);
        ctx.strokeStyle = limitColor;
        ctx.lineWidth = 1.8;

        limits.forEach(item => {
            if (item.val === null || isNaN(item.val)) return;
            const cx = this.toCanvasX(item.val);
            if (cx < -10 || cx > this.width + 10) return;

            ctx.beginPath();
            ctx.moveTo(cx, 0);
            ctx.lineTo(cx, this.height);
            ctx.stroke();

            // etiqueta de arriba
            ctx.setLineDash([]);
            ctx.fillStyle = limitColor;
            ctx.fillRect(cx - 24, 6, 48, 18);
            ctx.fillStyle = '#ffffff';
            ctx.font = 'bold 10px "Fira Code", monospace';
            ctx.textAlign = 'center';
            ctx.textBaseline = 'middle';
            ctx.fillText(item.label, cx, 15);
            ctx.setLineDash([5, 4]);
        });

        ctx.restore();
    }

    drawCurve(ctx, curveColor) {
        ctx.save();
        ctx.strokeStyle = curveColor;
        ctx.lineWidth = 2.5;
        ctx.lineJoin = 'round';
        ctx.lineCap = 'round';

        ctx.beginPath();
        let isDrawing = false;
        const totalPixels = this.width;
        const step = 1; // pixel a pixel para máxima suavidad

        for (let px = 0; px <= totalPixels; px += step) {
            const math = this.toMath(px, 0);
            const y = this.evalFunc(math.x);

            if (y === null || isNaN(y) || !isFinite(y) || Math.abs(y) > 1e6) {
                isDrawing = false;
                continue;
            }

            const py = this.toCanvasY(y);

            // no unir puntos cuando hay una asintota
            if (py < -this.height || py > this.height * 2) {
                isDrawing = false;
                continue;
            }

            if (!isDrawing) {
                ctx.moveTo(px, py);
                isDrawing = true;
            } else {
                ctx.lineTo(px, py);
            }
        }

        ctx.stroke();
        ctx.restore();
    }
}
