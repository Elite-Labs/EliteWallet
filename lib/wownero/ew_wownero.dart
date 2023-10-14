part of 'wownero.dart';

class EWWowneroAccountList extends WowneroAccountList {
	EWWowneroAccountList(this._wallet);
	final Object _wallet;

	@override
	@computed
  ObservableList<Account> get accounts {
  	final wowneroWallet = _wallet as WowneroWallet;
  	final accounts = wowneroWallet.walletAddresses.accountList
  		.accounts
  		.map((acc) => Account(id: acc.id, label: acc.label))
  		.toList();
  	return ObservableList<Account>.of(accounts);
  }

  @override
  void update(Object wallet) {
  	final wowneroWallet = wallet as WowneroWallet;
  	wowneroWallet.walletAddresses.accountList.update();
  }

  @override
	void refresh(Object wallet) {
		final wowneroWallet = wallet as WowneroWallet;
  	wowneroWallet.walletAddresses.accountList.refresh();
	}

	@override
  List<Account> getAll(Object wallet) {
  	final wowneroWallet = wallet as WowneroWallet;
  	return wowneroWallet.walletAddresses.accountList
  		.getAll()
  		.map((acc) => Account(id: acc.id, label: acc.label))
  		.toList();
  }

  @override
  Future<void> addAccount(Object wallet, {required String label}) async {
  	final wowneroWallet = wallet as WowneroWallet;
  	await wowneroWallet.walletAddresses.accountList.addAccount(label: label);
  }

  @override
  Future<void> setLabelAccount(Object wallet, {required int accountIndex, required String label}) async {
  	final wowneroWallet = wallet as WowneroWallet;
  	await wowneroWallet.walletAddresses.accountList
  		.setLabelAccount(
  			accountIndex: accountIndex,
  			label: label);
  }
}

class EWWowneroSubaddressList extends WowneroSubaddressList {
	EWWowneroSubaddressList(this._wallet);
	final Object _wallet;

	@override
	@computed
  ObservableList<Subaddress> get subaddresses {
  	final wowneroWallet = _wallet as WowneroWallet;
  	final subAddresses = wowneroWallet.walletAddresses.subaddressList
  		.subaddresses
  		.map((sub) => Subaddress(
  			id: sub.id,
  			address: sub.address,
  			label: sub.label))
  		.toList();
  	return ObservableList<Subaddress>.of(subAddresses);
  }

  @override
  void update(Object wallet, {required int accountIndex}) {
  	final wowneroWallet = wallet as WowneroWallet;
  	wowneroWallet.walletAddresses.subaddressList.update(accountIndex: accountIndex);
  }

  @override
  void refresh(Object wallet, {required int accountIndex}) {
  	final wowneroWallet = wallet as WowneroWallet;
  	wowneroWallet.walletAddresses.subaddressList.refresh(accountIndex: accountIndex);
  }

  @override
  List<Subaddress> getAll(Object wallet) {
  	final wowneroWallet = wallet as WowneroWallet;
  	return wowneroWallet.walletAddresses
  		.subaddressList
  		.getAll()
  		.map((sub) => Subaddress(id: sub.id, label: sub.label, address: sub.address))
  		.toList();
  }

  @override
  Future<void> addSubaddress(Object wallet, {required int accountIndex, required String label}) async {
  	final wowneroWallet = wallet as WowneroWallet;
  	await wowneroWallet.walletAddresses.subaddressList
  		.addSubaddress(
  			accountIndex: accountIndex,
  			label: label);
  }

  @override
  Future<void> setLabelSubaddress(Object wallet,
      {required int accountIndex, required int addressIndex, required String label}) async {
  	final wowneroWallet = wallet as WowneroWallet;
  	await wowneroWallet.walletAddresses.subaddressList
  		.setLabelSubaddress(
  			accountIndex: accountIndex,
  			addressIndex: addressIndex,
  			label: label);
  }
}

class EWWowneroWalletDetails extends WowneroWalletDetails {
	EWWowneroWalletDetails(this._wallet);
	final Object _wallet;

	@computed
  @override
  Account get account {
  	final wowneroWallet = _wallet as WowneroWallet;
  	final acc = wowneroWallet.walletAddresses.account as wownero_account.Account;
  	return Account(id: acc.id, label: acc.label);
  }

  @computed
  @override
	WowneroBalance get balance {
		final wowneroWallet = _wallet as WowneroWallet;
  	final balance = wowneroWallet.balance;
  	throw Exception('Unimplemented');
  	//return WowneroBalance(
  	//	fullBalance: balance.fullBalance,
  	//	unlockedBalance: balance.unlockedBalance);
	}
}

class EWWownero extends Wownero {
  @override
  WowneroAccountList getAccountList(Object wallet) {
		return EWWowneroAccountList(wallet);
	}

	@override
	WowneroSubaddressList getSubaddressList(Object wallet) {
		return EWWowneroSubaddressList(wallet);
	}

