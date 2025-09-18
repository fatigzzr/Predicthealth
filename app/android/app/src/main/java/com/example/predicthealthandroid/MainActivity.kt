package com.example.predicthealthandroid

import android.os.Bundle
import android.widget.*
import androidx.appcompat.app.AppCompatActivity
import com.example.predicthealthandroid.models.*
import com.example.predicthealthandroid.network.RetrofitInstance
import com.example.predicthealthandroid.network.PrediccionResponse
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

class MainActivity : AppCompatActivity() {

    private lateinit var viewFlipper: ViewFlipper
    private lateinit var nextButton: Button
    private lateinit var prevButton: Button
    private lateinit var resultTextView: TextView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        viewFlipper = findViewById(R.id.viewFlipper)
        nextButton = findViewById(R.id.nextButton)
        prevButton = findViewById(R.id.prevButton)
        resultTextView = findViewById(R.id.resultTextView)

        nextButton.setOnClickListener {
            if (viewFlipper.displayedChild < viewFlipper.childCount - 1) {
                viewFlipper.showNext()
            } else {
                sendFormulario()
            }
        }

        prevButton.setOnClickListener {
            if (viewFlipper.displayedChild > 0) viewFlipper.showPrevious()
        }

        // Setup checkbox logic for Colesterol Alto
        val colesterolCheckBox = findViewById<CheckBox>(R.id.colesterolCheckBox)
        val colesterolAltoCheckBox = findViewById<CheckBox>(R.id.colesterolAltoCheckBox)
        
        colesterolCheckBox.setOnCheckedChangeListener { _, isChecked ->
            colesterolAltoCheckBox.isEnabled = isChecked
            if (!isChecked) {
                colesterolAltoCheckBox.isChecked = false
                // Gray out when disabled
                colesterolAltoCheckBox.buttonTintList = getColorStateList(R.color.input_bg)
            } else {
                // Use accent color when enabled
                colesterolAltoCheckBox.buttonTintList = getColorStateList(R.color.accent)
            }
        }
    }
    private fun sendFormulario() {
        // --- Usuario ---
        val email = findViewById<EditText>(R.id.emailEditText).text.toString()
        val password = findViewById<EditText>(R.id.passwordEditText).text.toString()
        val nombre = findViewById<EditText>(R.id.nombreEditText).text.toString()
        val apellido = findViewById<EditText>(R.id.apellidoEditText).text.toString()
        val fechaNacimiento = findViewById<EditText>(R.id.fechaEditText).text.toString()
        val sexo = findViewById<EditText>(R.id.sexoEditText).text.toString()
        val edad = findViewById<EditText>(R.id.edadEditText).text.toString().toIntOrNull() ?: 0

        val usuario = Usuario(email, password, nombre, apellido, fechaNacimiento, sexo, edad)

        // --- Historial médico ---
        val diabetes = findViewById<CheckBox>(R.id.diabetesCheckBox).isChecked
        val hipertension = findViewById<CheckBox>(R.id.hipertensionCheckBox).isChecked
        val colesterol = findViewById<CheckBox>(R.id.colesterolCheckBox).isChecked
        val colesterolAlto = findViewById<CheckBox>(R.id.colesterolAltoCheckBox).isChecked

        val bmi = findViewById<EditText>(R.id.bmiEditText).text.toString().toFloatOrNull() ?: 0f
        val presion = findViewById<EditText>(R.id.presionEditText).text.toString()
        val saludGeneral = findViewById<EditText>(R.id.saludGeneralEditText).text.toString()

        // --- Medicamentos (opción múltiple) ---
        val medicacion = mutableListOf<String>()
        if (findViewById<CheckBox>(R.id.medicacionNingunaCheckBox).isChecked) medicacion.add("Ninguna")
        if (findViewById<CheckBox>(R.id.medicacionBetaCheckBox).isChecked) medicacion.add("Beta blocker")
        if (findViewById<CheckBox>(R.id.medicacionDiureticoCheckBox).isChecked) medicacion.add("Diurético")
        if (findViewById<CheckBox>(R.id.medicacionAceCheckBox).isChecked) medicacion.add("ACE inhibitor")
        if (findViewById<CheckBox>(R.id.medicacionOtroCheckBox).isChecked) medicacion.add("Otro")

        // --- ACV y problemas del corazón ---
        val acv = findViewById<CheckBox>(R.id.acvCheckBox).isChecked
        val problemasCorazon = findViewById<CheckBox>(R.id.problemasCorazonCheckBox).isChecked

        val historialMedico = HistorialMedico(
            diabetes, hipertension, Colesterol(colesterol, colesterolAlto),
            bmi, presion, medicacion, acv, problemasCorazon, saludGeneral
        )

        // --- Estilo de vida ---
        val consumeFrutas = findViewById<CheckBox>(R.id.frutasCheckBox).isChecked
        val consumeVerduras = findViewById<CheckBox>(R.id.verdurasCheckBox).isChecked
        val salDiaria = findViewById<EditText>(R.id.salEditText).text.toString().toIntOrNull() ?: 0
        val fuma = findViewById<CheckBox>(R.id.fumaCheckBox).isChecked
        val alcoholExceso = findViewById<CheckBox>(R.id.alcoholCheckBox).isChecked
        val dificultadMovilidad = findViewById<CheckBox>(R.id.dificultadMovCheckBox).isChecked
        val horasSueno = findViewById<EditText>(R.id.horasSuenoEditText).text.toString().toIntOrNull() ?: 0
        val nivelEstres = findViewById<EditText>(R.id.nivelEstresEditText).text.toString().toIntOrNull() ?: 0
        val diasSaludMental = findViewById<EditText>(R.id.diasSaludMentalEditText).text.toString().toIntOrNull() ?: 0
        val actividadFisica = findViewById<EditText>(R.id.actividadFisicaEditText).text.toString()
        val actividad3Veces = findViewById<CheckBox>(R.id.actividad3VecesCheckBox).isChecked
        val diasSaludFisica = findViewById<EditText>(R.id.diasSaludFisicaEditText).text.toString().toIntOrNull() ?: 0

        val estiloDeVida = EstiloDeVida(
            consumeFrutas, consumeVerduras, salDiaria, fuma, alcoholExceso,
            dificultadMovilidad, horasSueno, nivelEstres, diasSaludMental,
            actividadFisica, actividad3Veces, diasSaludFisica
        )

        // --- Documentos ---
        val tipoDoc = findViewById<EditText>(R.id.tipoDocumentoEditText).text.toString()
        val valorDoc = findViewById<EditText>(R.id.valorDocumentoEditText).text.toString().toFloatOrNull()

        val documentos = listOf(
            Documento(tipo = tipoDoc, valor = valorDoc)
        )

        val formulario = FormularioCompleto(usuario, historialMedico, estiloDeVida, documentos)

        // --- Retrofit call ---
        RetrofitInstance.apiService.enviarFormulario(formulario)
            .enqueue(object : Callback<PrediccionResponse> {
                override fun onResponse(call: Call<PrediccionResponse>, response: Response<PrediccionResponse>) {
                    if (response.isSuccessful) {
                        val pred = response.body()
                        resultTextView.text = "Riesgo diabetes: ${pred?.riesgoDiabetes}\n" +
                                "Riesgo hipertensión: ${pred?.riesgoHipertension}\n" +
                                "Color: ${pred?.color}"
                    } else {
                        resultTextView.text = "Error al enviar formulario: ${response.code()}"
                    }
                }

                override fun onFailure(call: Call<PrediccionResponse>, t: Throwable) {
                    resultTextView.text = "Fallo de red: ${t.message}"
                }
            })
    }
}
