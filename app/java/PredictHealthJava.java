import javax.swing.*;
import javax.swing.border.EmptyBorder;
import java.awt.*;
import java.awt.event.*;
import java.text.*;
import java.util.*;
import javax.swing.text.AbstractDocument;
import javax.swing.text.DocumentFilter;
import javax.swing.text.AttributeSet;
import javax.swing.text.BadLocationException;

public class PredictHealthJava extends JFrame {

    private CardLayout cardLayout;
    private JPanel mainPanel;
    private JButton nextButton, prevButton;
    private JLabel edadLabel;
    private JSpinner fechaNacimientoSpinner;

    public PredictHealthJava() {
        setTitle("PredictHealthJava");
        setSize(750, 600);
        setDefaultCloseOperation(EXIT_ON_CLOSE);
        setLocationRelativeTo(null);
        setResizable(false);

        cardLayout = new CardLayout();
        mainPanel = new JPanel(cardLayout);
        mainPanel.setBackground(new Color(0x132232));

        mainPanel.add(startPanel(), "Start");
        cardLayout.show(mainPanel, "Start");

        // Step panels
        mainPanel.add(step1Panel(), "Step1");
        mainPanel.add(step2Panel(), "Step2");
        mainPanel.add(step3Panel(), "Step3"); 
        mainPanel.add(step4Panel(), "Step4"); 
        mainPanel.add(step4_5Panel(), "Step4_5"); 
        mainPanel.add(step5Panel(), "Step5"); 
        mainPanel.add(step6Panel(), "Step6"); 
        mainPanel.add(step7Panel(), "Step7"); 
        mainPanel.add(step8Panel(), "Step8"); 
        //mainPanel.add(step9Panel(), "Step9"); 

        add(mainPanel, BorderLayout.CENTER);

        // Navigation buttons
        JPanel navPanel = new JPanel();
        navPanel.setBackground(new Color(0x132232));
        nextButton = createNavButton("Siguiente");
        prevButton = createNavButton("Anterior");
        prevButton.setEnabled(false);

        nextButton.addActionListener(e -> {
            cardLayout.next(mainPanel);
            updateNavButtons();
        });
        prevButton.addActionListener(e -> {
            cardLayout.previous(mainPanel);
            updateNavButtons();
        });

        navPanel.add(prevButton);
        navPanel.add(nextButton);
        add(navPanel, BorderLayout.SOUTH);
    }

    private JButton createNavButton(String text) {
        JButton btn = new JButton(text);
        btn.setForeground(Color.DARK_GRAY);
        btn.setBackground(new Color(0xADC7EA));
        btn.setFocusPainted(false);
        btn.setFont(new Font("SansSerif", Font.BOLD, 16));
        return btn;
    }

    private void updateNavButtons() {
        Component visible = getVisiblePanel();

        // Show nav buttons only if not on start panel
        boolean showNav = visible != mainPanel.getComponent(0);

        prevButton.setVisible(showNav);
        nextButton.setVisible(showNav);

        if (showNav) {
            prevButton.setEnabled(true);
            nextButton.setText(
                visible == mainPanel.getComponent(mainPanel.getComponentCount() - 1)
                ? "Finalizar" : "Siguiente"
            );
        }
    }

    private String getPanelName(Component comp) {
        for (Map.Entry<String, Component> entry : getPanelMap().entrySet()) {
            if (entry.getValue() == comp) return entry.getKey();
        }
        return "";
    }

    private Map<String, Component> getPanelMap() {
        Map<String, Component> map = new HashMap<>();
        for (Component c : mainPanel.getComponents()) {
            map.put(((CardLayout) mainPanel.getLayout()).toString(), c);
        }
        return map;
    }

    private Component getVisiblePanel() {
        for (Component c : mainPanel.getComponents()) {
            if (c.isVisible()) return c;
        }
        return null;
    }

