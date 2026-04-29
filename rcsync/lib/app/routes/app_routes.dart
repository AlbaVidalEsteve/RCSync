part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  static const HOME = _Paths.HOME;
  static const LIST = _Paths.LIST;
  static const LOGIN = _Paths.LOGIN;
  static const REGISTER = _Paths.REGISTER;
  static const PROFILE = _Paths.PROFILE;
  static const EVENT_DETAIL = _Paths.EVENT_DETAIL;
  static const CREATE_EVENT = _Paths.CREATE_EVENT;
  static const EVENT_REGISTRATION = _Paths.EVENT_REGISTRATION;
  static const CREATE_CHAMPIONSHIP = _Paths.CREATE_CHAMPIONSHIP;
  static const SPLASH = _Paths.SPLASH;

}

abstract class _Paths {
  static const HOME = '/home';
  static const LIST = '/list';
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const PROFILE = '/profile';
  static const EVENT_DETAIL = '/event-detail';
  static const CREATE_EVENT = '/create-event';
  static const EVENT_REGISTRATION = '/event-registration';
  static const CREATE_CHAMPIONSHIP = '/create-championship';
  static const SPLASH = '/splash';
}
