import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/cliente.dart';
import '../service/viacep_service.dart';

class FormCliente extends StatefulWidget {
  final Cliente? cliente; // null = novo cadastro, preenchido = edição
  const FormCliente({super.key, this.cliente});

  @override
  State<FormCliente> createState() => _FormClienteState();
}

class _FormClienteState extends State<FormCliente> {
  final _formKey = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _telefone = TextEditingController();
  final _cep = TextEditingController();
  final _rua = TextEditingController();
  final _bairro = TextEditingController();
  final _cidade = TextEditingController();
  final _estado = TextEditingController();
  bool _buscando = false;

  @override
  void initState() {
    super.initState();
    final c = widget.cliente;
    if (c != null) {
      _nome.text = c.nome;
      _telefone.text = c.telefone;
      _cep.text = c.cep;
      _rua.text = c.rua;
      _bairro.text = c.bairro;
      _cidade.text = c.cidade;
      _estado.text = c.estado;
    }
  }

  Future<void> _buscarCep() async {
    setState(() => _buscando = true);
    try {
      final dados = await ViaCepService.buscar(_cep.text);
      if (!mounted) return;
      if (dados == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('CEP não encontrado')));
      } else {
        _rua.text = dados['logradouro'] ?? '';
        _bairro.text = dados['bairro'] ?? '';
        _cidade.text = dados['localidade'] ?? '';
        _estado.text = dados['uf'] ?? '';
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao consultar o CEP')),
        );
      }
    } finally {
      if (mounted) setState(() => _buscando = false);
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final cliente = Cliente(
      id: widget.cliente?.id,
      nome: _nome.text,
      telefone: _telefone.text,
      cep: _cep.text,
      rua: _rua.text,
      bairro: _bairro.text,
      cidade: _cidade.text,
      estado: _estado.text,
    );

    try {
      if (widget.cliente == null) {
        await DatabaseHelper.instance.inserir(cliente);
      } else {
        await DatabaseHelper.instance.atualizar(cliente);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint('ERRO AO SALVAR: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
      }
    }
  }

  String? _obrigatorio(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Campo obrigatório' : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cliente == null ? 'Novo cliente' : 'Editar cliente'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nome,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: _obrigatorio,
              ),
              TextFormField(
                controller: _telefone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Telefone'),
                validator: _obrigatorio,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cep,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'CEP (8 dígitos)',
                      ),
                      validator: _obrigatorio,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _buscando ? null : _buscarCep,
                    child: _buscando
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Buscar'),
                  ),
                ],
              ),
              TextFormField(
                controller: _rua,
                decoration: const InputDecoration(labelText: 'Rua'),
              ),
              TextFormField(
                controller: _bairro,
                decoration: const InputDecoration(labelText: 'Bairro'),
              ),
              TextFormField(
                controller: _cidade,
                decoration: const InputDecoration(labelText: 'Cidade'),
              ),
              TextFormField(
                controller: _estado,
                decoration: const InputDecoration(labelText: 'Estado (UF)'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _salvar, child: const Text('Salvar')),
            ],
          ),
        ),
      ),
    );
  }
}