    private JPanel startPanel() {
        JPanel panel = new JPanel(new GridBagLayout());
        panel.setBackground(new Color(0x132232));
        GridBagConstraints gbc = new GridBagConstraints();
        gbc.insets = new Insets(20, 20, 20, 20);

        JLabel title = new JLabel("Bienvenido a PredictHealthJava");
        title.setForeground(Color.WHITE);
        title.setFont(new Font("SansSerif", Font.BOLD, 22));

        // Create buttons
        JButton loginButton = createNavButton("Iniciar sesión");
        JButton registerButton = createNavButton("Registrarse");

        // Add ActionListeners
        loginButton.addActionListener(e -> {
            cardLayout.show(mainPanel, "Step1");
            updateNavButtons();
        });
        registerButton.addActionListener(e -> {
            cardLayout.show(mainPanel, "Step2");
            updateNavButtons();
        });

        // Horizontal layout for buttons
        JPanel buttonPanel = new JPanel(new FlowLayout(FlowLayout.CENTER, 40, 10));
        buttonPanel.setBackground(new Color(0x132232));
        buttonPanel.add(loginButton);
        buttonPanel.add(registerButton);

        gbc.gridx = 0;
        gbc.gridy = 0;
        panel.add(title, gbc);

        gbc.gridy++;
        panel.add(buttonPanel, gbc);

        return panel;
    }


    // Step 1: Email & Password
    private JPanel step1Panel() {
        JPanel panel = new JPanel(new GridBagLayout());
        panel.setBackground(new Color(0x132232));
        panel.setBorder(new EmptyBorder(20, 20, 20, 20));
        GridBagConstraints gbc = new GridBagConstraints();
        gbc.insets = new Insets(8, 8, 8, 8);
        gbc.fill = GridBagConstraints.HORIZONTAL;

        JLabel emailLabel = createLabel("Email:");
        JTextField emailField = createTextField();

        JLabel passwordLabel = createLabel("Password:");
        JPasswordField passwordField = new JPasswordField();
        passwordField.setPreferredSize(new Dimension(200, 28));
        passwordField.setFont(new Font("SansSerif", Font.PLAIN, 16));
        passwordField.setBackground(new Color(0xF5F2E7));
        passwordField.setForeground(Color.BLACK);

        gbc.gridx = 0; gbc.gridy = 0; panel.add(emailLabel, gbc);
        gbc.gridx = 1; panel.add(emailField, gbc);
        gbc.gridx = 0; gbc.gridy++; panel.add(passwordLabel, gbc);
        gbc.gridx = 1; panel.add(passwordField, gbc);

        return panel;
    }

    // Step 2: Usuario info 
    private JPanel step2Panel() {
        JPanel panel = new JPanel(new GridBagLayout());
        panel.setBackground(new Color(0x132232));
        panel.setBorder(new EmptyBorder(20, 20, 20, 20));
        GridBagConstraints gbc = new GridBagConstraints();
        gbc.insets = new Insets(8, 8, 8, 8);
        gbc.fill = GridBagConstraints.HORIZONTAL;

        JLabel nombreLabel = createLabel("Nombre:");
        JTextField nombreField = createTextField();

        JLabel apellidoLabel = createLabel("Apellido:");
        JTextField apellidoField = createTextField();

        JLabel fechaLabel = createLabel("Fecha de nacimiento:");
        SpinnerDateModel dateModel = new SpinnerDateModel();
        fechaNacimientoSpinner = new JSpinner(dateModel);
        fechaNacimientoSpinner.setEditor(new JSpinner.DateEditor(fechaNacimientoSpinner, "yyyy-MM-dd"));
        fechaNacimientoSpinner.setPreferredSize(new Dimension(200,28));
        fechaNacimientoSpinner.addChangeListener(e -> updateEdadLabel());

        edadLabel = createLabel("Edad: ");

        JLabel sexoLabel = createLabel("Sexo:");
        JRadioButton hombreRadio = new JRadioButton("Hombre");
        JRadioButton mujerRadio = new JRadioButton("Mujer");
        JRadioButton otroRadio = new JRadioButton("Otro");
        ButtonGroup sexoGroup = new ButtonGroup();
        sexoGroup.add(hombreRadio); sexoGroup.add(mujerRadio); sexoGroup.add(otroRadio);
        JPanel sexoPanel = new JPanel(new FlowLayout(FlowLayout.LEFT));
        sexoPanel.setBackground(new Color(0x132232));
        sexoPanel.add(hombreRadio); sexoPanel.add(mujerRadio); sexoPanel.add(otroRadio);

        gbc.gridx=0; gbc.gridy=0; panel.add(nombreLabel, gbc);
        gbc.gridx=1; panel.add(nombreField, gbc);
        gbc.gridx=0; gbc.gridy++; panel.add(apellidoLabel, gbc);
        gbc.gridx=1; panel.add(apellidoField, gbc);
        gbc.gridx=0; gbc.gridy++; panel.add(fechaLabel, gbc);
        gbc.gridx=1; panel.add(fechaNacimientoSpinner, gbc);
        gbc.gridx=0; gbc.gridy++; panel.add(edadLabel, gbc);
        gbc.gridx=0; gbc.gridy++; panel.add(sexoLabel, gbc);
        gbc.gridx=1; panel.add(sexoPanel, gbc);

        return panel;
    }

