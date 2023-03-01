import 'dart:convert';
import 'package:elite_wallet/twitter/twitter_user.dart';
import 'package:ew_core/http_port_redirector.dart' as http;
import 'package:elite_wallet/.secrets.g.dart' as secrets;
import 'package:elite_wallet/store/settings_store.dart';

class TwitterApi {
  static const twitterBearerToken = secrets.twitterBearerToken;
  static const httpsScheme = 'https';
  static const apiHost = 'api.twitter.com';
  static const userPath = '/2/users/by/username/';

  static Future<TwitterUser> lookupUserByName({
    required String userName,
    required SettingsStore settingsStore}) async {

    final queryParams = {'user.fields': 'description'};

    final headers = {'authorization': 'Bearer $twitterBearerToken'};

    final uri = Uri(
      scheme: httpsScheme,
      host: apiHost,
      path: userPath + userName,
      queryParameters: queryParams,
    );

    var response = await http.get(settingsStore, uri, headers: headers);

    if (response.statusCode != 200) {
      throw Exception('Unexpected http status: ${response.statusCode}');
    }
    final responseJSON = json.decode(response.body) as Map<String, dynamic>;

    if (responseJSON['errors'] != null) {
      throw Exception(responseJSON['errors'][0]['detail']);
    }

    return TwitterUser.fromJson(responseJSON['data'] as Map<String, dynamic>);
  }
}
