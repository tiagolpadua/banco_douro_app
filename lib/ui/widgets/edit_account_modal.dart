import 'package:flutter/material.dart';
import '../../models/account.dart';
import '../../models/account_type.dart';
import '../../services/account_service.dart';
import '../../services/account_type_service.dart';
import '../../exceptions/api_exceptions.dart';
import '../styles/colors.dart';
import 'exception_dialog.dart';

class EditAccountModal extends StatefulWidget {
  final Account account;
  final VoidCallback? onSaved;

  const EditAccountModal({
    super.key,
    required this.account,
    this.onSaved,
  });

  @override
  State<EditAccountModal> createState() => _EditAccountModalState();
}

class _EditAccountModalState extends State<EditAccountModal> {
  String? _selectedAccountTypeId;
  List<AccountType> _accountTypes = [];
  bool _isLoadingTypes = true;

  late final TextEditingController _nameController;
  late final TextEditingController _lastNameController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account.name);
    _lastNameController = TextEditingController(text: widget.account.lastName);
    _selectedAccountTypeId = widget.account.accountType;
    _loadAccountTypes();
  }

  Future<void> _loadAccountTypes() async {
    try {
      final types = await AccountTypeService().getAll();
      setState(() {
        _accountTypes = types;
        if (_selectedAccountTypeId == null && types.isNotEmpty) {
          _selectedAccountTypeId = types.first.id;
        }
        _isLoadingTypes = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingTypes = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: EdgeInsets.only(
        left: 32,
        right: 32,
        top: 32,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Center(
              child: Icon(
                Icons.edit,
                size: 64,
                color: AppColor.orange,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              "Editar conta",
              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 24),
            ),
            const SizedBox(height: 16),
            const Text(
              "Altere os dados abaixo:",
              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
            ),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(label: Text("Nome")),
            ),
            TextFormField(
              controller: _lastNameController,
              decoration: const InputDecoration(label: Text("Último nome")),
            ),
            const SizedBox(height: 16),
            const Text("Tipo da conta"),
            _isLoadingTypes
                ? const Center(child: CircularProgressIndicator())
                : DropdownButton<String>(
                    value: _selectedAccountTypeId,
                    isExpanded: true,
                    items: _accountTypes.map((type) {
                      return DropdownMenuItem(
                        value: type.id,
                        child: Text(type.description),
                      );
                    }).toList(),
                    onChanged: (valor) {
                      if (valor != null) {
                        setState(() {
                          _selectedAccountTypeId = valor;
                        });
                      }
                    },
                  ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onCancelPressed,
                    child: const Text(
                      "Cancelar",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onSavePressed,
                    style: const ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(AppColor.orange),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Salvar",
                            style: TextStyle(color: Colors.black),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onCancelPressed() {
    Navigator.pop(context);
  }

  Future<void> _onSavePressed() async {
    setState(() => _isLoading = true);

    final updatedAccount = widget.account.copyWith(
      name: _nameController.text,
      lastName: _lastNameController.text,
      accountType: _selectedAccountTypeId,
    );

    try {
      final success = await AccountService().updateAccount(updatedAccount);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Conta atualizada com sucesso!')),
          );
          widget.onSaved?.call();
          Navigator.pop(context);
        } else {
          showExceptionDialog(context, content: 'Falha ao atualizar conta.');
        }
      }
    } on TokenExpiredException {
      if (mounted) {
        showExceptionDialog(
          context,
          title: 'Sessão expirada',
          content: 'Por favor, faça login novamente.',
        );
        Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
      }
    } on ServerException catch (e) {
      if (mounted) {
        showExceptionDialog(context, content: e.message);
      }
    } catch (e) {
      if (mounted) {
        showExceptionDialog(
          context,
          content: 'Erro ao atualizar conta. Tente novamente.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }
}
