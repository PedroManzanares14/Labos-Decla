% Pedro Jose Manzanarres Santos 00230422

% servidor web en prolog, version simple

:- module(server, [
    iniciar_servidor/0,
    iniciar_servidor/1,
    detener_servidor/0
]).

:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_json)).
:- use_module(library(http/http_cors)).
:- use_module(library(readutil)).

:- use_module('integrales').

% cors para que el navegador no bloquee todo
:- set_setting(http:cors, [*]).

% rutas de la api
:- http_handler(root(api/solve), handle_solve, [methods([post, options])]).
:- http_handler(root(api/health), handle_health, [methods([get])]).

% rutas de los archivos del frontend
:- http_handler(root(.), serve_index, []).
:- http_handler(root('index.html'), serve_index, []).
:- http_handler(root(css/'styles.css'), serve_css, []).
:- http_handler(root(js/'app.js'), serve_app_js, []).
:- http_handler(root(js/'graph.js'), serve_graph_js, []).
:- http_handler(/, serve_fallback, [prefix]).

% encontrar la carpeta del proyecto
proyecto_dir(ProjectDir) :-
    predicate_property(integrales:integrar(_,_,_), file(IntegFile)),
    file_directory_name(IntegFile, BackendDir),
    file_directory_name(BackendDir, ProjectDir).

% mandar archivos con el tipo correcto
enviar_archivo(RelPath, ContentType, Request) :-
    cors_enable(Request, [methods([get])]),
    proyecto_dir(ProjDir),
    atomic_list_concat([ProjDir, '/frontend/', RelPath], FilePath),
    (   exists_file(FilePath)
    ->  read_file_to_string(FilePath, Content, [encoding(utf8)]),
        format('Content-type: ~w; charset=UTF-8~n~n', [ContentType]),
        write(Content)
    ;   format('Status: 404 Not Found~n'),
        format('Content-type: text/plain; charset=UTF-8~n~n'),
        format('Archivo no encontrado: ~w~n', [RelPath])
    ).

serve_index(Request) :-
    enviar_archivo('index.html', 'text/html', Request).

serve_css(Request) :-
    enviar_archivo('css/styles.css', 'text/css', Request).

serve_app_js(Request) :-
    enviar_archivo('js/app.js', 'application/javascript', Request).

serve_graph_js(Request) :-
    enviar_archivo('js/graph.js', 'application/javascript', Request).

serve_fallback(Request) :-
    enviar_archivo('index.html', 'text/html', Request).

% endpoint para ver si esta vivo
handle_health(_Request) :-
    cors_enable,
    reply_json_dict(_{status: "ok", engine: "SWI-Prolog", version: "2026.2"}).

% aqui se resuelve la integral
handle_solve(Request) :-
    memberchk(method(options), Request),
    !,
    cors_enable,
    format('~n').

handle_solve(Request) :-
    cors_enable,
    http_read_json_dict(Request, DictIn),
    Expr = DictIn.get(expr),
    AVal = DictIn.get(a),
    BVal = DictIn.get(b),
    resolver(Expr, AVal, BVal, DictRes),
    reply_json_dict(DictRes).

% arrancar en 8080 normalmente
iniciar_servidor :-
    iniciar_servidor(8080).

iniciar_servidor(Port) :-
    catch(
        (   http_server(http_dispatch, [port(Port)]),
            format('~n======================================================~n'),
            format('  SERVIDOR SWI-PROLOG INICIADO EXITOSAMENTE~n'),
            format('  URL: http://localhost:~w/~n', [Port]),
            format('  Presione Ctrl+C en esta terminal para detener.~n'),
            format('======================================================~n~n'),
            % que no se cierre luego luego
            repeat,
            sleep(1000),
            fail
        ),
        error(socket_error(eaddrinuse, _), _),
        (   format('El puerto ~w ya esta en uso. Intentando puerto 8088...~n', [Port]),
            iniciar_servidor(8088)
        )
    ).

detener_servidor :-
    http_stop_server(8080, []),
    writeln('Servidor detenido').

% si se corre este archivo directamente
:- initialization(iniciar_servidor, main).
