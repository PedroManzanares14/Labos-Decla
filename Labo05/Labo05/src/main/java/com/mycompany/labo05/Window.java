package com.mycompany.labo05;

import javax.swing.BorderFactory;
import javax.swing.Box;
import javax.swing.BoxLayout;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;
import javax.swing.JTextField;
import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.Font;
import java.awt.Toolkit;
import java.awt.datatransfer.StringSelection;

public class Window extends JFrame {
    private static final Color BACKGROUND = new Color(0x1E1F29);
    private static final Color CARD = new Color(0x2A2B3A);
    private static final Color BORDER = new Color(0x3A3C52);
    private static final Color TEXT = new Color(0xF2F3F8);
    private static final Color MUTED = new Color(0x9096B0);
    private static final Color BLUE = new Color(0x6C8CFF);
    private static final Color GREEN = new Color(0x3DDC97);
    private static final Color AMBER = new Color(0xFFC857);
    private static final Color RED = new Color(0xFF6B6B);

    private final JTextField input = new JTextField();
    private final JTextArea result = new JTextArea(5, 34);
    private final JLabel status = new JLabel(" ");

    public Window(Connection connection) {
        super("Calculo simbolico en Prolog");
        setDefaultCloseOperation(EXIT_ON_CLOSE);
        setMinimumSize(new Dimension(680, 520));

        input.setFont(new Font(Font.MONOSPACED, Font.PLAIN, 18));
        input.setBackground(CARD);
        input.setForeground(TEXT);
        input.setCaretColor(TEXT);
        input.setBorder(BorderFactory.createCompoundBorder(
                BorderFactory.createLineBorder(BORDER),
                BorderFactory.createEmptyBorder(10, 12, 10, 12)));
        input.addActionListener(event -> execute(connection, "d"));

        result.setEditable(false);
        result.setLineWrap(true);
        result.setWrapStyleWord(true);
        result.setFont(new Font(Font.MONOSPACED, Font.PLAIN, 17));
        result.setBackground(CARD);
        result.setForeground(TEXT);
        result.setBorder(BorderFactory.createEmptyBorder(12, 14, 12, 14));

        JPanel content = new JPanel();
        content.setLayout(new BoxLayout(content, BoxLayout.Y_AXIS));
        content.setOpaque(false);
        addSection(content, label("Funcion f(x)"));
        addSection(content, input);
        addSection(content, examples());
        addSection(content, buttons(connection));
        addSection(content, label("Resultado"));
        addSection(content, new JScrollPane(result));
        addSection(content, footer());

        JPanel root = new JPanel(new BorderLayout(0, 18));
        root.setBackground(BACKGROUND);
        root.setBorder(BorderFactory.createEmptyBorder(24, 28, 24, 28));
        root.add(header(), BorderLayout.NORTH);
        root.add(content, BorderLayout.CENTER);
        setContentPane(root);
        pack();
        setLocationRelativeTo(null);
    }

    private JPanel header() {
        JPanel panel = new JPanel();
        panel.setLayout(new BoxLayout(panel, BoxLayout.Y_AXIS));
        panel.setOpaque(false);
        JLabel title = label("Calculo simbolico");
        title.setFont(new Font(Font.SANS_SERIF, Font.BOLD, 25));
        title.setForeground(TEXT);
        panel.add(title);
        panel.add(label("Derivadas e integrales resueltas con reglas en Prolog"));
        return panel;
    }

    private JPanel examples() {
        JPanel panel = new JPanel(new FlowLayout(FlowLayout.LEFT, 6, 0));
        panel.setOpaque(false);
        panel.add(label("Ejemplos:"));
        for (String example : new String[]{"x", "log(x)", "3*x^2", "3*x^2 + 4"}) {
            JButton button = button(example, CARD, TEXT);
            button.addActionListener(event -> input.setText(example));
            panel.add(button);
        }
        return panel;
    }

    private JPanel buttons(Connection connection) {
        JPanel panel = new JPanel(new FlowLayout(FlowLayout.LEFT, 10, 0));
        panel.setOpaque(false);
        JButton derivative = button("Derivar", BLUE, BACKGROUND);
        JButton integral = button("Integrar", GREEN, BACKGROUND);
        derivative.addActionListener(event -> execute(connection, "d"));
        integral.addActionListener(event -> execute(connection, "s"));
        panel.add(derivative);
        panel.add(integral);
        return panel;
    }

    private JPanel footer() {
        JPanel panel = new JPanel(new BorderLayout());
        panel.setOpaque(false);
        status.setForeground(MUTED);
        JButton copy = button("Copiar", CARD, TEXT);
        copy.addActionListener(event -> copyResult());
        panel.add(status, BorderLayout.WEST);
        panel.add(copy, BorderLayout.EAST);
        return panel;
    }

    private void execute(Connection connection, String predicate) {
        String expression = input.getText().trim();
        if (expression.isEmpty()) {
            showResult("Escribe una funcion primero.", "Aviso", AMBER);
            return;
        }
        try {
            String value = connection.consultar(predicate, expression);
            boolean success = !value.startsWith("Sin solucion");
            showResult(value, success ? "Listo" : "Aviso", success ? GREEN : AMBER);
        } catch (Exception exception) {
            showResult("Expresion invalida: " + exception.getMessage(), "Error", RED);
        }
    }

    private void showResult(String text, String message, Color color) {
        result.setText(text);
        status.setText(message);
        status.setForeground(color);
    }

    private void copyResult() {
        if (!result.getText().isEmpty()) {
            Toolkit.getDefaultToolkit().getSystemClipboard()
                    .setContents(new StringSelection(result.getText()), null);
            status.setText("Copiado");
            status.setForeground(BLUE);
        }
    }

    private static void addSection(JPanel panel, java.awt.Component component) {
        component.setMaximumSize(new Dimension(Integer.MAX_VALUE,
                component.getPreferredSize().height));
        panel.add(component);
        panel.add(Box.createVerticalStrut(10));
    }

    private static JLabel label(String text) {
        JLabel label = new JLabel(text);
        label.setForeground(MUTED);
        label.setFont(new Font(Font.SANS_SERIF, Font.BOLD, 12));
        return label;
    }

    private static JButton button(String text, Color background, Color foreground) {
        JButton button = new JButton(text);
        button.setFont(new Font(Font.SANS_SERIF, Font.BOLD, 13));
        button.setBackground(background);
        button.setForeground(foreground);
        button.setFocusPainted(false);
        button.setBorder(BorderFactory.createEmptyBorder(10, 18, 10, 18));
        return button;
    }
}