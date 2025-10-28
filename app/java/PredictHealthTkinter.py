import tkinter as tk
from tkinter import ttk, messagebox
from tkcalendar import DateEntry
import json
from datetime import datetime

class PredictHealthWizard:
    def __init__(self, root):
        self.root = root
        self.root.title("Predict Health Questionnaire")
        self.root.geometry("650x550")
        self.data = {}

        self.steps = ["Personal Info", "Medical History", "Lifestyle"]
        self.frames = []
        self.current_frame = 0

        self.create_steps_ui()
        self.create_frames()
        self.show_frame(0)

    def create_steps_ui(self):
        self.step_frame = ttk.Frame(self.root)
        self.step_frame.pack(fill="x", pady=10)
        self.step_labels = []
        for idx, name in enumerate(self.steps):
            lbl = ttk.Label(self.step_frame, text=name, borderwidth=1, relief="ridge", padding=5)
            lbl.pack(side="left", expand=True, fill="x", padx=2)
            self.step_labels.append(lbl)

    def update_step_ui(self):
        for i, lbl in enumerate(self.step_labels):
            if i == self.current_frame:
                lbl.config(background="lightblue")
            else:
                lbl.config(background="SystemButtonFace")

    def create_frames(self):
        # ---------------- Frame 0: Personal Info ----------------
        frame0 = ttk.Frame(self.root)
        ttk.Label(frame0, text="Personal Information", font=("Arial", 16)).pack(pady=10)

        self.email_var = tk.StringVar()
        self.password_var = tk.StringVar()
        self.nombre_var = tk.StringVar()
        self.apellido_var = tk.StringVar()
        self.sexo_var = tk.StringVar()
        self.fecha_var = tk.StringVar()

        entries = [
            ("Email:", self.email_var),
            ("Password:", self.password_var, True),
            ("Nombre:", self.nombre_var),
            ("Apellido:", self.apellido_var)
        ]
        for label, var, *show_pass in entries:
            ttk.Label(frame0, text=label).pack(anchor="w", padx=10)
            ttk.Entry(frame0, textvariable=var, show="*" if show_pass and show_pass[0] else "").pack(fill="x", padx=10)

        ttk.Label(frame0, text="Sexo:").pack(anchor="w", padx=10)
        sexo_frame = ttk.Frame(frame0)
        sexo_frame.pack(anchor="w", padx=10)
        for sex in ["Hombre", "Mujer", "Otro"]:
            ttk.Radiobutton(sexo_frame, text=sex, variable=self.sexo_var, value=sex).pack(side="left")

        ttk.Label(frame0, text="Fecha de Nacimiento:").pack(anchor="w", padx=10)
        self.fecha_entry = DateEntry(frame0, textvariable=self.fecha_var, date_pattern="yyyy-mm-dd")
        self.fecha_entry.pack(anchor="w", padx=10, pady=5)

        self.frames.append(frame0)

        # ---------------- Frame 1: Medical History ----------------
        frame1 = ttk.Frame(self.root)
        ttk.Label(frame1, text="Historial Médico", font=("Arial", 16)).pack(pady=10)

        self.diabetes_var = tk.BooleanVar()
        self.hipertension_var = tk.BooleanVar()
        self.colesterol_var = tk.BooleanVar()
        self.colesterol_alto_var = tk.BooleanVar()
        self.bmi_var = tk.StringVar()
        self.presion_var = tk.StringVar()
        self.salud_var = tk.StringVar()

        ttk.Checkbutton(frame1, text="Diabetes", variable=self.diabetes_var).pack(anchor="w", padx=10)
        ttk.Checkbutton(frame1, text="Hipertensión", variable=self.hipertension_var).pack(anchor="w", padx=10)
        ttk.Checkbutton(frame1, text="Colesterol", variable=self.colesterol_var,
                        command=self.toggle_colesterol_alto).pack(anchor="w", padx=10)
        self.colesterol_alto_cb = ttk.Checkbutton(frame1, text="Colesterol Alto", variable=self.colesterol_alto_var)
        self.colesterol_alto_cb.pack(anchor="w", padx=10)
        self.colesterol_alto_cb.state(['disabled'])

        ttk.Label(frame1, text="BMI:").pack(anchor="w", padx=10)
        ttk.Entry(frame1, textvariable=self.bmi_var).pack(fill="x", padx=10)

        ttk.Label(frame1, text="Presión arterial:").pack(anchor="w", padx=10)
        for p in ["Normal", "Pre-Hipertensión", "Hipertensión"]:
            ttk.Radiobutton(frame1, text=p, variable=self.presion_var, value=p).pack(anchor="w", padx=20)

        ttk.Label(frame1, text="Salud general:").pack(anchor="w", padx=10)
        for s in ["Malo","Regular","Bueno","Muy Bueno","Excelente"]:
            ttk.Radiobutton(frame1, text=s, variable=self.salud_var, value=s).pack(anchor="w", padx=20)

        self.frames.append(frame1)

        # ---------------- Frame 2: Lifestyle ----------------
        frame2 = ttk.Frame(self.root)
        ttk.Label(frame2, text="Estilo de Vida", font=("Arial", 16)).pack(pady=10)

        self.frutas_var = tk.StringVar()
        self.verduras_var = tk.StringVar()
        self.sal_var = tk.StringVar()
        self.fuma_var = tk.BooleanVar()
        self.alcohol_var = tk.BooleanVar()
        self.horas_sueno_var = tk.StringVar()
        self.nivel_estres_var = tk.StringVar()

        ttk.Label(frame2, text="Consume frutas?").pack(anchor="w", padx=10)
        for v in ["Si","No"]:
            ttk.Radiobutton(frame2, text=v, variable=self.frutas_var, value=v).pack(anchor="w", padx=20)

        ttk.Label(frame2, text="Consume verduras?").pack(anchor="w", padx=10)
        for v in ["Si","No"]:
            ttk.Radiobutton(frame2, text=v, variable=self.verduras_var, value=v).pack(anchor="w", padx=20)

        ttk.Label(frame2, text="Sal diaria (g):").pack(anchor="w", padx=10)
        ttk.Entry(frame2, textvariable=self.sal_var).pack(fill="x", padx=10)

        ttk.Checkbutton(frame2, text="Fuma", variable=self.fuma_var).pack(anchor="w", padx=10)
        ttk.Checkbutton(frame2, text="Alcohol en exceso", variable=self.alcohol_var).pack(anchor="w", padx=10)

        ttk.Label(frame2, text="Horas de sueño:").pack(anchor="w", padx=10)
        ttk.Entry(frame2, textvariable=self.horas_sueno_var).pack(fill="x", padx=10)

        ttk.Label(frame2, text="Nivel de estrés (1-10):").pack(anchor="w", padx=10)
        ttk.Entry(frame2, textvariable=self.nivel_estres_var).pack(fill="x", padx=10)

        self.frames.append(frame2)

        # ---------------- Navigation Buttons ----------------
        for f in self.frames:
            nav = ttk.Frame(f)
            nav.pack(pady=10, fill="x")
            ttk.Button(nav, text="Anterior", command=self.prev_frame).pack(side="left", padx=20)
            ttk.Button(nav, text="Siguiente", command=self.next_frame).pack(side="right", padx=20)

    def toggle_colesterol_alto(self):
        if self.colesterol_var.get():
            self.colesterol_alto_cb.state(['!disabled'])
        else:
            self.colesterol_alto_cb.state(['disabled'])
            self.colesterol_alto_var.set(False)

    def show_frame(self, idx):
        for f in self.frames:
            f.pack_forget()
        self.frames[idx].pack(fill="both", expand=True)
        self.current_frame = idx
        self.update_step_ui()

    def next_frame(self):
        if self.current_frame < len(self.frames)-1:
            self.show_frame(self.current_frame + 1)
        else:
            self.submit()

    def prev_frame(self):
        if self.current_frame > 0:
            self.show_frame(self.current_frame -1)

    def submit(self):
        # Validate
        if not self.email_var.get() or not self.nombre_var.get():
            messagebox.showerror("Error", "Email y nombre son requeridos")
            return

        self.data['usuario'] = {
            "email": self.email_var.get(),
            "nombre": self.nombre_var.get(),
            "apellido": self.apellido_var.get(),
            "sexo": self.sexo_var.get(),
            "fechaNacimiento": self.fecha_var.get()
        }

        self.data['historialMedico'] = {
            "diabetes": self.diabetes_var.get(),
            "hipertension": self.hipertension_var.get(),
            "colesterol": self.colesterol_var.get(),
            "colesterolAlto": self.colesterol_alto_var.get(),
            "bmi": float(self.bmi_var.get() or 0),
            "presion": self.presion_var.get(),
            "saludGeneral": self.salud_var.get()
        }

        self.data['estiloDeVida'] = {
            "consumeFrutas": self.frutas_var.get()=="Si",
            "consumeVerduras": self.verduras_var.get()=="Si",
            "salDiaria": int(self.sal_var.get() or 0),
            "fuma": self.fuma_var.get(),
            "alcoholExceso": self.alcohol_var.get(),
            "horasSueno": int(self.horas_sueno_var.get() or 0),
            "nivelEstres": int(self.nivel_estres_var.get() or 0)
        }

        messagebox.showinfo("Formulario enviado", json.dumps(self.data, indent=2))
        print(json.dumps(self.data, indent=2))

if __name__ == "__main__":
    root = tk.Tk()
    app = PredictHealthWizard(root)
    root.mainloop()
