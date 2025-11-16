import pandas as pd
import os

# input file
df = pd.read_csv("Backend/AI/Hypertension/hypertension_train.csv")

# split
train = df.sample(frac=0.8, random_state=0)
test = df.drop(train.index)

# output folder
os.makedirs("split", exist_ok=True)

# save
train.to_csv("Backend/AI/Hypertension/split/hypertension_train.csv", index=False)
test.to_csv("Backend/AI/Hypertension/split/hypertension_test.csv", index=False)
