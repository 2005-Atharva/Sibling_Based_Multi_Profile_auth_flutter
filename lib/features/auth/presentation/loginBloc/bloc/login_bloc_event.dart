// Events
abstract class LoginEvent {}

class LoginInputSubmitted extends LoginEvent {
  final String input;
  LoginInputSubmitted(this.input);
}
