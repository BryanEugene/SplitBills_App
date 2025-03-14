import 'package:share_plus/share_plus.dart';

class ShareService {
  static Future<void> inviteFriend(String name, String phone) async {
    final message = 'Hey $name, join me on Split Bill App to easily split bills and expenses! Download here: [App Link]';
    await Share.share(message);
  }

  static Future<void> shareBillSummary(double total, int participantsCount, String description) async {
    final perPerson = (total / participantsCount).toStringAsFixed(2);
    final message = 'Bill Split Summary:\n'
        '${description}\n'
        'Total: \$${total.toStringAsFixed(2)}\n'
        'Split between $participantsCount people\n'
        'Amount per person: \$$perPerson';
    await Share.share(message);
  }
}
