# Mathou 🦊 — MVP CPE 2026

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

## 👥 Travailler en équipe : un fichier par cycle

| Cycle | Fichier à compléter | État |
|---|---|---|
| 🎒 Primaire | `lib/curriculum/primaire.dart` | CP, CE1 (7 chapitres), CE2, CM1, CM2 |
| 📐 Collège | `lib/curriculum/college.dart` | à compléter |
| 🎓 Lycée | `lib/curriculum/lycee.dart` | à compléter |

Chaque fichier contient en haut un **modèle de chapitre** à copier. Un chapitre = une fonction
`(niveau 1..5, hasard) → Question(prompt, answer, explanation)`. Dès qu'un cycle a au moins
un chapitre, il devient jouable dans l'écran « Choisis ton niveau », avec les 4 mini-jeux,
le village et l'espace parent. **Pas besoin de toucher aux autres fichiers.**

Le style (couleurs, nom, mascotte) est centralisé dans `lib/theme.dart`.

Pour vérifier que tous les chapitres génèrent des questions valides : `flutter test`.

## Ce que contient le MVP

| Fonction | Fichier |
|---|---|
| Écran d'accueil + prénom de l'enfant | `lib/screens/onboarding_screen.dart`, `welcome_screen.dart` |
| Carte de progression (5 leçons, déblocage) | `lib/screens/map_screen.dart` |
| Leçon : QCM, saisie (pavé numérique), vrai/faux, 3 cœurs, XP | `lib/screens/lesson_screen.dart` |
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
