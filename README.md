#  DJINA - Votre Compagnon de Transport

DJINA est une application mobile de transport et livraison développée avec Flutter. Elle offre une expérience utilisateur moderne et intuitive pour tous vos besoins de déplacement au Sénégal.

##  Fonctionnalités

###  Interface Utilisateur
- Design moderne avec thème cohérent
- Navigation intuitive et fluide
- Widgets réutilisables pour une expérience uniforme
- Support des couleurs personnalisées via `AppTheme`

###  Authentification Complète
- Inscription et connexion sécurisées
- Vérification par code OTP
- Gestion des profils utilisateurs

##  Architecture

L'application suit une architecture Clean Architecture modulaire :

```
lib/
├── core/                    # Configurations globales
│   └── theme/              # Thème et couleurs
├── src/
│   ├── auth/               # Authentification
│   ├── onboarding/         # Introduction
│   ├── home/               # Page d'accueil et services
│   └── drawer/             # Menu latéral et profil
```

##  Comment Utiliser

### Installation
```bash
# Cloner le projet
git clone https://github.com/votre-username/djina_debug.git

# Installer les dépendances
flutter pub get

# Lancer l'application
flutter run
```

### Navigation
1. **Onboarding** → Introduction à l'application
2. **Authentification** → Connexion/Inscription
3. **Accueil** → Sélection des services
4. **Services** → Pages dédiées pour chaque service
5. **Profil** → Gestion du compte utilisateur

##  Technologies

- **Flutter** : Framework de développement
- **Provider** : Gestion d'état
- **Clean Architecture** : Structure modulaire
- **Material Design** : Interface utilisateur

##  Thème

L'application utilise un système de thème cohérent :
- **Couleur Primaire** : Blanc (`AppTheme.primaryColor`)
- **Couleur Secondaire** : Noir (`AppTheme.secondaryColor`) 
- **Couleur Accent** : Orange (`AppTheme.cardColor`)

##  Captures d'Écran


##  Prochaines Étapes

- [ ] Intégration avec l'API backend
- [ ] Géolocalisation en temps réel
- [ ] Système de paiement
- [ ] Notifications push
- [ ] Mode sombre

##  Équipe


---

*DJINA - Votre transport, notre priorité* 🇸🇳
