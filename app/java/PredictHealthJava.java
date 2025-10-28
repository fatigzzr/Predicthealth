import javax.swing.*;
import javax.swing.border.EmptyBorder;
import java.awt.*;
import java.awt.event.*;
import java.util.*;

public class PredictHealthJava extends JFrame {
    private CardLayout cardLayout;
    private JPanel mainPanel;
    private JButton nextButton, prevButton;
    private JProgressBar progressBar;
    
    // Step components
    private JTextField nombreField, apellidoField, emailField, passwordField, fechaField, edadField;
    private JCheckBox diabetesBox, hipertensionBox, colesterolBox, colesterolAltoBox;
    private JCheckBox medicacionNingunaBox, medicacionBetaBox, medicacionDiureticoBox, medicacionAceBox, medicacionOtroBox;
    private JTextField bmiField, salField, horasSuenoField, nivelEstresField, diasSaludMentalField, diasSaludFisicaField;
    private JCheckBox fumaBox, alcoholBox, dificultadMovBox, actividad3VecesBox;
    private JTextField actividadFisicaField, tipoDocField, valorDocField;

    private int currentStep = 0;
    private int totalSteps = 5;

    public PredictHealthJava() {
        setTitle("PredictHealthJava");
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setSize(600, 600);
        setLocationRelativeTo(null);

        // Set dark theme
        UIManager.put("Panel.background", new Color(0x132232));
        UIManager.put("Button.background", new Color(0xADC7EA));
        UIManager.put("Button.foreground", Color.BLACK);
        UIManager.put("Label.foreground", Color.WHITE);
        UIManager.put("TextField.background", Color.WHITE);
        UIManager.put("TextField.foreground", Color.BLACK);
        UIManager.put("CheckBox.background", new Color(0x132232));
        UIManager.put("CheckBox.foreground", Color.WHITE);

        cardLayout = new CardLayout();
        mainPanel = new JPanel(cardLayout);
        mainPanel.setBorder(new EmptyBorder(10, 10, 10, 10));

        // Steps
        mainPanel.add(step1Panel(), "0");
        mainPanel.add(step2Panel(), "1");
        mainPanel.add(step3Panel(), "2");
        mainPanel.add(step4Panel(), "3");
        mainPanel.add(step5Panel(), "4");

        // Navigation
        nextButton = new JButton("Next");
        prevButton = new JButton("Previous");
        nextButton.addActionListener(e -> nextStep());
        prevButton.addActionListener(e -> prevStep());

        progressBar = new JProgressBar(0, totalSteps);
        progressBar.setValue(0);
        progressBar.setStringPainted(true);
        progressBar.setForeground(new Color(0xADC7EA));
        progressBar.setBackground(new Color(0x132232));

        JPanel navPanel = new JPanel(new BorderLayout());
        navPanel.setBackground(new Color(0x132232));
        navPanel.add(prevButton, BorderLayout.WEST);
        navPanel.add(progressBar, BorderLayout.CENTER);
        navPanel.add(nextButton, BorderLayout.EAST);

        add(mainPanel, BorderLayout.CENTER);
        add(navPanel, BorderLayout.SOUTH);

        updateNav();
    }

    private JPanel step1Panel() {
        JPanel panel = new JPanel(new GridBagLayout());
        panel.setBackground(new Color(0x132232));
        GridBagConstraints gbc = new GridBagConstraints();
        gbc.insets = new Insets(5,5,5,5);
        gbc.fill = GridBagConstraints.HORIZONTAL;
        gbc.gridx = 0; gbc.gridy = 0;

        panel.add(new JLabel("Nombre:"), gbc);
        gbc.gridx = 1;
        nombreField = new JTextField(20);
        panel.add(nombreField, gbc);

        gbc.gridx = 0; gbc.gridy++;
        panel.add(new JLabel("Apellido:"), gbc);
        gbc.gridx = 1;
        apellidoField = new JTextField(20);
        panel.add(apellidoField, gbc);

        gbc.gridx = 0; gbc.gridy++;
        panel.add(new JLabel("Email:"), gbc);
        gbc.gridx = 1;
        emailField = new JTextField(20);
        panel.add(emailField, gbc);

        gbc.gridx = 0; gbc.gridy++;
        panel.add(new JLabel("Password:"), gbc);
        gbc.gridx = 1;
        passwordField = new JPasswordField(20);
        panel.add(passwordField, gbc);

        gbc.gridx = 0; gbc.gridy++;
        panel.add(new JLabel("Fecha de Nacimiento (yyyy-MM-dd):"), gbc);
        gbc.gridx = 1;
        fechaField = new JTextField(20);
        panel.add(fechaField, gbc);

        gbc.gridx = 0; gbc.gridy++;
        panel.add(new JLabel("Edad:"), gbc);
        gbc.gridx = 1;
        edadField = new JTextField(5);
        edadField.setEditable(false);
        panel.add(edadField, gbc);

        // Update age on date change
        fechaField.addFocusListener(new FocusAdapter() {
            @Override
            public void focusLost(FocusEvent e) {
                String text = fechaField.getText();
                try {
                    String[] parts = text.split("-");
                    int year = Integer.parseInt(parts[0]);
                    int month = Integer.parseInt(parts[1]) - 1;
                    int day = Integer.parseInt(parts[2]);
                    Calendar birth = Calendar.getInstance();
                    birth.set(year, month, day);
                    Calendar now = Calendar.getInstance();
                    int age = now.get(Calendar.YEAR) - birth.get(Calendar.YEAR);
                    if (now.get(Calendar.DAY_OF_YEAR) < birth.get(Calendar.DAY_OF_YEAR)) age--;
                    edadField.setText(String.valueOf(age));
                } catch (Exception ex) {
                    edadField.setText("");
                }
            }
        });

        return panel;
    }

