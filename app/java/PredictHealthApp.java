import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.dataformat.xml.XmlMapper;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;

public class PredictHealthApp {

    static Scanner sc = new Scanner(System.in);

    static class Usuario {
        public String email, password, nombre, apellido, fechaNacimiento, sexo;
        public int edad;
        public Usuario(String email, String password, String nombre, String apellido, String fechaNacimiento, String sexo, int edad) {
            this.email = email; this.password = password; this.nombre = nombre;
            this.apellido = apellido; this.fechaNacimiento = fechaNacimiento; this.sexo = sexo; this.edad = edad;
        }
    }

    static class Colesterol {
        public boolean colesterol, colesterolAlto;
        public Colesterol(boolean c, boolean ca) { colesterol = c; colesterolAlto = ca; }
    }

    static class HistorialMedico {
        public boolean diabetes, hipertension, acv, problemasCorazon, dificultadMovilidad;
        public Colesterol colesterol;
        public float bmi;
        public String presion, saludGeneral;
        public List<String> medicacion;
        public HistorialMedico(boolean diabetes, boolean hipertension, Colesterol colesterol,
                               float bmi, String presion, List<String> medicacion,
                               boolean acv, boolean problemasCorazon, String saludGeneral, boolean dificultadMovilidad) {
            this.diabetes = diabetes; this.hipertension = hipertension; this.colesterol = colesterol;
            this.bmi = bmi; this.presion = presion; this.medicacion = medicacion;
            this.acv = acv; this.problemasCorazon = problemasCorazon; this.saludGeneral = saludGeneral;
            this.dificultadMovilidad = dificultadMovilidad;
        }
    }

    static class EstiloDeVida {
        public boolean consumeFrutas, consumeVerduras, fuma, alcoholExceso, actividad3Veces;
        public int salDiaria, horasSueno, nivelEstres, diasSaludMental, diasSaludFisica;
        public boolean dificultadMovilidad;
        public String actividadFisica;
        public EstiloDeVida(boolean consumeFrutas, boolean consumeVerduras, int salDiaria,
                            boolean fuma, boolean alcoholExceso, boolean dificultadMovilidad,
                            int horasSueno, int nivelEstres, int diasSaludMental,
                            String actividadFisica, boolean actividad3Veces, int diasSaludFisica) {
            this.consumeFrutas = consumeFrutas; this.consumeVerduras = consumeVerduras; this.salDiaria = salDiaria;
            this.fuma = fuma; this.alcoholExceso = alcoholExceso; this.dificultadMovilidad = dificultadMovilidad;
            this.horasSueno = horasSueno; this.nivelEstres = nivelEstres; this.diasSaludMental = diasSaludMental;
            this.actividadFisica = actividadFisica; this.actividad3Veces = actividad3Veces; this.diasSaludFisica = diasSaludFisica;
        }
    }

    static class Documento { public String tipo; public Float valor; public Documento(String tipo, Float valor) { this.tipo = tipo; this.valor = valor; } }
    static class FormularioCompleto { public Usuario usuario; public HistorialMedico historialMedico; public EstiloDeVida estiloDeVida; public List<Documento> documentos; public FormularioCompleto(Usuario u, HistorialMedico h, EstiloDeVida e, List<Documento> d) { usuario = u; historialMedico = h; estiloDeVida = e; documentos = d; } }

