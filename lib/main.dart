import 'package:bitwit_shit/bloc/sdk_connectivity/sdk_connectivity_cubit.dart';
import 'package:bitwit_shit/services/injector.dart';
import 'bootstrap.dart';
import 'user_app.dart';

void main() {
  bootstrap(
    (ServiceInjector injector, SdkConnectivityCubit sdkConnectivityCubit) =>
        UserApp(injector: injector, sdkConnectivityCubit: sdkConnectivityCubit),
  );
}
