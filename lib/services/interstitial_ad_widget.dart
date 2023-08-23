import 'package:google_mobile_ads/google_mobile_ads.dart';

InterstitialAd? _interstitialAd;

void callInterstitialAd() {
  InterstitialAd.load(
    adUnitId: 'ca-app-pub-3940256099942544/1033173712', // It's sample ID
    request: const AdRequest(),
    adLoadCallback: InterstitialAdLoadCallback(
      onAdLoaded: (InterstitialAd ad) {
        print('onAdLoaded: $ad');
        _interstitialAd = ad;
      },
      onAdFailedToLoad: (LoadAdError error) {
        print('onAdFailedToLoad: ${error.message}');
      },
    ),
  );

  _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
    onAdShowedFullScreenContent: (InterstitialAd ad) =>
        print('onAdShowedFullScreenContent: $ad'),
    onAdDismissedFullScreenContent: (InterstitialAd ad) {
      print('onAdShowedFullScreenContent: $ad');
      ad.dispose();
    },
    onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
      print('$ad onAdFailedToShowFullScreenContent: $error');
      ad.dispose();
    },
    onAdImpression: (InterstitialAd ad) => print('$ad impression occurred.'),
  );

  _interstitialAd?.show();
}
