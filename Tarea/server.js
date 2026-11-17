// servidor node para no depender de levantar prolog a mano

const http = require('http');
const fs = require('fs');
const path = require('path');
const { spawn } = require('child_process');

const PORT = process.env.PORT || 8080;
const FRONTEND_DIR = path.join(__dirname, 'frontend');
const PROLOG_FILE = path.join(__dirname, 'backend', 'integrales.pl').replace(/\\/g, '/');

const MIME_TYPES = {
    '.html': 'text/html; charset=UTF-8',
    '.css': 'text/css; charset=UTF-8',
    '.js': 'application/javascript; charset=UTF-8',
    '.json': 'application/json; charset=UTF-8',
    '.png': 'image/png',
    '.jpg': 'image/jpeg',
    '.svg': 'image/svg+xml',
    '.ico': 'image/x-icon'
};

function resolverConProlog(expr, a, b) {
    return new Promise((resolve, reject) => {
        // por si meten comillas raras en la expresion
        const exprClean = (expr || '').replace(/'/g, "\\'");
        const aClean = a !== null && a !== undefined && a !== '' ? `'${String(a).replace(/'/g, "\\'")}'` : 'null';
        const bClean = b !== null && b !== undefined && b !== '' ? `'${String(b).replace(/'/g, "\\'")}'` : 'null';

        const goal = `resolver_json('${exprClean}', ${aClean}, ${bClean}, Out), write(Out), halt.`;

        const swipl = spawn('swipl', ['-q', '-s', PROLOG_FILE, '-g', goal]);

        let stdout = '';
        let stderr = '';

        swipl.stdout.on('data', data => {
            stdout += data.toString();
        });

        swipl.stderr.on('data', data => {
            stderr += data.toString();
        });

        swipl.on('error', err => {
            reject(new Error(`No se pudo ejecutar SWI-Prolog (swipl): ${err.message}`));
        });

        swipl.on('close', code => {
            if (stdout.trim().length > 0) {
                try {
                    const parsed = JSON.parse(stdout.trim());
                    resolve(parsed);
                } catch (e) {
                    resolve({
                        success: false,
                        error: `Error parseando respuesta de Prolog: ${stdout.trim()} (${stderr})`
                    });
                }
            } else {
                resolve({
                    success: false,
                    error: stderr || `SWI-Prolog finalizó con código de salida ${code} sin respuesta.`
                });
            }
        });
    });
}

const server = http.createServer(async (req, res) => {
    // cors, porque si no el navegador se queja
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

    if (req.method === 'OPTIONS') {
        res.writeHead(204);
        res.end();
        return;
    }

    const url = new URL(req.url, `http://${req.headers.host}`);

    // resolver integral
    if (url.pathname === '/api/solve' && req.method === 'POST') {
        let body = '';
        req.on('data', chunk => {
            body += chunk;
        });

        req.on('end', async () => {
            try {
                const data = JSON.parse(body || '{}');
                const result = await resolverConProlog(data.expr, data.a, data.b);
                res.writeHead(200, { 'Content-Type': 'application/json; charset=UTF-8' });
                res.end(JSON.stringify(result));
            } catch (err) {
                res.writeHead(400, { 'Content-Type': 'application/json; charset=UTF-8' });
                res.end(JSON.stringify({ success: false, error: err.message }));
            }
        });
        return;
    }

    // revisar si sigue vivo
    if (url.pathname === '/api/health' && req.method === 'GET') {
        res.writeHead(200, { 'Content-Type': 'application/json; charset=UTF-8' });
        res.end(JSON.stringify({ status: 'ok', engine: 'Node.js + SWI-Prolog CLI' }));
        return;
    }

    // archivos del frontend
    let filePath = path.join(FRONTEND_DIR, url.pathname === '/' ? 'index.html' : url.pathname);
    const ext = path.extname(filePath).toLowerCase();

    fs.stat(filePath, (err, stats) => {
        if (err || !stats.isFile()) {
            // si no existe, mandamos la pagina principal
            filePath = path.join(FRONTEND_DIR, 'index.html');
        }

        const mime = MIME_TYPES[ext] || 'text/plain; charset=UTF-8';

        fs.readFile(filePath, (readErr, content) => {
            if (readErr) {
                res.writeHead(404, { 'Content-Type': 'text/plain; charset=UTF-8' });
                res.end('404 Not Found');
            } else {
                res.writeHead(200, { 'Content-Type': mime });
                res.end(content);
            }
        });
    });
});

server.listen(PORT, () => {
    console.log(`======================================================`);
    console.log(`  SERVIDOR NODE.JS INICIADO EXITOSAMENTE`);
    console.log(`  URL: http://localhost:${PORT}/`);
    console.log(`  Conectado a SWI-Prolog: ${PROLOG_FILE}`);
    console.log(`======================================================`);
});