    private void updateEdadLabel() {
        Date birth = (Date) fechaNacimientoSpinner.getValue();
        Calendar birthCal = Calendar.getInstance();
        birthCal.setTime(birth);
        Calendar today = Calendar.getInstance();
        int age = today.get(Calendar.YEAR) - birthCal.get(Calendar.YEAR);
        if(today.get(Calendar.DAY_OF_YEAR) < birthCal.get(Calendar.DAY_OF_YEAR)) age--;
        edadLabel.setText("Edad: " + age);
    }

    // Step 3: Salud General
    private JPanel step3Panel() {
        JPanel panel = new JPanel(new GridBagLayout());
        panel.setBackground(new Color(0x132232));
        panel.setBorder(new EmptyBorder(20, 20, 20, 20));
        GridBagConstraints gbc = new GridBagConstraints();
        gbc.insets = new Insets(10, 10, 10, 10);
        gbc.fill = GridBagConstraints.HORIZONTAL;

        JLabel saludLabel = createLabel("¿Cómo calificaría su nivel de salud general?");
        gbc.gridx = 0; gbc.gridy = 0;
        panel.add(saludLabel, gbc); gbc.gridy++;

        JPanel saludPanel = new JPanel(new FlowLayout(FlowLayout.LEFT));
        saludPanel.setBackground(new Color(0x132232));
        JRadioButton malo = new JRadioButton("Malo"); 
        JRadioButton regular = new JRadioButton("Regular"); 
        JRadioButton bueno = new JRadioButton("Bueno"); 
        JRadioButton muyBueno = new JRadioButton("Muy Bueno"); 
        JRadioButton excelente = new JRadioButton("Excelente");
        ButtonGroup saludGroup = new ButtonGroup();
        saludGroup.add(malo); saludGroup.add(regular); saludGroup.add(bueno); saludGroup.add(muyBueno); saludGroup.add(excelente);
        saludPanel.add(malo); saludPanel.add(regular); saludPanel.add(bueno); saludPanel.add(muyBueno); saludPanel.add(excelente);

        panel.add(saludPanel, gbc);
        return panel;
    }

    // Step 4: Historial Médico
    private JPanel step4Panel() {
        JPanel panel = new JPanel(new GridBagLayout());
        panel.setBackground(new Color(0x132232));
        GridBagConstraints gbc = new GridBagConstraints();
        gbc.insets = new Insets(8, 8, 8, 8);
        gbc.fill = GridBagConstraints.HORIZONTAL;

        JLabel questionLabel = createLabel("¿Ha sido diagnosticado con alguna de estas enfermedades?");
        gbc.gridx = 0;
        gbc.gridy = 0;
        gbc.gridwidth = 2;
        panel.add(questionLabel, gbc);
        gbc.gridwidth = 1;

        JCheckBox diabetesBox = createCheckBox("Diabetes");
        JCheckBox hipertensionBox = createCheckBox("Hipertensión");
        JCheckBox colesterolBox = createCheckBox("Colesterol");
        JCheckBox colesterolAltoBox = createCheckBox("Colesterol Alto");
        colesterolAltoBox.setEnabled(false);

        colesterolBox.addItemListener(e -> {
            colesterolAltoBox.setEnabled(colesterolBox.isSelected());
            if (!colesterolBox.isSelected()) colesterolAltoBox.setSelected(false);
        });

        gbc.gridx = 0;
        gbc.gridy = 1;
        panel.add(diabetesBox, gbc);
        gbc.gridy++;
        panel.add(hipertensionBox, gbc);

        // Colesterol and Colesterol Alto side by side
        gbc.gridx = 0;
        gbc.gridy++;
        panel.add(colesterolBox, gbc);
        gbc.gridx = 1;
        panel.add(colesterolAltoBox, gbc);

        return panel;
    }

