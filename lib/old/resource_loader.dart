import 'dart:typed_data';

import "dart:ui" as ui;

import 'package:flutter/services.dart';

class ResourceLoader {
  Future<ui.Image> loadImage() async {
    ByteData bd = await rootBundle.load("assets/images/building.png");

    final Uint8List bytes = Uint8List.view(bd.buffer);

    final ui.Codec codec = await ui.instantiateImageCodec(bytes);

    final ui.Image image = (await codec.getNextFrame()).image;

    return image;
  }
}
