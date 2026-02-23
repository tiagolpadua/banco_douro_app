import 'package:banco_douro_app/models/account_type.dart';
import 'package:banco_douro_app/services/account_type_service.dart';
import 'package:banco_douro_app/utils/id_generator.dart';
import 'package:flutter/material.dart';
import '/models/account.dart';
import '/services/account_service.dart';
import '/ui/theme/app_colors.dart';

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
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 32,
        right: 32,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle indicator
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Icone com gradiente
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryLight],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.person_add_outlined,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Titulo
            const Text(
              "Adicionar nova conta",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 22,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Preencha os dados abaixo:",
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),

            // Campo Nome
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Nome",
                prefixIcon: const Icon(
                  Icons.person_outline,
                  color: AppColors.textSecondary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Campo Ultimo nome
            TextFormField(
              controller: _lastNameController,
              decoration: InputDecoration(
                labelText: "Último nome",
                prefixIcon: const Icon(
                  Icons.person_outline,
                  color: AppColors.textSecondary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Tipo da conta
            const Text(
              "Tipo da conta",
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            _isLoadingTypes
                ? const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.primary),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedAccountTypeId,
                      isExpanded: true,
                      underline: const SizedBox(),
                      icon: const Icon(Icons.keyboard_arrow_down,
                          color: AppColors.textSecondary),
                      items: _accountTypes.map((type) {
                        return DropdownMenuItem(
                          value: type.id,
                          child: Text(
                            type.description,
                            style: const TextStyle(
                                color: AppColors.textPrimary),
                          ),
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
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: isLoading ? null : onButtonCancelClicked,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Cancelar",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : onButtonSendClicked,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              "Adicionar",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
