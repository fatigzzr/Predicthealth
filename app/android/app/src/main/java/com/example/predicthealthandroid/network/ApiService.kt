package com.example.predicthealthandroid.network

import retrofit2.Call
import retrofit2.http.Body
import retrofit2.http.POST
import com.example.predicthealthandroid.models.FormularioCompleto

interface ApiService {
    @POST("prediccion")
    fun enviarFormulario(@Body formulario: FormularioCompleto): Call<PrediccionResponse>
}

data class PrediccionResponse(
    val riesgoDiabetes: Float,
    val riesgoHipertension: Float,
    val color: String
)
