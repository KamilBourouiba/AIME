# ✅ Correction des types @Generable

## Problème résolu

Les types avec `@Generable` ne peuvent pas être définis localement dans des fonctions. Ils doivent être définis au niveau du fichier.

## Corrections appliquées

### 1. ActionItemsExtractor.swift
- ✅ `ActionItemsResponse` déplacé au niveau du fichier (ligne 11)
- ✅ Suppression des définitions locales dans `extract()` et `extractStreaming()`
- ✅ Ajout de `@available(iOS 26.0, ...)`

### 2. QuestionAnswerer.swift
- ✅ `QuestionAnswerResponse` déplacé au niveau du fichier (ligne 12)
- ✅ Suppression des définitions locales dans `ask()` et `askStreaming()`
- ✅ Ajout de `@available(iOS 26.0, ...)`

### 3. TimelineExtractor.swift
- ✅ `TimelineResponse` déplacé au niveau du fichier (ligne 40)
- ✅ `TimelineItemResponse` déplacé au niveau du fichier (ligne 21)
- ✅ `TimelinePriorityResponse` déplacé au niveau du fichier (ligne 11)
- ✅ Suppression des définitions locales dans `extract()` et `extractStreaming()`
- ✅ Correction de `mapPriority()` pour utiliser `TimelinePriorityResponse`
- ✅ Ajout de `@available(iOS 26.0, ...)`

### 4. Summarizer.swift
- ✅ `Summary` déjà au niveau du fichier
- ✅ Ajout de `@available(iOS 26.0, ...)` à `Summary`
- ✅ Ajout de `@available(iOS 26.0, ...)` à `ChunkProcessor`

## Structure finale

Tous les types `@Generable` sont maintenant :
- ✅ Définis au niveau du fichier (pas dans des fonctions)
- ✅ Marqués comme `private` pour éviter les conflits
- ✅ Annotés avec `@available(iOS 26.0, ...)`

## Prochaines étapes

1. **Commitez et poussez** :
   ```bash
   cd AIME
   git add -A
   git commit -m "Fix: Déplacement des types @Generable au niveau du fichier"
   git push origin main
   ```

2. **Dans Xcode** :
   - File → Packages → Reset Package Caches
   - File → Packages → Resolve Package Versions
   - Recompilez : `Cmd + B`

Les erreurs "Local type cannot have attached extension macro" devraient maintenant être résolues !

