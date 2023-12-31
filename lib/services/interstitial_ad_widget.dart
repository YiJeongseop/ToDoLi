import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../main.dart';

InterstitialAd? _interstitialAd;
var status;

void loadInterstitialAd() {
  InterstitialAd.load(
    adUnitId: 'ca-app-pub-3940256099942544/1033173712', // It's sample ID
    request: (status == ConsentStatus.required) ? const AdRequest(nonPersonalizedAds: true) : const AdRequest(),
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
  try{
    _interstitialAd?.show();
  } catch (e) {
    _interstitialAd?.dispose();
  }
}

// Requesting Consent from European Users
// https://developers.google.com/admob/flutter/eu-consent?hl=en
void consentPersonalizedAds() {
  ConsentForm.loadConsentForm((consentForm) async {
    consentForm.show((formError) {Get.back();});
  }, (formError) {});
}

void cancelConsentPersonalizedAds() {
  ConsentInformation.instance.reset();

  final params = ConsentRequestParameters();
  // final params = ConsentRequestParameters(consentDebugSettings: debugSettings); // for test

  ConsentInformation.instance.requestConsentInfoUpdate(params, () async {Get.back();}, (error) {});
}

void setStatus() async {
  status = await ConsentInformation.instance.getConsentStatus();
}