    // Step 4.5: ACV y Problemas del corazón
    private JPanel step4_5Panel() {
        JPanel panel = new JPanel(new GridBagLayout());
        panel.setBackground(new Color(0x132232));
        panel.setBorder(new EmptyBorder(20, 20, 20, 20));
        GridBagConstraints gbc = new GridBagConstraints();
        gbc.insets = new Insets(10, 10, 10, 10);
        gbc.fill = GridBagConstraints.HORIZONTAL;

        JLabel questionLabel = createLabel("¿Ha padecido alguna de estas condiciones?");
        gbc.gridx = 0; gbc.gridy = 0; gbc.gridwidth = 2;
        panel.add(questionLabel, gbc);

        JCheckBox acvBox = createCheckBox("Accidente Cerebrovascular (ACV)");
        JCheckBox problemasCorazonBox = createCheckBox("Problemas del Corazón");

        gbc.gridwidth = 1;
        gbc.gridx = 0; gbc.gridy++;
        panel.add(acvBox, gbc);
        gbc.gridx = 1;
        panel.add(problemasCorazonBox, gbc);

        return panel;
    }

    // Step 5: BMI
    private JPanel step5Panel() {
        JPanel panel = new JPanel(new GridBagLayout());
        panel.setBackground(new Color(0x132232));
        panel.setBorder(new EmptyBorder(20, 20, 20, 20));
        GridBagConstraints gbc = new GridBagConstraints();
        gbc.insets = new Insets(10, 10, 10, 10);
        gbc.fill = GridBagConstraints.HORIZONTAL;

        JLabel bmiLabel = createLabel("BMI:");
        JTextField bmiField = createTextField();

        // Only allow decimal numbers
        ((AbstractDocument) bmiField.getDocument()).setDocumentFilter(new DocumentFilter() {
            public void insertString(DocumentFilter.FilterBypass fb, int offset, String string, AttributeSet attr) throws BadLocationException {
                if (string != null && string.matches("[0-9.]*")) {
                    super.insertString(fb, offset, string, attr);
                }
            }

            public void replace(DocumentFilter.FilterBypass fb, int offset, int length, String text, AttributeSet attrs) throws BadLocationException {
                if (text != null && text.matches("[0-9.]*")) {
                    super.replace(fb, offset, length, text, attrs);
                }
            }
        });

        gbc.gridx = 0; gbc.gridy = 0; panel.add(bmiLabel, gbc);
        gbc.gridx = 1; panel.add(bmiField, gbc);

        gbc.gridx = 0; gbc.gridy++;
        panel.add(createLabel("Presión Arterial:"), gbc);
        JPanel presionPanel = new JPanel(new FlowLayout(FlowLayout.LEFT));
        presionPanel.setBackground(new Color(0x132232));
        JRadioButton normal = new JRadioButton("Normal");
        JRadioButton preHip = new JRadioButton("Pre-Hipertensión");
        JRadioButton hipert = new JRadioButton("Hipertensión");
        ButtonGroup presionGroup = new ButtonGroup();
        presionGroup.add(normal);
        presionGroup.add(preHip);
        presionGroup.add(hipert);
        presionPanel.add(normal);
        presionPanel.add(preHip);
        presionPanel.add(hipert);
        gbc.gridx = 1;
        panel.add(presionPanel, gbc);

        return panel;
    }

    // Step 6: Medicamentos
    private JPanel step6Panel() {
        JPanel panel = new JPanel(new GridBagLayout());
        panel.setBackground(new Color(0x132232));
        panel.setBorder(new EmptyBorder(20, 20, 20, 20));
        GridBagConstraints gbc = new GridBagConstraints();
        gbc.insets = new Insets(10, 10, 10, 10);
        gbc.fill = GridBagConstraints.HORIZONTAL;
        gbc.gridx = 0; gbc.gridy = 0;

        JLabel medsLabel = createLabel("¿Toma alguno de estos medicamentos? Seleccione todos los que apliquen:");
        panel.add(medsLabel, gbc); gbc.gridy++;

        JCheckBox ninguno = createCheckBox("Ninguno");
        JCheckBox beta = createCheckBox("Beta blocker");
        JCheckBox diuretico = createCheckBox("Diurético");
        JCheckBox ace = createCheckBox("ACE inhibitor");
        JCheckBox otro = createCheckBox("Otro");

        // Ninguno disables all other options
        ninguno.addItemListener(e -> {
            boolean selected = ninguno.isSelected();
            beta.setEnabled(!selected); diuretico.setEnabled(!selected); ace.setEnabled(!selected); otro.setEnabled(!selected);
            if(selected) { beta.setSelected(false); diuretico.setSelected(false); ace.setSelected(false); otro.setSelected(false); }
        });

        panel.add(ninguno, gbc); gbc.gridy++;
        panel.add(beta, gbc); gbc.gridy++;
        panel.add(diuretico, gbc); gbc.gridy++;
        panel.add(ace, gbc); gbc.gridy++;
        panel.add(otro, gbc);

        return panel;
    }

