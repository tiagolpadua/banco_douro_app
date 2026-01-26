import 'package:banco_douro_app/models/account_type.dart';
import 'package:banco_douro_app/services/account_type_service.dart';
import 'package:flutter/material.dart';
import '/models/account.dart';
import '/services/account_service.dart';
import '/ui/styles/colors.dart';
import 'package:uuid/uuid.dart';

class AddAccountModal extends StatefulWidget {
  const AddAccountModal({super.key});

  @override
  State<AddAccountModal> createState() => _AddAccountModalState();
}

class _AddAccountModalState extends State<AddAccountModal> {
  String? _selectedAccountTypeId;
  List<AccountType> _accountTypes = [];
  bool _isLoadingTypes = true;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAccountTypes();
  }

  Future<void> _loadAccountTypes() async {
    try {
      final types = await AccountTypeService().getAll();
      setState(() {
        _accountTypes = types;
        if (types.isNotEmpty) {
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
              child: Image.asset(
                "assets/images/icon_add_account.png",
                width: 64,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              "Adicionar nova conta",
              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 24),
            ),
            const SizedBox(height: 16),
            const Text(
              "Preencha os dados abaixo:",
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
                    onPressed: (isLoading)
                        ? null
                        : () {
                            onButtonCancelClicked();
                          },
                    child: const Text(
                      "Cancelar",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      onButtonSendClicked();
                    },
                    style: const ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(AppColor.orange),
                    ),
                    child: (isLoading)
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Adicionar",
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

  void onButtonCancelClicked() {
    if (!isLoading) {
      Navigator.pop(context);
    }
  }

  Future<void> onButtonSendClicked() async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });

      String name = _nameController.text;
      String lastName = _lastNameController.text;

      Account account = Account(
        id: const Uuid().v1(),
        name: name,
        lastName: lastName,
        balance: 0,
        accountType: _selectedAccountTypeId,
      );

      await AccountService().addAccount(account);

      closeModal();
    }
  }

  void closeModal() {
    Navigator.pop(context);
  }

  @override
  dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }
}