    private JPanel step2Panel() {
        JPanel panel = new JPanel(new GridLayout(0, 1));
        panel.setBackground(new Color(0x132232));

        panel.add(new JLabel("Historial Médico:"));

        diabetesBox = new JCheckBox("Diabetes");
        hipertensionBox = new JCheckBox("Hipertensión");
        colesterolBox = new JCheckBox("Colesterol");
        colesterolAltoBox = new JCheckBox("Colesterol Alto");
        colesterolAltoBox.setEnabled(false);

        colesterolBox.addActionListener(e -> colesterolAltoBox.setEnabled(colesterolBox.isSelected()));

        panel.add(diabetesBox);
        panel.add(hipertensionBox);
        panel.add(colesterolBox);
        panel.add(colesterolAltoBox);

        panel.add(new JLabel("BMI:"));
        bmiField = new JTextField(5);
        panel.add(bmiField);

        panel.add(new JLabel("Medicación:"));
        medicacionNingunaBox = new JCheckBox("Ninguna");
        medicacionBetaBox = new JCheckBox("Beta blocker");
        medicacionDiureticoBox = new JCheckBox("Diurético");
        medicacionAceBox = new JCheckBox("ACE inhibitor");
        medicacionOtroBox = new JCheckBox("Otro");
        panel.add(medicacionNingunaBox);
        panel.add(medicacionBetaBox);
        panel.add(medicacionDiureticoBox);
        panel.add(medicacionAceBox);
        panel.add(medicacionOtroBox);

        return panel;
    }

    private JPanel step3Panel() {
        JPanel panel = new JPanel(new GridLayout(0, 1));
        panel.setBackground(new Color(0x132232));

        panel.add(new JLabel("Estilo de Vida:"));

        fumaBox = new JCheckBox("Fuma");
        alcoholBox = new JCheckBox("Alcohol Exceso");
        dificultadMovBox = new JCheckBox("Dificultad Movilidad");
        actividad3VecesBox = new JCheckBox("Actividad ≥3 veces semana");

        panel.add(fumaBox);
        panel.add(alcoholBox);
        panel.add(dificultadMovBox);
        panel.add(actividad3VecesBox);

        panel.add(new JLabel("Sal diaria (g):"));
        salField = new JTextField(5);
        panel.add(salField);

        panel.add(new JLabel("Horas de sueño:"));
        horasSuenoField = new JTextField(5);
        panel.add(horasSuenoField);

        panel.add(new JLabel("Nivel de estrés:"));
        nivelEstresField = new JTextField(5);
        panel.add(nivelEstresField);

        panel.add(new JLabel("Días de salud mental:"));
        diasSaludMentalField = new JTextField(5);
        panel.add(diasSaludMentalField);

        panel.add(new JLabel("Actividad física:"));
        actividadFisicaField = new JTextField(20);
        panel.add(actividadFisicaField);

        panel.add(new JLabel("Días de salud física:"));
        diasSaludFisicaField = new JTextField(5);
        panel.add(diasSaludFisicaField);

        return panel;
    }

    private JPanel step4Panel() {
        JPanel panel = new JPanel(new GridLayout(0, 1));
        panel.setBackground(new Color(0x132232));
        panel.add(new JLabel("Documentos:"));

        panel.add(new JLabel("Tipo:"));
        tipoDocField = new JTextField(10);
        panel.add(tipoDocField);

        panel.add(new JLabel("Valor:"));
        valorDocField = new JTextField(10);
        panel.add(valorDocField);

        return panel;
    }

    private JPanel step5Panel() {
        JPanel panel = new JPanel();
        panel.setBackground(new Color(0x132232));
        JLabel label = new JLabel("Fin del cuestionario. Presiona Next para enviar.");
        label.setForeground(Color.WHITE);
        panel.add(label);
        return panel;
    }

    private void nextStep() {
        if (currentStep < totalSteps - 1) currentStep++;
        else submitForm();
        cardLayout.show(mainPanel, String.valueOf(currentStep));
        updateNav();
    }

    private void prevStep() {
        if (currentStep > 0) currentStep--;
        cardLayout.show(mainPanel, String.valueOf(currentStep));
        updateNav();
    }

    private void updateNav() {
        prevButton.setEnabled(currentStep > 0);
        progressBar.setValue(currentStep);
    }

    private void submitForm() {
        JOptionPane.showMessageDialog(this, "Formulario enviado!");
        // Here you can serialize data or call backend API
    }

    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> {
            PredictHealthJava app = new PredictHealthJava();
            app.setVisible(true);
        });
    }
}
