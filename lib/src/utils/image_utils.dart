import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import 'package:guardiancare/src/constants/colors.dart';
import 'package:guardiancare/src/utils/logger_util.dart';

class ImageUtils {
  // Singleton pattern
  static final ImageUtils _instance = ImageUtils._internal();
  factory ImageUtils() => _instance;
  ImageUtils._internal();

  final ImagePicker _imagePicker = ImagePicker();
  
  // Get image from gallery
  Future<File?> pickImageFromGallery({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality ?? 80,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      logger.e('Error picking image from gallery', e);
      return null;
    }
  }

  // Capture image from camera
  Future<File?> captureImageFromCamera({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality ?? 80,
        preferredCameraDevice: CameraDevice.rear,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      logger.e('Error capturing image from camera', e);
      return null;
    }
  }

  // Save image to app's documents directory
  Future<File?> saveImageToAppDir(File imageFile, {String? fileName}) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final String name = fileName ?? '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String imagePath = '${directory.path}/$name';
      
      // Copy the file to app's documents directory
      final File savedImage = await imageFile.copy(imagePath);
      return savedImage;
    } catch (e) {
      logger.e('Error saving image to app directory', e);
      return null;
    }
  }

  // Get image from network with caching
  static Widget getNetworkImage(
    String imageUrl, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    String? placeholder,
    Widget? errorWidget,
    bool isSvg = false,
  }) {
    if (imageUrl.isEmpty) {
      return _buildPlaceholder(width, height, fit, placeholder);
    }

    if (isSvg) {
      return SvgPicture.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholderBuilder: (_) => _buildPlaceholder(width, height, fit, placeholder),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => _buildPlaceholder(width, height, fit, placeholder),
      errorWidget: (context, url, error) => errorWidget ?? _buildErrorWidget(width, height, fit),
      memCacheWidth: width?.toInt(),
      memCacheHeight: height?.toInt(),
    );
  }

  // Get image from file
  static Widget getFileImage(
    String filePath, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    String? placeholder,
  }) {
    if (filePath.isEmpty) {
      return _buildPlaceholder(width, height, fit, placeholder);
    }

    final isSvg = filePath.toLowerCase().endsWith('.svg');
    
    if (isSvg) {
      return SvgPicture.asset(
        filePath,
        width: width,
        height: height,
        fit: fit,
        placeholderBuilder: (_) => _buildPlaceholder(width, height, fit, placeholder),
      );
    }

    return Image.file(
      File(filePath),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => _buildErrorWidget(width, height, fit),
    );
  }

  // Get image from asset
  static Widget getAssetImage(
    String assetPath, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    String? package,
    String? placeholder,
  }) {
    final isSvg = assetPath.toLowerCase().endsWith('.svg');
    
    if (isSvg) {
      return SvgPicture.asset(
        assetPath,
        width: width,
        height: height,
        fit: fit,
        package: package,
        placeholderBuilder: (_) => _buildPlaceholder(width, height, fit, placeholder),
      );
    }

    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      package: package,
      errorBuilder: (context, error, stackTrace) => _buildErrorWidget(width, height, fit),
    );
  }

  // Build placeholder widget
  static Widget _buildPlaceholder(
    double? width,
    double? height,
    BoxFit fit,
    String? placeholder,
  ) {
    if (placeholder != null) {
      return Image.asset(
        placeholder,
        width: width,
        height: height,
        fit: fit,
      );
    }
    
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.image, color: Colors.grey, size: 40),
      ),
    );
  }

  // Build error widget
  static Widget _buildErrorWidget(double? width, double? height, BoxFit fit) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
      ),
    );
  }

  // Get image file extension
  static String getImageExtension(String imagePath) {
    return path.extension(imagePath).toLowerCase().replaceAll('.', '');
  }

  // Check if image is SVG
  static bool isSvg(String imagePath) {
    return getImageExtension(imagePath) == 'svg';
  }

  // Convert image file to bytes
  Future<Uint8List?> imageFileToBytes(File imageFile) async {
    try {
      return await imageFile.readAsBytes();
    } catch (e) {
      logger.e('Error converting image file to bytes', e);
      return null;
    }
  }

  // Convert bytes to image file
  Future<File?> bytesToImageFile(Uint8List bytes, String fileName) async {
    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      logger.e('Error converting bytes to image file', e);
      return null;
    }
  }

  // Get image size
  static Future<Size> getImageSize(String imagePath) async {
    try {
      final File file = File(imagePath);
      if (!await file.exists()) {
        return Size.zero;
      }
      
      final Uint8List bytes = await file.readAsBytes();
      final image = await decodeImageFromList(bytes);
      return Size(image.width.toDouble(), image.height.toDouble());
    } catch (e) {
      logger.e('Error getting image size', e);
      return Size.zero;
    }
  }

  // Get image aspect ratio
  static Future<double> getImageAspectRatio(String imagePath) async {
    final size = await getImageSize(imagePath);
    if (size == Size.zero) return 1.0;
    return size.width / size.height;
  }

  // Create a circular image
  static Widget circularImage({
    required String imageUrl,
    required double radius,
    String? placeholder,
    bool isAsset = false,
    bool isFile = false,
    BoxFit fit = BoxFit.cover,
  }) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: isAsset
              ? AssetImage(imageUrl) as ImageProvider
              : isFile
                  ? FileImage(File(imageUrl)) as ImageProvider
                  : NetworkImage(imageUrl) as ImageProvider,
          fit: fit,
          onError: (exception, stackTrace) {
            logger.e('Error loading image: $exception');
          },
        ),
      ),
      child: imageUrl.isEmpty || (isFile && !File(imageUrl).existsSync())
          ? _buildPlaceholder(radius * 2, radius * 2, fit, placeholder)
          : null,
    );
  }
}
