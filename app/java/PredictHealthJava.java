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
import java.net.InetSocketAddress;
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
    private String logoutUrl;
    private String authMeUrl;
    private String pacienteUrl;
    private String estiloVidaUrl;
    // predictUrl already present
    private String predictUrl;

    private JPanel sexoPanel;
    private JPanel saludPanel;
    private JPanel presionPanel;
    private JPanel frutasPanel;
    private JPanel verdurasPanel;
    private JPanel fumaPanel;
    private JPanel alcoholPanel;
    private JPanel movilidadPanel;
    private JTextField salField;
    private JPanel statusPanel;
    // Charts and last values
    private PieChartPanel diabChart;
    private PieChartPanel hipChart;
    private double lastDiabetesPct = 55.0;
    private double lastHypertensionPct = 28.0;
    private String lastUserId = null;
    // network timeouts (ms)
    private final int CONNECT_TIMEOUT = 15000;
    private final int READ_TIMEOUT = 15000;
    
    public PredictHealthJava() {
        loadConfig();
        System.setProperty("java.net.preferIPv4Stack", "true");
        System.setProperty("java.net.preferIPv6Addresses", "false");
        // Clear common JVM proxy properties which can interfere with direct connections
        try {
            System.clearProperty("http.proxyHost");
            System.clearProperty("http.proxyPort");
            System.clearProperty("https.proxyHost");
            System.clearProperty("https.proxyPort");
            System.clearProperty("socksProxyHost");
            System.clearProperty("socksProxyPort");
        } catch (Exception ex) {
            // ignore
        }

        setTitle("PredictHealth");
        setSize(750, 600);
        setDefaultCloseOperation(EXIT_ON_CLOSE);
        setLocationRelativeTo(null);
        setResizable(false);

        cardLayout = new CardLayout();
        mainPanel = new JPanel(cardLayout);
        mainPanel.setBackground(new Color(0x132232));

        mainPanel.add(startPanel(), "Start");
        mainPanel.add(registerPanel(), "Register");
        step1Panel = createStep1Panel();
        mainPanel.add(step1Panel, "Step1");
        statusPanel = statusPanel();
        mainPanel.add(statusPanel, "Status");
        step2Panel = step2Panel();
        mainPanel.add(step2Panel, "Step2");
        step3Panel = step3Panel();
        mainPanel.add(step3Panel, "Step3");
        step4Panel = step4Panel();
        mainPanel.add(step4Panel, "Step4");
        step4_5Panel = step4_5Panel();
        mainPanel.add(step4_5Panel, "Step4_5");
        step5Panel = step5Panel();
        mainPanel.add(step5Panel, "Step5");
        step6Panel = step6Panel();
        mainPanel.add(step6Panel, "Step6");
        step7Panel = step7Panel();
        mainPanel.add(step7Panel, "Step7");
        step8Panel = step8Panel();
        mainPanel.add(step8Panel, "Step8");

        add(mainPanel, BorderLayout.CENTER);

        JPanel navPanel = new JPanel();
        navPanel.setBackground(new Color(0x132232));
        nextButton = createNavButton("Siguiente");
        prevButton = createNavButton("Anterior");

        nextButton.addActionListener(e -> {
            if (!validateCurrentStep()) return;
                Component visible = getVisiblePanel();
                String name = getPanelName(visible);

                if (name.equals("Register")) sendRegisterData();
                if (name.equals("Step1") && !loggedIn) {
                    JOptionPane.showMessageDialog(this, "Por favor inicie sesión primero.");
                    return;
                }

                // Call outputAllFieldsAsJson when on last panel
                if (isLastPanel(visible)) {
                    // run final save+prediction in background to avoid blocking EDT
                    nextButton.setEnabled(false);
                    prevButton.setEnabled(false);
                    setCursor(Cursor.getPredefinedCursor(Cursor.WAIT_CURSOR));

                    SwingWorker<Boolean, Void> worker = new SwingWorker<>() {
                        private String messageToShow = null;
                        private boolean success = false;

                        @Override
                        protected Boolean doInBackground() throws Exception {
                            boolean dataSaved = outputAllFieldsAsJson();
                            if (!dataSaved) {
                                messageToShow = "Error guardando los datos. No se puede hacer la predicción.";
                                success = false;
                                return false;
                            }
                            // small pause to allow DB commit
                            try { Thread.sleep(1000); } catch (InterruptedException ie) { Thread.currentThread().interrupt(); }

                            // use lastUserId set by outputAllFieldsAsJson to call predict; avoid extra auth/me
                            String userId = lastUserId;
                            if (userId != null) {
                                try {
                                    System.out.println("Calling predict for userId=" + userId);
                                    String basePredict = predictUrl;
                                    if (!basePredict.endsWith("/")) basePredict = basePredict + "/";
                                    URL predUrl = new URL(basePredict + userId);
                                    // perform a quick TCP-level check first to help diagnose JVM-level networking issues
                                    int testPort = predUrl.getPort() > 0 ? predUrl.getPort() : ("https".equalsIgnoreCase(predUrl.getProtocol()) ? 443 : 80);
                                    if (!socketConnectTest(predUrl.getHost(), testPort, 5000)) {
                                        messageToShow = "No se pudo establecer conexión TCP a " + predUrl.getHost() + ":" + testPort + ". Verifique conectividad o proxy JVM.";
                                        success = false;
                                        return success;
                                    }
                                    HttpURLConnection predConn = (HttpURLConnection) predUrl.openConnection();
                                    predConn.setRequestMethod("GET");
                                    predConn.setRequestProperty("Accept", "application/json");
                                    predConn.setConnectTimeout(CONNECT_TIMEOUT);
                                    predConn.setReadTimeout(READ_TIMEOUT);
                                    int respCode = predConn.getResponseCode();
                                    if (respCode == 200) {
                                        try (BufferedReader br = new BufferedReader(new InputStreamReader(predConn.getInputStream(), "utf-8"))) {
                                            StringBuilder predResp = new StringBuilder();
                                            String line;
                                            while ((line = br.readLine()) != null) predResp.append(line);
                                            JSONObject jsonResp = new JSONObject(predResp.toString());
                                            JSONObject prediction = jsonResp.has("prediction") ? jsonResp.getJSONObject("prediction") : null;
                                            if (prediction != null) {
                                                double pct = prediction.optDouble("percentage", -1);
                                                String cat = prediction.optString("risk_label", "Desconocido");
                                                messageToShow = String.format("Probabilidad de diabetes: %.1f%%\nCategoría de riesgo: %s", pct, cat);
                                                if (pct >= 0) {
                                                    lastDiabetesPct = pct;
                                                    if (diabChart != null) diabChart.setPercentage((int)Math.round(pct));
                                                    String redisKey = (userId != null && !userId.isEmpty()) ? ("user:" + userId + ":diabetes_probability") : "predict:diabetes:last";
                                                    saveToRedis(redisKey, String.valueOf(pct));
                                                }
                                                success = true;
                                            } else {
                                                messageToShow = "¡No se recibió predicción!";
                                                success = false;
                                            }
                                        }
                                    } else {
                                        messageToShow = "Error consultando el microservicio de predicción: respuesta " + respCode;
                                        success = false;
                                    }
                                    predConn.disconnect();
                                } catch (java.net.ConnectException ce) {
                                    messageToShow = "No se pudo conectar al microservicio de predicción (timeout).";
                                    success = false;
                                } catch (Exception ex) {
                                    messageToShow = "Error en la predicción: " + ex.getMessage();
                                    success = false;
                                }
                            } else {
                                messageToShow = "ID de usuario no disponible. No se puede hacer la predicción.";
                                success = false;
                            }

                            return success;
                        }

                        @Override
                        protected void done() {
                            try {
                                // restore UI
                                setCursor(Cursor.getDefaultCursor());
                                nextButton.setEnabled(true);
                                prevButton.setEnabled(true);
                                Boolean res = get();
                                if (messageToShow != null) {
                                    if (res != null && res) JOptionPane.showMessageDialog(PredictHealthJava.this, messageToShow, "Predicción de riesgo de diabetes", JOptionPane.INFORMATION_MESSAGE);
                                    else JOptionPane.showMessageDialog(PredictHealthJava.this, messageToShow, "Predicción", JOptionPane.WARNING_MESSAGE);
                                }
                                // After showing the popup, always go back to the Status panel and refresh charts
                                if (diabChart != null) diabChart.setPercentage((int)Math.round(lastDiabetesPct));
                                if (hipChart != null) hipChart.setPercentage((int)Math.round(lastHypertensionPct));
                                cardLayout.show(mainPanel, "Status");
                                updateNavButtons();
                            } catch (Exception ex) {
                                setCursor(Cursor.getDefaultCursor());
                                nextButton.setEnabled(true);
                                prevButton.setEnabled(true);
                                JOptionPane.showMessageDialog(PredictHealthJava.this, "Error en el proceso final: " + ex.getMessage(), "Error", JOptionPane.ERROR_MESSAGE);
                            }
                        }
                    };

                    worker.execute();
                    return;
                }

                cardLayout.next(mainPanel);
                updateNavButtons();
            }
        );

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
        boolean loaded = false;
        try (InputStream in = new FileInputStream("config.properties")) {
            props.load(in);
            loaded = true;
        } catch (IOException e) {
            // config not found or unreadable; we'll use defaults below
        }

        // Read URLs from properties if present, otherwise use sensible defaults
        loginUrl = props.getProperty("login.url", "http://34.135.18.33:8001/auth/login");
        registerUrl = props.getProperty("register.url", "http://34.135.18.33:8002/register");
        authMeUrl = props.getProperty("auth.me.url", "http://34.135.18.33:8001/auth/me");
        pacienteUrl = props.getProperty("paciente.url", "http://34.135.18.33:8003/paciente");
        estiloVidaUrl = props.getProperty("estilo_vida.url", "http://34.135.18.33:8004/estilo_vida");
        logoutUrl = props.getProperty("logout.url", "");
        predictUrl = props.getProperty("predict.url", "http://34.135.18.33:8008/predict");

        // Debug: print resolved configuration so we know what the JVM will use
        if (loaded) {
            System.out.println("Loaded config.properties. Resolved endpoints:");
        } else {
            System.out.println("config.properties not found; using default endpoints:");
        }
        System.out.println("  login.url = " + loginUrl);
        System.out.println("  auth.me.url = " + authMeUrl);
        System.out.println("  paciente.url = " + pacienteUrl);
        System.out.println("  estilo_vida.url = " + estiloVidaUrl);
        System.out.println("  predict.url = " + predictUrl);
        System.out.println("  logout.url = " + (logoutUrl == null || logoutUrl.isEmpty() ? "(not configured)" : logoutUrl));
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

    // Hide nav buttons on Start, Register, Status and the login screen (Step1)
    boolean showNav = loggedIn && !(name.equals("Start") || name.equals("Register") || name.equals("Status") || name.equals("Step1"));
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
        if (comp == mainPanel.getComponent(3)) return "Status";
        if (comp == mainPanel.getComponent(4)) return "Step2";
        if (comp == mainPanel.getComponent(5)) return "Step3";
        if (comp == mainPanel.getComponent(6)) return "Step4";
        if (comp == mainPanel.getComponent(7)) return "Step4_5";
        if (comp == mainPanel.getComponent(8)) return "Step5";
        if (comp == mainPanel.getComponent(9)) return "Step6";
        if (comp == mainPanel.getComponent(10)) return "Step7";
        if (comp == mainPanel.getComponent(11)) return "Step8";
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
        gbc.gridx = 0;
        gbc.gridy++;
        gbc.gridwidth = 1;
        JLabel emailLabel = new JLabel("E-mail");
        emailLabel.setForeground(Color.WHITE);
        emailLabel.setFont(new Font("SansSerif", Font.BOLD, 16));
        registerPanel.add(emailLabel, gbc);
        emailField = createTextField();
        gbc.gridx = 1;
        registerPanel.add(emailField, gbc);

        // Password
        gbc.gridx = 0; gbc.gridy++;
        JLabel passwordLabel = new JLabel("Contraseña");
        passwordLabel.setForeground(Color.WHITE);
        passwordLabel.setFont(new Font("SansSerif", Font.BOLD, 16));
        registerPanel.add(passwordLabel, gbc);
        passwordField = new JPasswordField();
        passwordField.setPreferredSize(new Dimension(200, 28));
        passwordField.setFont(new Font("SansSerif", Font.PLAIN, 16));
        passwordField.setBackground(new Color(0xF5F2E7));
        passwordField.setForeground(Color.BLACK);
        gbc.gridx = 1;
        registerPanel.add(passwordField, gbc);

        // Confirm Password
        gbc.gridx = 0; gbc.gridy++;
        JLabel confirmPasswordLabel = new JLabel("Confirmar Contraseña");
        confirmPasswordLabel.setForeground(Color.WHITE);
        confirmPasswordLabel.setFont(new Font("SansSerif", Font.BOLD, 16));
        registerPanel.add(confirmPasswordLabel, gbc);
        confirmPasswordField = new JPasswordField();
        confirmPasswordField.setPreferredSize(new Dimension(200, 28));
        confirmPasswordField.setFont(new Font("SansSerif", Font.PLAIN, 16));
        confirmPasswordField.setBackground(new Color(0xF5F2E7));
        confirmPasswordField.setForeground(Color.BLACK);
        gbc.gridx = 1;
        registerPanel.add(confirmPasswordField, gbc);

        // Register button
        gbc.gridx = 0; gbc.gridy++; gbc.gridwidth = 2;
        JButton registerBtn = createNavButton("Registrar");
        registerBtn.addActionListener(e -> {
            if (!String.valueOf(passwordField.getPassword())
                    .equals(String.valueOf(confirmPasswordField.getPassword()))) {
                JOptionPane.showMessageDialog(registerPanel, "Las contraseñas no coinciden", "Error", JOptionPane.ERROR_MESSAGE);
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
            JOptionPane.showMessageDialog(this, "Las contraseñas no coinciden", "Error", JOptionPane.ERROR_MESSAGE);
            return;
        }

        try {
            java.net.URL url = new java.net.URL(registerUrl);
            java.net.HttpURLConnection conn = (java.net.HttpURLConnection) url.openConnection();
            conn.setConnectTimeout(CONNECT_TIMEOUT);
            conn.setReadTimeout(READ_TIMEOUT);
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type","application/json");
            conn.setDoOutput(true);
            try(java.io.OutputStream os = conn.getOutputStream()){ os.write(json.getBytes()); }
            int code = conn.getResponseCode();
            if(code==200) JOptionPane.showMessageDialog(this,"¡Registro exitoso!");
            else JOptionPane.showMessageDialog(this,"Registro fallido: "+code);
            conn.disconnect();
        } catch(Exception ex){
            JOptionPane.showMessageDialog(this,"Error al contactar el servicio de registro");
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

        // Back button
        JButton backBtn = createNavButton("Atrás");
        backBtn.addActionListener(e -> {
            cardLayout.show(mainPanel, "Start");
            updateNavButtons();
        });
        gbc.gridx = 0; gbc.gridy = 0; gbc.gridwidth = 2; gbc.anchor = GridBagConstraints.WEST;
        step1Panel.add(backBtn, gbc);

        // Email
        gbc.gridx = 0; gbc.gridy = 1; gbc.gridwidth = 1;
        JLabel emailLabel = createLabel("Email:");
        JTextField emailField = createTextField();
        step1Panel.add(emailLabel, gbc);
        gbc.gridx = 1;
        step1Panel.add(emailField, gbc);

        // Password
        gbc.gridx = 0; gbc.gridy = 2;
        JLabel passwordLabel = createLabel("Password:");
        JPasswordField passwordField = new JPasswordField();
        passwordField.setPreferredSize(new Dimension(200,28));
        step1Panel.add(passwordLabel, gbc);
        gbc.gridx = 1;
        step1Panel.add(passwordField, gbc);

        // Login button
        JButton loginBtn = createNavButton("Login");
        loginBtn.addActionListener(e -> {
            sendLoginData(emailField.getText(), new String(passwordField.getPassword()));
            updateNavButtons();
        });

        gbc.gridx = 0; gbc.gridy = 3; gbc.gridwidth = 2;
        step1Panel.add(loginBtn, gbc);

        return step1Panel;
    }

    private void sendLoginData(String username, String password) {
            try {
            String json = String.format("{\"username\":\"%s\",\"password\":\"%s\"}", username, password);
            java.net.URL url = new java.net.URL(loginUrl);
            java.net.HttpURLConnection conn = (java.net.HttpURLConnection) url.openConnection();
            conn.setConnectTimeout(CONNECT_TIMEOUT);
            conn.setReadTimeout(READ_TIMEOUT);
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
                JOptionPane.showMessageDialog(this, "¡Inicio de sesión exitoso!");
                // after login, show the status dashboard before the questionnaire
                cardLayout.show(mainPanel, "Status");
            } else {
                loggedIn = false;
                if (code == 401) {
                    JOptionPane.showMessageDialog(this, "Credenciales inválidas. Por favor verifique su correo electrónico y contraseña.", "Inicio de sesión fallido", JOptionPane.ERROR_MESSAGE);
                } else {
                    JOptionPane.showMessageDialog(this, "Inicio de sesión fallido. Por favor intente de nuevo.", "Inicio de sesión fallido", JOptionPane.ERROR_MESSAGE);
                }
            }

            conn.disconnect();
        } catch(Exception ex){
            loggedIn = false;
            JOptionPane.showMessageDialog(this,"Error al contactar el servicio de autenticación");
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
        sexoPanel = new JPanel(new FlowLayout(FlowLayout.LEFT));
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

        saludPanel = new JPanel(new FlowLayout(FlowLayout.LEFT));
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
        presionPanel = new JPanel(new FlowLayout(FlowLayout.LEFT));
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

        JCheckBox beta = createCheckBox("Beta blocker");
        JCheckBox diuretico = createCheckBox("Diurético");
        JCheckBox ace = createCheckBox("ACE inhibitor");
        JCheckBox otro = createCheckBox("Otro");

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
                if (cb.isSelected() && !"Otro".equals(cb.getText())) {
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
        frutasPanel = new JPanel(new FlowLayout(FlowLayout.LEFT));
        frutasPanel.setBackground(new Color(0x132232));
        frutasPanel.add(frutasSi); frutasPanel.add(frutasNo);

        JLabel verdurasLabel = createLabel("¿Consume verduras diariamente?");
        JRadioButton verdurasSi = new JRadioButton("Sí");
        JRadioButton verdurasNo = new JRadioButton("No");
        ButtonGroup verdurasGroup = new ButtonGroup();
        verdurasGroup.add(verdurasSi); verdurasGroup.add(verdurasNo);
        verdurasPanel = new JPanel(new FlowLayout(FlowLayout.LEFT));
        verdurasPanel.setBackground(new Color(0x132232));
        verdurasPanel.add(verdurasSi); verdurasPanel.add(verdurasNo);

        JLabel salLabel = createLabel("¿Cuántos gramos de sal consume diariamente?");
        salField = createTextField();
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
        fumaPanel = new JPanel(new FlowLayout(FlowLayout.LEFT));
        fumaPanel.setBackground(new Color(0x132232));
        fumaPanel.add(fumaSi); fumaPanel.add(fumaNo);

        JLabel alcoholLabel = createLabel("¿Consume alcohol en exceso?");
        JRadioButton alcoholSi = new JRadioButton("Sí");
        JRadioButton alcoholNo = new JRadioButton("No");
        ButtonGroup alcoholGroup = new ButtonGroup();
        alcoholGroup.add(alcoholSi); alcoholGroup.add(alcoholNo);
        alcoholPanel = new JPanel(new FlowLayout(FlowLayout.LEFT));
        alcoholPanel.setBackground(new Color(0x132232));
        alcoholPanel.add(alcoholSi); alcoholPanel.add(alcoholNo);

        JLabel movilidadLabel = createLabel("¿Presenta problemas de movilidad?");
        JRadioButton movilidadSi = new JRadioButton("Sí");
        JRadioButton movilidadNo = new JRadioButton("No");
        ButtonGroup movilidadGroup = new ButtonGroup();
        movilidadGroup.add(movilidadSi); movilidadGroup.add(movilidadNo);
        movilidadPanel = new JPanel(new FlowLayout(FlowLayout.LEFT));
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

    // Status panel shown after login: two placeholder percentage graphs and a Nuevo Registro button
    private JPanel statusPanel() {
        if (statusPanel != null) return statusPanel;
        statusPanel = new JPanel(new GridBagLayout());
        statusPanel.setBackground(new Color(0x132232));
        statusPanel.setBorder(new EmptyBorder(20, 20, 20, 20));
        GridBagConstraints gbc = new GridBagConstraints();
        gbc.insets = new Insets(12, 12, 12, 12);
        gbc.fill = GridBagConstraints.HORIZONTAL;

        JLabel title = new JLabel("Estado de Salud");
        title.setForeground(Color.WHITE);
        title.setFont(new Font("SansSerif", Font.BOLD, 20));
        gbc.gridx = 0; gbc.gridy = 0; gbc.gridwidth = 2;
        statusPanel.add(title, gbc);

        // Diabetes placeholder
    JLabel diabLabel = createLabel("Diabetes (Estimado):");
    diabChart = new PieChartPanel((int)Math.round(lastDiabetesPct), new Color(0xE53935));
    diabChart.setPreferredSize(new Dimension(140,140));
    gbc.gridwidth = 1; gbc.gridy++; gbc.gridx = 0;
    statusPanel.add(diabLabel, gbc);
    gbc.gridx = 1;
    statusPanel.add(diabChart, gbc);

        // Hypertension placeholder
    JLabel hipLabel = createLabel("Hipertensión (Estimado):");
    hipChart = new PieChartPanel((int)Math.round(lastHypertensionPct), new Color(0x1E88E5));
    hipChart.setPreferredSize(new Dimension(140,140));
    gbc.gridy++; gbc.gridx = 0;
    statusPanel.add(hipLabel, gbc);
    gbc.gridx = 1;
    statusPanel.add(hipChart, gbc);

        // Panel for buttons
        JPanel btns = new JPanel(new FlowLayout(FlowLayout.CENTER, 12, 0));
        btns.setBackground(new Color(0x132232));

        // Nuevo Registro button to start the questionnaire
        JButton nuevoBtn = createNavButton("Nuevo Registro");
        nuevoBtn.addActionListener(e -> {
            // go to questionnaire (Step2) where the user can enter new record
            cardLayout.show(mainPanel, "Step2");
            updateNavButtons();
        });
        btns.add(nuevoBtn);

        // Logout button
        JButton logoutBtn = createNavButton("Cerrar sesión");
        logoutBtn.addActionListener(e -> {
            // Try to revoke token if logout URL configured
            if (accessToken != null && !accessToken.isEmpty() && logoutUrl != null && !logoutUrl.isEmpty()) {
                try {
                    URL url = new URL(logoutUrl);
                    HttpURLConnection con = (HttpURLConnection) url.openConnection();
                    con.setRequestMethod("POST");
            con.setRequestProperty("Authorization", "Bearer " + accessToken);
                con.setConnectTimeout(CONNECT_TIMEOUT);
                con.setReadTimeout(READ_TIMEOUT);
                    con.setDoOutput(true);
                    int code = con.getResponseCode();
                    System.out.println("Logout call returned: " + code);
                    con.disconnect();
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }
            // local cleanup
            accessToken = null;
            loggedIn = false;
            cardLayout.show(mainPanel, "Start");
            updateNavButtons();
        });
        btns.add(logoutBtn);

        gbc.gridx = 0; gbc.gridy++; gbc.gridwidth = 2; gbc.anchor = GridBagConstraints.CENTER;
        statusPanel.add(btns, gbc);

        return statusPanel;
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

    private boolean outputAllFieldsAsJson() {
        JSONObject paciente = new JSONObject();
        JSONObject salud = new JSONObject();
        JSONObject estilo_vida = new JSONObject();

        // Step 2: Paciente info
        putNotNull(paciente, "nombre", nombreField != null ? nombreField.getText() : "");
        putNotNull(paciente, "apellido", apellidoField != null ? apellidoField.getText() : "");
        Date birth = (fechaNacimientoSpinner != null) ? (Date) fechaNacimientoSpinner.getValue() : null;
        putNotNull(paciente, "fecha_nacimiento", birth != null ? new java.text.SimpleDateFormat("yyyy-MM-dd").format(birth) : "");
        
        String sexoValue = getSelectedButtonText(sexoPanel);
        if ("Hombre".equals(sexoValue)) sexoValue = "M";
        else if ("Mujer".equals(sexoValue)) sexoValue = "F";
        else if ("Otro".equals(sexoValue)) sexoValue = "";
        putNotNull(paciente, "sexo", sexoValue);

        putNotNull(paciente, "fecha", new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date()));

        // Step 3: Salud General
        putNotNull(salud, "salud_general", !getSelectedButtonText(saludPanel).isEmpty() ? getSelectedButtonText(saludPanel) : "NO SELECCIONADO");

        // Step 4: Historial Médico
        putNotNull(salud, "diabetes", getCheckBoxState(step4Panel, "Diabetes"));
        putNotNull(salud, "hipertension", getCheckBoxState(step4Panel, "Hipertensión"));
        putNotNull(salud, "colesterol", getCheckBoxState(step4Panel, "Colesterol"));
        putNotNull(salud, "colesterol_alto", getCheckBoxState(step4Panel, "Colesterol Alto"));

        // Step 4.5
        putNotNull(salud, "acv", getCheckBoxState(step4_5Panel, "Accidente Cerebrovascular (ACV)"));
        putNotNull(salud, "problemas_corazon", getCheckBoxState(step4_5Panel, "Problemas del Corazón"));

        // Step 5: BMI & presión
        putNotNull(salud, "bmi", getTextFieldValue(step5Panel, 0));
        putNotNull(salud, "presion", !getSelectedButtonText(presionPanel).isEmpty() ? getSelectedButtonText(presionPanel) : "NO SELECCIONADO");

        // Step 6: Medicamentos
        putNotNull(salud, "medicamentos", getSelectedMedications());

        // Step 7 & 8: Lifestyle
        putNotNull(estilo_vida, "frutas", getSelectedButtonText(frutasPanel));
        putNotNull(estilo_vida, "verduras", getSelectedButtonText(verdurasPanel));
        String salValue = (salField != null && !salField.getText().trim().isEmpty()) ? salField.getText().trim() : "0";
        putNotNull(estilo_vida, "sal", salValue);
        putNotNull(estilo_vida, "fuma", getSelectedButtonText(fumaPanel));
        putNotNull(estilo_vida, "alcohol", getSelectedButtonText(alcoholPanel));
        putNotNull(estilo_vida, "movilidad", getSelectedButtonText(movilidadPanel));
        putNotNull(estilo_vida, "actividad_frecuente", getSelectedButtonText(step8Panel));
        putNotNull(estilo_vida, "horas_sueno", getTextFieldValue(step8Panel, 0));
        putNotNull(estilo_vida, "nivel_estres", getComboBoxSelected(step8Panel, 3));
        putNotNull(estilo_vida, "salud_mental", getTextFieldValue(step8Panel, 1));
        putNotNull(estilo_vida, "actividad_fisica", getComboBoxSelected(step8Panel, 6));
        //putNotNull(salud, "actividad_frecuente2", getSelectedButtonText(step8Panel, "Sí", "No"));
        putNotNull(estilo_vida, "salud_fisica", getTextFieldValue(step8Panel, 2));

        // Retrieve user ID from Auth microservice
        String userId = null;
        try {
            URL meUrl = new URL(authMeUrl);
            HttpURLConnection authConn = (HttpURLConnection) meUrl.openConnection();
            authConn.setRequestMethod("GET");
            authConn.setRequestProperty("Authorization", "Bearer " + accessToken); // token saved from login
            authConn.setConnectTimeout(CONNECT_TIMEOUT);
            authConn.setReadTimeout(READ_TIMEOUT);

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
        // store userId for later predict call to avoid calling auth/me again
        if (userId != null) lastUserId = userId;
        if (userId != null) paciente.put("id_usuario", userId);
        if (userId != null) estilo_vida.put("id_usuario", userId);

        // POST Paciente JSON
        boolean pacienteSaved = false;
        try {
            URL url = new URL(pacienteUrl);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
                conn.setConnectTimeout(CONNECT_TIMEOUT);
                conn.setReadTimeout(READ_TIMEOUT);
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/json; utf-8");
            conn.setDoOutput(true);

            try (OutputStream os = conn.getOutputStream()) {
                byte[] input = paciente.toString().getBytes("utf-8");
                os.write(input, 0, input.length);
            }

            int code = conn.getResponseCode();
            System.out.println("POST /paciente -> Response code: " + code);
            pacienteSaved = (code >= 200 && code < 300);
            // Try to parse returned body for an id if auth/me wasn't available
            if (pacienteSaved) {
                try (BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream(), "utf-8"))) {
                    StringBuilder respBody = new StringBuilder();
                    String l;
                    while ((l = br.readLine()) != null) respBody.append(l);
                    if (respBody.length() > 0) {
                        try {
                            JSONObject respJson = new JSONObject(respBody.toString());
                            String found = null;
                            if (respJson.has("id_usuario")) found = respJson.optString("id_usuario", null);
                            else if (respJson.has("id")) found = respJson.optString("id", null);
                            else if (respJson.has("user_id")) found = respJson.optString("user_id", null);
                            if (found != null && !found.isEmpty()) {
                                lastUserId = found;
                                System.out.println("Found userId from paciente response: " + lastUserId);
                            }
                        } catch (Exception ex) {
                            // ignore parse errors
                        }
                    }
                } catch (Exception ex) {
                    // ignore
                }
            }
            conn.disconnect();
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }

        // POST estilo_vida JSON
        boolean estiloVidaSaved = false;
        try {
            URL url = new URL(estiloVidaUrl);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
                conn.setConnectTimeout(CONNECT_TIMEOUT);
                conn.setReadTimeout(READ_TIMEOUT);
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/json; utf-8");
            conn.setDoOutput(true);

            try (OutputStream os = conn.getOutputStream()) {
                byte[] input = estilo_vida.toString().getBytes("utf-8");
                os.write(input, 0, input.length);
            }

            int code = conn.getResponseCode();
            System.out.println("POST /estilo_vida -> Response code: " + code);
            estiloVidaSaved = (code >= 200 && code < 300);
            conn.disconnect();
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
        
        System.out.println("Paciente:");
        System.out.println(paciente.toString(4));

        System.out.println("Estilo_Vida:");
        System.out.println(estilo_vida.toString(4));

        System.out.println("Salud:");
        System.out.println(salud.toString(4));
        
        // Return true only if both POSTs succeeded
        return pacienteSaved && estiloVidaSaved;
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

    // Minimal Redis SET via RESP protocol (best-effort, non-blocking for app)
    private void saveToRedis(String key, String value) {
        try (java.net.Socket s = new java.net.Socket("127.0.0.1", 6379)) {
            OutputStream os = s.getOutputStream();
            // Build RESP: *3\r\n$3\r\nSET\r\n$<klen>\r\nkey\r\n$<vlen>\r\nvalue\r\n
            String cmd = "*3\r\n$3\r\nSET\r\n$" + key.getBytes("utf-8").length + "\r\n" + key + "\r\n$" + value.getBytes("utf-8").length + "\r\n" + value + "\r\n";
            os.write(cmd.getBytes("utf-8"));
            os.flush();
            // read simple reply line
            BufferedReader br = new BufferedReader(new InputStreamReader(s.getInputStream(), "utf-8"));
            String resp = br.readLine();
            System.out.println("Redis SET response: " + resp);
        } catch (Exception e) {
            // best-effort, do not block app
            System.out.println("Could not save to Redis: " + e.getMessage());
        }
    }

    // Simple TCP connect test to check if JVM can reach a host:port (helps diagnose Java vs curl differences)
    private boolean socketConnectTest(String host, int port, int timeoutMs) {
        if (host == null || host.isEmpty() || port <= 0) return false;
        try (java.net.Socket sock = new java.net.Socket()) {
            sock.connect(new InetSocketAddress(host, port), timeoutMs);
            return true;
        } catch (Exception e) {
            System.out.println("Socket test to " + host + ":" + port + " failed: " + e.getMessage());
            return false;
        }
    }

    // Small Pie chart panel for percentage visualization
    private static class PieChartPanel extends JPanel {
        private int percentage = 0;
        private Color arcColor = Color.RED;

        public PieChartPanel(int pct, Color color) {
            this.percentage = Math.max(0, Math.min(100, pct));
            this.arcColor = color;
            setOpaque(false);
        }

        public void setPercentage(int pct) {
            this.percentage = Math.max(0, Math.min(100, pct));
            repaint();
        }

        @Override
        protected void paintComponent(Graphics g) {
            super.paintComponent(g);
            int w = getWidth();
            int h = getHeight();
            int size = Math.min(w, h) - 6;
            int x = (w - size) / 2;
            int y = (h - size) / 2;

            Graphics2D g2 = (Graphics2D) g.create();
            g2.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);

            // background circle (light gray ring)
            g2.setColor(new Color(0x333333));
            g2.fillOval(x, y, size, size);

            // arc for percentage
            int angle = (int) Math.round(percentage * 360.0 / 100.0);
            g2.setColor(arcColor);
            g2.fillArc(x + 2, y + 2, size - 4, size - 4, 90, -angle);

            // inner cutout for donut effect
            int inner = Math.max(8, size / 3);
            g2.setColor(new Color(0x132232));
            g2.fillOval(x + inner/2, y + inner/2, size - inner, size - inner);

            // percentage text
            String txt = percentage + "%";
            Font f = getFont().deriveFont(Font.BOLD, Math.max(12, size / 6));
            g2.setFont(f);
            FontMetrics fm = g2.getFontMetrics();
            int tx = x + (size - fm.stringWidth(txt)) / 2;
            int ty = y + (size + fm.getAscent()) / 2 - fm.getDescent();
            // pick text color with good contrast
            g2.setColor(Color.WHITE);
            g2.drawString(txt, tx, ty);

            g2.dispose();
        }
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
        if (panel == null) return "0";
        int count = 0;
        for (Component comp : panel.getComponents()) {
            if (comp instanceof JTextField tf) {
                if (count == index) {
                    String val = tf.getText();
                    return (val == null || val.trim().isEmpty()) ? "0" : val;
                }
                count++;
            }
        }
        return "0";
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

    // Validator for required fields on each step
    private boolean validateCurrentStep() {
        Component visible = getVisiblePanel();
        String name = getPanelName(visible);
        // Step 2: Nombre, Apellido, Fecha de Nacimiento, Sexo
        if (name.equals("Step2")) {
            if (nombreField == null || nombreField.getText().trim().isEmpty() ||
                apellidoField == null || apellidoField.getText().trim().isEmpty() ||
                fechaNacimientoSpinner == null || fechaNacimientoSpinner.getValue() == null ||
                getSelectedButtonText(sexoPanel).isEmpty()) {
                JOptionPane.showMessageDialog(this, "Debe completar todos los campos obligatorios: Nombre, Apellido, Fecha de nacimiento y Sexo.", "Campos obligatorios", JOptionPane.WARNING_MESSAGE);
                return false;
            }
        }
        // Step 3: Salud General obligatorio
        if (name.equals("Step3")) {
            if (getSelectedButtonText(saludPanel).isEmpty()) {
                JOptionPane.showMessageDialog(this, "Seleccione una opción de Salud General.", "Campos obligatorios", JOptionPane.WARNING_MESSAGE);
                return false;
            }
        }
        // Step 5: BMI obligatorio y Presión arterial obligatorio
        if (name.equals("Step5")) {
            String bmiVal = getTextFieldValue(step5Panel, 0);
            if (bmiVal.trim().isEmpty() || getSelectedButtonText(presionPanel).isEmpty()) {
                JOptionPane.showMessageDialog(this, "Debe completar BMI y seleccionar una opción de Presión arterial.", "Campos obligatorios", JOptionPane.WARNING_MESSAGE);
                return false;
            }
        }
        // Step 7: Frutas, Verduras, Fuma, Alcohol, Movilidad
        if (name.equals("Step7")) {
            if (getSelectedButtonText(frutasPanel, "Sí", "No").isEmpty() ||
                getSelectedButtonText(verdurasPanel, "Sí", "No").isEmpty() ||
                getSelectedButtonText(fumaPanel, "Sí", "No").isEmpty() ||
                getSelectedButtonText(alcoholPanel, "Sí", "No").isEmpty() ||
                getSelectedButtonText(movilidadPanel, "Sí", "No").isEmpty()) {
                JOptionPane.showMessageDialog(this, "Complete todas las opciones de estilo de vida (frutas, verduras, fuma, alcohol, movilidad).", "Campos obligatorios", JOptionPane.WARNING_MESSAGE);
                return false;
            }
        }
        // Step 8: Actividad frecuente, etc. (if any radio is required can add here)
        // Add more step validations as needed, remaining conservative
        return true;
    }
}
