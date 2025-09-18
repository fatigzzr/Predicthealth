package com.example.predicthealthandroid.models

data class EstiloDeVida(
    val consumeFrutas: Boolean,
    val consumeVerduras: Boolean,
    val salDiariaGramos: Int,
    val fuma: Boolean,
    val alcoholExceso: Boolean,
    val dificultadMovilidad: Boolean,
    val horasSueno: Int,
    val nivelEstres: Int,
    val diasSaludMentalMala: Int,
    val actividadFisica: String,
    val actividad3VecesSemana: Boolean,
    val diasSaludFisicaMala: Int
)
