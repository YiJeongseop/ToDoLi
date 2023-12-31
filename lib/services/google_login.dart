part of event_calendar;

// https://developers.google.com/drive/api/guides/api-specific-auth?hl=en
final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveFileScope, drive.DriveApi.driveAppdataScope]);

Future<bool> signInWithGoogle(BuildContext context) async {
  Get.dialog(const LoadingOverlay(), barrierDismissible: false);
  GoogleSignInAccount? googleUser;

  try{
    googleUser = await googleSignIn.signIn();
  } catch (e) {
    Get.back();
    Get.back();
    Get.back();
    showSnackbar(context, AppLocalizations.of(context)!.loginFail, 5);
    return false;
  }

  if (googleUser == null) {
    Get.back();
    return false;
  }

  try {
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);

    Get.back();
    Get.back();
    Get.back();
    isLogined = true;
    return true;
  } catch (e) {
    Get.back();
    return false;
  }
}

void loginDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: (!Get.isDarkMode) ? Colors.white : const Color(0xFF505458),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9.0)),
        content: GestureDetector(
          onTap: () {
            signInWithGoogle(context);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFF000000), width: 2),
              borderRadius: BorderRadius.circular(25.0),
            ),
            width: MediaQuery.of(context).size.width * 0.77,
            height: MediaQuery.of(context).size.height * 0.085,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                  child: Image.asset(
                    'images/google_logo.png',
                    // https://about.google/brand-resource-center/logos-list/
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width * 0.08,
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.035),
                Text(
                  'Sign in with Google',
                  style: en18.copyWith(color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

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
