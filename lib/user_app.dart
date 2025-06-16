import 'package:bitwit_shit/bloc/account/account_cubit.dart';
import 'package:bitwit_shit/bloc/account/onboarding_preferences.dart';
import 'package:bitwit_shit/bloc/connectivity/connectivity_cubit.dart';
import 'package:bitwit_shit/bloc/input/input_cubit.dart';
import 'package:bitwit_shit/bloc/payment_limits/payment_limits_cubit.dart';
import 'package:bitwit_shit/bloc/payments/payments_cubit.dart';
import 'package:bitwit_shit/bloc/sdk_connectivity/sdk_connectivity_cubit.dart';
import 'package:bitwit_shit/bloc/time_capsule/time_capsule_cubit.dart';
import 'package:bitwit_shit/routes/qr_scan/qr_scan_view.dart';
import 'package:bitwit_shit/routes/splash/splash_page.dart';
import 'package:bitwit_shit/routes/home/wallet_home_screen.dart';
import 'package:bitwit_shit/routes/initial_walkthrough/initial_walkthrough_page.dart';
import 'package:bitwit_shit/services/injector.dart';
import 'package:bitwit_shit/services/lnurl_service.dart';
import 'package:bitwit_shit/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

final _log = Logger("UserApp");

class UserApp extends StatelessWidget {
  final ServiceInjector injector;
  final SdkConnectivityCubit sdkConnectivityCubit;

  const UserApp({
    super.key,
    required this.injector,
    required this.sdkConnectivityCubit,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AccountCubit>(
          lazy: false,
          create:
              (BuildContext context) => AccountCubit(injector.breezSdkLiquid),
        ),
        BlocProvider<SdkConnectivityCubit>(
          create: (context) => sdkConnectivityCubit,
        ),
        BlocProvider<ConnectivityCubit>(
          create: (BuildContext context) => ConnectivityCubit(),
        ),
        BlocProvider<InputCubit>(
          create: (BuildContext context) => InputCubit(injector.breezSdkLiquid),
        ),
        BlocProvider<PaymentsCubit>(
          create:
              (BuildContext context) => PaymentsCubit(injector.breezSdkLiquid),
        ),
        BlocProvider<PaymentLimitsCubit>(
          create:
              (BuildContext context) =>
                  PaymentLimitsCubit(injector.breezSdkLiquid),
        ),
        BlocProvider<TimeCapsuleCubit>(
          create:
              (BuildContext context) =>
                  TimeCapsuleCubit(context.read<AccountCubit>()),
        ),
      ],
      child: Provider<LnUrlService>(
        create: (BuildContext context) => LnUrlService(injector.breezSdkLiquid),
        child: const AppView(),
      ),
    );
  }
}

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  final GlobalKey _appKey = GlobalKey();
  final GlobalKey<NavigatorState> _homeNavigatorKey =
      GlobalKey<NavigatorState>();
  late Future<bool> _isOnboardingCompleteFuture;

  @override
  void initState() {
    super.initState();
    _isOnboardingCompleteFuture = OnboardingPreferences.isOnboardingComplete();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isOnboardingCompleteFuture,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (!snapshot.hasData) {
          return Container(color: Color(0xFFC6C0B3));
        }

        final bool isOnboardingComplete = snapshot.data ?? false;

        return MaterialApp(
          key: _appKey,
          title: 'Skibidi Wallet',
          theme: AppTheme.lightTheme,
          builder: (BuildContext context, Widget? child) {
            const double kMaxTitleTextScaleFactor = 1.3;

            return MediaQuery.withClampedTextScaling(
              maxScaleFactor: kMaxTitleTextScaleFactor,
              child: child!,
            );
          },
          initialRoute: 'splash',
          onGenerateRoute: (RouteSettings settings) {
            _log.info('New route: ${settings.name}');
            switch (settings.name) {
              case 'splash':
                return MaterialPageRoute(
                  builder:
                      (context) => SplashPage(
                        isOnboardingComplete: isOnboardingComplete,
                      ),
                  settings: settings,
                );
              case '/intro':
                return MaterialPageRoute(
                  builder: (context) => const InitialWalkthroughPage(),
                  settings: settings,
                );
              case '/':
                return MaterialPageRoute(
                  builder:
                      (context) => NavigatorPopHandler(
                        onPopWithResult:
                            (Object? result) =>
                                _homeNavigatorKey.currentState!.maybePop(),
                        child: Navigator(
                          initialRoute: '/',
                          key: _homeNavigatorKey,
                          onGenerateRoute: (RouteSettings settings) {
                            _log.info('New inner route: ${settings.name}');
                            switch (settings.name) {
                              case '/':
                                return MaterialPageRoute(
                                  builder:
                                      (context) => const WalletHomeScreen(),
                                  settings: settings,
                                );
                              case '/qr_scan':
                                return MaterialPageRoute<String>(
                                  fullscreenDialog: true,
                                  builder: (context) => const QrScanView(),
                                  settings: settings,
                                );
                            }
                            assert(false);
                            return null;
                          },
                        ),
                      ),
                  settings: settings,
                );
            }
            assert(false);
            return null;
          },
        );
      },
    );
  }
}
