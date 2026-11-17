// logica principal, sin mucho misterio

document.addEventListener('DOMContentLoaded', () => {
    // cosas que usamos de la pagina
    const exprInput = document.getElementById('exprInput');
    const limitAInput = document.getElementById('limitA');
    const limitBInput = document.getElementById('limitB');
    const integralForm = document.getElementById('integralForm');
    const solveBtn = document.getElementById('solveBtn');
    const clearBtn = document.getElementById('clearBtn');
    const liveMathPreview = document.getElementById('liveMathPreview');
    const serverStatusBadge = document.getElementById('serverStatusBadge');
    const themeToggleBtn = document.getElementById('themeToggleBtn');
    const infoModalBtn = document.getElementById('infoModalBtn');
    const infoModal = document.getElementById('infoModal');
    const closeModalBtn = document.getElementById('closeModalBtn');
    const modalUnderstoodBtn = document.getElementById('modalUnderstoodBtn');
    const examplesContainer = document.getElementById('examplesContainer');
    const historyList = document.getElementById('historyList');
    const clearHistoryBtn = document.getElementById('clearHistoryBtn');

    // paneles de resultado
    const welcomePlaceholder = document.getElementById('welcomePlaceholder');
    const errorContainer = document.getElementById('errorContainer');
    const errorMessage = document.getElementById('errorMessage');
    const resultsDetails = document.getElementById('resultsDetails');
    const resultStatusBadge = document.getElementById('resultStatusBadge');
    const latexAntiderivative = document.getElementById('latexAntiderivative');
    const plainAntiderivative = document.getElementById('plainAntiderivative');
    const copyAntiderivBtn = document.getElementById('copyAntiderivBtn');
    const ruleText = document.getElementById('ruleText');
    const areaResultBlock = document.getElementById('areaResultBlock');
    const areaValueDisplay = document.getElementById('areaValueDisplay');
    const latexBarrowFormula = document.getElementById('latexBarrowFormula');
    const faValueDisplay = document.getElementById('faValueDisplay');
    const fbValueDisplay = document.getElementById('fbValueDisplay');

    // el grafico
    const grapher = new IntegralGrapher('integralCanvas');

    // botones del grafico
    document.getElementById('zoomInBtn')?.addEventListener('click', () => grapher.zoomIn());
    document.getElementById('zoomOutBtn')?.addEventListener('click', () => grapher.zoomOut());
    document.getElementById('resetZoomBtn')?.addEventListener('click', () => grapher.resetView());

    // ejemplos de las reglas
    const CATALOGO_REGLAS = [
        { id: 'a', cat: 'poly', label: 'a) ∫ k dx', expr: '5', a: '0', b: '3', desc: 'Constante k = 5' },
        { id: 'b', cat: 'poly', label: 'b) ∫ x dx', expr: 'x', a: '0', b: '4', desc: 'Variable lineal' },
        { id: 'c', cat: 'poly', label: 'c) ∫ (k*x) dx', expr: '3 * x', a: '0', b: '2', desc: 'Constante por x' },
        { id: 'd1', cat: 'poly', label: 'd) ∫ x^n dx (n=3)', expr: 'x ^ 3', a: '1', b: '3', desc: 'Potencia n = 3' },
        { id: 'd2', cat: 'poly', label: 'd) ∫ x^-1 dx (1/x)', expr: '1 / x', a: '1', b: '4', desc: 'Logaritmo natural' },
        { id: 'e', cat: 'poly', label: 'e) ∫ u dx (polinomio)', expr: 'x^2 + 2*x + 1', a: '0', b: '2', desc: 'Trinomio cuadrático' },
        { id: 'f', cat: 'trig', label: 'f) ∫ (k*u) dx', expr: '4 * sin(x)', a: '0', b: 'pi', desc: '4 veces seno' },
        { id: 'g', cat: 'trig', label: 'g) ∫ (u + v) dx', expr: 'sin(x) + cos(x)', a: '0', b: 'pi/2', desc: 'Suma sin + cos' },
        { id: 'h', cat: 'hyp', label: 'h) ∫ (u - v) dx', expr: 'cosh(x) - sinh(x)', a: '0', b: '1', desc: 'Resta cosh - sinh' },
        { id: 'i1', cat: 'exp', label: 'i) ∫ a^x dx (e^x)', expr: 'e ^ x', a: '0', b: '2', desc: 'Exponencial natural' },
        { id: 'i2', cat: 'exp', label: 'i) ∫ a^x dx (2^x)', expr: '2 ^ x', a: '0', b: '3', desc: 'Base arbitraria a=2' },
        { id: 'j', cat: 'exp', label: 'j) ∫ a^u dx (e^(2x))', expr: 'e ^ (2 * x)', a: '0', b: '1', desc: 'Exponencial lineal' },
        { id: 'k', cat: 'trig', label: 'k) ∫ sin(x) dx', expr: 'sin(x)', a: '0', b: 'pi', desc: 'Función seno' },
        { id: 'l', cat: 'trig', label: 'l) ∫ cos(x) dx', expr: 'cos(x)', a: '0', b: 'pi/2', desc: 'Función coseno' },
        { id: 'm', cat: 'trig', label: 'm) ∫ tan(x) dx', expr: 'tan(x)', a: '0', b: 'pi/4', desc: 'Función tangente' },
        { id: 'n', cat: 'inv', label: 'n) ∫ asin(x) dx', expr: 'asin(x)', a: '0', b: '0.8', desc: 'Arco seno' },
        { id: 'o', cat: 'inv', label: 'o) ∫ acos(x) dx', expr: 'acos(x)', a: '0', b: '0.8', desc: 'Arco coseno' },
        { id: 'p', cat: 'inv', label: 'p) ∫ atan(x) dx', expr: 'atan(x)', a: '0', b: '1.5', desc: 'Arco tangente' },
        { id: 'q', cat: 'hyp', label: 'q) ∫ sh(x) dx', expr: 'sh(x)', a: '0', b: '1.5', desc: 'Seno hiperbólico' },
        { id: 'r', cat: 'hyp', label: 'r) ∫ cosh(x) dx', expr: 'cosh(x)', a: '0', b: '1.5', desc: 'Coseno hiperbólico' },
        { id: 's', cat: 'hyp', label: 's) ∫ tanh(x) dx', expr: 'tanh(x)', a: '0', b: '1.5', desc: 'Tangente hiperbólica' },
        { id: 't', cat: 'hyp', label: 't) ∫ arcsinh(x) dx', expr: 'arcsinh(x)', a: '0', b: '2', desc: 'Arco sinh' },
        { id: 'u', cat: 'hyp', label: 'u) ∫ arccosh(x) dx', expr: 'arccosh(x)', a: '1.2', b: '3', desc: 'Arco cosh [x >= 1]' },
        { id: 'v', cat: 'hyp', label: 'v) ∫ arctanh(x) dx', expr: 'arctanh(x)', a: '0', b: '0.7', desc: 'Arco tanh [|x| < 1]' }
    ];

    // arranque de la interfaz
    initTheme();
    renderExamples('all');
    loadHistory();
    checkServerHealth();
    updateLivePreview();

    // que aparezca algo al cargar
    setTimeout(() => {
        resolverIntegral();
    }, 400);

    // eventos principales

    // enviar formulario
    integralForm.addEventListener('submit', (e) => {
        e.preventDefault();
        resolverIntegral();
    });

    // preview mientras escriben
    exprInput.addEventListener('input', () => {
        updateLivePreview();
    });

    // limpiar todo
    clearBtn.addEventListener('click', () => {
        exprInput.value = '';
        limitAInput.value = '';
        limitBInput.value = '';
        updateLivePreview();
        welcomePlaceholder.style.display = 'block';
        resultsDetails.style.display = 'none';
        errorContainer.style.display = 'none';
        grapher.setProblem(null, null, null);
        exprInput.focus();
    });

    // botones de matematicas
    document.querySelectorAll('.key-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            const textToInsert = btn.getAttribute('data-insert');
            insertAtCursor(exprInput, textToInsert);
            updateLivePreview();
            exprInput.focus();
        });
    });

    // filtros
    document.querySelectorAll('.filter-tab').forEach(tab => {
        tab.addEventListener('click', () => {
            document.querySelectorAll('.filter-tab').forEach(t => t.classList.remove('active'));
            tab.classList.add('active');
            renderExamples(tab.getAttribute('data-category'));
        });
    });

    // copiar resultado
    copyAntiderivBtn.addEventListener('click', () => {
        const text = plainAntiderivative.textContent;
        if (text) {
            navigator.clipboard.writeText(text).then(() => {
                copyAntiderivBtn.textContent = '✅';
                setTimeout(() => copyAntiderivBtn.textContent = '📋', 1500);
            });
        }
    });

    // historial
    clearHistoryBtn.addEventListener('click', () => {
        localStorage.removeItem('integrals_history');
        loadHistory();
    });

    // ventana de info
    infoModalBtn.addEventListener('click', () => infoModal.style.display = 'flex');
    closeModalBtn.addEventListener('click', () => infoModal.style.display = 'none');
    modalUnderstoodBtn.addEventListener('click', () => infoModal.style.display = 'none');
    infoModal.addEventListener('click', (e) => {
        if (e.target === infoModal) infoModal.style.display = 'none';
    });

    // preparar expresiones para el grafico

    // deja la expresion en un formato que entendamos
    function normalizarExpresion(expr) {
        if (!expr) return '';
        let s = expr.trim();

        // nombres que vienen en español
        s = s.replace(/\bsen\b/g, 'sin');
        s = s.replace(/\btg\b/g, 'tan');

        // 3x deberia ser 3*x
        s = s.replace(/(\d+(\.\d+)?)\s*x\b/g, '$1*x');

        // tambien pasa con las funciones
        s = s.replace(/(\d+(\.\d+)?|x)\s*(sin|cos|tan|asin|acos|atan|sh|sinh|ch|cosh|th|tanh|arcsinh|asinh|arccosh|acosh|arctanh|atanh|ln|log|exp|sqrt)\b/g, '$1*$3');

        // parentesis pegados
        s = s.replace(/\)\s*\(/g, ')*(');
        s = s.replace(/(\d+(\.\d+)?|x)\s*\(/g, '$1*(');

        return s;
    }

    // arma la funcion que usa el canvas
    function crearEvaluadorJS(exprStr) {
        try {
            let jsExpr = normalizarExpresion(exprStr);

            // pasar nombres a Math
            jsExpr = jsExpr.replace(/\bpi\b/g, 'Math.PI');
            jsExpr = jsExpr.replace(/\be\b/g, 'Math.E');

            // js usa ** para potencias
            jsExpr = jsExpr.replace(/\^/g, '**');

            // funciones
            const mathMap = [
                { re: /\barcsinh\b/g, sub: 'Math.asinh' },
                { re: /\barccosh\b/g, sub: 'Math.acosh' },
                { re: /\barctanh\b/g, sub: 'Math.atanh' },
                { re: /\basinh\b/g, sub: 'Math.asinh' },
                { re: /\bacosh\b/g, sub: 'Math.acosh' },
                { re: /\batanh\b/g, sub: 'Math.atanh' },
                { re: /\barcsin\b/g, sub: 'Math.asin' },
                { re: /\barccos\b/g, sub: 'Math.acos' },
                { re: /\barctan\b/g, sub: 'Math.atan' },
                { re: /\basin\b/g, sub: 'Math.asin' },
                { re: /\bacos\b/g, sub: 'Math.acos' },
                { re: /\batan\b/g, sub: 'Math.atan' },
                { re: /\bsinh\b/g, sub: 'Math.sinh' },
                { re: /\bcosh\b/g, sub: 'Math.cosh' },
                { re: /\btanh\b/g, sub: 'Math.tanh' },
                { re: /\bsh\b/g, sub: 'Math.sinh' },
                { re: /\bch\b/g, sub: 'Math.cosh' },
                { re: /\bth\b/g, sub: 'Math.tanh' },
                { re: /\bsin\b/g, sub: 'Math.sin' },
                { re: /\bsen\b/g, sub: 'Math.sin' },
                { re: /\bcos\b/g, sub: 'Math.cos' },
                { re: /\btan\b/g, sub: 'Math.tan' },
                { re: /\btg\b/g, sub: 'Math.tan' },
                { re: /\bln\b/g, sub: 'Math.log' },
                { re: /\blog\b/g, sub: 'Math.log' },
                { re: /\bexp\b/g, sub: 'Math.exp' },
                { re: /\bsqrt\b/g, sub: 'Math.sqrt' },
                { re: /\babs\b/g, sub: 'Math.abs' }
            ];

            for (const { re, sub } of mathMap) {
                jsExpr = jsExpr.replace(re, sub);
            }

            // probamos crearla
            const fn = new Function('x', `
                try {
                    const res = ${jsExpr};
                    return isFinite(res) ? res : null;
                } catch(e) {
                    return null;
                }
            `);

            // y vemos si responde
            fn(1);
            return fn;
        } catch (e) {
            console.warn('No se pudo compilar evaluador JS:', e);
            return null;
        }
    }

    // convierte los limites a numero
    function evaluarLimiteNumerico(valStr) {
        if (!valStr || valStr.trim() === '') return null;
        const clean = valStr.trim().toLowerCase()
            .replace(/\bpi\b/g, String(Math.PI))
            .replace(/\be\b/g, String(Math.E));
        try {
            const num = Function(`'use strict'; return (${clean})`)();
            return isNaN(num) ? null : Number(num);
        } catch (e) {
            const parsed = parseFloat(valStr);
            return isNaN(parsed) ? null : parsed;
        }
    }

    // preview de la formula
    function updateLivePreview() {
        const raw = exprInput.value.trim();
        if (!raw) {
            liveMathPreview.innerHTML = '<span style="color:var(--text-muted);font-size:0.9rem;">Escribe una función para ver su formato...</span>';
            return;
        }

        const aVal = limitAInput.value.trim();
        const bVal = limitBInput.value.trim();

        let latexExpr = convertirALatexSimple(raw);
        let integralString = '';

        if (aVal !== '' && bVal !== '') {
            integralString = `\\int_{${aVal}}^{${bVal}} ${latexExpr} \\, dx`;
        } else {
            integralString = `\\int ${latexExpr} \\, dx`;
        }

        renderKatex(integralString, liveMathPreview);
    }

    function convertirALatexSimple(str) {
        let s = str;
        s = s.replace(/\*/g, ' \\cdot ');
        s = s.replace(/\^([0-9a-zA-Z]+)/g, '^{$1}');
        s = s.replace(/\bsin\b/g, '\\sin');
        s = s.replace(/\bcos\b/g, '\\cos');
        s = s.replace(/\btan\b/g, '\\tan');
        s = s.replace(/\basin\b/g, '\\arcsin');
        s = s.replace(/\bacos\b/g, '\\arccos');
        s = s.replace(/\batan\b/g, '\\arctan');
        s = s.replace(/\bsh\b/g, '\\sinh');
        s = s.replace(/\bch\b/g, '\\cosh');
        s = s.replace(/\bth\b/g, '\\tanh');
        s = s.replace(/\bsinh\b/g, '\\sinh');
        s = s.replace(/\bcosh\b/g, '\\cosh');
        s = s.replace(/\btanh\b/g, '\\tanh');
        s = s.replace(/\bln\b/g, '\\ln');
        s = s.replace(/\bsqrt\((.*?)\)/g, '\\sqrt{$1}');
        return s;
    }

    function renderKatex(latexString, targetElement) {
        if (window.katex) {
            try {
                katex.render(latexString, targetElement, {
                    throwOnError: false,
                    displayMode: false
                });
            } catch (e) {
                targetElement.textContent = latexString;
            }
        } else {
            targetElement.textContent = latexString;
        }
    }

    // pedirle la integral a prolog
    async function resolverIntegral() {
        const rawExpr = exprInput.value.trim();
        if (!rawExpr) {
            mostrarError('Por favor ingresa una función matemática para integrar.');
            return;
        }

        const normalizedExpr = normalizarExpresion(rawExpr);
        const limitAVal = limitAInput.value.trim();
        const limitBVal = limitBInput.value.trim();

        // mostrar que esta cargando
        solveBtn.disabled = true;
        solveBtn.innerHTML = '<span class="status-dot"></span> Consultando Prolog...';
        ocultarError();

        try {
            const response = await fetch('/api/solve', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    expr: normalizedExpr,
                    a: limitAVal !== '' ? limitAVal : null,
                    b: limitBVal !== '' ? limitBVal : null
                })
            });

            if (!response.ok) {
                throw new Error(`Error en el servidor (${response.status}): ${response.statusText}`);
            }

            const data = await response.json();

            if (!data.success) {
                mostrarError(data.error || 'No se pudo resolver la integral en la base de conocimientos.');
                return;
            }

            // salio bien
            mostrarResultados(data);

            // actualizar grafico
            const numA = evaluarLimiteNumerico(limitAVal);
            const numB = evaluarLimiteNumerico(limitBVal);
            const fnEvaluator = crearEvaluadorJS(normalizedExpr);
            grapher.setProblem(fnEvaluator, numA, numB);

            // guardar esto
            guardarEnHistorial({
                expr: rawExpr,
                antideriv: data.antiderivative,
                area: data.has_limits ? data.area : null,
                a: limitAVal,
                b: limitBVal,
                date: new Date().toLocaleTimeString()
            });

        } catch (err) {
            mostrarError(`Fallo de conexión con el motor Prolog: ${err.message}. Asegúrate de que el servidor esté en ejecución.`);
        } finally {
            solveBtn.disabled = false;
            solveBtn.innerHTML = '<span class="btn-icon-text">⚡</span> Resolver Integral';
        }
    }

    function mostrarResultados(data) {
        welcomePlaceholder.style.display = 'none';
        errorContainer.style.display = 'none';
        resultsDetails.style.display = 'block';

        // resultado
        const latexAnti = `${data.antiderivative_latex} + C`;
        renderKatex(latexAnti, latexAntiderivative);
        plainAntiderivative.textContent = `${data.antiderivative} + C`;

        // regla usada
        ruleText.textContent = data.rule || 'Regla de integración simbólica';

        // area, si mandaron limites
        if (data.has_limits && data.area !== null) {
            areaResultBlock.style.display = 'block';
            areaValueDisplay.textContent = Number(data.area).toFixed(4);
            faValueDisplay.textContent = Number(data.fa).toFixed(4);
            fbValueDisplay.textContent = Number(data.fb).toFixed(4);

            const barrowLatex = `\\int_{${data.a}}^{${data.b}} f(x) \\, dx = F(${data.b}) - F(${data.a}) = ${Number(data.fb).toFixed(4)} - (${Number(data.fa).toFixed(4)}) = ${Number(data.area).toFixed(4)}`;
            renderKatex(barrowLatex, latexBarrowFormula);
        } else {
            areaResultBlock.style.display = 'none';
        }
    }

    function mostrarError(mensaje) {
        welcomePlaceholder.style.display = 'none';
        resultsDetails.style.display = 'none';
        errorContainer.style.display = 'flex';
        errorMessage.textContent = mensaje;
    }

    function ocultarError() {
        errorContainer.style.display = 'none';
    }

    // pintar ejemplos
    function renderExamples(category) {
        examplesContainer.innerHTML = '';

        const filtrados = category === 'all' 
            ? CATALOGO_REGLAS 
            : CATALOGO_REGLAS.filter(r => r.cat === category);

        filtrados.forEach(item => {
            const div = document.createElement('div');
            div.className = 'example-item';
            div.innerHTML = `
                <span class="example-label">${item.label}</span>
                <span class="example-tag">${item.desc}</span>
            `;

            div.addEventListener('click', () => {
                exprInput.value = item.expr;
                limitAInput.value = item.a;
                limitBInput.value = item.b;
                updateLivePreview();
                resolverIntegral();
                window.scrollTo({ top: 0, behavior: 'smooth' });
            });

            examplesContainer.appendChild(div);
        });
    }

    // historial del navegador
    function loadHistory() {
        const stored = localStorage.getItem('integrals_history');
        if (!stored) {
            historyList.innerHTML = '<li class="history-empty">Aún no hay cálculos en el historial.</li>';
            return;
        }

        try {
            const list = JSON.parse(stored);
            if (!Array.isArray(list) || list.length === 0) {
                historyList.innerHTML = '<li class="history-empty">Aún no hay cálculos en el historial.</li>';
                return;
            }

            historyList.innerHTML = '';
            list.slice(0, 8).forEach(item => {
                const li = document.createElement('li');
                li.className = 'history-item';
                const areaInfo = item.area !== null ? `Área: ${Number(item.area).toFixed(3)} u²` : 'Indefinida';
                li.innerHTML = `
                    <span class="history-expr">∫ ${item.expr} dx</span>
                    <span class="history-area">${areaInfo}</span>
                `;

                li.addEventListener('click', () => {
                    exprInput.value = item.expr;
                    limitAInput.value = item.a || '';
                    limitBInput.value = item.b || '';
                    updateLivePreview();
                    resolverIntegral();
                });

                historyList.appendChild(li);
            });
        } catch (e) {
            historyList.innerHTML = '<li class="history-empty">Error al cargar historial.</li>';
        }
    }

    function guardarEnHistorial(entry) {
        let list = [];
        try {
            const stored = localStorage.getItem('integrals_history');
            if (stored) list = JSON.parse(stored);
        } catch (e) {
            list = [];
        }

        // no repetir el ultimo
        if (list.length > 0 && list[0].expr === entry.expr && list[0].a === entry.a && list[0].b === entry.b) {
            return;
        }

        list.unshift(entry);
        if (list.length > 15) list = list.slice(0, 15);
        localStorage.setItem('integrals_history', JSON.stringify(list));
        loadHistory();
    }

    // ver si responde el servidor
    async function checkServerHealth() {
        try {
            const res = await fetch('/api/health');
            if (res.ok) {
                const data = await res.json();
                const dot = serverStatusBadge.querySelector('.status-dot');
                const text = serverStatusBadge.querySelector('.status-text');
                dot.className = 'status-dot online';
                text.textContent = `Prolog Activo (${data.engine || 'SWI-Prolog'})`;
            } else {
                throw new Error('Status no ok');
            }
        } catch (e) {
            const dot = serverStatusBadge.querySelector('.status-dot');
            const text = serverStatusBadge.querySelector('.status-text');
            dot.className = 'status-dot offline';
            text.textContent = 'Servidor Desconectado';
        }
    }

    // cambiar tema
    function initTheme() {
        const savedTheme = localStorage.getItem('app_theme') || 'dark';
        document.documentElement.setAttribute('data-theme', savedTheme);
        updateThemeUI(savedTheme);

        themeToggleBtn.addEventListener('click', () => {
            const current = document.documentElement.getAttribute('data-theme');
            const next = current === 'dark' ? 'light' : 'dark';
            document.documentElement.setAttribute('data-theme', next);
            localStorage.setItem('app_theme', next);
            updateThemeUI(next);
            grapher.render();
        });
    }

    function updateThemeUI(theme) {
        const darkIcon = themeToggleBtn.querySelector('.theme-icon-dark');
        const lightIcon = themeToggleBtn.querySelector('.theme-icon-light');
        if (theme === 'dark') {
            darkIcon.style.display = 'inline';
            lightIcon.style.display = 'none';
        } else {
            darkIcon.style.display = 'none';
            lightIcon.style.display = 'inline';
        }
    }

    // meter texto donde esta el cursor
    function insertAtCursor(input, text) {
        const start = input.selectionStart || 0;
        const end = input.selectionEnd || 0;
        const val = input.value;

        // si tiene parentesis, dejarlo adentro
        const hasParentheses = text.endsWith('()');
        input.value = val.substring(0, start) + text + val.substring(end);

        const newPos = hasParentheses ? start + text.length - 1 : start + text.length;
        input.setSelectionRange(newPos, newPos);
    }
});
