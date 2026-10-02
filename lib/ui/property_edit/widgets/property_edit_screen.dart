import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:imobi_app/domain/models/property.dart';
import 'package:imobi_app/routing/router.dart';
import 'package:imobi_app/ui/core/themes/app_colors.dart';
import 'package:imobi_app/ui/core/ui/state_message.dart';
import 'package:imobi_app/ui/property_edit/view_models/property_edit_view_model.dart';
import 'package:imobi_app/utils/currency_input.dart';
import 'package:provider/provider.dart';

class PropertyEditScreen extends StatelessWidget {
  const PropertyEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PropertyEditViewModel>();
    final original = viewModel.original;

    if (viewModel.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editar imóvel')),
        body: const StateMessage.loading(message: 'Carregando imóvel…'),
      );
    }
    if (original == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editar imóvel')),
        body: StateMessage(
          icon: Icons.home_work_outlined,
          message: 'Este imóvel não está mais disponível.',
          hint: 'Ele pode ter sido removido ou o link está desatualizado.',
          action: FilledButton(
            onPressed: () => context.go(Routes.home),
            child: const Text('Voltar para a lista'),
          ),
        ),
      );
    }
    return _EditForm(original: original);
  }
}

class _EditForm extends StatefulWidget {
  const _EditForm({required this.original});

  final Property original;

  @override
  State<_EditForm> createState() => _EditFormState();
}

class _EditFormState extends State<_EditForm> {
  final _formKey = GlobalKey<FormState>();
  late final _draft = PropertyForm.fromProperty(widget.original);

  late final _title = TextEditingController(text: _draft.title);
  late final _description = TextEditingController(text: _draft.description);
  late final _price = TextEditingController(text: _draft.price);
  late final _city = TextEditingController(text: _draft.city);
  late final _neighborhood = TextEditingController(text: _draft.neighborhood);
  late final _bedrooms = TextEditingController(text: _draft.bedrooms);
  late final _bathrooms = TextEditingController(text: _draft.bathrooms);
  late final _parkingSpaces = TextEditingController(text: _draft.parkingSpaces);
  late final _area = TextEditingController(text: _draft.area);
  late PropertyType _type = _draft.type;

  final _titleFocus = FocusNode();
  final _priceFocus = FocusNode();
  final _cityFocus = FocusNode();
  final _neighborhoodFocus = FocusNode();
  final _areaFocus = FocusNode();

  @override
  void dispose() {
    for (final controller in [
      _title,
      _description,
      _price,
      _city,
      _neighborhood,
      _bedrooms,
      _bathrooms,
      _parkingSpaces,
      _area,
    ]) {
      controller.dispose();
    }
    for (final focus in [
      _titleFocus,
      _priceFocus,
      _cityFocus,
      _neighborhoodFocus,
      _areaFocus,
    ]) {
      focus.dispose();
    }
    super.dispose();
  }

  PropertyForm _currentForm() => PropertyForm(
    title: _title.text,
    description: _description.text,
    type: _type,
    price: _price.text,
    city: _city.text,
    neighborhood: _neighborhood.text,
    bedrooms: _bedrooms.text,
    bathrooms: _bathrooms.text,
    parkingSpaces: _parkingSpaces.text,
    area: _area.text,
  );

  /// Moves the cursor (and the scroll) to the first field with an error and
  /// says how many need fixing. The snack bar is also read by screen readers,
  /// for whom the red borders say nothing.
  void _showInvalidFields() {
    final checks = [
      (_title, PropertyEditViewModel.validateTitle, _titleFocus),
      (_price, PropertyEditViewModel.validatePrice, _priceFocus),
      (_city, PropertyEditViewModel.validateCity, _cityFocus),
      (
        _neighborhood,
        PropertyEditViewModel.validateNeighborhood,
        _neighborhoodFocus,
      ),
      (_area, PropertyEditViewModel.validateArea, _areaFocus),
    ];
    final invalidFocuses = [
      for (final (controller, validate, focus) in checks)
        if (validate(controller.text) != null) focus,
    ];
    if (invalidFocuses.isEmpty) return;

    invalidFocuses.first.requestFocus();
    final count = invalidFocuses.length;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          count == 1
              ? 'Corrija o campo destacado para salvar.'
              : 'Corrija os $count campos destacados para salvar.',
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      _showInvalidFields();
      return;
    }
    final viewModel = context.read<PropertyEditViewModel>();
    final messenger = ScaffoldMessenger.of(context);

    final saved = await viewModel.save(_currentForm());
    if (!mounted) return;

