import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class FirebaseStorageService {
  static Future<String> uploadAvatar(XFile image, String uid) async {
    final storageRef = FirebaseStorage.instance
        .ref('avatars')
        .child('$uid.jpg');

    await storageRef.putData(await image.readAsBytes());
    return await storageRef.getDownloadURL();
  }
}