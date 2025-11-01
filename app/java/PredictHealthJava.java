import javax.swing.*;
import javax.swing.border.EmptyBorder;
import java.awt.*;
import java.awt.event.*;
import java.text.*;
import java.util.*;
import java.io.*;
import javax.swing.text.*;
import javax.swing.text.AbstractDocument;
import javax.swing.text.DocumentFilter;
import javax.swing.text.AttributeSet;
import javax.swing.text.BadLocationException;
import org.json.JSONObject;
import org.json.JSONArray;
import java.util.List;
import java.util.ArrayList;
import java.net.URL;
import java.net.HttpURLConnection;
import java.io.OutputStream;
import java.io.InputStreamReader;
import java.io.BufferedReader;


public class PredictHealthJava extends JFrame {

    private CardLayout cardLayout;
    private JPanel mainPanel;
    private JPanel registerPanel;
    private JPanel step1Panel;
    private JPanel step2Panel;
    private JPanel step3Panel;
    private JPanel step4Panel;
    private JPanel step4_5Panel;
    private JPanel step5Panel;
    private JPanel step6Panel;
    private JPanel step7Panel;
    private JPanel step8Panel;
    private JButton nextButton, prevButton;
    private JLabel edadLabel;
    private JSpinner fechaNacimientoSpinner;

    private JTextField nombreField;
    private JTextField apellidoField;
    private JTextField emailField;
    private JPasswordField passwordField;
    private JPasswordField confirmPasswordField;

    private boolean loggedIn = false;

    private String loginUrl;
    private String registerUrl;
    private String accessToken;

