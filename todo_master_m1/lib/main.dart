import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants.dart';
import 'providers/auth_provider.dart';
import 'providers/location_weather_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/todo_provider.dart';
import 'services/api_service.dart';
import 'services/auth_api.dart';
import 'services/todo_api.dart';
import 'services/weather_api.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TodoApp());
}

class AppTheme {
  static const Color primary = Color(0xFF2196F3);   
  static const Color secondary = Color(0xFFFF9800); 
  static const Color accent = Color(0xFF4CAF50);    

  static ThemeData light() {
    final scheme = ColorScheme(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: Colors.white,
      secondary: secondary,
      onSecondary: Colors.white,
      error: Colors.red.shade700,
      onError: Colors.white,
      background: Colors.grey.shade50,
      onBackground: Colors.black,
      surface: Colors.white,
      onSurface: Colors.black87,
    );

    final interBase = GoogleFonts.interTextTheme();
    
    final text = interBase.copyWith(
      titleLarge: GoogleFonts.poppins(textStyle: interBase.titleLarge),
      titleMedium: GoogleFonts.poppins(textStyle: interBase.titleMedium),
      titleSmall: GoogleFonts.poppins(textStyle: interBase.titleSmall),
      headlineMedium: GoogleFonts.poppins(textStyle: interBase.headlineMedium),
      headlineSmall: GoogleFonts.poppins(textStyle: interBase.headlineSmall),
      labelLarge: GoogleFonts.poppins(textStyle: interBase.labelLarge),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: text,
      scaffoldBackgroundColor: scheme.background,
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade100,
        hintStyle: const TextStyle(color: Colors.black54),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: StadiumBorder(),
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        backgroundColor: Colors.grey.shade100,
        selectedColor: primary.withOpacity(0.2),
        labelStyle: GoogleFonts.inter(color: Colors.black87),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: primary,
        titleTextStyle: text.titleMedium,
        subtitleTextStyle: GoogleFonts.inter(color: Colors.black54),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}



class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();
    final authApi = AuthApi(apiService);
    final todoApi = TodoApi(apiService);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authApi)),
        ChangeNotifierProvider(create: (_) => LocationWeatherProvider(WeatherApi())),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProxyProvider<AuthProvider, TodoProvider?>(
          create: (_) => null,
          update: (_, auth, previous) {
            if (auth.accountId == null) return null;
            return TodoProvider(api: todoApi, accountId: auth.accountId!);
          },
        ),
      ],
      child: MaterialApp(
      title: 'Todo Master M1',
      theme: AppTheme.light(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (ctx){
          final auth = Provider.of<AuthProvider>(ctx, listen: false);
          return FutureBuilder(
            future: auth.tryAutoLogin(),
            builder: (_, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              return (auth.accountId != null) ? const HomeScreen() : const LoginScreen();
            },
          );
        },
        '/home': (_) => const HomeScreen(),
      },
    ),

    );
  }
}