    // Step 7: Lifestyle part 1
    private JPanel step7Panel() {
        JPanel panel = new JPanel(new GridBagLayout());
        panel.setBackground(new Color(0x132232));
        panel.setBorder(new EmptyBorder(20, 20, 20, 20));
        GridBagConstraints gbc = new GridBagConstraints();
        gbc.insets = new Insets(8, 8, 8, 8);
        gbc.fill = GridBagConstraints.HORIZONTAL;

        JLabel frutasLabel = createLabel("¿Consume frutas diariamente?");
        JRadioButton frutasSi = new JRadioButton("Sí");
        JRadioButton frutasNo = new JRadioButton("No");
        ButtonGroup frutasGroup = new ButtonGroup();
        frutasGroup.add(frutasSi); frutasGroup.add(frutasNo);
        JPanel frutasPanel = new JPanel(new FlowLayout(FlowLayout.LEFT));
        frutasPanel.setBackground(new Color(0x132232));
        frutasPanel.add(frutasSi); frutasPanel.add(frutasNo);

        JLabel verdurasLabel = createLabel("¿Consume verduras diariamente?");
        JRadioButton verdurasSi = new JRadioButton("Sí");
        JRadioButton verdurasNo = new JRadioButton("No");
        ButtonGroup verdurasGroup = new ButtonGroup();
        verdurasGroup.add(verdurasSi); verdurasGroup.add(verdurasNo);
        JPanel verdurasPanel = new JPanel(new FlowLayout(FlowLayout.LEFT));
        verdurasPanel.setBackground(new Color(0x132232));
        verdurasPanel.add(verdurasSi); verdurasPanel.add(verdurasNo);

        JLabel salLabel = createLabel("¿Cuántos gramos de sal consume diariamente?");
        JTextField salField = createTextField();
        ((AbstractDocument) salField.getDocument()).setDocumentFilter(new DocumentFilter() {
            @Override
            public void insertString(FilterBypass fb, int offset, String string, AttributeSet attr) throws BadLocationException {
                if (string.matches("[0-9.]*")) super.insertString(fb, offset, string, attr);
            }
            @Override
            public void replace(FilterBypass fb, int offset, int length, String text, AttributeSet attrs) throws BadLocationException {
                if (text.matches("[0-9.]*")) super.replace(fb, offset, length, text, attrs);
            }
        });

        JLabel fumaLabel = createLabel("¿Fuma?");
        JRadioButton fumaSi = new JRadioButton("Sí");
        JRadioButton fumaNo = new JRadioButton("No");
        ButtonGroup fumaGroup = new ButtonGroup();
        fumaGroup.add(fumaSi); fumaGroup.add(fumaNo);
        JPanel fumaPanel = new JPanel(new FlowLayout(FlowLayout.LEFT));
        fumaPanel.setBackground(new Color(0x132232));
        fumaPanel.add(fumaSi); fumaPanel.add(fumaNo);

        JLabel alcoholLabel = createLabel("¿Consume alcohol en exceso?");
        JRadioButton alcoholSi = new JRadioButton("Sí");
        JRadioButton alcoholNo = new JRadioButton("No");
        ButtonGroup alcoholGroup = new ButtonGroup();
        alcoholGroup.add(alcoholSi); alcoholGroup.add(alcoholNo);
        JPanel alcoholPanel = new JPanel(new FlowLayout(FlowLayout.LEFT));
        alcoholPanel.setBackground(new Color(0x132232));
        alcoholPanel.add(alcoholSi); alcoholPanel.add(alcoholNo);

        JLabel movilidadLabel = createLabel("¿Presenta problemas de movilidad?");
        JRadioButton movilidadSi = new JRadioButton("Sí");
        JRadioButton movilidadNo = new JRadioButton("No");
        ButtonGroup movilidadGroup = new ButtonGroup();
        movilidadGroup.add(movilidadSi); movilidadGroup.add(movilidadNo);
        JPanel movilidadPanel = new JPanel(new FlowLayout(FlowLayout.LEFT));
        movilidadPanel.setBackground(new Color(0x132232));
        movilidadPanel.add(movilidadSi); movilidadPanel.add(movilidadNo);

        gbc.gridx=0; gbc.gridy=0; panel.add(frutasLabel, gbc); gbc.gridx=1; panel.add(frutasPanel, gbc);
        gbc.gridx=0; gbc.gridy++; panel.add(verdurasLabel, gbc); gbc.gridx=1; panel.add(verdurasPanel, gbc);
        gbc.gridx=0; gbc.gridy++; panel.add(salLabel, gbc); gbc.gridx=1; panel.add(salField, gbc);
        gbc.gridx=0; gbc.gridy++; panel.add(fumaLabel, gbc); gbc.gridx=1; panel.add(fumaPanel, gbc);
        gbc.gridx=0; gbc.gridy++; panel.add(alcoholLabel, gbc); gbc.gridx=1; panel.add(alcoholPanel, gbc);
        gbc.gridx=0; gbc.gridy++; panel.add(movilidadLabel, gbc); gbc.gridx=1; panel.add(movilidadPanel, gbc);

        return panel;
    }

