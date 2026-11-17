/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 */

package com.mycompany.labo05;

import javax.swing.SwingUtilities;

public class Labo05 {

    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> {
            try {
                new Window(new Connection()).setVisible(true);
            } catch (Exception exception) {
                throw new IllegalStateException("No se pudo iniciar Prolog", exception);
            }
        });
    }
}
