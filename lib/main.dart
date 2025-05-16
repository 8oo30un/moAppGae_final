import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shrine/home.dart';
import 'package:shrine/login.dart';
import 'package:shrine/wishlist.dart';
import 'app.dart'; // 기존 Shrine UI 포함
import 'firebase_options.dart'; // Firebase 설정 파일
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => WishlistProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Final App',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: AuthGate(), // 로그인 여부에 따라 이동
      routes: {
        '/home': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
      },
    );
  }
}

class AuthGate extends StatefulWidget {
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _loadingWishlist = true;
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    _tryLoadWishlist();
  }

  Future<void> _tryLoadWishlist() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !_hasLoaded) {
      final wishlistProvider = context.read<WishlistProvider>();
      await wishlistProvider.loadWishlist();
      if (mounted) {
        setState(() {
          _loadingWishlist = false;
          _hasLoaded = true;
        });
      }
    } else {
      setState(() {
        _loadingWishlist = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LoginPage();
        }
        if (_loadingWishlist) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return const ShrineApp();
      },
    );
  }
}