    if (saved) {
      context.go(Routes.property(widget.original.id));
      messenger.showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_outline, color: AppColors.brand50),
              SizedBox(width: 8),
              Text('Imóvel atualizado'),
            ],
          ),
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Não foi possível salvar agora.'),
          action: SnackBarAction(label: 'Atualizar', onPressed: _save),
        ),
      );
    }
  }

  /// Back arrow and system back: leave directly when nothing changed,
  /// otherwise ask. "Cancelar" uses `go` and never reaches this.
  Future<void> _onBack(bool didPop, Object? result) async {
    final viewModel = context.read<PropertyEditViewModel>();
    if (didPop || viewModel.isSaving) return;
    if (!viewModel.hasChanges(_currentForm())) {
      context.pop();
      return;
    }
    final discard = await _confirmDiscard(context);
    if (discard && mounted) context.go(Routes.property(widget.original.id));
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<PropertyEditViewModel>().isSaving;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _onBack,
      child: Scaffold(
        appBar: AppBar(title: const Text('Editar imóvel')),
        body: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUnfocus,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _FormTextField(
                label: 'Título',
                isRequired: true,
                controller: _title,
                focusNode: _titleFocus,
                validator: PropertyEditViewModel.validateTitle,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              _FormTextField(
                label: 'Descrição',
                controller: _description,
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                minLines: 2,
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              _TypeField(
                value: _type,
                onChanged: (type) => setState(() => _type = type),
              ),
              const SizedBox(height: 16),
              _FormTextField(
                label: 'Preço',
                isRequired: true,
                controller: _price,
                focusNode: _priceFocus,
                validator: PropertyEditViewModel.validatePrice,
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
              ),
              const SizedBox(height: 16),
              _FormTextField(
                label: 'Cidade',
                isRequired: true,
                controller: _city,
                focusNode: _cityFocus,
                validator: PropertyEditViewModel.validateCity,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              _FormTextField(
                label: 'Bairro',
                isRequired: true,
                controller: _neighborhood,
                focusNode: _neighborhoodFocus,
                validator: PropertyEditViewModel.validateNeighborhood,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              // Short counts that never show errors: side by side is safe.
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _CountField(label: 'Quartos', controller: _bedrooms),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _CountField(
                      label: 'Banheiros',
                      controller: _bathrooms,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _CountField(
                      label: 'Vagas',
                      controller: _parkingSpaces,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _FormTextField(
                label: 'Área',
                isRequired: true,
                controller: _area,
                focusNode: _areaFocus,
                validator: PropertyEditViewModel.validateArea,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
                ],
                suffixText: 'm²',
                textInputAction: TextInputAction.done,
              ),
            ],
          ),
        ),
        bottomNavigationBar: _ActionsBar(
          isSaving: isSaving,
          onCancel: () => context.go(Routes.property(widget.original.id)),
          onSave: _save,
        ),
      ),
    );
  }
}

Future<bool> _confirmDiscard(BuildContext context) async {
  final discard = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Descartar alterações?'),
      content: const Text(
        'As mudanças feitas neste imóvel ainda não foram salvas.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Editar'),
        ),
        // Destructive action: red outline and icon, dark text (contrast).
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).pop(true),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.text,
            side: const BorderSide(color: AppColors.danger),
          ),
          icon: const Icon(Icons.delete_outline, color: AppColors.danger),
          label: const Text('Descartar'),
        ),
      ],
    ),
  );
  return discard ?? false;
}

/// Label above the box, error shown as red border + ⚠ icon + dark message
/// (contrast decision 1 in the imobibrasil-design skill).
class _FormTextField extends StatelessWidget {
  const _FormTextField({
    required this.label,
    required this.controller,
    this.isRequired = false,
    this.focusNode,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.suffixText,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction = TextInputAction.next,
    this.minLines,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final bool isRequired;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? suffixText;
  final TextCapitalization textCapitalization;
  final TextInputAction textInputAction;
  final int? minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final validator = this.validator;
    const errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(color: AppColors.danger, width: 2),
    );

    return FormField<String>(
      initialValue: controller.text,
      validator: validator == null ? null : (_) => validator(controller.text),
      builder: (field) {
        final error = field.errorText;
        return MergeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FieldLabel(label: label, isRequired: isRequired),
              TextField(
                controller: controller,
                focusNode: focusNode,
                onChanged: field.didChange,
                keyboardType: keyboardType,
                inputFormatters: inputFormatters,
                textCapitalization: textCapitalization,
                textInputAction: textInputAction,
                minLines: minLines,
                maxLines: maxLines,
                decoration: InputDecoration(
                  isDense: true,
                  suffixText: suffixText,
                  suffixIcon: error == null
                      ? null
                      : const Icon(
                          Icons.error_outline,
                          color: AppColors.danger,
                        ),
                  enabledBorder: error == null ? null : errorBorder,
                  focusedBorder: error == null ? null : errorBorder,
                ),
              ),
              if (error != null) _ErrorLine(message: error),
            ],
          ),
        );
      },
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, this.isRequired = false});

  final String label;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        isRequired ? '$label *' : label,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _ErrorLine extends StatelessWidget {
  const _ErrorLine({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, size: 16, color: AppColors.danger),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountField extends StatelessWidget {
  const _CountField({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return _FormTextField(
      label: label,
      controller: controller,
      keyboardType: TextInputType.number,
      // Digits only, at most 2: invalid counts cannot be typed (H5).
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(2),
      ],
    );
  }
}

class _TypeField extends StatelessWidget {
  const _TypeField({required this.value, required this.onChanged});

  final PropertyType value;
  final ValueChanged<PropertyType> onChanged;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FieldLabel(label: 'Tipo', isRequired: true),
          DropdownButtonFormField<PropertyType>(
            initialValue: value,
            isDense: true,
            items: const [
              DropdownMenuItem(value: PropertyType.sale, child: Text('Venda')),
              DropdownMenuItem(
                value: PropertyType.rent,
                child: Text('Aluguel'),
              ),
            ],
            onChanged: (type) {
              if (type != null) onChanged(type);
            },
          ),
        ],
      ),
    );
  }
}

class _ActionsBar extends StatelessWidget {
  const _ActionsBar({
    required this.isSaving,
    required this.onCancel,
    required this.onSave,
  });

  final bool isSaving;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: isSaving ? null : onCancel,
                child: const Text('Cancelar'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: isSaving ? null : onSave,
                child: isSaving
                    ? const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text('Salvando…'),
                        ],
                      )
                    : const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
