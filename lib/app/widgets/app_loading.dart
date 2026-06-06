import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';

/// The app's branded loading indicator: the `branding/loading.json` Lottie
/// animation, centered and bounded to [size]. Use this in place of a
/// `CircularProgressIndicator` for full-screen / large loading states.
class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({super.key, this.size = 88});

  /// Width/height of the animation box (it scales to fit).
  final double size;

  @override
  Widget build(BuildContext context) => Center(
        child: SizedBox.square(
          dimension: size,
          child: Lottie.asset(
            'branding/loading.json',
            repeat: true,
            fit: BoxFit.contain,
          ),
        ),
      );
}
