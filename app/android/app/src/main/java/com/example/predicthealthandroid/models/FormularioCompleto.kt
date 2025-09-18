package com.example.predicthealthandroid.models

data class FormularioCompleto(
    val usuario: Usuario,
    val historialMedico: HistorialMedico,
    val estiloDeVida: EstiloDeVida,
    val documentos: List<Documento>
)