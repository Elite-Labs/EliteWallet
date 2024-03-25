import 'dart:async';
import 'package:elite_wallet/anonpay/anonpay_invoice_info.dart';
import 'package:elite_wallet/core/auth_service.dart';
import 'package:elite_wallet/entities/language_service.dart';
import 'package:elite_wallet/buy/order.dart';
import 'package:elite_wallet/locales/locale.dart';
import 'package:elite_wallet/store/yat/yat_store.dart';
import 'package:elite_wallet/utils/device_info.dart';
import 'package:elite_wallet/utils/exception_handler.dart';
import 'package:ew_core/address_info.dart';
import 'package:elite_wallet/utils/responsive_layout_util.dart';
import 'package:ew_core/hive_type_ids.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:elite_wallet/di.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:elite_wallet/themes/theme_base.dart';
import 'package:elite_wallet/router.dart' as Router;
import 'package:elite_wallet/routes.dart';
import 'package:elite_wallet/generated/i18n.dart';
import 'package:elite_wallet/reactions/bootstrap.dart';
import 'package:elite_wallet/store/app_store.dart';
import 'package:elite_wallet/store/authentication_store.dart';
import 'package:elite_wallet/entities/transaction_description.dart';
import 'package:elite_wallet/entities/get_encryption_key.dart';
import 'package:elite_wallet/entities/contact.dart';
import 'package:ew_core/node.dart';
import 'package:ew_core/wallet_info.dart';
import 'package:elite_wallet/entities/default_settings_migration.dart';
import 'package:ew_core/wallet_type.dart';
import 'package:elite_wallet/entities/template.dart';
import 'package:elite_wallet/exchange/trade.dart';
import 'package:elite_wallet/exchange/exchange_template.dart';
import 'package:elite_wallet/src/screens/root/root.dart';
import 'package:uni_links/uni_links.dart';
import 'package:ew_core/unspent_coins_info.dart';
import 'package:elite_wallet/monero/monero.dart';
import 'package:ew_core/elite_hive.dart';

final navigatorKey = GlobalKey<NavigatorState>();
final rootKey = GlobalKey<RootState>();
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

Future<void> main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = ExceptionHandler.onError;

    /// A callback that is invoked when an unhandled error occurs in the root
    /// isolate.
    PlatformDispatcher.instance.onError = (error, stack) {
      ExceptionHandler.onError(FlutterErrorDetails(exception: error, stack: stack));

      return true;
    };

    await EliteHive.close();

    await initializeAppConfigs();

    runApp(App());
  }, (error, stackTrace) async {
    ExceptionHandler.onError(FlutterErrorDetails(exception: error, stack: stackTrace));
  });
}

