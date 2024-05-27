import 'package:flutter/material.dart';
import 'package:tela/src/screens/welcome_screen.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  var _scale = 10.0;
  var _animationOpacityLogo = 0.0;

  double get _logoAnimationWidth => 100 * _scale;
  double get _logoAnimationHeight => 120 * _scale;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _animationOpacityLogo = 1.0;
        _scale = 2;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 9, 43, 2),
      body: Stack(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/images/fundo.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.2),
                  BlendMode.dstATop,
                ),
              ),
            ),
          ),
          AnimatedOpacity(
            duration: const Duration(seconds: 3),
            curve: Curves.easeIn,
            opacity: _animationOpacityLogo,
             onEnd: () {
              Navigator.of(context).pushAndRemoveUntil(
                PageRouteBuilder(
                  settings: const RouteSettings(name: '/home'),
                  pageBuilder: (
                    context,
                    animation,
                    secondaryAnimation,
                  ) {
                    return const WelcomeScreen();
                  },
                  transitionsBuilder: (_, animation, __, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                ),
                (route) => false,
              );
             },
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(seconds: 3),
                curve: Curves.linearToEaseOut,
                width: _logoAnimationWidth,
                height: _logoAnimationHeight,
                child: Image.asset(
                  'assets/images/logo.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}