    // Step 8: Lifestyle part 2
    private JPanel step8Panel() {
        JPanel panel = new JPanel(new GridBagLayout());
        panel.setBackground(new Color(0x132232));
        panel.setBorder(new EmptyBorder(20, 20, 20, 20));
        GridBagConstraints gbc = new GridBagConstraints();
        gbc.insets = new Insets(8, 8, 8, 8);
        gbc.fill = GridBagConstraints.HORIZONTAL;

        // 2. Horas de sueño
        JLabel horasSuenoLabel = createLabel("¿Cuántas horas duerme de noche en promedio?");
        JTextField horasSuenoField = createTextField();
        ((AbstractDocument) horasSuenoField.getDocument()).setDocumentFilter(new DocumentFilter() {
            @Override
            public void insertString(FilterBypass fb, int offset, String string, AttributeSet attr) throws BadLocationException {
                if (string.matches("[0-9.]*")) super.insertString(fb, offset, string, attr);
            }
            @Override
            public void replace(FilterBypass fb, int offset, int length, String text, AttributeSet attrs) throws BadLocationException {
                if (text.matches("[0-9.]*")) super.replace(fb, offset, length, text, attrs);
            }
        });

        // 3. Nivel de estrés
        JLabel nivelEstresLabel = createLabel("Del 1 al 10, ¿cómo calificaría su nivel de estrés diario?");
        String[] estresOptions = {"1","2","3","4","5","6","7","8","9","10"};
        JComboBox<String> estresCombo = new JComboBox<>(estresOptions);

        // 4. Salud mental
        JLabel saludMentalLabel = createLabel("En los últimos 30 días, ¿cuántos días con mala salud mental tuvo?");
        JTextField saludMentalField = createTextField();
        ((AbstractDocument) saludMentalField.getDocument()).setDocumentFilter(new DocumentFilter() {
            @Override
            public void insertString(FilterBypass fb, int offset, String string, AttributeSet attr) throws BadLocationException {
                if (string.matches("[0-9]*")) super.insertString(fb, offset, string, attr);
            }
            @Override
            public void replace(FilterBypass fb, int offset, int length, String text, AttributeSet attrs) throws BadLocationException {
                if (text.matches("[0-9]*")) super.replace(fb, offset, length, text, attrs);
            }
        });

        // 5. Nivel de actividad física
        JLabel actividadFisicaLabel = createLabel("Del 1 al 5, ¿cómo calificaría su nivel de actividad física?");
        String[] actividadOptions = {"1","2","3","4","5"};
        JComboBox<String> actividadCombo = new JComboBox<>(actividadOptions);

        // 6. Actividad física frecuente
        JLabel actividadFrecuenteLabel = createLabel("¿Hace actividad física 3 o más veces a la semana?");
        JRadioButton actividadSi = new JRadioButton("Sí");
        JRadioButton actividadNo = new JRadioButton("No");
        ButtonGroup actividadGroup = new ButtonGroup();
        actividadGroup.add(actividadSi); actividadGroup.add(actividadNo);
        JPanel actividadPanel = new JPanel(new FlowLayout(FlowLayout.LEFT));
        actividadPanel.setBackground(new Color(0x132232));
        actividadPanel.add(actividadSi); actividadPanel.add(actividadNo);

        // 7. Salud física
        JLabel saludFisicaLabel = createLabel("En los últimos 30 días, ¿cuántos días con mala salud física tuvo?");
        JTextField saludFisicaField = createTextField();
        ((AbstractDocument) saludFisicaField.getDocument()).setDocumentFilter(new DocumentFilter() {
            @Override
            public void insertString(FilterBypass fb, int offset, String string, AttributeSet attr) throws BadLocationException {
                if (string.matches("[0-9]*")) super.insertString(fb, offset, string, attr);
            }
            @Override
            public void replace(FilterBypass fb, int offset, int length, String text, AttributeSet attrs) throws BadLocationException {
                if (text.matches("[0-9]*")) super.replace(fb, offset, length, text, attrs);
            }
        });

        gbc.gridx=0; gbc.gridy=0; panel.add(horasSuenoLabel, gbc); gbc.gridx=1; panel.add(horasSuenoField, gbc);
        gbc.gridx=0; gbc.gridy++; panel.add(nivelEstresLabel, gbc); gbc.gridx=1; panel.add(estresCombo, gbc);
        gbc.gridx=0; gbc.gridy++; panel.add(saludMentalLabel, gbc); gbc.gridx=1; panel.add(saludMentalField, gbc);
        gbc.gridx=0; gbc.gridy++; panel.add(actividadFisicaLabel, gbc); gbc.gridx=1; panel.add(actividadCombo, gbc);
        gbc.gridx=0; gbc.gridy++; panel.add(actividadFrecuenteLabel, gbc); gbc.gridx=1; panel.add(actividadPanel, gbc);
        gbc.gridx=0; gbc.gridy++; panel.add(saludFisicaLabel, gbc); gbc.gridx=1; panel.add(saludFisicaField, gbc);

        return panel;
    }


