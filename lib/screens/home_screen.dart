import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vpn_basic_project/utils/colors.dart';

import '../controllers/home_controller.dart';
import '../helpers/ad_helper.dart';
import '../helpers/config.dart';
import '../helpers/pref.dart';
import '../main.dart';
import '../models/vpn_status.dart';
import '../services/vpn_engine.dart';
import '../widgets/count_down_timer.dart';
import '../widgets/watch_ad_dialog.dart';
import 'location_screen.dart';
import 'network_test_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final _controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.sizeOf(context);

    ///Add listener to update vpn state
    VpnEngine.vpnStageSnapshot().listen((event) {
      _controller.vpnState.value = event;
    });
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading:
            Icon(CupertinoIcons.home, color: Theme.of(context).iconTheme.color),
        title: Text(
          'VPN',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : kDefaultBlueColor,
          ),
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.brightness_medium,
                  color: Theme.of(context).iconTheme.color),
              onPressed: () {
                if (Config.hideAds) {
                  Get.changeThemeMode(
                      Pref.isDarkMode ? ThemeMode.light : ThemeMode.dark);
                  Pref.isDarkMode = !Pref.isDarkMode;
                } else {
                  Get.dialog(WatchAdDialog(onComplete: () {
                    AdHelper.showRewardedAd(onComplete: () {
                      Get.changeThemeMode(
                          Pref.isDarkMode ? ThemeMode.light : ThemeMode.dark);
                      Pref.isDarkMode = !Pref.isDarkMode;
                    });
                  }));
                }
              }),
          IconButton(
              icon: Icon(CupertinoIcons.info,
                  color: Theme.of(context).iconTheme.color),
              onPressed: () => Get.to(() => NetworkTestScreen()))
        ],
      ),
      bottomNavigationBar: _changeLocation(context),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Obx(() => _vpnButton()),
          Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _modernCard(
                      title: _controller.vpn.value.countryLong.isEmpty
                          ? 'Country'
                          : _controller.vpn.value.countryLong,
                      subtitle: 'FREE',
                      icon: _controller.vpn.value.countryLong.isEmpty
                          ? const Icon(Icons.vpn_lock_rounded,
                              color: Colors.white)
                          : Image.asset(
                              'assets/flags/${_controller.vpn.value.countryShort.toLowerCase()}.png',
                              height: 32)),
                  _modernCard(
                      title: _controller.vpn.value.ping.isEmpty
                          ? '100 ms'
                          : '${_controller.vpn.value.ping} ms',
                      subtitle: 'PING',
                      icon: const Icon(Icons.speed, color: Colors.white)),
                ],
              )),
          StreamBuilder<VpnStatus?>(
              initialData: VpnStatus(),
              stream: VpnEngine.vpnStatusSnapshot(),
              builder: (context, snapshot) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _modernCard(
                        title: '${snapshot.data?.byteIn ?? '0 kbps'}',
                        subtitle: 'DOWNLOAD',
                        icon: const Icon(Icons.arrow_downward_rounded,
                            color: Colors.white)),
                    _modernCard(
                        title: '${snapshot.data?.byteOut ?? '0 kbps'}',
                        subtitle: 'UPLOAD',
                        icon: const Icon(Icons.arrow_upward_rounded,
                            color: Colors.white)),
                  ],
                );
              }),
        ],
      ),
    );
  }

  Widget _vpnButton() {
    return Column(
      children: [
        GestureDetector(
          onTap: _controller.connectToVpn,
          child: Container(
            width: mq.width * 0.4,
            height: mq.width * 0.4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  _controller.getButtonColor.withOpacity(0.8),
                  _controller.getButtonColor,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: _controller.getButtonColor.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.power_settings_new,
                      size: 32, color: Colors.white),
                  const SizedBox(height: 6),
                  Text(
                    _controller.getButtonText,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14),
                  )
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
          decoration: BoxDecoration(
            color: _controller.getButtonColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _controller.vpnState.value == VpnEngine.vpnDisconnected
                ? 'Not Connected'
                : _controller.vpnState.replaceAll('_', ' ').toUpperCase(),
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => CountDownTimer(
            startTimer: _controller.vpnState.value == VpnEngine.vpnConnected)),
      ],
    );
  }

  Widget _changeLocation(BuildContext context) => SafeArea(
        child: GestureDetector(
          onTap: () => Get.to(() => LocationScreen()),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [kDefaultBlueColor, kDefaultLightBlueColor],
              ),
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: const [
                Icon(CupertinoIcons.globe, color: Colors.white, size: 28),
                SizedBox(width: 10),
                Text(
                  'Change Location',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500),
                ),
                Spacer(),
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.keyboard_arrow_right_rounded,
                      color: Color(0xFF5D1BE2), size: 26),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _modernCard({
    required String title,
    required String subtitle,
    required Widget icon,
  }) {
    return Container(
      width: mq.width * 0.42,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: const Offset(4, 4)),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: kDefaultBlueColor,
            child: icon,
          ),
          const SizedBox(height: 10),
          Text(title,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 6),
          Text(subtitle,
              style: TextStyle(
                  color: Theme.of(Get.context!).hintColor, fontSize: 12)),
        ],
      ),
    );
  }
}
