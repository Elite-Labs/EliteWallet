import 'package:elite_wallet/core/execution_state.dart';

class AuthenticationBanned extends ExecutionState {
  AuthenticationBanned({this.error});

  final String error;
}

