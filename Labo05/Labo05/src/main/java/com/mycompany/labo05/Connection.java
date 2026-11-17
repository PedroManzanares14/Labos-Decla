package com.mycompany.labo05;

import alice.tuprolog.Prolog;
import alice.tuprolog.SolveInfo;
import alice.tuprolog.Struct;
import alice.tuprolog.Term;
import alice.tuprolog.Theory;

import java.io.InputStream;

public class Connection {
    private final Prolog engine = new Prolog();

    public Connection() throws Exception {
        try (InputStream input = getClass().getResourceAsStream("/calculo.pl")) {
            if (input == null) {
                throw new IllegalStateException("No se encontro calculo.pl");
            }
            engine.setTheory(new Theory(input));
        }
    }

    public String consultar(String predicado, String expresion) throws Exception {
        SolveInfo info = engine.solve(predicado + "(x, " + expresion + ", R).");
        return info.isSuccess() ? format(info.getTerm("R"))
                : "Sin solucion para esa expresion";
    }

    private String format(Term term) {
        term.resolveTerm();
        term = term.getTerm();
        if (!(term instanceof Struct)) {
            return term.toString();
        }
        Struct structure = (Struct) term;
        String name = structure.getName().replace("'", "");
        if (structure.getArity() == 1) {
            return name + "(" + format(structure.getArg(0)) + ")";
        }
        if (structure.getArity() != 2 || !"+-*/^".contains(name)) {
            return engine.toString(term);
        }
        return format(structure.getArg(0)) + name + format(structure.getArg(1));
    }
}