    public PredictHealthJava() {
        loadConfig();

        setTitle("PredictHealthJava");
        setSize(750, 600);
        setDefaultCloseOperation(EXIT_ON_CLOSE);
        setLocationRelativeTo(null);
        setResizable(false);

        cardLayout = new CardLayout();
        mainPanel = new JPanel(cardLayout);
        mainPanel.setBackground(new Color(0x132232));

        mainPanel.add(startPanel(), "Start");
        mainPanel.add(registerPanel(), "Register");
        mainPanel.add(createStep1Panel(), "Step1");
        mainPanel.add(step2Panel(), "Step2");
        mainPanel.add(step3Panel(), "Step3"); 
        mainPanel.add(step4Panel(), "Step4"); 
        mainPanel.add(step4_5Panel(), "Step4_5"); 
        mainPanel.add(step5Panel(), "Step5"); 
        mainPanel.add(step6Panel(), "Step6"); 
        mainPanel.add(step7Panel(), "Step7"); 
        mainPanel.add(step8Panel(), "Step8"); 

        add(mainPanel, BorderLayout.CENTER);

        JPanel navPanel = new JPanel();
        navPanel.setBackground(new Color(0x132232));
        nextButton = createNavButton("Siguiente");
        prevButton = createNavButton("Anterior");

        nextButton.addActionListener(e -> {
            Component visible = getVisiblePanel();
            String name = getPanelName(visible);

            if (name.equals("Register")) sendRegisterData();
            if (name.equals("Step1") && !loggedIn) {
                JOptionPane.showMessageDialog(this, "Please login first.");
                return;
            }

            // Call outputAllFieldsAsJson when on last panel
            if (isLastPanel(visible)) {
                outputAllFieldsAsJson();
                JOptionPane.showMessageDialog(this, "All data collected and output to console.");
                return;
            }

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

        cardLayout.show(mainPanel, "Start");
        updateNavButtons();
    }

    private void loadConfig() {
        Properties props = new Properties();
        try (InputStream in = new FileInputStream("config.properties")) {
            props.load(in);
            loginUrl = props.getProperty("login.url", "http://localhost:8001/auth/login");
            registerUrl = props.getProperty("register.url", "http://localhost:8002/register");
        } catch (IOException e) {
            e.printStackTrace();
            loginUrl = "http://localhost:8001/auth/login";
            registerUrl = "http://localhost:8002/register";
        }
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
        String name = getPanelName(visible);

        boolean showNav = loggedIn && !(name.equals("Start") || name.equals("Register"));
        prevButton.setVisible(showNav);
        nextButton.setVisible(showNav);

        if (showNav) {
            prevButton.setEnabled(true);
            nextButton.setText(isLastPanel(visible) ? "Finalizar" : "Siguiente");
        }
    }

    private boolean isLastPanel(Component comp) {
        return comp == mainPanel.getComponent(mainPanel.getComponentCount() - 1);
    }

    private String getPanelName(Component comp) {
        if (comp == mainPanel.getComponent(0)) return "Start";
        if (comp == mainPanel.getComponent(1)) return "Register";
        if (comp == mainPanel.getComponent(2)) return "Step1";
        if (comp == mainPanel.getComponent(3)) return "Step2";
        if (comp == mainPanel.getComponent(4)) return "Step3";
        if (comp == mainPanel.getComponent(5)) return "Step4";
        if (comp == mainPanel.getComponent(6)) return "Step4_5";
        if (comp == mainPanel.getComponent(7)) return "Step5";
        if (comp == mainPanel.getComponent(8)) return "Step6";
        if (comp == mainPanel.getComponent(9)) return "Step7";
        if (comp == mainPanel.getComponent(10)) return "Step8";
        return "";
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

        JButton loginButton = createNavButton("Iniciar sesión");
        JButton registerButton = createNavButton("Registrarse");

        loginButton.addActionListener(e -> {
            cardLayout.show(mainPanel, "Step1");
            updateNavButtons();
        });
        registerButton.addActionListener(e -> {
            cardLayout.show(mainPanel, "Register");
            updateNavButtons();
        });

        JPanel buttonPanel = new JPanel(new FlowLayout(FlowLayout.CENTER, 40, 10));
        buttonPanel.setBackground(new Color(0x132232));
        buttonPanel.add(loginButton);
        buttonPanel.add(registerButton);

        gbc.gridx = 0; gbc.gridy = 0;
        panel.add(title, gbc);
        gbc.gridy++;
        panel.add(buttonPanel, gbc);

        return panel;
    }

    private JPanel registerPanel() {
        if (registerPanel != null) return registerPanel;

        registerPanel = new JPanel(new GridBagLayout());
        registerPanel.setBackground(new Color(0x132232));
        GridBagConstraints gbc = new GridBagConstraints();
        gbc.insets = new Insets(10, 10, 10, 10);
        gbc.fill = GridBagConstraints.HORIZONTAL;

        JButton backBtn = createNavButton("Atrás");
        backBtn.addActionListener(e -> cardLayout.show(mainPanel, "Start"));
        gbc.gridx = 0; gbc.gridy = 0; gbc.gridwidth = 2; gbc.anchor = GridBagConstraints.WEST;
        registerPanel.add(backBtn, gbc);

        // Email
        gbc.gridy++;
        emailField = createTextField();
        registerPanel.add(new JLabel("Email:") {{
            setForeground(Color.WHITE);
            setFont(new Font("SansSerif", Font.BOLD, 16));
        }}, gbc);
        gbc.gridx = 1;
        registerPanel.add(emailField, gbc);

        // Password
        gbc.gridx = 0; gbc.gridy++;
        passwordField = new JPasswordField();
        passwordField.setPreferredSize(new Dimension(200, 28));
        passwordField.setFont(new Font("SansSerif", Font.PLAIN, 16));
        passwordField.setBackground(new Color(0xF5F2E7));
        passwordField.setForeground(Color.BLACK);
        registerPanel.add(new JLabel("Password:") {{
            setForeground(Color.WHITE);
            setFont(new Font("SansSerif", Font.BOLD, 16));
        }}, gbc);
        gbc.gridx = 1;
        registerPanel.add(passwordField, gbc);

        // Confirm Password
        gbc.gridx = 0; gbc.gridy++;
        confirmPasswordField = new JPasswordField();
        confirmPasswordField.setPreferredSize(new Dimension(200, 28));
        confirmPasswordField.setFont(new Font("SansSerif", Font.PLAIN, 16));
        confirmPasswordField.setBackground(new Color(0xF5F2E7));
        confirmPasswordField.setForeground(Color.BLACK);
        registerPanel.add(new JLabel("Confirm Password:") {{
            setForeground(Color.WHITE);
            setFont(new Font("SansSerif", Font.BOLD, 16));
        }}, gbc);
        gbc.gridx = 1;
        registerPanel.add(confirmPasswordField, gbc);

        // Register button
        gbc.gridx = 0; gbc.gridy++; gbc.gridwidth = 2;
        JButton registerBtn = createNavButton("Registrar");
        registerBtn.addActionListener(e -> {
            if (!String.valueOf(passwordField.getPassword())
                    .equals(String.valueOf(confirmPasswordField.getPassword()))) {
                JOptionPane.showMessageDialog(registerPanel, "Passwords do not match", "Error", JOptionPane.ERROR_MESSAGE);
                return;
            }
            sendRegisterData();
        });
        registerPanel.add(registerBtn, gbc);

        return registerPanel;
    }


    private void sendRegisterData() {
        String email = emailField.getText();
        String password = new String(passwordField.getPassword());
        String confirm = new String(confirmPasswordField.getPassword());

        String json = String.format("{\"email\":\"%s\",\"contraseña\":\"%s\",\"id_rol\":1}", email, password);

        if (!password.equals(confirm)) {
            JOptionPane.showMessageDialog(this, "Passwords do not match", "Error", JOptionPane.ERROR_MESSAGE);
            return;
        }

        try {
            java.net.URL url = new java.net.URL(registerUrl);
            java.net.HttpURLConnection conn = (java.net.HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type","application/json");
            conn.setDoOutput(true);
            try(java.io.OutputStream os = conn.getOutputStream()){ os.write(json.getBytes()); }
            int code = conn.getResponseCode();
            if(code==200) JOptionPane.showMessageDialog(this,"Registration successful!");
            else JOptionPane.showMessageDialog(this,"Registration failed: "+code);
            conn.disconnect();
        } catch(Exception ex){
            JOptionPane.showMessageDialog(this,"Error contacting register service");
            ex.printStackTrace();
        }
    }

    private JPanel createStep1Panel() {
        if (step1Panel != null) return step1Panel;
        step1Panel = new JPanel(new GridBagLayout());
        step1Panel.setBackground(new Color(0x132232));
        step1Panel.setBorder(new EmptyBorder(20,20,20,20));

        GridBagConstraints gbc = new GridBagConstraints();
        gbc.insets = new Insets(8,8,8,8);
        gbc.fill = GridBagConstraints.HORIZONTAL;

        JLabel emailLabel = createLabel("Email:");
        JTextField emailField = createTextField();
        JLabel passwordLabel = createLabel("Password:");
        JPasswordField passwordField = new JPasswordField();
        passwordField.setPreferredSize(new Dimension(200,28));

        gbc.gridx=0; gbc.gridy=0; step1Panel.add(emailLabel, gbc);
        gbc.gridx=1; step1Panel.add(emailField, gbc);
        gbc.gridx=0; gbc.gridy=1; step1Panel.add(passwordLabel, gbc);
        gbc.gridx=1; step1Panel.add(passwordField, gbc);

        JButton loginBtn = createNavButton("Login");
        loginBtn.addActionListener(e -> {
            sendLoginData(emailField.getText(), new String(passwordField.getPassword()));
            updateNavButtons();
        });

        gbc.gridx=0; gbc.gridy=2; gbc.gridwidth=2; step1Panel.add(loginBtn, gbc);

        return step1Panel;
    }

    private void sendLoginData(String username, String password) {
        try {
            String json = String.format("{\"username\":\"%s\",\"password\":\"%s\"}", username, password);
            java.net.URL url = new java.net.URL(loginUrl);
            java.net.HttpURLConnection conn = (java.net.HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type","application/json");
            conn.setDoOutput(true);
            try(java.io.OutputStream os = conn.getOutputStream()){ os.write(json.getBytes()); }
            int code = conn.getResponseCode();
            if (code == 200) {
                try (BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream(), "utf-8"))) {
                    StringBuilder response = new StringBuilder();
                    String line;
                    while ((line = br.readLine()) != null) response.append(line);

                    // parse login response JSON
                    JSONObject resp = new JSONObject(response.toString());
                    String receivedAccessToken = resp.getString("access_token");
                    accessToken = receivedAccessToken; // store in class-level field
                }

                loggedIn = true;
                JOptionPane.showMessageDialog(this, "Login successful!");
                cardLayout.show(mainPanel, "Step2");
            }

            conn.disconnect();
        } catch(Exception ex){
            loggedIn = false;
            JOptionPane.showMessageDialog(this,"Error contacting auth service");
            ex.printStackTrace();
        }
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
        nombreField = createTextField();

        JLabel apellidoLabel = createLabel("Apellido:");
        apellidoField = createTextField();

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

    private String getSelectedMedications() {
        if (step6Panel == null) return "[]"; // empty JSON array

        List<String> selected = new ArrayList<>();
        for (Component comp : step6Panel.getComponents()) {
            if (comp instanceof JCheckBox cb) {
                if (cb.isSelected() && !"Ninguno".equals(cb.getText())) {
                    selected.add(cb.getText());
                }
            }
        }

        return new JSONArray(selected).toString();
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
        box.setFont(new Font("SansSerif", Font.PLAIN, 16));
        return box;
    }

    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> {
            PredictHealthJava app = new PredictHealthJava();
            app.setVisible(true);
        });
    }

    private void outputAllFieldsAsJson() {
        JSONObject paciente = new JSONObject();
        JSONObject salud = new JSONObject();

        // Step 2: Paciente info
        putNotNull(paciente, "nombre", nombreField != null ? nombreField.getText() : "");
        putNotNull(paciente, "apellido", apellidoField != null ? apellidoField.getText() : "");
        Date birth = (fechaNacimientoSpinner != null) ? (Date) fechaNacimientoSpinner.getValue() : null;
        putNotNull(paciente, "fecha_nacimiento", birth != null ? new java.text.SimpleDateFormat("yyyy-MM-dd").format(birth) : "");
        putNotNull(paciente, "sexo", getSelectedButtonText(step2Panel));
        putNotNull(paciente, "fecha", new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date()));

        // Step 3: Salud General
        putNotNull(salud, "salud_general", getSelectedButtonText(step3Panel));

        // Step 4: Historial Médico
        putNotNull(salud, "diabetes", getCheckBoxState(step4Panel, "Diabetes"));
        putNotNull(salud, "hipertension", getCheckBoxState(step4Panel, "Hipertensión"));
        putNotNull(salud, "colesterol", getCheckBoxState(step4Panel, "Colesterol"));
        putNotNull(salud, "colesterol_alto", getCheckBoxState(step4Panel, "Colesterol Alto"));

        // Step 4.5
        putNotNull(salud, "acv", getCheckBoxState(step4_5Panel, "Accidente Cerebrovascular (ACV)"));
        putNotNull(salud, "problemas_corazon", getCheckBoxState(step4_5Panel, "Problemas del Corazón"));

        // Step 5: BMI & presión
        putNotNull(salud, "bmi", getTextFieldValue(step5Panel, 1));
        putNotNull(salud, "presion", getSelectedButtonText(step5Panel));

        // Step 6: Medicamentos
        putNotNull(salud, "medicamentos", getSelectedMedications());

        // Step 7 & 8: Lifestyle
        putNotNull(salud, "frutas", getSelectedButtonText(step7Panel));
        putNotNull(salud, "verduras", getSelectedButtonText(step7Panel));
        putNotNull(salud, "fuma", getSelectedButtonText(step7Panel));
        putNotNull(salud, "alcohol", getSelectedButtonText(step7Panel));
        putNotNull(salud, "movilidad", getSelectedButtonText(step7Panel));
        putNotNull(salud, "actividad_frecuente", getSelectedButtonText(step8Panel));
        putNotNull(salud, "horas_sueno", getTextFieldValue(step8Panel, 0));
        putNotNull(salud, "nivel_estres", getComboBoxSelected(step8Panel, 3));
        putNotNull(salud, "salud_mental", getTextFieldValue(step8Panel, 4));
        putNotNull(salud, "actividad_fisica", getComboBoxSelected(step8Panel, 6));
        putNotNull(salud, "actividad_frecuente2", getSelectedButtonText(step8Panel, "Sí", "No"));
        putNotNull(salud, "salud_fisica", getTextFieldValue(step8Panel, 8));

        // Retrieve user ID from Auth microservice
        String userId = null;
        try {
            URL meUrl = new URL("http://localhost:8001/auth/me");
            HttpURLConnection authConn = (HttpURLConnection) meUrl.openConnection();
            authConn.setRequestMethod("GET");
            authConn.setRequestProperty("Authorization", "Bearer " + accessToken); // token saved from login

            if (authConn.getResponseCode() == 200) {
                try (BufferedReader br = new BufferedReader(new InputStreamReader(authConn.getInputStream(), "utf-8"))) {
                    StringBuilder response = new StringBuilder();
                    String line;
                    while ((line = br.readLine()) != null) response.append(line);
                    JSONObject me = new JSONObject(response.toString());
                    userId = me.getString("sub");
                }
            }
            authConn.disconnect();
        } catch (Exception e) {
            e.printStackTrace();
        }
        if (userId != null) paciente.put("id_usuario", userId);

        // POST Paciente JSON
        try {
            URL url = new URL("http://localhost:8003/paciente");
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/json; utf-8");
            conn.setDoOutput(true);

            try (OutputStream os = conn.getOutputStream()) {
                byte[] input = paciente.toString().getBytes("utf-8");
                os.write(input, 0, input.length);
            }

            int code = conn.getResponseCode();
            System.out.println("POST /paciente -> Response code: " + code);
            conn.disconnect();
        } catch (Exception e) {
            e.printStackTrace();
        }

        System.out.println("Paciente:");
        System.out.println(paciente.toString(4));

        // Still print Salud
        System.out.println("Salud:");
        System.out.println(salud.toString(4));
    }


