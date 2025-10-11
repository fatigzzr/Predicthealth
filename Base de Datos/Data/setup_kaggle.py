"""
Script para configurar Kaggle y descargar el dataset de hipertensión
"""

import os
import subprocess
import sys

def setup_kaggle_credentials():
    """Configurar credenciales de Kaggle"""
    print("=== CONFIGURANDO CREDENCIALES DE KAGGLE ===")
    
    # Verificar si kaggle está instalado
    try:
        import kaggle
        print("✅ Kaggle ya está instalado")
    except ImportError:
        print("📦 Instalando kaggle...")
        subprocess.check_call([sys.executable, "-m", "pip", "install", "kaggle"])
        print("✅ Kaggle instalado")
    
    # Verificar si existe el archivo de credenciales
    kaggle_dir = os.path.expanduser("~/.kaggle")
    kaggle_key_file = os.path.join(kaggle_dir, "kaggle.json")
    
    if os.path.exists(kaggle_key_file):
        print("✅ Archivo de credenciales de Kaggle encontrado")
        return True
    else:
        print("❌ No se encontró el archivo de credenciales de Kaggle")
        print("\n📋 Para configurar Kaggle:")
        print("1. Ve a https://www.kaggle.com/account")
        print("2. Haz clic en 'Create New API Token'")
        print("3. Descarga el archivo kaggle.json")
        print(f"4. Coloca el archivo en: {kaggle_dir}")
        print("5. Ejecuta: chmod 600 ~/.kaggle/kaggle.json")
        return False

def download_hypertension_dataset():
    """Descargar el dataset de hipertensión"""
    print("\n=== DESCARGANDO DATASET DE HIPERTENSIÓN ===")
    
    try:
        import kaggle
        from kaggle.api.kaggle_api_extended import KaggleApi
        
        # Inicializar API
        api = KaggleApi()
        api.authenticate()
        
        # Descargar el dataset
        print("Descargando dataset...")
        api.dataset_download_files(
            "miadul/hypertension-risk-prediction-dataset",
            path="./",
            unzip=True
        )
        
        print("✅ Dataset descargado exitosamente")
        return True
        
    except Exception as e:
        print(f"❌ Error al descargar el dataset: {e}")
        return False

def main():
    print("Configurando Kaggle para descargar el dataset de hipertensión...")
    
    # Configurar credenciales
    if setup_kaggle_credentials():
        # Descargar dataset
        if download_hypertension_dataset():
            print("\n✅ Configuración completada exitosamente")
            print("Ahora puedes ejecutar load_hypertension_dataset.py")
        else:
            print("\n❌ No se pudo descargar el dataset")
    else:
        print("\n❌ Configura las credenciales de Kaggle primero")

if __name__ == "__main__":
    main()
