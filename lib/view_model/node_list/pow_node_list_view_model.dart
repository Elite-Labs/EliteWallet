import 'package:elite_wallet/generated/i18n.dart';
import 'package:elite_wallet/store/app_store.dart';
import 'package:elite_wallet/utils/mobx.dart';
import 'package:hive/hive.dart';
import 'package:mobx/mobx.dart';
import 'package:ew_core/wallet_base.dart';
import 'package:elite_wallet/store/settings_store.dart';
import 'package:ew_core/node.dart';
import 'package:elite_wallet/entities/node_list.dart';
import 'package:elite_wallet/entities/default_settings_migration.dart';
import 'package:ew_core/wallet_type.dart';

part 'pow_node_list_view_model.g.dart';

class PowNodeListViewModel = PowNodeListViewModelBase with _$PowNodeListViewModel;

abstract class PowNodeListViewModelBase with Store {
  PowNodeListViewModelBase(this._nodeSource, this._appStore)
      : nodes = ObservableList<Node>(),
        settingsStore = _appStore.settingsStore {
    _bindNodes();

    reaction((_) => _appStore.wallet, (WalletBase? _wallet) {
      _bindNodes();
    });
  }

  @computed
  Node get currentNode {
    final node = settingsStore.powNodes[_appStore.wallet!.type];

    if (node == null) {
      throw Exception('No node for wallet type: ${_appStore.wallet!.type}');
    }

    return node;
  }

  String getAlertContent(String uri) =>
      S.current.change_current_node(uri) +
      '${uri.endsWith('.onion') || uri.contains('.onion:') ? '\n' + S.current.orbot_running_alert : ''}';

  final ObservableList<Node> nodes;
  final SettingsStore settingsStore;
  final Box<Node> _nodeSource;
  final AppStore _appStore;

  Future<void> reset() async {
    await resetPowToDefault(_nodeSource);

    Node node;

    switch (_appStore.wallet!.type) {
      case WalletType.nano:
        node = getNanoDefaultPowNode(nodes: _nodeSource)!;
        break;
      default:
        throw Exception('Unexpected wallet type: ${_appStore.wallet!.type}');
    }

    await setAsCurrent(node);
  }

  @action
  Future<void> delete(Node node) async => node.delete();

  Future<void> setAsCurrent(Node node) async =>
      settingsStore.powNodes[_appStore.wallet!.type] = node;

  @action
  void _bindNodes() {
    nodes.clear();
    _nodeSource.bindToList(
      nodes,
      filter: (val) => val.type == _appStore.wallet!.type,
      initialFire: true,
    );
  }
}