    // Helper methods
    private int calculateAge(Date birth) {
        Calendar birthCal = Calendar.getInstance();
        birthCal.setTime(birth);
        Calendar today = Calendar.getInstance();
        int age = today.get(Calendar.YEAR) - birthCal.get(Calendar.YEAR);
        if(today.get(Calendar.DAY_OF_YEAR) < birthCal.get(Calendar.DAY_OF_YEAR)) age--;
        return age;
    }

    // Example: get selected radio button text from a panel
    private String getSelectedButtonText(JPanel panel) {
        if (panel == null) return "";  // avoid NPE
        for (Component comp : panel.getComponents()) {
            if (comp instanceof JPanel) {
                for (Component inner : ((JPanel) comp).getComponents()) {
                    if (inner instanceof JRadioButton rb && rb.isSelected()) return rb.getText();
                }
            } else if (comp instanceof JRadioButton rb && rb.isSelected()) {
                return rb.getText();
            }
        }
        return "";
    }


    // Overload with a keyword to find specific group (like "frutas")
    private String getSelectedButtonText(JPanel panel, String option1, String option2) {
        if (panel == null) return "";
        for (Component comp : panel.getComponents()) {
            if (comp instanceof JPanel) {
                for (Component inner : ((JPanel) comp).getComponents()) {
                    if (inner instanceof JRadioButton rb && rb.isSelected()) return rb.getText();
                }
            } else if (comp instanceof JRadioButton rb && rb.isSelected()) {
                return rb.getText();
            }
        }
        // fallback if nothing is selected
        return "";
    }

