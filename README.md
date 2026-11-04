# Mathou 🐱 — MVP CPE 2026

Application mobile Flutter (Android / iOS) pour apprendre les maths comme sur Duolingo.
Niveau ciblé pour le MVP : **CE1 – CE2**.

## Lancer l'app (première fois)

Dans PowerShell, à la racine du dossier `C:\Projets\cpe2026_maths` :

```powershell
flutter create . --project-name mathou --org com.cpe2026 --platforms android,ios
flutter pub get
flutter run
```

`flutter create .` ajoute les dossiers `android/` et `ios/` sans toucher au code de `lib/`.
Branchez un téléphone Android (débogage USB activé) ou lancez un émulateur avant `flutter run`.

## Générer l'APK à partager (QR code pour le jury)

```powershell
flutter build apk --release
```

L'APK se trouve dans `build\app\outputs\flutter-apk\app-release.apk`.

## Le concept : jouer, gagner des pièces, construire son village

- Chaque leçon est un **mini-jeu** (la rotation change à chaque partie) :
  🎈 Éclate les ballons · 🧺 Attrape les fruits · 🏎️ Course folle · ⚔️ Duel du monstre (toujours pour le Boss).
- Chaque bonne réponse rapporte des **pièces 🪙** (bonus combo), + 15 pièces si on gagne la partie.
- Les pièces servent à **construire son village** (17 éléments, du 🌻 à la 🚀) qui monte en rang :
  Campement → Hameau → Village → Petite ville → Grande ville.
- Derrière le jeu : l'algorithme adaptatif choisit la difficulté de chaque calcul,
  et une explication pas à pas s'affiche à chaque erreur.

Fichiers : `lib/games/` (mini-jeux), `lib/screens/village_screen.dart`, `lib/models/village.dart`.

## 🐱 Identité visuelle

- Mascotte : le chat **Mathou** (`assets/images/mathou.png`).
- Palette : orange `#FF8C38`, bleu foncé `#16355F`, noir `#232323`, blanc.
- Polices : **Nunito** (titres) et **Quicksand** (textes), licence SIL OFL, dans `assets/fonts/`.
- Un **thème par cycle** (Cycle 1 → Lycée), en **clair ou sombre** (Espace parent → Réglages → Apparence).
  Tout est dans `lib/theme.dart`.

## 📚 Programme : de la maternelle à la Terminale

| Cycle | Fichier | Classes |
|---|---|---|
| 🧸 Cycle 1 | `lib/curriculum/cycle1.dart` | PS, MS, GS |
| 🎒 Cycle 2 | `lib/curriculum/cycle2.dart` | CP, CE1, CE2 |
| 🧭 Cycle 3 | `lib/curriculum/cycle3.dart` | CM1, CM2, 6e |
| 📐 Cycle 4 | `lib/curriculum/cycle4.dart` | 5e, 4e, 3e |
| 🎓 Lycée | `lib/curriculum/lycee.dart` | 2nde, 1re, Terminale (spécialité) |

Chapitres construits d'après les programmes officiels (dossier `docs` des specs).
Un chapitre = une fonction `(niveau 1..5, hasard) → Question`. Types de questions :
- `Question(...)` : réponse numérique (case à remplir, mini-jeux) ;
- `Question.text(...)` : réponse en texte (fraction, forme, mot) en QCM ;
- `Question.graph(...)` : placer un point sur une **droite graduée** ou dans un **repère**.

Écriture mathématique dans les textes : `\frac{3}{4}`, `x^{2}`, `u_{n}`, `\sqrt{16}`, `\int`.

Pour vérifier que tous les chapitres génèrent des questions valides : `flutter test`.

## ✏️ Deux façons de jouer chaque chapitre

- **Mini-jeu** (ballons, fruits, course, duel) : réponses à choisir, pièces et village.
- **Exercices** (façon Mathraining) : un énoncé, une case réponse, « Soumettre ».
  Les chapitres de graphiques se font uniquement dans ce mode.

## 🎯 Personnalisation

- Chapitre **recommandé** sur la carte (lacunes + oubli + nouveautés).
- **Révision express** : 80 % de questions sur les points faibles.
- Espace parent : temps moyen de réponse, parties de la semaine, prochain chapitre conseillé.

## ⭐ Freemium

Gratuit, avec une fenêtre « pub » une partie sur trois qui propose **Mathou Premium**
(4,99 €/mois ou 39,99 €/an, 7 jours d'essai). Version démo : aucun paiement réel.
Fichier : `lib/screens/premium_screen.dart`.

## Ce que contient le MVP

| Fonction | Fichier |
|---|---|
| Écran d'accueil + prénom de l'enfant | `lib/screens/onboarding_screen.dart`, `welcome_screen.dart` |
| Carte de progression (5 leçons, déblocage) | `lib/screens/map_screen.dart` |
| Mode Exercices (case réponse, QCM, droite graduée, repère) | `lib/screens/exercise_screen.dart` |
| Écran de fin + confettis | `lib/screens/result_screen.dart` |
| Espace parent (contrôle parental, stats, analyse) | `lib/screens/parent_gate.dart`, `parent_dashboard_screen.dart` |
| Générateur d'exercices (5 niveaux par compétence + explications) | `lib/logic/exercise_generator.dart` |
| **Algorithme adaptatif (type Elo)** | `lib/logic/adaptive_engine.dart` |
| Sauvegarde locale de la progression | `lib/logic/progress_store.dart` |

## L'algorithme adaptatif (à expliquer au jury)

- Chaque compétence de l'enfant a une note θ (1000 au départ), chaque niveau d'exercice une difficulté D.
- Probabilité de réussite prévue : `p = 1 / (1 + 10^((D − θ)/400))`.
- Après chaque réponse : `θ ← θ + K × (résultat − p)`.
- L'app choisit le niveau où l'enfant a **~70 % de chances de réussir** : ni trop facile, ni décourageant.
- Les exercices ratés reviennent plus tard dans la leçon (répétition), avec une explication pas à pas.
- Le Boss cible en priorité la compétence la plus faible.

## Pour la démo

Espace parent → « Débloquer toutes les leçons » pour montrer toute la carte,
et « Réinitialiser la progression » avant de passer devant le jury.

## Personnaliser

- Nom de l'app et mascotte : `lib/theme.dart` (`AppInfo`).
- Couleurs / leçons : `lib/models/skill.dart`.
- Nombre de bonnes réponses par leçon : `goal` dans `lesson_screen.dart`.
