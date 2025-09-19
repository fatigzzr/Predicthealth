package com.example.predicthealthandroid.models

data class HistorialMedico(
    val diabetes: Boolean,
    val hipertension: Boolean,
    val colesterol: Colesterol,
    val bmi: Float,
    val presionArterial: String,
    val medicacion: List<String>,
    val acv: Boolean,
    val problemasCorazon: Boolean,
    val saludGeneral: String
)