    // Step 9: Documentos
    /*private JPanel step9Panel() {
        JPanel panel = new JPanel(new GridBagLayout());
        panel.setBackground(new Color(0x132232));
        panel.setBorder(new EmptyBorder(20, 20, 20, 20));
        GridBagConstraints gbc = new GridBagConstraints();
        gbc.insets = new Insets(8, 8, 8, 8);
        gbc.fill = GridBagConstraints.HORIZONTAL;

        JLabel tipoDocLabel = createLabel("Tipo de documento:");
        JTextField tipoDocField = createTextField();
        JLabel valorDocLabel = createLabel("Valor del documento:");
        JTextField valorDocField = createTextField();

        gbc.gridx=0; gbc.gridy=0; panel.add(tipoDocLabel, gbc); gbc.gridx=1; panel.add(tipoDocField, gbc);
        gbc.gridx=0; gbc.gridy++; panel.add(valorDocLabel, gbc); gbc.gridx=1; panel.add(valorDocField, gbc);

        return panel;
    }*/


    private JLabel createLabel(String text) {
        JLabel lbl = new JLabel(text);
        lbl.setForeground(Color.WHITE);
        lbl.setFont(new Font("SansSerif", Font.BOLD, 16));
        return lbl;
    }

    private JTextField createTextField() {
        JTextField field = new JTextField();
        field.setPreferredSize(new Dimension(200,28));
        field.setFont(new Font("SansSerif", Font.PLAIN,16));
        field.setBackground(new Color(0xF5F2E7));
        field.setForeground(Color.BLACK);
        return field;
    }

    private JCheckBox createCheckBox(String text) {
        JCheckBox box = new JCheckBox(text);
        box.setForeground(Color.WHITE);
        box.setBackground(new Color(0x132232));
        box.setFont(new Font("SansSerif", Font.PLAIN,16));
        return box;
    }

    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> {
            PredictHealthJava app = new PredictHealthJava();
            app.setVisible(true);
        });
    }
}
