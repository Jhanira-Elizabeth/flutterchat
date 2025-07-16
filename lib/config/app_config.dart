class AppConfig {
  // Configuración del servidor backend
  // URL de Azure actualizada
  static const String baseUrl = 'https://tursd-grhzehh6hta4e9en.eastus-01.azurewebsites.net/api/v1';
  
  // URLs alternativas para diferentes ambientes
  static const String localUrl = 'http://localhost:3000/api/v1';
  static const String developmentUrl = 'http://192.168.1.100:3000/api/v1'; // IP local
  static const String azureUrl = 'https://tursd-grhzehh6hta4e9en.eastus-01.azurewebsites.net/api/v1'; // URL de Azure
  static const String renderUrl = 'https://tursd.onrender.com/api/v1'; // URL de Render (backup)
  
  // Configuración de sincronización
  static const int syncIntervalHours = 24; // Sincronizar cada 24 horas
  static const int connectionTimeoutSeconds = 10; // Timeout de conexión
  
  // Configuración de la aplicación
  static const String appName = 'Turismo App';
  static const String appVersion = '1.0.0';
  
  // Configuración de base de datos
  static const String databaseName = 'turismo_app.db';
  static const int databaseVersion = 1;
  
  // Variables de entorno
  static const String googleApiKey = 'AIzaSyDiYjZ1vSjtP6N65bKDk4phpc1jzTxqh64';
  static const String firebaseApiKey = 'AIzaSyDxoJO2bLaVxujrb7Ny0QgMEBtDbFQvvsU';
  static const String firebaseAppId = '1:1049265785157:android:3552c29862e8280952162c';
  static const String firebaseMessagingSenderId = '1049265785157';
  static const String firebaseProjectId = 'tursd-e8787';
  static const String firebaseStorageBucket = 'tursd-e8787.appspot.com';
  
  // Para producción, usar la URL de Azure
  static String getCurrentUrl() {
    if (enableDebugPrints) {
      print('AppConfig: Usando URL: $azureUrl');
    }
    return azureUrl; // Usar URL de Azure para producción
  }
  
  // Configuraciones adicionales
  static const bool enableDebugPrints = true; // false en producción
  static const bool autoSyncOnStartup = true; // Habilitado para sincronizar con Azure
  static const bool showSyncDialogOnFirstRun = true; // Mostrar diálogo de sync al inicio
  static const bool offlineOnly = false; // Usar datos de Azure con respaldo local
  
  // Configuraciones de servicios externos que requieren internet
  static const bool enableGoogleAuth = true; // Autenticación de Google para favoritos
  static const bool enableGoogleMaps = true; // Google Maps para ubicaciones
  static const bool enableChatbot = true; // Chatbot y consultas online
  static const bool enableInternetServices = true; // Servicios que requieren internet
  
  // URLs para servicios específicos
  static const String chatbotApiUrl = 'https://api.openai.com/v1'; // URL del chatbot
  static const String googleMapsApiKey = 'AIzaSyDiYjZ1vSjtP6N65bKDk4phpc1jzTxqh64'; // Clave de Google Maps
}

// Enum para diferentes entornos
enum Environment {
  development,
  staging,
  production,
}

class EnvironmentConfig {
  static Environment currentEnvironment = Environment.development;
  
  static String getBaseUrl() {
    switch (currentEnvironment) {
      case Environment.development:
        return AppConfig.localUrl;
      case Environment.staging:
        return AppConfig.developmentUrl;
      case Environment.production:
        return AppConfig.azureUrl;
    }
  }
}
