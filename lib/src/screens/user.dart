// Definições de Usuário

enum UserRole {
  funcionario, // Pode cadastrar, consultar e excluir reservas
  leitor,      // Pode apenas ler e consultar reservas
}

class User {
  String id;
  String nome;
  UserRole role;

  User({required this.id, required this.nome, required this.role});
}
