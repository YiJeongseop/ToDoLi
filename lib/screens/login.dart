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

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

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
    return Scaffold(
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
                Text(
                  'ToDoLi',
                  style: GoogleFonts.pangolin(
                    fontSize: 110.0,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF000000),
                  ),
                  textAlign: TextAlign.center,
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
                          style: en20,
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
    );
  }
}
