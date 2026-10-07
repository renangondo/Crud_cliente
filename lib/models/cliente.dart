class Cliente {
  int? id;
  String nome;
  String telefone;
  String cep;
  String rua;
  String bairro;
  String cidade;
  String estado;

  Cliente({
    this.id,
    required this.nome,
    required this.telefone,
    required this.cep,
    required this.rua,
    required this.bairro,
    required this.cidade,
    required this.estado,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'nome': nome,
        'telefone': telefone,
        'cep': cep,
        'rua': rua,
        'bairro': bairro,
        'cidade': cidade,
        'estado': estado,
      };

  factory Cliente.fromMap(Map<String, dynamic> m) => Cliente(
        id: m['id'] as int?,
        nome: m['nome'],
        telefone: m['telefone'],
        cep: m['cep'],
        rua: m['rua'],
        bairro: m['bairro'],
        cidade: m['cidade'],
        estado: m['estado'],
      );
}