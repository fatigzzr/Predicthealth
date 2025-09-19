package com.example.predicthealthandroid.models

data class Documento(
    val tipo: String,
    val valor: Float? = null,   // For numeric values like HbA1c, colesterol
    val texto: String? = null    // For textual documents like tratamientos, hallazgos
)
