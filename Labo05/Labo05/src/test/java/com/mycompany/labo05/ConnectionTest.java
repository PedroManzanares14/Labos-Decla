package com.mycompany.labo05;

import static org.junit.jupiter.api.Assertions.assertEquals;

import org.junit.jupiter.api.Test;

class ConnectionTest {
    @Test
    void consultaDerivadaDesdeElRecursoProlog() throws Exception {
        Connection connection = new Connection();

        assertEquals("3*x^2", connection.consultar("d", "x^3"));
    }

    @Test
    void consultaIntegralDesdeElRecursoProlog() throws Exception {
        Connection connection = new Connection();

        assertEquals("3*1/3*x^3+4*x", connection.consultar("s", "3*x^2+4"));
    }
}