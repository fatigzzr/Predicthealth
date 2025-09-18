package com.example.predicthealthandroid.models

data class Documento(
    val tipo: String,
    val valor: Any? = null,
    val colesterolLDL: Int? = null,
    val colesterolHDL: Int? = null,
    val trigliceridos: Int? = null,
    val glucosaAyunas: Int? = null,
    val creatinina: Float? = null,
    val filtradoGlomerular: Int? = null,
    val PA_sistolica_promedio: Int? = null,
    val PA_diastolica_promedio: Int? = null,
    val diabetes: List<String>? = null,
    val hipertension: List<String>? = null
)