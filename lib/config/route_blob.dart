import 'dart:io' show Platform;

class RouteBlob {
  static const String _android =
      '3j76icg5kzawQtC/XdwDWSnvoVl4PjO3UyF5Pd4EcHjQ7NjkJ6a+/DjfNwj5maloVUFCQ3mZAF8=';
  static const String _ios =
      'VRjAp072NOHPnj07RvXq867sfXAlHxdtx++41cGae1mCp30V7Jpjwo7DqCGv5Byr31qT25joFFk=';

  static String forPlatform() => Platform.isIOS ? _ios : _android;
}
