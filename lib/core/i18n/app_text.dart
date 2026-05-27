class AppText {
  AppText(this.languageCode);

  final String languageCode;

  bool get isSpanish => languageCode == 'es';

  String get appName => isSpanish ? 'Zappy' : 'Zappy';
  String get loginTitle => isSpanish ? 'Iniciar sesión' : 'Sign in';
  String get welcome => isSpanish ? 'Bienvenido a Zappy' : 'Welcome to Zappy';
  String get email => isSpanish ? 'Email' : 'Email';
  String get password => isSpanish ? 'Contraseña' : 'Password';
  String get invalidEmail => isSpanish ? 'Ingresa un email válido' : 'Enter a valid email';
  String get invalidPassword => isSpanish ? 'Mínimo 6 caracteres' : 'Minimum 6 characters';
  String get login => isSpanish ? 'Entrar' : 'Log in';
  String get registerMock => isSpanish ? 'Crear cuenta (mock)' : 'Create account (mock)';

  String get feed => isSpanish ? 'Feed' : 'Feed';
  String get live => isSpanish ? 'Live' : 'Live';
  String get chat => isSpanish ? 'Chat' : 'Chat';
  String get games => isSpanish ? 'Games' : 'Games';
  String get wallet => isSpanish ? 'Wallet' : 'Wallet';
  String get logout => isSpanish ? 'Cerrar sesión' : 'Log out';
  String get language => isSpanish ? 'Idioma' : 'Language';

  String get balanceNow => isSpanish ? 'Balance actual' : 'Current balance';
  String get estimated => isSpanish ? 'Estimado' : 'Estimated';
  String get withdraw => isSpanish ? 'Retirar' : 'Withdraw';
  String get transfer => isSpanish ? 'Transferir' : 'Transfer';
  String get buyCoins => isSpanish ? 'Comprar monedas' : 'Buy coins';
  String get seeMore => isSpanish ? 'Ver más' : 'See more';
  String get popularGifts => isSpanish ? 'Regalos populares' : 'Popular gifts';
  String get catalog => isSpanish ? 'Catálogo' : 'Catalog';
  String get movements => isSpanish ? 'Movimientos' : 'Transactions';
  String get history => isSpanish ? 'Historial' : 'History';
  String get popular => isSpanish ? 'Popular' : 'Popular';

  String get languageChanged => isSpanish ? 'Idioma cambiado' : 'Language changed';
}
