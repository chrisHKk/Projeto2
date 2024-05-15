// Controle de Acesso

import 'user.dart';

class AccessControl {
  static bool canEditReservation(User user) {
    return user.role == UserRole.funcionario;
  }

  static bool canViewReservation(User user) {
    return user.role == UserRole.funcionario || user.role == UserRole.leitor;
  }
}
