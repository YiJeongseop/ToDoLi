![README image](https://github.com/YiJeongseop/ToDoLi/assets/112690335/4b21ea38-b499-420e-8a44-ff518604f21d)
# ToDoLi ![README image2](https://github.com/YiJeongseop/ToDoLi/assets/112690335/29c62c59-f4f6-4dc2-a7b2-0ea721df60e1)
I started studying flutter a few months ago. I heard that a simple app is good for the first app.
I thought an app that combines __calendar and to-do list__ would be good, and I made it. 
It's a really simple app, but I was able to create it with a lot of help from __SfCalendar__.

It's available on the [Google Play Store](https://play.google.com/store/apps/details?id=com.sanashi.todoli).

## Features
* Google Login Using Firebase ( google-services.json used at this time is not in this repository. if you want to refer to this code, you should have your own google-services.json )
* Upload appointments to Google Drive, download appointments from Google Drive
* English and Korean translations 

![Translation](https://github.com/YiJeongseop/ToDoLi/assets/112690335/9b0a98db-f916-4639-a279-c72933c1777c)
* Change the color of some parts of the UI
* Change and delete parts of recurring appointments
* Play interstitial ads when the UI changes color ( If you want to refer to this code, change App ID in AndroidManifest.xml and Ads ID in interstitial_ad_widget.dart to your own )

## Screenshots
![Screenshots](https://github.com/YiJeongseop/ToDoLi/assets/112690335/4ee4c1e1-a6c9-4220-b5b9-49f5b2e2b835)

## Packages
* [syncfusion_flutter_calendar](https://pub.dev/packages/syncfusion_flutter_calendar)

  It is necessary to have __a commercial or community license__ to use syncfusion_flutter_calendar. Please refer to the links below.
  
  https://github.com/syncfusion/flutter-examples/blob/master/LICENSE
  
  ​https://help.syncfusion.com/flutter/licensing/overview
  
  https://www.syncfusion.com/products/communitylicense
  
* [google_sign_in](https://pub.dev/packages/google_sign_in)
* [googleapis](https://pub.dev/packages/googleapis)
* [google_fonts](https://pub.dev/packages/google_fonts)
* [google_mobile_ads](https://pub.dev/packages/google_mobile_ads)
* [firebase_auth](https://pub.dev/packages/firebase_auth)
* [firebase_core](https://pub.dev/packages/firebase_core)
* [flutter_localization](https://pub.dev/packages/flutter_localization)
* [intl](https://pub.dev/packages/intl)
* [get](https://pub.dev/packages/get)
* [shared_preferences](https://pub.dev/packages/shared_preferences)
* [url_launcher](https://pub.dev/packages/url_launcher)
* [http](https://pub.dev/packages/http)
