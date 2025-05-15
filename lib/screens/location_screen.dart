import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lottie/lottie.dart';
import 'package:vpn_basic_project/utils/colors.dart';

import '../controllers/location_controller.dart';
import '../controllers/native_ad_controller.dart';
import '../helpers/ad_helper.dart';
import '../main.dart';
import '../widgets/vpn_card.dart';

class LocationScreen extends StatelessWidget {
  LocationScreen({super.key});

  final LocationController _controller = Get.put(LocationController());
  final NativeAdController _adController = NativeAdController();
  final RxString _searchText = ''.obs;

  @override
  Widget build(BuildContext context) {
    if (_controller.vpnList.isEmpty) _controller.getVpnData();

    _adController.ad = AdHelper.loadNativeAd(adController: _adController);

    return Obx(
      () {
        final filteredList = _controller.vpnList
            .where((vpn) => vpn.countryLong
                .toLowerCase()
                .contains(_searchText.value.toLowerCase()))
            .toList();

        return Scaffold(
          appBar: AppBar(
            backgroundColor: kDefaultBlueColor,
            title: Text('VPN Locations (${_controller.vpnList.length})'),
          ),

          bottomNavigationBar: _adController.ad != null &&
                  _adController.adLoaded.isTrue
              ? SafeArea(
                  child: SizedBox(
                    height: 85,
                    child: AdWidget(ad: _adController.ad!),
                  ),
                )
              : null,

          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10, right: 10),
            child: FloatingActionButton(
              backgroundColor: kDefaultBlueColor,
              onPressed: () => _controller.getVpnData(),
              child: Icon(CupertinoIcons.refresh),
            ),
          ),

          body: _controller.isLoading.value
              ? _loadingWidget()
              : _controller.vpnList.isEmpty
                  ? _noVPNFound()
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          child: TextField(
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.search),
                              hintText: 'Search by country...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onChanged: (val) => _searchText.value = val,
                          ),
                        ),
                        Expanded(child: _vpnData(filteredList)),
                      ],
                    ),
        );
      },
    );
  }
Widget _vpnData(List filteredList) {
  if (filteredList.isEmpty) {
    return Expanded(
      child: Center(
        child: Text(
          'No matching VPNs found! 😔',
          style: TextStyle(
              fontSize: 18,
              color: Colors.black54,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  return Expanded(
    child: ListView.builder(
      itemCount: filteredList.length,
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        top: mq.height * .015,
        bottom: mq.height * .1,
        left: mq.width * .04,
        right: mq.width * .04,
      ),
      itemBuilder: (ctx, i) => VpnCard(vpn: filteredList[i]),
    ),
  );
}

  Widget _loadingWidget() => SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LottieBuilder.asset('assets/lottie/loading.json',
                width: mq.width * .7),
            Text(
              'Loading VPNs... 😌',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      );

  Widget _noVPNFound() => Center(
        child: Text(
          'VPNs Not Found! 😔',
          style: TextStyle(
              fontSize: 18, color: Colors.black54, fontWeight: FontWeight.bold),
        ),
      );
}
