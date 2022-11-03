import 'dart:io';
import 'package:elite_wallet/store/settings_store.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart' as ioc;
import 'package:cw_core/port_redirector.dart';

Future<http.Response> get(
  SettingsStore settingsStore,
  dynamic url,
  {Map<String, String> headers,
   HttpClient httpClient}) async {

  Map<String, dynamic> map =
    await _initializeRedirector(settingsStore, url, httpClient);

  http.Client client = map['client'] as http.Client;
  PortRedirector redirector = map['redirector'] as PortRedirector;
  Uri redirectorUrl = map['url'] as Uri;

  final response =
    await client.get(redirectorUrl.toString(), headers: headers);
  return response;
}

Future<http.Response> post(
  SettingsStore settingsStore,
  dynamic url,
  {Map<String, String> headers,
   Object body,
   HttpClient httpClient}) async {

  Map<String, dynamic> map =
    await _initializeRedirector(settingsStore, url, httpClient);

  http.Client client = map['client'] as http.Client;
  PortRedirector redirector = map['redirector'] as PortRedirector;
  Uri redirectorUrl = map['url'] as Uri;

  final response = 
    await client.post(
      redirectorUrl.toString(),
      headers: headers,
      body: body);
  return response;
}

Future<http.Response> put(
  SettingsStore settingsStore,
  dynamic url,
  {Map<String, String> headers,
   Object body,
   HttpClient httpClient}) async {

  Map<String, dynamic> map =
    await _initializeRedirector(settingsStore, url, httpClient);

  http.Client client = map['client'] as http.Client;
  PortRedirector redirector = map['redirector'] as PortRedirector;
  Uri redirectorUrl = map['url'] as Uri;

  final response = 
    await client.put(
      redirectorUrl.toString(),
      headers: headers,
      body: body);
  return response;
}

Future<Map<String, dynamic>> _initializeRedirector(
  SettingsStore settingsStore,
  dynamic serverUrl,
  HttpClient httpClient) async {

  Uri url;
  if (serverUrl is String) {
    url = Uri.parse(serverUrl);
  } else if (serverUrl is Uri) {
    url = serverUrl;
  } else {
    throw "Unknown type of serverUrl " + serverUrl.runtimeType.toString();
  }

  String serverHost = url.host;
  PortRedirector portRedirector = await PortRedirector.start(
    settingsStore, url.host, url.port, timeout: Duration(seconds: 5));
  String host = portRedirector.host;
  int port = portRedirector.port;

  httpClient ??= HttpClient();

  httpClient.findProxy = (Uri temp) {
      return "PROXY " + host + ":" + port.toString();
    };

  final http.Client ioClient = ioc.IOClient(httpClient);

  return {'client': ioClient, 'redirector': portRedirector, 'url': url};
}