  @override
	TransactionHistoryBase getTransactionHistory(Object wallet) {
		final wowneroWallet = wallet as WowneroWallet;
		return wowneroWallet.transactionHistory;
	}

  @override
	WowneroWalletDetails getWowneroWalletDetails(Object wallet) {
		return EWWowneroWalletDetails(wallet);
	}

	@override
	int getHeightByDate({required DateTime date}) {
		return getWowneroHeightByDate(date: date);
	}

  @override
  int getCurrentHeight() => wownero_wallet_api.getCurrentHeight();

  @override
	TransactionPriority getDefaultTransactionPriority() {
		return MoneroTransactionPriority.automatic;
	}

  @override
	TransactionPriority deserializeMoneroTransactionPriority({required int raw}) {
		return MoneroTransactionPriority.deserialize(raw: raw);
	}

  @override
	List<TransactionPriority> getTransactionPriorities() {
		return MoneroTransactionPriority.all;
	}

  @override
	List<String> getWowneroWordList(String language) {
		switch (language.toLowerCase()) {
		  case 'english':
		    return EnglishMnemonics.words;
		  default:
		    return EnglishMnemonics.words;
		}
	}

  @override
	WalletCredentials createWowneroRestoreWalletFromKeysCredentials({
			required String name,
      required String spendKey,
      required String viewKey,
      required String address,
      required String password,
      required String language,
      required int height}) {
		return WowneroRestoreWalletFromKeysCredentials(
			name: name,
			spendKey: spendKey,
			viewKey: viewKey,
			address: address,
			password: password,
			language: language,
			height: height);
	}
  
  @override
	WalletCredentials createWowneroRestoreWalletFromSeedCredentials({
    required String name,
    required String password,
    required int height,
    required String mnemonic}) {
		return WowneroRestoreWalletFromSeedCredentials(
			name: name,
			password: password,
			height: height,
			mnemonic: mnemonic);
	}

  @override
	WalletCredentials createWowneroNewWalletCredentials({
    required String name,
    required String language,
    String? password}) {
		return WowneroNewWalletCredentials(
			name: name,
			password: password,
			language: language);
	}

  @override
	Map<String, String> getKeys(Object wallet) {
		final wowneroWallet = wallet as WowneroWallet;
		final keys = wowneroWallet.keys;
		return <String, String>{
			'privateSpendKey': keys.privateSpendKey,
      'privateViewKey': keys.privateViewKey,
      'publicSpendKey': keys.publicSpendKey,
      'publicViewKey': keys.publicViewKey};
	}

  @override
	Object createWowneroTransactionCreationCredentials({
    required List<Output> outputs,
    required TransactionPriority priority}) {
		return WowneroTransactionCreationCredentials(
			outputs: outputs.map((out) => OutputInfo(
					fiatAmount: out.fiatAmount,
					cryptoAmount: out.cryptoAmount,
					address: out.address,
					note: out.note,
					sendAll: out.sendAll,
					extractedAddress: out.extractedAddress,
					isParsedAddress: out.isParsedAddress,
					formattedCryptoAmount: out.formattedCryptoAmount))
				.toList(),
			priority: priority as MoneroTransactionPriority);
	}

  @override
	String formatterWowneroAmountToString({required int amount}) {
		return wowneroAmountToString(amount: amount);
	}
  
  @override
	double formatterWowneroAmountToDouble({required int amount}) {
		return wowneroAmountToDouble(amount: amount);
	}

  @override
	int formatterWowneroParseAmount({required String amount}) {
		return wowneroParseAmount(amount: amount);
	}

  @override
	Account getCurrentAccount(Object wallet) {
		final wowneroWallet = wallet as WowneroWallet;
		final acc = wowneroWallet.walletAddresses.account as wownero_account.Account;
		return Account(id: acc.id, label: acc.label);
	}

  @override
	void setCurrentAccount(Object wallet, int id, String label) {
		final wowneroWallet = wallet as WowneroWallet;
		wowneroWallet.walletAddresses.account = wownero_account.Account(id: id, label: label);
	}

  @override
	void onStartup() {
		wownero_wallet_api.onStartup();
	}

  @override
	int getTransactionInfoAccountId(TransactionInfo tx) {
		final wowneroTransactionInfo = tx as WowneroTransactionInfo;
		return wowneroTransactionInfo.accountIndex;
	}

  @override
	WalletService createWowneroWalletService(Box<WalletInfo> walletInfoSource) {
		return WowneroWalletService(walletInfoSource);
	}

  @override
	String getTransactionAddress(Object wallet, int accountIndex, int addressIndex) {
		final wowneroWallet = wallet as WowneroWallet;
		return wowneroWallet.getTransactionAddress(accountIndex, addressIndex);
	}

	@override
  String getSubaddressLabel(Object wallet, int accountIndex, int addressIndex) {
		final wowneroWallet = wallet as WowneroWallet;
		return wowneroWallet.getSubaddressLabel(accountIndex, addressIndex);
	}
}
