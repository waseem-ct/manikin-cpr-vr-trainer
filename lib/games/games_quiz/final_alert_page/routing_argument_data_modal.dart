
import '../../common_widgets/game_export_class.dart';

class RouteArguments {
  final BluetoothDevice device;
  final int correctPoints;
  final int incorrectPoints;
  final int quizPoints;
  final String? jsonKey;
  final String? pageId;

  RouteArguments({required this.device, required this.correctPoints, required this.incorrectPoints, required this.quizPoints, required this.jsonKey, this.pageId});

  // Factory method to parse from a list
  factory RouteArguments.fromList(List<dynamic> args) {
    return RouteArguments(
      device: args[0] as BluetoothDevice,
      correctPoints: args[1] as int,
      incorrectPoints: args[2] as int,
      quizPoints: args[3] as int,
      jsonKey: args[4] ?? "",
      pageId: args.length > 5 ? args[5] ?? "" : null,
    );
  }

  @override
  String toString() {
    return '$RouteArguments(device: $device, correctAnswerPoints: $correctPoints, incorrectAnswerPoints: $incorrectPoints, quizPoints: $quizPoints, jsonKey: $jsonKey, pageId: $pageId)';
  }
}
