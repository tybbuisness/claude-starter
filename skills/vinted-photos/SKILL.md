---
name: vinted-photos
description: Génère les photos et le texte d'une annonce Vinted à partir d'un lien ou d'une photo produit, via l'API ArgoLink. À utiliser dès que je donne un lien produit (Temu, AliExpress, SHEIN) ou une photo et que je parle de photos, de fiche ou d'annonce Vinted.
---

# Photos et fiche Vinted

Dossier de travail : `~/second-brain/projets/vinted/<nom-du-produit>/`.

## 1. Lire le produit
- Ouvre le lien. Relève le coloris, la taille, la matière, les dimensions, ce qui est inclus ou non.
- Enregistre 1 à 3 photos de référence du bon coloris sous `ref1.jpg`, `ref2.jpg`, `ref3.jpg`.
- Si la page est inaccessible, demande-moi une photo. N'invente aucune caractéristique.

## 2. Générer une grille 2x2, découpée en 4 photos
Un seul appel produit les 4 photos : c'est moins cher et le lieu reste cohérent. Écris le prompt dans `prompt.txt` (UTF-8), puis lance :

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$HOME\.claude\skills\vinted-photos\generer.ps1" -Images ref1.jpg,ref2.jpg -PromptFile prompt.txt
```

Le script crée `grille.png`, puis `photo1.jpg` à `photo4.jpg`. Modèle obligatoire : `gpt-image-2.5-sunburst`, en 2160x2880. Ce sont ses réglages par défaut : ne les change pas.

Le prompt commence par « amateur, super realistic photo taken with a phone (iPhone). A vertical 3:4 image containing a 2x2 grid of 4 separate photos », puis demande :
- exactement le même produit que la référence (forme, couleur, motifs, nombre de pièces) ;
- 4 cases de même taille qui coupent l'image exactement en deux dans les deux sens, sans bordure, sans espace, sans texte ;
- en haut à gauche le produit entier, en haut à droite le produit porté ou utilisé, en bas à gauche un gros plan sur la matière, en bas à droite un autre angle ;
- dans chaque case, le sujet garde une marge visible avec les bords ;
- lumière de maison, cadrage imparfait, intérieur ordinaire, aucun logo ajouté ;
- toute personne visible est d'origine européenne.

La référence est toujours la photo du fournisseur, jamais une image déjà générée : sinon le produit se déforme.

## 3. Contrôler chaque photo découpée
Ouvre `photo1.jpg` à `photo4.jpg`, pas seulement la grille. Compare chacune à la référence et vérifie qu'aucune n'est coupée au mauvais endroit. Si une photo est mauvaise, corrige le prompt et relance.

## 4. Écrire la fiche
- Titre : type de produit, coloris, taille, matière.
- Description : courte, naturelle, avec uniquement des informations vraies.
- Pas de fausse marque, pas de faux état, pas de faux délai.
- Enregistre le tout dans `fiche.md`, puis ouvre le dossier.

## Erreurs
- Clé absente ou refusée : demande-moi de vérifier ma clé ArgoLink sans jamais me la faire écrire dans le chat.
- Solde insuffisant : dis-moi de recharger sur argolink.io.
- Refus ou échec isolé : relance la même photo une fois, sans changer de modèle.
