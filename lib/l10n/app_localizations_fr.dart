// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Rapport Sécuritaire';

  @override
  String get welcome => 'Bienvenue';

  @override
  String get reportCrime => 'Signaler un Crime';

  @override
  String get myReports => 'Mes Rapports';

  @override
  String get messages => 'Messages';

  @override
  String get profile => 'Profil';

  @override
  String get dashboard => 'Tableau de Bord';

  @override
  String get emergency => 'Urgence';

  @override
  String get communityForum => 'Forum Communautaire';

  @override
  String get watchGroups => 'Groupes de Surveillance';

  @override
  String get helpSupport => 'Aide & Support';

  @override
  String get settings => 'Paramètres';

  @override
  String get logout => 'Déconnexion';

  @override
  String get login => 'Connexion';

  @override
  String get signup => 'S\'inscrire';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get forgotPassword => 'Mot de passe oublié?';

  @override
  String get submit => 'Soumettre';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get delete => 'Supprimer';

  @override
  String get edit => 'Modifier';

  @override
  String get search => 'Rechercher';

  @override
  String get filter => 'Filtrer';

  @override
  String get sort => 'Trier';

  @override
  String get loading => 'Chargement...';

  @override
  String get error => 'Erreur';

  @override
  String get success => 'Succès';

  @override
  String get noData => 'Aucune donnée disponible';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get description => 'Description';

  @override
  String get location => 'Emplacement';

  @override
  String get anonymous => 'Anonyme';

  @override
  String get submitAnonymously => 'Soumettre anonymement';

  @override
  String get addEvidence => 'Ajouter des Preuves';

  @override
  String get photo => 'Photo';

  @override
  String get video => 'Vidéo';

  @override
  String get audio => 'Audio';

  @override
  String get continueButton => 'Continuer';

  @override
  String get back => 'Retour';

  @override
  String get next => 'Suivant';

  @override
  String get previous => 'Précédent';

  @override
  String get close => 'Fermer';

  @override
  String get confirm => 'Confirmer';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get signIn => 'Se connecter';

  @override
  String get logIntoYourAccount => 'Connectez-vous à votre compte';

  @override
  String get rememberMe => 'Se souvenir de moi?';

  @override
  String get noAccount => 'Pas de compte?';

  @override
  String get createAnAccount => 'Créer un compte';

  @override
  String get fullName => 'Nom complet';

  @override
  String get emailAddress => 'Adresse e-mail';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get registerAnonymously => 'S\'inscrire anonymement';

  @override
  String get enterFullName => 'Entrer le nom complet';

  @override
  String get usernameMustBeAtLeast3Characters =>
      'Le nom d’utilisateur doit comporter au moins 3 caractères';

  @override
  String get usernameMustBeLessThan50Characters =>
      'Le nom d’utilisateur doit comporter moins de 50 caractères';

  @override
  String get youremailGmailCom => 'votreemail@gmail.com';

  @override
  String get testCredentials => 'Identifiants de test';

  @override
  String get emailTestSafereportCom => 'E-mail: test@safereport.com';

  @override
  String get passwordSafeReport123 => 'Mot de passe: SafeReport123';

  @override
  String goodMorning(String userName) {
    return 'Bonjour, $userName';
  }

  @override
  String goodAfternoon(String userName) {
    return 'Bon après-midi, $userName';
  }

  @override
  String goodEvening(String userName) {
    return 'Bonsoir, $userName';
  }

  @override
  String get accessibilitySettingsTitle => 'Paramètres d’accessibilité';

  @override
  String get accessibilityCustomize =>
      'Personnalisez l’application pour la rendre plus facile à utiliser';

  @override
  String get fontSizeLabel => 'Taille de police';

  @override
  String get fontSizeSmall => 'Petite (12px)';

  @override
  String get fontSizeLarge => 'Grande (28px)';

  @override
  String get fontSizePreview => 'Aperçu : voici l’apparence du texte';

  @override
  String get darkModeTitle => 'Mode sombre';

  @override
  String get darkModeSubtitle =>
      'Passez en mode sombre pour une meilleure visibilité en faible luminosité';

  @override
  String get ttsTitle => 'Activer la synthèse vocale';

  @override
  String get ttsSubtitle => 'Lit le texte à voix haute lorsqu’il est activé';

  @override
  String get ttsEnabledToast => 'Synthèse vocale activée';

  @override
  String get settingsSavedAutomatically =>
      'Les paramètres sont enregistrés automatiquement';

  @override
  String get reportNow => 'Signaler maintenant';

  @override
  String get yourCommunitySafetyHub =>
      'Votre Centre de\nSécurité Communautaire';

  @override
  String get communityStatus => 'Statut de la Communauté';

  @override
  String get thisWeek => 'Cette Semaine';

  @override
  String get avgResponse => 'Temps de Réponse Moyen';

  @override
  String get safetyLevel => 'Niveau de Sécurité';

  @override
  String get quickActions => 'Actions Rapides';

  @override
  String get nearbyIncidents => 'Incidents à Proximité';

  @override
  String nearbyIncidentsCount(int count) {
    return '$count à proximité';
  }

  @override
  String get viewAll => 'Voir tout';

  @override
  String get watchGroupInfo => 'Groupe de Surveillance';

  @override
  String newAlerts(int count) {
    return '$count nouvelles alertes';
  }

  @override
  String get safetyEducation => 'Éducation à la Sécurité';

  @override
  String get learnMore => 'En savoir plus';

  @override
  String get selectIncidentType => 'Sélectionner le Type d\'Incident';

  @override
  String get pleaseSelectAnIncidentType =>
      'Veuillez sélectionner un type d\'incident';

  @override
  String get pleaseProvideADescription => 'Veuillez fournir une description';

  @override
  String get suspiciousPerson => 'Personne Suspecte';

  @override
  String get individualActingSuspiciously =>
      'Individu agissant de manière suspecte';

  @override
  String get vehicleActivity => 'Activité Véhiculaire';

  @override
  String get suspiciousVehicleBehavior => 'Comportement suspect de véhicule';

  @override
  String get abandonedItem => 'Objet Abandonné';

  @override
  String get unattendedSuspiciousItems => 'Objets suspects non surveillés';

  @override
  String get theftBurglary => 'Vol/Cambriolage';

  @override
  String get propertyTheftOrBreakIn => 'Vol de propriété ou effraction';

  @override
  String get vandalism => 'Vandalisme';

  @override
  String get propertyDamageOrGraffiti => 'Dommages à la propriété ou graffitis';

  @override
  String get drugActivity => 'Activité de Drogue';

  @override
  String get suspectedDrugRelatedBehavior =>
      'Comportement suspect lié à la drogue';

  @override
  String get assaultViolence => 'Agression/Violence';

  @override
  String get physicalAltercationOrThreat => 'Altercation physique ou menace';

  @override
  String get noiseDisturbance => 'Nuisance Sonore';

  @override
  String get excessiveNoiseComplaint => 'Plainte pour bruit excessif';

  @override
  String get trespassing => 'Intrusion';

  @override
  String get unauthorizedEntry => 'Entrée non autorisée';

  @override
  String get other => 'Autre';

  @override
  String get otherIncidentType => 'Autre type d\'incident';

  @override
  String get describeTheIncident => 'Décrire l\'incident';

  @override
  String get addPhotosVideosOrAudio => 'Ajouter des Photos, Vidéos ou Audio';

  @override
  String get draftSaved => 'Brouillon enregistré';

  @override
  String get saving => 'Enregistrement...';

  @override
  String savedXMinutesAgo(int minutes) {
    return 'Enregistré il y a $minutes minutes';
  }

  @override
  String get restoreDraft => 'Restaurer le Brouillon';

  @override
  String get youHaveAnUnsavedDraft =>
      'Vous avez un brouillon non enregistré. Souhaitez-vous le restaurer?';

  @override
  String get restore => 'Restaurer';

  @override
  String get discard => 'Ignorer';

  @override
  String get continueToLocation => 'Continuer vers la localisation';

  @override
  String get all => 'Tous';

  @override
  String get active => 'Actif';

  @override
  String get resolved => 'Résolu';

  @override
  String get submitted => 'Soumis';

  @override
  String get reviewing => 'En cours d\'examen';

  @override
  String get sortBy => 'Trier par';

  @override
  String get date => 'Date';

  @override
  String get status => 'Statut';

  @override
  String get type => 'Type';

  @override
  String get deleteReports => 'Supprimer les Rapports';

  @override
  String areYouSureYouWantToDelete(int count) {
    return 'Êtes-vous sûr de vouloir supprimer $count rapport(s)?';
  }

  @override
  String get reportsDeleted => 'Rapports supprimés';

  @override
  String get noReportsSelected => 'Aucun rapport sélectionné';

  @override
  String get exportToPDF => 'Exporter en PDF';

  @override
  String get shareReports => 'Partager les Rapports';

  @override
  String get mySafetyReports => 'Mes Rapports de Sécurité';

  @override
  String get accountInformation => 'Informations du compte';

  @override
  String get name => 'Nom';

  @override
  String get phone => 'Téléphone';

  @override
  String memberSince(String date) {
    return 'Membre depuis $date';
  }

  @override
  String get myProfile => 'Mon Profil';

  @override
  String get accountSettings => 'Paramètres du Compte';

  @override
  String get changePassword => 'Changer le mot de passe';

  @override
  String get editProfile => 'Modifier le Profil';

  @override
  String get myImpact => 'Mon impact';

  @override
  String get offlineQueue => 'File d’attente hors ligne';

  @override
  String get accessibility => 'Accessibilité';

  @override
  String get language => 'Langue';

  @override
  String get accountSettingsTitle => 'Paramètres du compte';

  @override
  String get manageYourPreferences => 'Gérer vos préférences';

  @override
  String get securitySettings => 'Paramètres de Sécurité';

  @override
  String lastChangedXDaysAgo(int days) {
    return 'Dernière modification il y a $days jours';
  }

  @override
  String get update => 'Mettre à jour';

  @override
  String get twoFactorAuthentication => 'Authentification à Deux Facteurs';

  @override
  String get addExtraSecurityToYourAccount =>
      'Ajouter une sécurité supplémentaire à votre compte';

  @override
  String get biometricLogin => 'Connexion biométrique';

  @override
  String get useFingerprintOrFaceId =>
      'Utiliser l\'empreinte digitale ou la reconnaissance faciale';

  @override
  String get notificationsPreferences => 'Préférences de Notifications';

  @override
  String get pushNotifications => 'Notifications Push';

  @override
  String get reportUpdatesAndAlerts => 'Mises à jour et alertes de rapports';

  @override
  String get emailUpdates => 'Mises à jour par E-mail';

  @override
  String get weeklyCommunitySummary => 'Résumé hebdomadaire de la communauté';

  @override
  String get watchGroupAlerts => 'Alertes des Groupes de Surveillance';

  @override
  String get messagesFromYourGroups => 'Messages de vos groupes';

  @override
  String get privacySettings => 'Paramètres de Confidentialité';

  @override
  String get defaultAnonymousMode => 'Mode Anonyme par Défaut';

  @override
  String get alwaysSubmitReportsAnonymously =>
      'Toujours soumettre les rapports anonymement';

  @override
  String get locationSharing => 'Partage de Localisation';

  @override
  String get sharePreciseLocationWithReports =>
      'Partager l\'emplacement précis avec les rapports';

  @override
  String get anonymousReportingGuide => 'Guide de Signalement Anonyme';

  @override
  String get learnAboutPrivacyProtections =>
      'En savoir plus sur les protections de confidentialité';

  @override
  String get languagePreferences => 'Préférences de Langue';

  @override
  String get appLanguage => 'Langue de l’application';

  @override
  String get english => 'Anglais';

  @override
  String get french => 'Français';

  @override
  String get kinyarwanda => 'Kinyarwanda';

  @override
  String get swahili => 'Swahili';

  @override
  String get spanish => 'Espagnol';

  @override
  String get offlineReports => 'Rapports Hors Ligne';

  @override
  String get manageReportsWhenOffline => 'Gérer les rapports hors ligne';

  @override
  String get currentPassword => 'Mot de Passe Actuel';

  @override
  String get newPassword => 'Nouveau Mot de Passe';

  @override
  String get passwordStrength => 'Force du Mot de Passe';

  @override
  String get weak => 'Faible';

  @override
  String get medium => 'Moyen';

  @override
  String get strong => 'Fort';

  @override
  String get veryStrong => 'Très Fort';

  @override
  String get passwordRequirements => 'Exigences du Mot de Passe';

  @override
  String get atLeast8Characters => 'Au moins 8 caractères';

  @override
  String get oneUppercaseLetter => 'Une lettre majuscule';

  @override
  String get oneLowercaseLetter => 'Une lettre minuscule';

  @override
  String get oneNumber => 'Un chiffre';

  @override
  String get oneSpecialCharacter => 'Un caractère spécial';

  @override
  String get passwordChangedSuccessfully => 'Mot de passe modifié avec succès!';

  @override
  String get accessibilitySettings => 'Paramètres d\'Accessibilité';

  @override
  String get customizeTheAppToMakeItEasierToUse =>
      'Personnaliser l\'application pour la rendre plus facile à utiliser';

  @override
  String get fontSize => 'Taille de Police';

  @override
  String get adjustTextSize =>
      'Ajuster la taille du texte pour une meilleure lisibilité';

  @override
  String get highContrastMode => 'Mode Contraste Élevé';

  @override
  String get improveVisibilityWithHighContrast =>
      'Améliorer la visibilité avec des couleurs à contraste élevé';

  @override
  String get textToSpeech => 'Synthèse Vocale';

  @override
  String get readContentAloud => 'Lire le contenu à voix haute';

  @override
  String get accessibilitySettingsSavedSuccessfully =>
      'Paramètres d\'accessibilité enregistrés avec succès!';

  @override
  String errorSavingSettings(String error) {
    return 'Erreur lors de l\'enregistrement des paramètres: $error';
  }

  @override
  String get helpSupportTitle => 'Aide & Support';

  @override
  String get getAssistanceAndAnswers => 'Obtenir de l\'aide et des réponses';

  @override
  String get needHelp => 'Besoin d\'Aide?';

  @override
  String get wereHereToAssistYou247 =>
      'Nous sommes là pour vous aider 24h/24 et 7j/7';

  @override
  String get startLiveChat => 'Démarrer le Chat en Direct';

  @override
  String get quickHelp => 'Aide Rapide';

  @override
  String get frequentlyAskedQuestions => 'Questions Fréquemment Posées';

  @override
  String get commonQuestionsAndAnswers => 'Questions et réponses courantes';

  @override
  String get reportingGuidelines => 'Directives de Signalement';

  @override
  String get bestPracticesForSafetyReporting =>
      'Meilleures pratiques pour le signalement de sécurité';

  @override
  String get communityGuidelines => 'Directives Communautaires';

  @override
  String get rulesAndExpectations => 'Règles et attentes';

  @override
  String get contactOptions => 'Options de Contact';

  @override
  String get emailSupport => 'Support par E-mail';

  @override
  String get supportSafereportCom => 'support@saferreport.com';

  @override
  String get phoneSupport => 'Support Téléphonique';

  @override
  String get call => 'Appeler';

  @override
  String get sendFeedback => 'Envoyer des Commentaires';

  @override
  String get tellUsHowWeCanImprove =>
      'Dites-nous comment nous pouvons améliorer ......';

  @override
  String get submitFeedback => 'Soumettre les Commentaires';

  @override
  String get couldNotOpenEmailClient => 'Impossible d\'ouvrir le client e-mail';

  @override
  String couldNotMakePhoneCall(String error) {
    return 'Impossible de passer un appel téléphonique: $error';
  }

  @override
  String get emergencyMode => 'Mode Urgence';

  @override
  String get helpIsOnTheWay =>
      'L\'aide est en route.\nVotre localisation est partagée avec les services d\'urgence.';

  @override
  String get policeETA => 'Temps d\'Arrivée de la Police';

  @override
  String xToYMinutes(int min, int max) {
    return '$min-$max minutes';
  }

  @override
  String get callNow => 'APPELER';

  @override
  String get cancelEmergency => 'Annuler l’urgence';

  @override
  String get yourEmergencyContactsHaveBeenNotified =>
      'Vos contacts d\'urgence ont été notifiés';

  @override
  String get selectEmergencyService => 'Sélectionnez le service d’urgence';

  @override
  String get policeEmergency => 'Police (urgence)';

  @override
  String get fireDepartment => 'Pompiers';

  @override
  String get ambulance => 'Ambulance';

  @override
  String get nonEmergencyPolice => 'Police (non urgence)';

  @override
  String get communityForumTitle => 'Forum Communautaire';

  @override
  String get discussLocalSafetys => 'Discuter de la sécurité locale';

  @override
  String get popular => 'Populaire';

  @override
  String get recent => 'Récent';

  @override
  String get following => 'Suivi';

  @override
  String get createNewPost => 'Créer un Nouveau Message';

  @override
  String get recentPostsComingSoon => 'Messages récents à venir...';

  @override
  String get followingPostsComingSoon => 'Messages suivis à venir...';

  @override
  String get bestHomeSecurityCameras2023 =>
      'Meilleures caméras de sécurité domestique 2023?';

  @override
  String get neighborhoodPatrolTips => 'Conseils de patrouille de quartier';

  @override
  String get holidaySafetyAdvisory => 'Avis de Sécurité des Vacances';

  @override
  String get comments => 'Commentaires';

  @override
  String get helpful => 'Utile';

  @override
  String hoursAgo(int hours) {
    return 'Il y a $hours heures';
  }

  @override
  String get yesterday => 'Hier';

  @override
  String daysAgo(int days) {
    return 'il y a $days jours';
  }

  @override
  String get myWatchGroups => 'Mes Groupes de Surveillance';

  @override
  String get communitySafetyPartnerships =>
      'Partenariats de sécurité communautaire';

  @override
  String get oakStreetResidential => 'Résidentiel Oak Street';

  @override
  String get oakStreetNeighborhood => 'Quartier Oak Street';

  @override
  String get downtownBusiness => 'Affaires du Centre-Ville';

  @override
  String get businessDistrict => 'Quartier des Affaires';

  @override
  String get members => 'Membres';

  @override
  String get alerts => 'Alertes';

  @override
  String get coverage => 'Couverture';

  @override
  String get schedule => 'Horaire';

  @override
  String get monFri9AM5PM => 'Lun-Ven 9h-17h';

  @override
  String get businessHours => 'Heures d\'ouverture';

  @override
  String get viewMessages => 'Voir les Messages';

  @override
  String get viewDetails => 'Voir les Détails';

  @override
  String get findMoreGroups => 'Trouver Plus de Groupes';

  @override
  String get discoverAndJoinWatchGroups =>
      'Découvrir et rejoindre des groupes de surveillance dans votre région';

  @override
  String get browseGroups => 'Parcourir les Groupes';

  @override
  String get yourImpact => 'Votre Impact';

  @override
  String get contributionsToCommunitySafety =>
      'Vos contributions à la sécurité communautaire';

  @override
  String get reportsSubmitted => 'Rapports Soumis';

  @override
  String get watchGroupsJoined => 'Groupes de Surveillance Rejoints';

  @override
  String get helpfulResponses => 'Réponses Utiles';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get enableNotifications => 'Activer les Notifications';

  @override
  String get stayInformedAboutImportantUpdates =>
      'Restez informé des mises à jour et alertes importantes';

  @override
  String get enable => 'Activer';

  @override
  String get skip => 'Ignorer';

  @override
  String get messagesTitle => 'Messages';

  @override
  String get yourCommunications => 'Vos communications';

  @override
  String get reportCommunications => 'Communications de Rapports';

  @override
  String get directContact => 'Contact Direct';

  @override
  String get officer => 'Officier';

  @override
  String get newMessage => 'Nouveau Message';

  @override
  String get viewAllMessages => 'Voir Tous les Messages';

  @override
  String get joinDiscussion => 'Rejoindre la Discussion';

  @override
  String get anonymousReporting => 'Signalement Anonyme';

  @override
  String get whatIsHidden => 'Ce qui est Caché';

  @override
  String get whatIsShared => 'Ce qui est Partagé';

  @override
  String get benefits => 'Avantages';

  @override
  String get legalProtection => 'Protection Légale';

  @override
  String get faq => 'FAQ';

  @override
  String get appLanguageTitle => 'Langue de l\'Application';

  @override
  String get selectYourPreferredLanguage =>
      'Sélectionnez votre langue préférée:';

  @override
  String get saveLanguage => 'Enregistrer la Langue';

  @override
  String get nearbyIncidentsTitle => 'Incidents à Proximité';

  @override
  String get mapView => 'Vue Carte';

  @override
  String get radius => 'Rayon';

  @override
  String get timeFilter => 'Filtre Temporel';

  @override
  String get km => 'km';

  @override
  String get h => 'h';

  @override
  String minAgo(int minutes) {
    return 'il y a $minutes min';
  }

  @override
  String hourAgo(int hours) {
    return 'il y a $hours heure';
  }

  @override
  String hoursAgoPlural(int hours) {
    return 'il y a $hours heures';
  }

  @override
  String get distance => 'Distance';

  @override
  String get severity => 'Gravité';

  @override
  String get low => 'Faible';

  @override
  String get high => 'Élevé';

  @override
  String get safeReport => 'SafeReport';

  @override
  String get aRealTimeCrimePreventionPlatform =>
      'Une Plateforme de Prévention de la Criminalité en Temps Réel utilise une technologie intelligente pour détecter et répondre à la criminalité instantanément, aidant à garder les communautés en sécurité grâce à des alertes rapides et des actions basées sur les données.';

  @override
  String get getStarted => 'Commencer';

  @override
  String get loginSuccessful => 'Connexion réussie! Bienvenue sur SafeReport';

  @override
  String get invalidEmailOrPassword =>
      'E-mail ou mot de passe invalide. Essayez les identifiants d\'exemple.';

  @override
  String get pleaseEnterBothEmailAndPassword =>
      'Veuillez entrer l\'e-mail et le mot de passe';

  @override
  String connectionError(String error) {
    return 'Erreur de connexion: $error';
  }

  @override
  String get accountCreatedSuccessfully =>
      'Compte créé avec succès! Veuillez vous connecter.';

  @override
  String get unknown => 'Inconnu';

  @override
  String photosAdded(int count) {
    return '$count photo(s) ajoutée(s)';
  }

  @override
  String videosAdded(int count) {
    return '$count vidéo(s) ajoutée(s)';
  }

  @override
  String audiosAdded(int count) {
    return '$count audio(s) ajouté(s)';
  }

  @override
  String activeAlertsInYourArea(int count) {
    return '$count alertes actives dans votre région';
  }

  @override
  String get viewGroups => 'Voir les Groupes';

  @override
  String get callForHelp => 'Appeler à l\'aide';

  @override
  String get submitIncident => 'Soumettre un Incident';

  @override
  String get viewContributions => 'Voir les contributions';

  @override
  String get safetyTips => 'Conseils de sécurité';

  @override
  String get home => 'Accueil';

  @override
  String get managePreferencesSubtitle => 'Gérez vos préférences';

  @override
  String get quickAccess => 'Accès rapide';

  @override
  String get pendingReports => 'Rapports en attente';

  @override
  String get viewStats => 'Voir les statistiques';

  @override
  String get accessibilityCardTitle => 'Accessibilité';

  @override
  String get fontDisplay => 'Police et affichage';

  @override
  String get securitySettingsTitle => 'Paramètres de sécurité';

  @override
  String lastChangedDaysAgo(int days) {
    return 'Dernier changement il y a $days jours';
  }

  @override
  String get neverChanged => 'Jamais modifié';

  @override
  String get twoFactorAuth => 'Authentification à deux facteurs';

  @override
  String get addExtraSecurity =>
      'Ajoutez une sécurité supplémentaire à votre compte';

  @override
  String get useFingerprint =>
      'Utiliser l’empreinte ou la reconnaissance faciale';

  @override
  String get notificationsPreferencesTitle => 'Préférences de notifications';

  @override
  String get pushNotificationsLabel => 'Notifications push';

  @override
  String get pushNotificationsSubtitle => 'Mises à jour de rapports et alertes';

  @override
  String get emailUpdatesLabel => 'Mises à jour par email';

  @override
  String get emailUpdatesSubtitle => 'Résumé hebdomadaire de la communauté';

  @override
  String get watchGroupAlertsLabel => 'Alertes des groupes de vigilance';

  @override
  String get watchGroupAlertsSubtitle => 'Messages de vos groupes';

  @override
  String get privacySettingsTitle => 'Paramètres de confidentialité';

  @override
  String get defaultAnonymousModeLabel => 'Mode anonyme par défaut';

  @override
  String get defaultAnonymousModeSubtitle =>
      'Toujours envoyer les rapports anonymement';

  @override
  String get locationSharingLabel => 'Partage de localisation';

  @override
  String get locationSharingSubtitle =>
      'Partager la localisation précise avec les rapports (Toujours activé)';

  @override
  String get anonymousGuideTitle => 'Guide du signalement anonyme';

  @override
  String get anonymousGuideSubtitle =>
      'En savoir plus sur les protections de confidentialité';

  @override
  String get languagePreferencesTitle => 'Préférences de langue';

  @override
  String languageChangedTo(String language) {
    return 'Langue changée en $language';
  }

  @override
  String get accessibilitySettingsLinkTitle => 'Paramètres d’accessibilité';

  @override
  String get accessibilitySettingsLinkSubtitle =>
      'Ajuster la taille de police, le contraste et la synthèse vocale';

  @override
  String get saveAllSettings => 'Enregistrer tous les paramètres';

  @override
  String get settingsSavedSuccess => 'Paramètres enregistrés avec succès';

  @override
  String get anonymousReportingTitle => 'Signalement anonyme';

  @override
  String get reportSafely => 'Signaler en toute sécurité';

  @override
  String get identityProtected => 'Votre identité est entièrement protégée';

  @override
  String get whatsHiddenTitle => 'Ce qui est caché';

  @override
  String get hiddenName => 'Votre nom et identité';

  @override
  String get hiddenEmail => 'Adresse email';

  @override
  String get hiddenPhone => 'Numéro de téléphone';

  @override
  String get hiddenAccountId => 'ID du compte';

  @override
  String get hiddenPersonalIdentifiers => 'Identifiants personnels';

  @override
  String get whatsSharedTitle => 'Ce qui est toujours partagé';

  @override
  String get sharedLocation => 'Lieu de l’incident uniquement';

  @override
  String get sharedTime => 'Heure du rapport';

  @override
  String get sharedDescription => 'Description du rapport';

  @override
  String get sharedEvidence => 'Preuves (si fournies)';

  @override
  String get helpsPolice =>
      'Ces informations aident la police à répondre efficacement sans révéler qui vous êtes';

  @override
  String get benefitsAnonymousTitle => 'Avantages du signalement anonyme';

  @override
  String get benefit1 => 'Signaler sans peur de représailles';

  @override
  String get benefit2 => 'Protéger votre sécurité personnelle';

  @override
  String get benefit3 => 'Aider votre communauté sans exposition';

  @override
  String get benefit4 => 'Aucun suivi sauf si vous le choisissez';

  @override
  String get legalProtectionTitle => 'Protection juridique';

  @override
  String get legalProtectionText =>
      'Les signalements anonymes sont protégés par la loi. Votre identité ne peut pas être divulguée sans votre consentement explicite, même en cas de procédure légale.';

  @override
  String get faqTitle => 'Questions fréquemment posées';

  @override
  String get faqQ1 => 'La police peut-elle retrouver mon rapport jusqu’à moi ?';

  @override
  String get faqA1 =>
      'Non. Les rapports anonymes sont chiffrés et stockés sans aucune information d’identification.';

  @override
  String get faqQ2 => 'Puis-je passer de l’anonymat au non-anonymat ?';

  @override
  String get faqA2 =>
      'Oui, vous pouvez choisir pour chaque rapport de le soumettre anonymement ou avec vos informations.';

  @override
  String get faqQ3 => 'Mon rapport sera-t-il pris moins au sérieux ?';

  @override
  String get faqA3 =>
      'Non. Tous les rapports sont examinés de la même manière, qu’ils soient anonymes ou non.';

  @override
  String get orText => 'ou';

  @override
  String get continueWithGoogle => 'Continuer avec Google';

  @override
  String get usernameOptionalLabel => 'Nom d’utilisateur (optionnel)';

  @override
  String get usernameOptionalHint =>
      'Laissez vide pour l’auto-générer depuis l’email';

  @override
  String get phoneNumberLabel => 'Numéro de téléphone';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get phoneRequired => 'Le numéro de téléphone est requis';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get alreadyHaveAccount => 'Vous avez déjà un compte ?';

  @override
  String get signUpTitle => 'Inscription';

  @override
  String get easyReporting => 'Signalement facile';

  @override
  String get communityWatch => 'Vigilance communautaire';

  @override
  String get anonymousSecure => 'Anonyme et sécurisé';

  @override
  String get emergencyReady => 'Prêt pour l\'urgence';

  @override
  String get onboardingDescCommon =>
      'Signalez les activités suspectes en un instant,\nquelques gestes suffisent. Votre sécurité est notre priorité.';

  @override
  String get skipTutorial => 'Passer le tutoriel';

  @override
  String get profileTitle => 'Mon profil';

  @override
  String get profileSubtitle => 'Gérez vos informations personnelles';

  @override
  String get usernameLabel => 'Nom d’utilisateur';

  @override
  String get locationLabel => 'Lieu';

  @override
  String get emergencyContactTitle => 'Contact d’urgence';

  @override
  String get emergencyContactNameHint => 'Jane Doe';

  @override
  String get emergencyContactPhoneHint => '+250 7............';

  @override
  String get saveChanges => 'Enregistrer les modifications';

  @override
  String get unableToLoadProfile => 'Impossible de charger le profil';

  @override
  String get retry => 'Réessayer';

  @override
  String get goBack => 'Retour';

  @override
  String get memberSinceUnknown => 'Membre depuis : inconnu';

  @override
  String get usingAvailableData =>
      'Impossible de charger le profil complet. Utilisation des données disponibles.';

  @override
  String get userIdNotFound =>
      'ID utilisateur introuvable. Veuillez vous reconnecter.';

  @override
  String get loadProfileError =>
      'Une erreur est survenue lors du chargement de votre profil. Veuillez réessayer.';

  @override
  String get profileUpdatedSuccess => 'Profil mis à jour avec succès';

  @override
  String get failedToUpdateProfile => 'Échec de la mise à jour du profil';

  @override
  String get logoutConfirmTitle => 'Déconnexion';

  @override
  String get logoutConfirmMessage => 'Voulez-vous vraiment vous déconnecter ?';

  @override
  String get learnReportProtect => 'Apprendre. Signaler. Protéger.';

  @override
  String get empowerWithKnowledge =>
      'Renforcez-vous grâce à des connaissances sur le signalement responsable';

  @override
  String get featuredArticles => 'Articles à la une';

  @override
  String get howToReportTitle => 'Comment signaler';

  @override
  String get whatToReportTitle => 'Que signaler';

  @override
  String get videoTutorialsTitle => 'Tutoriels vidéo';

  @override
  String get quickSafetyTipsTitle => 'Conseils de sécurité rapides';

  @override
  String get emergencyStepsTitle => 'Étapes d’urgence';

  @override
  String get closeText => 'Fermer';

  @override
  String get searchFaqHint => 'Rechercher dans la FAQ...';

  @override
  String get noFaqsFound => 'Aucune FAQ trouvée';

  @override
  String get tryDifferentSearchTerms => 'Essayez d’autres termes de recherche';

  @override
  String get browseByCategory => 'Parcourir par catégorie';

  @override
  String resultsFound(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    String _temp1 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '$count résultat$_temp0 trouvé$_temp1';
  }

  @override
  String get tutorialFaqTitle => 'Tutoriel & FAQ';

  @override
  String get fullNameRequired => 'Le nom complet est requis';

  @override
  String get onboardingDesc1 =>
      'Signalez les activités suspectes en un instant avec seulement quelques gestes. Votre sécurité est notre priorité.';

  @override
  String get myReportStatusTitle => 'Statut de mes rapports';

  @override
  String get suspiciousActivityLabel => 'Activité suspecte';

  @override
  String get vandalismLabel => 'Vandalisme';

  @override
  String get theftLabel => 'Vol';

  @override
  String get statusPending => 'En attente';

  @override
  String get statusInReview => 'En cours d\'examen';

  @override
  String get statusResolved => 'Résolu';

  @override
  String get dateLabel => 'Date';

  @override
  String get detailsCta => 'Détails';

  @override
  String get reportSubmittedTitle => 'Rapport envoyé !';

  @override
  String get reportSubmittedSubtitle =>
      'Merci d’aider à sécuriser votre communauté. Les forces de l’ordre ont été informées.';

  @override
  String get reportIdLabel => 'ID du rapport :';

  @override
  String get saveIdForReference => 'Gardez cet identifiant en référence';

  @override
  String get viewMyReportsCta => 'Voir mes rapports';

  @override
  String get returnToHomeCta => 'Retour à l’accueil';

  @override
  String get estimatedResponseTime => 'Temps de réponse estimé : 5-10 minutes';

  @override
  String get reportDetailsTitle => 'Détails du rapport';

  @override
  String get unableToLoadReportDetails =>
      'Impossible de charger les détails du rapport';

  @override
  String get notAvailable => 'N/D';

  @override
  String updatedTimeAgo(Object timeAgo) {
    return 'Mis à jour $timeAgo';
  }

  @override
  String get updatedUnknown => 'Mis à jour : Inconnu';

  @override
  String get untitledReport => 'Rapport sans titre';

  @override
  String get noDescriptionProvided => 'Aucune description fournie';

  @override
  String get locationNotSpecified => 'Lieu non spécifié';

  @override
  String get incidentInformation => 'Informations sur l’incident';

  @override
  String get typeLabel => 'Type';

  @override
  String get timeLabel => 'Heure';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get statusUpdates => 'Mises à jour du statut';

  @override
  String get reportUnderReview => 'Rapport en cours d’examen';

  @override
  String minutesAgo(Object minutes) {
    return 'Il y a $minutes minutes';
  }

  @override
  String get officerAssigned => 'Un agent a été assigné à l’enquête';

  @override
  String get reportReceived => 'Rapport reçu';

  @override
  String get reportLogged => 'Votre rapport a été enregistré et priorisé';

  @override
  String get anonymousReportLabel => 'Rapport anonyme';

  @override
  String get protectedLabel => 'Protégé';

  @override
  String get reviewReportTitle => 'Vérifier le rapport';

  @override
  String get confirmSubmission => 'Confirmez votre soumission';

  @override
  String get reportSummaryTitle => 'Résumé du rapport';

  @override
  String get evidenceLabel => 'Preuves';

  @override
  String get noEvidenceAttached => 'Aucune preuve jointe';

  @override
  String get yesLabel => 'Oui';

  @override
  String get noLabel => 'Non';

  @override
  String get emergencyPrompt => 'Urgence ?';

  @override
  String get call911Prompt => 'Appelez le 112 en cas de danger immédiat';

  @override
  String get submitReportCta => 'Soumettre le rapport';

  @override
  String get saveAsDraftCta => 'Enregistrer comme brouillon';

  @override
  String get reportSubmitFailed => 'Échec de l’envoi du rapport';

  @override
  String get draftSavedSuccess =>
      'Rapport enregistré comme brouillon avec succès';

  @override
  String get draftSaveFailed => 'Échec de l’enregistrement du brouillon';

  @override
  String get reportCrimeTitle => 'Signaler un incident';

  @override
  String get reportCrimeSubtitle => 'Aidez à sécuriser votre communauté';

  @override
  String get selectIncidentTypeTitle => 'Sélectionnez le type d’incident';

  @override
  String get provideDetailsHint =>
      'Donnez des détails sur ce que vous avez observé';

  @override
  String get addEvidenceTitle => 'Ajouter des preuves';

  @override
  String get optionalLabel => '(Optionnel)';

  @override
  String get evidenceHelperText => 'Photos, vidéos ou enregistrements audio';

  @override
  String filesAttachedCount(Object count) {
    return '$count fichier(s) joint(s)';
  }

  @override
  String get savingLabel => 'Enregistrement...';

  @override
  String get restoreDraftTitle => 'Restaurer le brouillon ?';

  @override
  String restoreDraftMessage(Object timeAgo) {
    return 'Vous avez un brouillon non sauvegardé datant de $timeAgo.';
  }

  @override
  String get incidentLabel => 'Incident';

  @override
  String get descriptionPlaceholder =>
      'Décrivez en détail ce que vous avez observé...';

  @override
  String get pleaseSelectIncidentType =>
      'Veuillez sélectionner un type d’incident';

  @override
  String get pleaseProvideDescription => 'Veuillez fournir une description';

  @override
  String filesAddedCount(Object count, Object type) {
    return '$count $type ajouté(s)';
  }

  @override
  String get submitAnonymouslyTitle => 'Soumettre anonymement';

  @override
  String get identityProtectedSubtitle => 'Votre identité sera protégée';

  @override
  String get anonymousToggleYes => 'Oui';

  @override
  String get anonymousToggleNo => 'Non';

  @override
  String get photoLabel => 'Photo';

  @override
  String get videoLabel => 'Vidéo';

  @override
  String get audioLabel => 'Audio';

  @override
  String get suspiciousPersonLabel => 'Personne suspecte';

  @override
  String get vehicleActivityLabel => 'Activité de véhicule';

  @override
  String get abandonedItemLabel => 'Objet abandonné';

  @override
  String get theftBurglaryLabel => 'Vol/Cambriolage';

  @override
  String get vandalismLabelFull => 'Vandalisme';

  @override
  String get drugActivityLabel => 'Activité liée à la drogue';

  @override
  String get assaultLabel => 'Agression/Violence';

  @override
  String get noiseDisturbanceLabel => 'Nuisance sonore';

  @override
  String get trespassingLabel => 'Intrusion';

  @override
  String get otherIncidentLabel => 'Autre';

  @override
  String get incidentSubtitleDefault => 'Sélectionnez le type d’incident';

  @override
  String get changePasswordTitle => 'Changez votre mot de passe';

  @override
  String get changePasswordResetDesc =>
      'Entrez votre nouveau mot de passe ci-dessous.';

  @override
  String get changePasswordSettingsDesc =>
      'Entrez votre mot de passe actuel et votre nouveau mot de passe ci-dessous.';

  @override
  String get currentPasswordLabel => 'Mot de passe actuel';

  @override
  String get newPasswordLabel => 'Nouveau mot de passe';

  @override
  String get confirmPasswordLabel => 'Confirmez le mot de passe';

  @override
  String get passwordChangedSuccess => 'Mot de passe changé avec succès !';

  @override
  String get enterCurrentPassword =>
      'Veuillez entrer votre mot de passe actuel';

  @override
  String passwordChange30DayRule(Object days, Object remaining) {
    return 'Le mot de passe ne peut être changé qu’une fois tous les 30 jours. Dernier changement il y a $days jours. Veuillez attendre $remaining jours de plus.';
  }

  @override
  String get failedToChangePassword => 'Échec du changement de mot de passe';

  @override
  String get userNotFoundLogin =>
      'Utilisateur introuvable. Veuillez vous reconnecter.';

  @override
  String get backToSignIn => 'Retour à la connexion';

  @override
  String get cancelCta => 'Annuler';

  @override
  String get changePasswordCta => 'Changer le mot de passe';

  @override
  String get verifyEmailTitle => 'Vérifiez votre email';

  @override
  String get verifyEmailSubtitle =>
      'Nous avons envoyé un code de vérification à';

  @override
  String get verifyEmailCta => 'Vérifier l’email';

  @override
  String get didNotReceiveCode => 'Vous n’avez pas reçu de code ?';

  @override
  String get sendNewCode => 'Envoyer un nouveau code';

  @override
  String get verificationCodeLabel => 'Code de vérification';

  @override
  String get enter6Digits => 'Entrez 6 chiffres';

  @override
  String get enter6DigitCode => 'Veuillez entrer le code à 6 chiffres';

  @override
  String get invalidOrExpiredCode => 'Code invalide ou expiré';

  @override
  String get newCodeSent =>
      'Nouveau code de vérification envoyé à votre email.';

  @override
  String get failedToSendCode => 'Échec de l’envoi du nouveau code';

  @override
  String get forgotPasswordTitle => 'Mot de passe oublié ?';

  @override
  String get forgotPasswordDesc =>
      'Saisissez votre adresse email et nous vous enverrons les instructions pour réinitialiser votre mot de passe.';

  @override
  String get emailLabel => 'Email';

  @override
  String get enterEmailAddress => 'Veuillez entrer votre adresse email';

  @override
  String get sendResetLink => 'Envoyer le lien de réinitialisation';

  @override
  String get failedToSendReset =>
      'Échec de l’envoi du code de réinitialisation';

  @override
  String get emergencyModeTitle => 'Mode urgence';

  @override
  String get emergencyModeSubtitle =>
      'L’aide est en route.\nVotre position est partagée avec les services d’urgence.';

  @override
  String get policeEtaLabel => 'ETA Police';

  @override
  String etaMinutes(Object max, Object min) {
    return '$min-$max minutes';
  }

  @override
  String get emergencyContactsNotified =>
      'Vos contacts d’urgence ont été informés';
}