    private Component getComponentByName(JPanel panel, String name) {
        if (panel == null) return null;
        for (Component c : panel.getComponents()) {
            if (c instanceof JCheckBox cb && cb.getText().equals(name)) return cb;
        }
        return null;
    }

    private boolean getCheckBoxState(JPanel panel, String text) {
        if (panel == null) return false;
        for (Component comp : panel.getComponents()) {
            if (comp instanceof JCheckBox cb && cb.getText().equals(text)) return cb.isSelected();
        }
        return false;
    }

    private String getTextFieldValue(JPanel panel, int index) {
        if (panel == null) return "";
        int count = 0;
        for (Component comp : panel.getComponents()) {
            if (comp instanceof JTextField tf) {
                if (count == index) return tf.getText();
                count++;
            }
        }
        return "";
    }

    // Helper to add values, using empty string if null
    private void putNotNull(org.json.JSONObject obj, String key, Object value) {
        obj.put(key, value != null ? value : "");
    }

    // Helper to get JComboBox selected item or "" if missing/null
    private Object getComboBoxSelected(JPanel panel, int componentIdx) {
        if (panel != null && panel.getComponentCount() > componentIdx && panel.getComponent(componentIdx) instanceof JComboBox<?>) {
            Object selected = ((JComboBox<?>) panel.getComponent(componentIdx)).getSelectedItem();
            return (selected != null) ? selected : "";
        }
        return "";
    }
}
