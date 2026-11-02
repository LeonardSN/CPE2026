import sys
import pandas as pd
import numpy as np
from sklearn.ensemble import IsolationForest
from sklearn.preprocessing import OneHotEncoder

def main():
    
    ## I : Récupération du thème
    
    if len(sys.argv) < 2:
        print("Error. Expected: python3 main.py [product]")
        sys.exit(1)
    product = sys.argv[1]
    
    # Ici on obtient data_csv avec product
    
    df_product = pd.read_csv(data_csv)
    # data_csv à définir (à récupérer grâce à une API utilisant la variable "product")
    
    # II : Définition de l'encoder
    
    encoder = OneHotEncoder(sparse_output=False)
    statut_encoded = encoder.fit_transform(df_product[["statut"]]) # statut est un exemple
    statut_df = pd.DataFrame(statut_encoded, columns=encoder.get_feature_names_out(["statut"]))

    X = pd.concat([df_product[["age", "revenu"]], statut_df], axis=1) # age et revenu sont aussi des exemples
    # si besoin d'un one hot encoder
    clf = IsolationForest(random_state=42)
    clf.fit(X)

    # III : Application du IsolationForest

    # Génération du score
    # Plus le score est BAS (négatif), plus la ligne est une anomalie (atypique)
    # Plus le score est HAUT (positif), plus la ligne est normale (représentative)
    df_product["score_unsupervised"] = clf.score_samples(X)

    # Classement des lignes (Top 1 = La ligne la plus centrale/typique)
    df_product["rang_centralite"] = df_product["score_unsupervised"].rank(
        ascending=False, method="min"
    )
    
    print(df_product.sort_values(by="rang_centralite"))

if __name__ == "__main__":
    main()
