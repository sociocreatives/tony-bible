import 'package:admob_flutter/admob_flutter.dart';
import 'package:bibleartwallpaperhd/services/admobService.dart';
import 'package:bibleartwallpaperhd/widgets/showLoadingWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late AdmobInterstitial interstitialAd;

  @override
  void initState() {
    super.initState();
    if(AdmobService.isUserSubscribed == false){
      interstitialAd = AdmobService.getInterstitialAd()!;
      interstitialAd.load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DataSnapshot>(
        future: FirebaseDatabase.instance.ref().child('Categories').child('Main-Categories').orderByChild('status').equalTo(true).get(),
        builder: (context, snapshot) {

          if (snapshot.connectionState != ConnectionState.done) {
            return ShowLoadingWidget();
          }

          Map<dynamic, dynamic> values = Map<String, dynamic>.from(
              snapshot.data!.value as Map<String, dynamic>);
          List<dynamic> keys = values.keys.toList();
          List<Widget> cardList = [];

          keys.forEach((key) {
            cardList.add(InkWell(
              onTap: () async {
                // bool isLoadd = await interstitialAd.isLoaded;
                // if (interstitialAd != null && await interstitialAd.isLoaded) {
                //   interstitialAd.show();
                //   interstitialAd = AdmobService.getInterstitialAd();
                //   interstitialAd.load();
                // }
                Navigator.of(context).pushNamed('subCategories', arguments: key);
              },
              child: Card(
                elevation: 8,
                margin: EdgeInsets.all(8),
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 200,
                      color: Colors.black,
                      child: CachedNetworkImage(
                        imageUrl: values[key]['thumbnail'],
                        progressIndicatorBuilder: (context, url, downloadProgress) =>
                            Center(child: SizedBox(width: 40, height: 40, child: CircularProgressIndicator(value: downloadProgress.progress))),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              values[key]['displayName'],
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ));
          });

          return ListView.builder(
            itemCount: cardList.length,
            itemBuilder: (_, index) {
              return cardList[index];
            },
          );
        });
  }
}
