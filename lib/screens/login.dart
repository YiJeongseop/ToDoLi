part of event_calendar;

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(
      fit: StackFit.expand,
      children: [
        ModalBarrier(
          color: Colors.black54,
          dismissible: false,
        ),
        Center(
          child: CircularProgressIndicator(),
        ),
      ],
    );
  }
}

// https://developers.google.com/drive/api/guides/api-specific-auth?hl=en
final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveFileScope, drive.DriveApi.driveAppdataScope]);

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final controller = ConfettiController();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    // https://api.flutter.dev/flutter/animation/Curves-class.html
    _animation = Tween(begin: -200.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();

    controller.play();
    stopController();
  }

  @override
  void dispose() {
    _controller.dispose();

    controller.dispose();
    super.dispose();
  }

  Future<void> signInWithGoogle() async {
      Get.dialog(const LoadingOverlay(), barrierDismissible: false);

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if(googleUser == null) {
        Get.back();
        return;
      }

      try{
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await FirebaseAuth.instance.signInWithCredential(credential);

        Get.back();
      } catch(e){
        Get.back();
        return;
      }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Scaffold(
          body: SafeArea(
            child: Center(
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Color(0xFFD7F1FC),
                      Color(0xFFD7FCD8),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _animation.value),
                          child: Text(
                            'ToDoLi',
                            style: GoogleFonts.pangolin(
                              fontSize: 110.0,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF000000),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                    GestureDetector(
                      onTap: () => signInWithGoogle(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFF000000), width: 2),
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        width: MediaQuery.of(context).size.width / 1.25,
                        height: MediaQuery.of(context).size.height / 11.7,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                              child: Image.asset(
                                'images/google_logo.png',
                                // You can get this image from https://about.google/brand-resource-center/logos-list/
                                fit: BoxFit.cover,
                                width: MediaQuery.of(context).size.width / 10,
                              ),
                            ),
                            Text(
                              'Sign in with Google',
                              style: en22,
                              textAlign: TextAlign.center,
                            ),
                            const CircleAvatar(
                              backgroundColor: Colors.white,
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        ConfettiWidget(
          confettiController: controller,
          shouldLoop: true,

          colors: const [
            Color(0xFF97D7E1),
            Color(0xFFE5C1F5),
            Color(0xFFECB7B2),
            Color(0xFFECDD83),
            Color(0xFF8BD39A)
          ],

          blastDirectionality: BlastDirectionality.explosive,

          emissionFrequency: 0.00,
          numberOfParticles: 30,
        )
      ],
    );
  }

  void stopController() async{
    await Future.delayed(const Duration(seconds: 2));

    controller.stop();
  }
}
