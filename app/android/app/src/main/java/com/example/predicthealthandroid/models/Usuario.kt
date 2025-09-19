package com.example.predicthealthandroid.models

data class Usuario(
    val email: String,
    val contrasena: String,
    val nombre: String,
    val apellido: String,
    val fechaNacimiento: String,
    val sexo: String,
    val edad: Int
)
