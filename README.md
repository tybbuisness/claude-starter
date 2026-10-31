# Claude Code starter (Windows)

Une configuration légère pour Claude Code : des règles de travail et trois plugins officiels.

## Installer

Claude Code doit déjà être installé. Dans PowerShell :

```powershell
irm https://raw.githubusercontent.com/tybbuisness/claude-starter/main/install.ps1 | iex
```

## Ce qui est installé

- `CLAUDE.md` dans `~/.claude` (l'ancien fichier est sauvegardé), avec la mémoire automatique
- un second brain dans `~/second-brain`, jamais écrasé
- le skill `vinted-photos`, avec sa clé ArgoLink saisie en masqué
- les plugins `superpowers`, `frontend-design` et `skill-creator`
- Context7, pour consulter la documentation à jour des outils
