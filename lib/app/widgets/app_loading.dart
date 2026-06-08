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
  Widget build(BuildContext context) {
    // Honor reduce-motion: render a single static frame (no perpetual ticker)
    // instead of the looping animation. This is both an accessibility win and
    // keeps widget tests deterministic - a repeating Lottie never lets
    // pumpAndSettle settle.
    final reduce = MediaQuery.disableAnimationsOf(context);
    return Center(
      child: SizedBox.square(
        dimension: size,
        child: Lottie.asset(
          'branding/loading.json',
          repeat: !reduce,
          animate: !reduce,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
