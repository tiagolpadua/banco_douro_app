import 'package:banco_douro_app/models/account_type.dart';
import 'package:banco_douro_app/services/account_type_service.dart';
import 'package:banco_douro_app/utils/id_generator.dart';
import 'package:flutter/material.dart';
import '../../models/account.dart';
import '../../services/account_service.dart';
import '../theme/app_colors.dart';

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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: EdgeInsets.only(
        left: 32,
        right: 32,
        top: 12,
        bottom: bottomInset + 16,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar do modal
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Icone com BoxDecoration
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Image.asset(
                    "assets/images/icon_add_account.png",
                    width: 40,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Titulo estilizado
              const Text(
                "Adicionar nova conta",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 22,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Preencha os dados abaixo para criar uma nova conta bancaria.",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Campo Nome
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Nome",
                  prefixIcon: Icon(
                    Icons.person_outline,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Campo Sobrenome
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: "Sobrenome",
                  prefixIcon: Icon(
                    Icons.person_outline,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Tipo da conta
              const Text(
                "Tipo da conta",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              _isLoadingTypes
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedAccountTypeId,
                        isExpanded: true,
                        underline: const SizedBox(),
                        borderRadius: BorderRadius.circular(12),
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
                    ),
              const SizedBox(height: 32),

              // Botoes
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isLoading ? null : onButtonCancelClicked,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Cancelar",
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading ? null : onButtonSendClicked,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Adicionar",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
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
        id: IdGenerator.generate(),
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
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }
}
