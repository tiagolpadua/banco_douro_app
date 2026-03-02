import 'package:banco_douro_app/providers/account_provider.dart';
import 'package:banco_douro_app/utils/id_generator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/models/account.dart';
import '/ui/theme/app_colors.dart';

class AddAccountModal extends StatefulWidget {
  const AddAccountModal({super.key});

  @override
  State<AddAccountModal> createState() => _AddAccountModalState();
}

class _AddAccountModalState extends State<AddAccountModal> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedAccountTypeId;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AccountProvider>();
      if (provider.accountTypes.isEmpty && !provider.isLoadingAccountTypes) {
        provider.loadAccountTypes();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AccountProvider>();
    final accountTypes = provider.accountTypes;

    if (_selectedAccountTypeId == null && accountTypes.isNotEmpty) {
      _selectedAccountTypeId = accountTypes.first.id;
    }

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
        child: Form(
          key: _formKey,
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

              // Ícone com fundo gradiente
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

              // Título
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
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o nome';
                  }
                  return null;
                },
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
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Campo Último nome
              TextFormField(
                controller: _lastNameController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o ultimo nome';
                  }
                  return null;
                },
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
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Tipo da conta
              const Text(
                "Tipo da conta",
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 6),
              provider.isLoadingAccountTypes
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : accountTypes.isEmpty
                  ? const Text(
                      'Nenhum tipo de conta disponivel.',
                      style: TextStyle(color: AppColors.textSecondary),
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
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColors.textSecondary,
                        ),
                        items: accountTypes.map((type) {
                          return DropdownMenuItem(
                            value: type.id,
                            child: Text(
                              type.description,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                              ),
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

              // Botões
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
      if (!_formKey.currentState!.validate()) {
        return;
      }

      if (_selectedAccountTypeId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione um tipo de conta')),
        );
        return;
      }

      setState(() {
        isLoading = true;
      });

      final String name = _nameController.text.trim();
      final String lastName = _lastNameController.text.trim();

      final account = Account(
        id: IdGenerator.generate(),
        name: name,
        lastName: lastName,
        balance: 0,
        accountType: _selectedAccountTypeId,
      );

      try {
        await context.read<AccountProvider>().addAccount(account);
        closeModal();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao adicionar conta: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
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
