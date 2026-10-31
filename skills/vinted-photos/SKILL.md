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

## 2. Générer 4 photos
Écris un prompt par photo dans `prompt1.txt` à `prompt4.txt` (UTF-8), puis lance pour chacune :

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$HOME\.claude\skills\vinted-photos\generer.ps1" -Images ref1.jpg,ref2.jpg -PromptFile prompt1.txt -Out photo1.png
```

| Photo | Scène |
|---|---|
| 1 | Produit entier, bien visible |
| 2 | Produit porté ou utilisé |
| 3 | Gros plan sur la matière |
| 4 | Autre angle, même lieu |

Modèle obligatoire : `gpt-image-2.5-sunburst`, format 3:4 en 2K. Le script les applique par défaut : ne les change pas. Génère une photo à la fois.

Chaque prompt commence par « amateur, super realistic photo taken with a phone (iPhone) », puis demande : exactement le même produit que la référence (forme, couleur, motifs, nombre de pièces), lumière de maison, cadrage imparfait, intérieur ordinaire, aucun texte ni logo ajouté. Une personne visible est d'origine européenne, écrit dans le prompt.

La référence est toujours la photo du fournisseur, jamais une image déjà générée : sinon le produit se déforme.

## 3. Contrôler chaque image
Ouvre chaque image dès sa sortie et compare-la à la référence. Si le produit diffère, corrige le prompt et relance.

## 4. Écrire la fiche
- Titre : type de produit, coloris, taille, matière.
- Description : courte, naturelle, avec uniquement des informations vraies.
- Pas de fausse marque, pas de faux état, pas de faux délai.
- Enregistre le tout dans `fiche.md`, puis ouvre le dossier.

## Erreurs
- Clé absente ou refusée : demande-moi de vérifier ma clé ArgoLink sans jamais me la faire écrire dans le chat.
- Solde insuffisant : dis-moi de recharger sur argolink.io.
- Refus ou échec isolé : relance la même photo une fois, sans changer de modèle.