Future<void> initializeAppConfigs() async {
  final appDir = await getApplicationDocumentsDirectory();
  EliteHive.init(appDir.path);

  if (!EliteHive.isAdapterRegistered(Contact.typeId)) {
    EliteHive.registerAdapter(ContactAdapter());
  }

  if (!EliteHive.isAdapterRegistered(Node.typeId)) {
    EliteHive.registerAdapter(NodeAdapter());
  }

  if (!EliteHive.isAdapterRegistered(TransactionDescription.typeId)) {
    EliteHive.registerAdapter(TransactionDescriptionAdapter());
  }

  if (!EliteHive.isAdapterRegistered(Trade.typeId)) {
    EliteHive.registerAdapter(TradeAdapter());
  }

  if (!EliteHive.isAdapterRegistered(AddressInfo.typeId)) {
    EliteHive.registerAdapter(AddressInfoAdapter());
  }

  if (!EliteHive.isAdapterRegistered(WalletInfo.typeId)) {
    EliteHive.registerAdapter(WalletInfoAdapter());
  }

  if (!EliteHive.isAdapterRegistered(DERIVATION_TYPE_TYPE_ID)) {
    EliteHive.registerAdapter(DerivationTypeAdapter());
  }

  if (!EliteHive.isAdapterRegistered(WALLET_TYPE_TYPE_ID)) {
    EliteHive.registerAdapter(WalletTypeAdapter());
  }

  if (!EliteHive.isAdapterRegistered(Template.typeId)) {
    EliteHive.registerAdapter(TemplateAdapter());
  }

  if (!EliteHive.isAdapterRegistered(ExchangeTemplate.typeId)) {
    EliteHive.registerAdapter(ExchangeTemplateAdapter());
  }

  if (!EliteHive.isAdapterRegistered(Order.typeId)) {
    EliteHive.registerAdapter(OrderAdapter());
  }

  if (!EliteHive.isAdapterRegistered(UnspentCoinsInfo.typeId)) {
    EliteHive.registerAdapter(UnspentCoinsInfoAdapter());
  }

  if (!EliteHive.isAdapterRegistered(AnonpayInvoiceInfo.typeId)) {
    EliteHive.registerAdapter(AnonpayInvoiceInfoAdapter());
  }

  final secureStorage = FlutterSecureStorage(
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  final transactionDescriptionsBoxKey =
      await getEncryptionKey(secureStorage: secureStorage, forKey: TransactionDescription.boxKey);
  final tradesBoxKey = await getEncryptionKey(secureStorage: secureStorage, forKey: Trade.boxKey);
  final ordersBoxKey = await getEncryptionKey(secureStorage: secureStorage, forKey: Order.boxKey);
  final contacts = await EliteHive.openBox<Contact>(Contact.boxName);
  final nodes = await EliteHive.openBox<Node>(Node.boxName);
  final powNodes =
      await EliteHive.openBox<Node>(Node.boxName + "pow"); // must be different from Node.boxName
  final transactionDescriptions = await EliteHive.openBox<TransactionDescription>(
      TransactionDescription.boxName,
      encryptionKey: transactionDescriptionsBoxKey);
  final trades = await EliteHive.openBox<Trade>(Trade.boxName, encryptionKey: tradesBoxKey);
  final orders = await EliteHive.openBox<Order>(Order.boxName, encryptionKey: ordersBoxKey);
  final walletInfoSource = await EliteHive.openBox<WalletInfo>(WalletInfo.boxName);
  final templates = await EliteHive.openBox<Template>(Template.boxName);
  final exchangeTemplates = await EliteHive.openBox<ExchangeTemplate>(ExchangeTemplate.boxName);
  final anonpayInvoiceInfo = await EliteHive.openBox<AnonpayInvoiceInfo>(AnonpayInvoiceInfo.boxName);
  final unspentCoinsInfoSource = await EliteHive.openBox<UnspentCoinsInfo>(UnspentCoinsInfo.boxName);

  await initialSetup(
      sharedPreferences: await SharedPreferences.getInstance(),
      nodes: nodes,
      powNodes: powNodes,
      walletInfoSource: walletInfoSource,
      contactSource: contacts,
      tradesSource: trades,
      ordersSource: orders,
      unspentCoinsInfoSource: unspentCoinsInfoSource,
      // fiatConvertationService: fiatConvertationService,
      templates: templates,
      exchangeTemplates: exchangeTemplates,
      transactionDescriptions: transactionDescriptions,
      secureStorage: secureStorage,
      anonpayInvoiceInfo: anonpayInvoiceInfo,
      initialMigrationVersion: 31);
}

Future<void> initialSetup(
    {required SharedPreferences sharedPreferences, 
    required Box<Node> nodes,
    required Box<Node> powNodes,
    required Box<WalletInfo> walletInfoSource,
    required Box<Contact> contactSource,
    required Box<Trade> tradesSource,
    required Box<Order> ordersSource,
    // required FiatConvertationService fiatConvertationService,
    required Box<Template> templates,
    required Box<ExchangeTemplate> exchangeTemplates,
    required Box<TransactionDescription> transactionDescriptions,
    required FlutterSecureStorage secureStorage,
    required Box<AnonpayInvoiceInfo> anonpayInvoiceInfo,
    required Box<UnspentCoinsInfo> unspentCoinsInfoSource,
    int initialMigrationVersion = 31}) async {
  LanguageService.loadLocaleList();
  await defaultSettingsMigration(
      secureStorage: secureStorage,
      version: initialMigrationVersion,
      sharedPreferences: sharedPreferences,
      walletInfoSource: walletInfoSource,
      contactSource: contactSource,
      tradeSource: tradesSource,
      nodes: nodes,
      powNodes: powNodes);
  await setup(
      walletInfoSource: walletInfoSource,
      nodeSource: nodes,
      powNodeSource: powNodes,
      contactSource: contactSource,
      tradesSource: tradesSource,
      templates: templates,
      exchangeTemplates: exchangeTemplates,
      transactionDescriptionBox: transactionDescriptions,
      ordersSource: ordersSource,
      anonpayInvoiceInfoSource: anonpayInvoiceInfo,
      unspentCoinsInfoSource: unspentCoinsInfoSource,
      secureStorage: secureStorage);
  await bootstrap(navigatorKey);
  monero?.onStartup();
}

class App extends StatefulWidget {
  @override
  AppState createState() => AppState();
}

class AppState extends State<App> with SingleTickerProviderStateMixin {
  AppState() : yatStore = getIt.get<YatStore>();

  YatStore yatStore;
  StreamSubscription? stream;

  @override
  void initState() {
    super.initState();
    //_handleIncomingLinks();
    //_handleInitialUri();
  }

  Future<void> _handleInitialUri() async {
    try {
      final uri = await getInitialUri();
      print('uri: $uri');
      if (uri == null) {
        return;
      }
      if (!mounted) return;
      //_fetchEmojiFromUri(uri);
    } catch (e) {
      if (!mounted) return;
      print(e.toString());
    }
  }

  void _handleIncomingLinks() {
    if (!kIsWeb) {
      stream = getUriLinksStream().listen((Uri? uri) {
        print('uri: $uri');
        if (!mounted) return;
        //_fetchEmojiFromUri(uri);
      }, onError: (Object error) {
        if (!mounted) return;
        print('Error: $error');
      });
    }
  }

  void _fetchEmojiFromUri(Uri uri) {
    //final queryParameters = uri.queryParameters;
    //if (queryParameters?.isEmpty ?? true) {
    //  return;
    //}
    //final emoji = queryParameters['eid'];
    //final refreshToken = queryParameters['refresh_token'];
    //if ((emoji?.isEmpty ?? true)||(refreshToken?.isEmpty ?? true)) {
    //  return;
    //}
    //yatStore.emoji = emoji;
    //yatStore.refreshToken = refreshToken;
    //yatStore.emojiIncommingSC.add(emoji);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (BuildContext context) {
      final appStore = getIt.get<AppStore>();
      final authService = getIt.get<AuthService>();
      final settingsStore = appStore.settingsStore;
      final statusBarColor = Colors.transparent;
      final authenticationStore = getIt.get<AuthenticationStore>();
      final initialRoute = authenticationStore.state == AuthenticationState.uninitialized
          ? Routes.disclaimer
          : Routes.login;
      final currentTheme = settingsStore.currentTheme;
      final statusBarBrightness =
          currentTheme.type == ThemeType.dark ? Brightness.light : Brightness.dark;
      final statusBarIconBrightness =
          currentTheme.type == ThemeType.dark ? Brightness.light : Brightness.dark;
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: statusBarColor,
          statusBarBrightness: statusBarBrightness,
          statusBarIconBrightness: statusBarIconBrightness));

      return Root(
          key: rootKey,
          appStore: appStore,
          authenticationStore: authenticationStore,
          navigatorKey: navigatorKey,
          authService: authService,
          child: MaterialApp(
            navigatorObservers: [routeObserver],
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            theme: settingsStore.theme,
            localizationsDelegates: localizationDelegates,
            supportedLocales: S.delegate.supportedLocales,
            locale: Locale(settingsStore.languageCode),
            onGenerateRoute: (settings) => Router.createRoute(settings),
            initialRoute: initialRoute,
            home: _Home(),
          ));
    });
  }
}

class _Home extends StatefulWidget {
  const _Home();

  @override
  State<_Home> createState() => _HomeState();
}

class _HomeState extends State<_Home> {
  @override
  void didChangeDependencies() {
    _setOrientation(context);

    super.didChangeDependencies();
  }

  void _setOrientation(BuildContext context) {
    if (!DeviceInfo.instance.isDesktop) {
      if (responsiveLayoutUtil.shouldRenderMobileUI) {
        SystemChrome.setPreferredOrientations(
            [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
      } else {
        SystemChrome.setPreferredOrientations(
            [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