    public static void main(String[] args) throws ParseException {
        System.out.println("=== Datos del Usuario ===");
        String email = readString("Email: ");
        String password = readString("Password: ");
        String nombre = readString("Nombre: ");
        String apellido = readString("Apellido: ");
        String fechaNacimiento = readDate("Fecha de nacimiento (yyyy-MM-dd): ");
        String sexo = readOption("Sexo (Hombre/Mujer/Otro): ", Arrays.asList("Hombre","Mujer","Otro"));

        int edad = calculateAge(fechaNacimiento);
        Usuario usuario = new Usuario(email,password,nombre,apellido,fechaNacimiento,sexo,edad);

        System.out.println("=== Historial Médico ===");
        boolean diabetes = readBoolean("Diabetes (true/false): ");
        boolean hipertension = readBoolean("Hipertensión (true/false): ");
        boolean colesterol = readBoolean("Colesterol (true/false): ");
        boolean colesterolAlto = colesterol ? readBoolean("Colesterol alto (true/false): ") : false;
        float bmi = readFloat("BMI: ");
        String presion = readOption("Presión (Normal/Pre-Hipertensión/Hipertensión): ", Arrays.asList("Normal","Pre-Hipertensión","Hipertensión"));
        String saludGeneral = readOption("Salud general (Malo/Regular/Bueno/Muy Bueno/Excelente): ", Arrays.asList("Malo","Regular","Bueno","Muy Bueno","Excelente"));
        List<String> medicacion = readList("Medicación (separa por coma, ej: Ninguna,Beta blocker): ");

        boolean acv = readBoolean("ACV (true/false): ");
        boolean problemasCorazon = readBoolean("Problemas del corazón (true/false): ");
        boolean dificultadMovilidad = readBoolean("Dificultad movilidad (true/false): ");

        HistorialMedico historial = new HistorialMedico(diabetes, hipertension, new Colesterol(colesterol, colesterolAlto),
                bmi, presion, medicacion, acv, problemasCorazon, saludGeneral, dificultadMovilidad);

        System.out.println("=== Estilo de Vida ===");
        boolean consumeFrutas = readBoolean("Consume frutas (true/false): ");
        boolean consumeVerduras = readBoolean("Consume verduras (true/false): ");
        int salDiaria = readInt("Sal diaria (mg): ");
        boolean fuma = readBoolean("Fuma (true/false): ");
        boolean alcoholExceso = readBoolean("Alcohol exceso (true/false): ");
        int horasSueno = readInt("Horas de sueño: ");
        int nivelEstres = readInt("Nivel de estrés: ");
        int diasSaludMental = readInt("Días salud mental: ");
        String actividadFisica = readString("Actividad física: ");
        boolean actividad3Veces = readBoolean("Actividad 3 veces por semana (true/false): ");
        int diasSaludFisica = readInt("Días salud física: ");

        EstiloDeVida estilo = new EstiloDeVida(consumeFrutas, consumeVerduras, salDiaria,fuma,alcoholExceso,dificultadMovilidad,
                horasSueno,nivelEstres,diasSaludMental,actividadFisica,actividad3Veces,diasSaludFisica);

        System.out.println("=== Documentos ===");
        String tipoDoc = readString("Tipo documento: ");
        Float valorDoc = readFloat("Valor documento (float): ");
        List<Documento> documentos = Collections.singletonList(new Documento(tipoDoc, valorDoc));

        FormularioCompleto formulario = new FormularioCompleto(usuario,historial,estilo,documentos);

        try {
            ObjectMapper jsonMapper = new ObjectMapper();
            String jsonOutput = jsonMapper.writerWithDefaultPrettyPrinter().writeValueAsString(formulario);
            System.out.println("\n--- JSON Output ---\n"+jsonOutput);

            XmlMapper xmlMapper = new XmlMapper();
            String xmlOutput = xmlMapper.writerWithDefaultPrettyPrinter().writeValueAsString(formulario);
            System.out.println("\n--- XML Output ---\n"+xmlOutput);
        } catch (Exception e) { e.printStackTrace(); }
    }

    // --- Input helpers ---
    static String readString(String prompt) {
        String input;
        do { System.out.print(prompt); input = sc.nextLine().trim(); } while (input.isEmpty());
        return input;
    }

    static boolean readBoolean(String prompt) {
        String input;
        do { System.out.print(prompt); input = sc.nextLine().trim().toLowerCase(); } while (!input.equals("true") && !input.equals("false"));
        return input.equals("true");
    }

    static int readInt(String prompt) {
        int value = 0;
        while (true) {
            try { System.out.print(prompt); value = Integer.parseInt(sc.nextLine().trim()); break; }
            catch (NumberFormatException e){ System.out.println("Ingrese un número válido."); }
        }
        return value;
    }

    static float readFloat(String prompt) {
        float value = 0;
        while (true) {
            try { System.out.print(prompt); value = Float.parseFloat(sc.nextLine().trim()); break; }
            catch (NumberFormatException e){ System.out.println("Ingrese un número válido."); }
        }
        return value;
    }

    static String readOption(String prompt, List<String> options) {
        String input;
        do { System.out.print(prompt); input = sc.nextLine().trim(); } while (!options.contains(input));
        return input;
    }

    static List<String> readList(String prompt) {
        System.out.print(prompt);
        String line = sc.nextLine();
        if (line.trim().isEmpty()) return new ArrayList<>();
        return Arrays.asList(line.split("\\s*,\\s*"));
    }

    static String readDate(String prompt) {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        sdf.setLenient(false);
        String date;
        while (true) {
            System.out.print(prompt);
            date = sc.nextLine().trim();
            try { sdf.parse(date); break; }
            catch (ParseException e){ System.out.println("Formato de fecha inválido. Use yyyy-MM-dd."); }
        }
        return date;
    }

    static int calculateAge(String fechaNacimiento) throws ParseException {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        Date birthDate = sdf.parse(fechaNacimiento);
        Calendar birth = Calendar.getInstance();
        birth.setTime(birthDate);
        Calendar now = Calendar.getInstance();
        int age = now.get(Calendar.YEAR) - birth.get(Calendar.YEAR);
        if (now.get(Calendar.DAY_OF_YEAR) < birth.get(Calendar.DAY_OF_YEAR)) age--;
        return age;
    }
}
