import 'package:elite_wallet/anypay/any_pay_payment.dart';
import 'package:elite_wallet/ionia/ionia_order.dart';

class IoniaAnyPayPaymentInfo {
	const IoniaAnyPayPaymentInfo(this.ioniaOrder, this.anyPayPayment);

	final IoniaOrder ioniaOrder;
	final AnyPayPayment anyPayPayment;
}
