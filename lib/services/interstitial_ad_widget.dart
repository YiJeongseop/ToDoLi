import 'package:google_mobile_ads/google_mobile_ads.dart';

InterstitialAd? _interstitialAd;

void loadInterstitialAd() {
  InterstitialAd.load(
    adUnitId: 'ca-app-pub-3940256099942544/1033173712', // It's sample ID
    request: const AdRequest(),
    adLoadCallback: InterstitialAdLoadCallback(
      onAdLoaded: (InterstitialAd ad) => _interstitialAd = ad,
      onAdFailedToLoad: (LoadAdError error) {},
    ),
  );
}

void callInterstitialAd() {
  _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
    onAdDismissedFullScreenContent: (InterstitialAd ad) => ad.dispose(),
    onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) => ad.dispose(),
  );

  _interstitialAd?.show();
}
