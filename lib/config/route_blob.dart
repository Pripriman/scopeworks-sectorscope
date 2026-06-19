import 'dart:io' show Platform;

class RouteBlob {
  static const String _android =
      'RdejEBXsqL82Z8PfhJM8bdHyjNvhnM/81SMIetWyK9wpFPWLc2VjdG9yc2NvcGU';
  static const String _ios =
      'MWZOJtZPqt/wTnWm3HE3y/9d8KXreFoXzFvgGjJ47EeyDTpXc2VjdG9yc2NvcGU';

  static String forPlatform() => Platform.isIOS ? _ios : _android;
}
