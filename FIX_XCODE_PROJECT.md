# 🔧 Guide pour corriger le projet Xcode

## Problème

Le projet Xcode essaie d'utiliser AIME depuis GitHub (`https://github.com/KamilBourouiba/AIME`), mais ce dépôt n'existe pas encore.

## ✅ Solution : Ajouter AIME comme dépendance locale

### Étapes dans Xcode

1. **Ouvrez** `AIMEExampleApp.xcodeproj` dans Xcode

2. **Sélectionnez le projet** (icône bleue en haut à gauche)

3. **Sélectionnez la cible** `AIMEExampleApp`

4. **Allez dans l'onglet "Package Dependencies"**

5. **Supprimez la dépendance GitHub** :
   - Trouvez `AIME` dans la liste
   - Cliquez dessus et appuyez sur `Suppr` ou cliquez sur `-`

6. **Ajoutez la dépendance locale** :
   - Cliquez sur `+` en bas
   - Choisissez "Add Local..."
   - Naviguez vers :
     ```
     /Users/apprenant122/Downloads/FMSample day 2 (1)/FMSample task 11 solution/AIME
     ```
   - Sélectionnez le dossier `AIME` (celui avec `Package.swift`)
   - Cliquez sur "Add Package"

7. **Vérifiez** :
   - AIME devrait apparaître avec un chemin local (pas une URL GitHub)
   - Le chemin devrait être quelque chose comme : `file:///Users/apprenant122/Downloads/...`

8. **Recompilez** : `Cmd + B`

## 🎯 Chemin exact à utiliser

```
/Users/apprenant122/Downloads/FMSample day 2 (1)/FMSample task 11 solution/AIME
```

**Important** : Sélectionnez le dossier qui **contient** `Package.swift`, pas un sous-dossier.

## ✅ Vérification

Après avoir ajouté la dépendance :

1. **Vérifiez l'import** :
   ```swift
   import AIME  // Ne devrait plus donner d'erreur
   ```

2. **Construisez** : `Cmd + B`
   - Devrait compiler sans erreur "No such module 'AIME'"

3. **Exécutez** : `Cmd + R`

## 🐛 Dépannage

### Si "Add Local..." ne fonctionne pas

Essayez cette méthode alternative :

1. File → Add Package Dependencies
2. Dans la barre de recherche, collez le chemin complet :
   ```
   /Users/apprenant122/Downloads/FMSample day 2 (1)/FMSample task 11 solution/AIME
   ```
3. Xcode devrait détecter que c'est un package local

### Si le chemin avec espaces pose problème

Vous pouvez créer un lien symbolique sans espaces :

```bash
ln -s "/Users/apprenant122/Downloads/FMSample day 2 (1)/FMSample task 11 solution/AIME" ~/AIME
```

Puis utilisez `~/AIME` comme chemin dans Xcode.

### Nettoyer le cache

Si ça ne fonctionne toujours pas :

1. Product → Clean Build Folder (`Shift + Cmd + K`)
2. Fermez Xcode
3. Supprimez `DerivedData` :
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/AIMEExampleApp-*
   ```
4. Rouvrez Xcode et réessayez

## 📝 Alternative : Utiliser GitHub

Si vous préférez utiliser GitHub (une fois le dépôt créé) :

1. Poussez AIME sur GitHub (voir `PUSH_NOW.md`)
2. Dans Xcode, mettez à jour l'URL de la dépendance vers votre dépôt GitHub
3. Xcode téléchargera automatiquement le package

## ✅ Après correction

Votre code devrait fonctionner :

```swift
import AIME

struct ContentView: View {
    @StateObject private var transcriber = Transcriber()
    // ... reste du code
}
```

