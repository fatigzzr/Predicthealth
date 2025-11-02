import pandas as pd

splits = {'train': 'train.parquet', 'test': 'test.parquet'}
df = pd.read_parquet("hf://datasets/Bena345/cdc-diabetes-health-indicators/" + splits["train"])

df.to_csv("train.csv", index=False)
print("CSV saved as train.csv")