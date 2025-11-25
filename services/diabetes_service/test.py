import pandas as pd
from services.shared.db import get_conn

def get_top3_sexes():
    try:
        with get_conn() as conn:
            query = """
                SELECT id_usuario, sexo
                FROM paciente
                ORDER BY id_usuario DESC
                LIMIT 3;
            """
            df = pd.read_sql(query, conn)
            return df
    except Exception as e:
        print("Error:", e)
        return None

if __name__ == "__main__":
    df = get_top3_sexes()
    if df is not None:
        print("Top 3 users by id_usuario and their sexes:")
        print(df)
