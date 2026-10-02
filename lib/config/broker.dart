/// Example broker contact: the listings JSON has no broker data.
/// The phone is deliberately invalid so nobody real is reached.
abstract final class BrokerContact {
  static const name = 'Corretor ImobiBrasil';
  static const phoneDisplay = '(18) 0000-0000';

  /// Country code + area code + number, as WhatsApp and the dialer expect.
  static const phoneDigits = '551800000000';
  static const email = 'corretor@imobibrasil.com.br';
}
