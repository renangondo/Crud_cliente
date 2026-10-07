import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/cliente.dart';
import 'form_cliente.dart';

class ListaClientes extends StatefulWidget {
  const ListaClientes({super.key});

  @override
  State<ListaClientes> createState() => _ListaClientesState();
}

class _ListaClientesState extends State<ListaClientes> {
  List<Cliente> _clientes = [];

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final lista = await DatabaseHelper.instance.listar();
    debugPrint(lista.map((c) => c.toMap()).toList().toString());
    setState(() => _clientes = lista);
  }

  Future<void> _abrirForm([Cliente? cliente]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FormCliente(cliente: cliente)),
    );
    _carregar(); // atualiza a lista ao voltar
  }

  Future<void> _excluir(Cliente c) async {
    await DatabaseHelper.instance.excluir(c.id!);
    _carregar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clientes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirForm(),
        child: const Icon(Icons.add),
      ),
      body: _clientes.isEmpty
          ? const Center(child: Text('Nenhum cliente cadastrado'))
          : ListView.builder(
              itemCount: _clientes.length,
              itemBuilder: (context, i) {
                final c = _clientes[i];
                return ListTile(
                  title: Text(c.nome),
                  subtitle: Text(
                    '${c.rua}, ${c.bairro}\n${c.cidade} - ${c.estado}',
                  ),
                  isThreeLine: true,
                  onTap: () => _abrirForm(c),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _excluir(c),
                  ),
                );
              },
            ),
    );
  }
}
