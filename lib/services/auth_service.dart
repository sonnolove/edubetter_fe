import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Đăng nhập bằng Email/Pass
  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e.code));
    }
  }

  // Đăng ký tài khoản mới
  Future<UserCredential> signUp(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e.code));
    }
  }

  // Đăng xuất
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Xử lý thông báo lỗi tiếng Việt cho thân thiện
  String _handleAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Không tìm thấy tài khoản này.';
      case 'wrong-password':
        return 'Sai mật khẩu.';
      case 'email-already-in-use':
        return 'Email này đã được đăng ký rồi.';
      case 'weak-password':
        return 'Mật khẩu quá yếu (cần ít nhất 6 ký tự).';
      case 'invalid-email':
        return 'Email không hợp lệ.';
      default:
        return 'Lỗi xác thực: $code';
    }
  }
}