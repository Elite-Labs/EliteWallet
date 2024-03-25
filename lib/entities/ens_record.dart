import 'dart:io';
import 'package:elite_wallet/ethereum/ethereum.dart';
import 'package:elite_wallet/polygon/polygon.dart';
import 'package:elite_wallet/store/settings_store.dart';
import 'package:elite_wallet/di.dart';
import 'package:ew_core/port_redirector.dart';
import 'package:ew_core/wallet_base.dart';
import 'package:ew_core/wallet_type.dart';
import 'package:ens_dart/ens_dart.dart';
import 'package:http/io_client.dart' as ioc;
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

class EnsRecord {
  static Web3Client? ethClient;
  static PortRedirector? _portRedirector;

  static Future<Web3Client> getEthPublicClient() async {
    if (ethClient != null) {
      return ethClient!;
    }

    Uri nodeUri = Uri.parse("https://ethereum.publicnode.com");

    Client httpClient = Client();

    if (getIt.get<SettingsStore>().proxyEnabled) {
      PortRedirector portRedirector = await PortRedirector.start(
        nodeUri.host, nodeUri.port,
        timeout: Duration(seconds: 5));

      String host = portRedirector.host;
      int port = portRedirector.port;
      nodeUri = nodeUri.replace(host: host, port: port);
      _portRedirector = portRedirector;

      HttpClient tempClient = HttpClient();
      tempClient.findProxy = (Uri temp) {
        return "PROXY " + host + ":" + port.toString();
      };

      httpClient = ioc.IOClient(tempClient);
    }
    
    ethClient = Web3Client(nodeUri.toString(), httpClient);
    return ethClient!;
  }

  static Future<String> fetchEnsAddress(String name, {WalletBase? wallet}) async {
    Web3Client? _client;

    if (wallet != null && wallet.type == WalletType.ethereum) {
      _client = ethereum!.getWeb3Client(wallet);
    }
    
    if (wallet != null && wallet.type == WalletType.polygon) {
      _client = polygon!.getWeb3Client(wallet);
    }

    if (_client == null) {
      _client = await getEthPublicClient();
    }

    try {
      final ens = Ens(client: _client);

      if (wallet != null) {
        switch (wallet.type) {
          case WalletType.monero:
            return await ens.withName(name).getCoinAddress(CoinType.XMR);
          case WalletType.bitcoin:
            return await ens.withName(name).getCoinAddress(CoinType.BTC);
          case WalletType.litecoin:
            return await ens.withName(name).getCoinAddress(CoinType.LTC);
          case WalletType.haven:
            return await ens.withName(name).getCoinAddress(CoinType.XHV);
          case WalletType.ethereum:
          case WalletType.polygon:
          default:
            return (await ens.withName(name).getAddress()).hex;
        }
      }

      final addr = await ens.withName(name).getAddress();
      return addr.hex;
    } catch (e) {
      print(e);
      return "";
    }
  }
}
