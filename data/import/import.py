# -*- coding: utf-8 -*-
"""
Created on Tue Nov  3 04:20:34 2026

@author: cuucp
"""

"""
Demande + Concurrence pour TOUS les pays – UN Comtrade (API avec clé gratuite)
==============================================================================
Dans Jupyter :
    %pip install requests pandas
    %run demande_concurrence_tous_pays.py

La clé est demandée au lancement (elle n'est pas écrite dans le fichier,
pour ne pas la publier par erreur sur GitHub).

Résultats :
    demande_comtrade_tous_pays.csv      1 ligne par pays : importations par année + croissance
    concurrence_comtrade_tous_pays.csv  1 ligne par pays : fournisseurs, part du 1er, part de la France, concentration
    brut_imports_par_fournisseur.csv    toutes les lignes reçues (pour vérifier)
"""

import getpass
import time

import pandas as pd
import requests

# ---------------------------------------------------------------- paramètres
PRODUITS = ["040690"]            # ajoutez d'autres codes SH6, ex. "220421" (vins), "190531" (biscuits)
ANNEES = [2021, 2022, 2023, 2024]
FRANCE = 251                     # code ONU de la France

URL = "https://comtradeapi.un.org/data/v1/get/C/A/HS"   # C = biens, A = annuel, HS = nomenclature
CLE = getpass.getpass("Clé API Comtrade (Primary key) : ").strip()
ENTETES = {"Ocp-Apim-Subscription-Key": CLE}


def appel(produit, annee, partenaire=None):
    """Importations du produit, pour TOUS les pays déclarants (reporterCode absent)."""
    params = {
        "cmdCode": produit, "period": annee, "flowCode": "M",
        "customsCode": "C00", "motCode": 0, "partner2Code": 0,   # totaux, évite les doublons
        "includeDesc": "true", "maxRecords": 100000,
    }
    if partenaire is not None:
        params["partnerCode"] = partenaire
    for essai in range(3):
        r = requests.get(URL, params=params, headers=ENTETES, timeout=120)
        if r.status_code == 429:                      # trop de requêtes : on attend
            time.sleep(10 * (essai + 1))
            continue
        if r.status_code != 200:
            raise RuntimeError(f"HTTP {r.status_code} : {r.text[:300]}")
        time.sleep(2)
        js = r.json()
        if js.get("error"):
            raise RuntimeError(js["error"])
        return js.get("data", [])
    raise RuntimeError("Trop de refus (429), réessayez plus tard")


# ---------------------------------------------------------------- collecte
brut = []
for produit in PRODUITS:
    for annee in ANNEES:
        # Une seule requête : tous les pays déclarants x tous leurs fournisseurs
        try:
            data = appel(produit, annee)
        except Exception as e:
            print(f"! {produit} {annee} : {e}")
            continue
        for x in data:
            brut.append({
                "produit": produit, "annee": annee,
                "pays_code": x.get("reporterCode"), "pays_iso3": x.get("reporterISO"),
                "pays": x.get("reporterDesc"),
                "fournisseur_code": x.get("partnerCode"), "fournisseur": x.get("partnerDesc"),
                "valeur_usd": x.get("primaryValue") or 0, "poids_kg": x.get("netWgt"),
            })
        nb_pays = len({x.get("reporterCode") for x in data})
        print(f"ok {produit} {annee} : {len(data)} lignes, {nb_pays} pays déclarants")

df = pd.DataFrame(brut)
if df.empty:
    raise SystemExit("Aucune donnée reçue : vérifiez la clé et le message d'erreur ci-dessus.")
df.to_csv("brut_imports_par_fournisseur.csv", index=False)

monde = df[df.fournisseur_code == 0]                 # ligne « World » = total importé
detail = df[df.fournisseur_code != 0]                # une ligne par fournisseur

# ---------------------------------------------------------------- demande
dem = monde.pivot_table(index=["produit", "pays_iso3", "pays"], columns="annee",
                        values="valeur_usd", aggfunc="sum")
dem.columns = [f"imports_{a}_usd" for a in dem.columns]
dem = dem.reset_index()
cols = [c for c in dem.columns if c.startswith("imports_")]


def croissance(ligne):
    vals = [(int(c[8:12]), ligne[c]) for c in cols if pd.notna(ligne[c]) and ligne[c] > 0]
    if len(vals) < 2:
        return None
    (a0, v0), (a1, v1) = vals[0], vals[-1]
    return round((v1 / v0) ** (1 / (a1 - a0)) - 1, 4)


dem["croissance_annuelle_moy"] = dem.apply(croissance, axis=1)
dem["derniere_annee_dispo"] = dem.apply(
    lambda l: max((int(c[8:12]) for c in cols if pd.notna(l[c])), default=None), axis=1)
dem.to_csv("demande_comtrade_tous_pays.csv", index=False)

# ---------------------------------------------------------------- concurrence (dernière année dispo par pays)
derniere = detail.groupby(["produit", "pays_iso3"]).annee.transform("max")
d = detail[detail.annee == derniere].copy()
d["part"] = d.valeur_usd / d.groupby(["produit", "pays_iso3"]).valeur_usd.transform("sum")


def resume(g):
    g = g.sort_values("valeur_usd", ascending=False)
    return pd.Series({
        "annee": g.annee.iloc[0],
        "nb_fournisseurs": len(g),
        "premier_fournisseur": g.fournisseur.iloc[0],
        "part_premier_fournisseur": round(g.part.iloc[0], 4),
        "part_france": round(g.loc[g.fournisseur_code == FRANCE, "part"].sum(), 4),
        "hhi_concentration": round((g.part ** 2).sum(), 4),   # 0 = très ouvert, 1 = un seul fournisseur
    })


conc = d.groupby(["produit", "pays_iso3", "pays"]).apply(resume).reset_index()
conc.to_csv("concurrence_comtrade_tous_pays.csv", index=False)

print(f"\nTerminé : {dem.pays_iso3.nunique()} pays pour la demande, {conc.pays_iso3.nunique()} pour la concurrence.")
print(dem.sort_values(cols[-1], ascending=False).head(10).to_string(index=False))