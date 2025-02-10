import '../models/user_model.dart';
import '../services/database_service.dart';

class UserController {
  final UserService _databaseService = UserService.instance;

  Future<void> addUser(String name, String email, String password) async {
    String hashedPassword = User.hashPassword(password);
    User user = User(name: name, email: email, passwordHash: hashedPassword);
    await _databaseService.insertUser(user);
  }

  Future<bool> login(String email, String password) async {
    User? user = await _databaseService.getUserByEmail(email);
    if (user != null) {
      String hashedInputPassword = User.hashPassword(password);
      return user.passwordHash == hashedInputPassword;
    }
    return false;
  }
}
