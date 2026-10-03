import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:imobi_app/domain/models/property.dart';
import 'package:imobi_app/ui/core/themes/app_colors.dart';
import 'package:imobi_app/ui/property_form/view_models/property_form.dart';
import 'package:imobi_app/utils/currency_input.dart';

/// The listing form screen shared by editing and creating. It owns the
/// fields, validation feedback and the back/discard flow; the screen using it
/// decides what saving means and where leaving goes.
class PropertyFormView extends StatefulWidget {
  const PropertyFormView({
    super.key,
    required this.screenTitle,
    required this.initial,
    required this.isSaving,
    required this.labels,
    required this.hasChanges,
    required this.onSave,
    required this.onLeave,
  });

  final String screenTitle;
  final PropertyForm initial;
  final bool isSaving;
  final PropertyFormLabels labels;

  /// Decides whether leaving needs the "Descartar alterações?" confirmation.
  final bool Function(PropertyForm form) hasChanges;

  /// Called with a valid form. Returns whether it saved; on success the
  /// screen has already moved on, on failure an error with retry is shown.
  final Future<bool> Function(PropertyForm form) onSave;

  /// "Cancelar" and a confirmed discard.
  final VoidCallback onLeave;

  @override
  State<PropertyFormView> createState() => _PropertyFormViewState();
}

/// Texts that differ between editing and creating.
class PropertyFormLabels {
  const PropertyFormLabels({
    required this.save,
    required this.saving,
    required this.saveError,
    required this.discardMessage,
  });

  final String save;
  final String saving;
  final String saveError;
  final String discardMessage;
}

class _PropertyFormViewState extends State<PropertyFormView> {
  final _formKey = GlobalKey<FormState>();

  late final _title = TextEditingController(text: widget.initial.title);
  late final _description = TextEditingController(
    text: widget.initial.description,
  );
  late final _price = TextEditingController(text: widget.initial.price);
  late final _city = TextEditingController(text: widget.initial.city);
  late final _neighborhood = TextEditingController(
    text: widget.initial.neighborhood,
  );
  late final _bedrooms = TextEditingController(text: widget.initial.bedrooms);
  late final _bathrooms = TextEditingController(text: widget.initial.bathrooms);
  late final _parkingSpaces = TextEditingController(
    text: widget.initial.parkingSpaces,
  );
  late final _area = TextEditingController(text: widget.initial.area);
  late PropertyType? _type = widget.initial.type;

  final _titleFocus = FocusNode();
  final _typeFocus = FocusNode();
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
      _typeFocus,
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
      (PropertyFormRules.validateTitle(_title.text), _titleFocus),
      (PropertyFormRules.validateType(_type), _typeFocus),
      (PropertyFormRules.validatePrice(_price.text), _priceFocus),
      (PropertyFormRules.validateCity(_city.text), _cityFocus),
      (
        PropertyFormRules.validateNeighborhood(_neighborhood.text),
        _neighborhoodFocus,
      ),
      (PropertyFormRules.validateArea(_area.text), _areaFocus),
    ];
    final invalidFocuses = [
      for (final (error, focus) in checks)
        if (error != null) focus,
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
    final messenger = ScaffoldMessenger.of(context);

    final saved = await widget.onSave(_currentForm());
    if (saved || !mounted) return;

    messenger.showSnackBar(
      SnackBar(
        content: Text(widget.labels.saveError),
        action: SnackBarAction(label: 'Atualizar', onPressed: _save),
      ),
    );
  }

  /// Back arrow and system back: leave directly when nothing changed,
  /// otherwise ask. "Cancelar" never reaches this.
  Future<void> _onBack(bool didPop, Object? result) async {
    if (didPop || widget.isSaving) return;
    if (!widget.hasChanges(_currentForm())) {
      context.pop();
      return;
    }
    final discard = await _confirmDiscard(
      context,
      widget.labels.discardMessage,
    );
    if (discard && mounted) widget.onLeave();
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = widget.isSaving;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _onBack,
      child: Scaffold(
        appBar: AppBar(title: Text(widget.screenTitle)),
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
                validator: PropertyFormRules.validateTitle,
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
                initialValue: _type,
                focusNode: _typeFocus,
                onChanged: (type) => setState(() => _type = type),
              ),
              const SizedBox(height: 16),
              _FormTextField(
                label: 'Preço',
                isRequired: true,
                controller: _price,
                focusNode: _priceFocus,
                validator: PropertyFormRules.validatePrice,
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
              ),
              const SizedBox(height: 16),
              _FormTextField(
                label: 'Cidade',
                isRequired: true,
                controller: _city,
                focusNode: _cityFocus,
                validator: PropertyFormRules.validateCity,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              _FormTextField(
                label: 'Bairro',
                isRequired: true,
                controller: _neighborhood,
                focusNode: _neighborhoodFocus,
                validator: PropertyFormRules.validateNeighborhood,
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
              // Unit in the label, not as a suffix: a suffix inside the
              // MergeSemantics of the field breaks the semantics tree once the
              // field has text (found by the widget test). The label is also
              // where WCAG 3.3.2 expects the expected format.
              _FormTextField(
                label: 'Área (m²)',
                isRequired: true,
                controller: _area,
                focusNode: _areaFocus,
                validator: PropertyFormRules.validateArea,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
                ],
                textInputAction: TextInputAction.done,
              ),
            ],
          ),
        ),
        bottomNavigationBar: _ActionsBar(
          isSaving: isSaving,
          saveLabel: widget.labels.save,
          savingLabel: widget.labels.saving,
          onCancel: widget.onLeave,
          onSave: _save,
        ),
      ),
    );
  }
}

const _errorBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(8)),
  borderSide: BorderSide(color: AppColors.danger, width: 2),
);

Future<bool> _confirmDiscard(BuildContext context, String message) async {
  final discard = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Descartar alterações?'),
      content: Text(message),
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
  final TextCapitalization textCapitalization;
  final TextInputAction textInputAction;
  final int? minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final validator = this.validator;
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
                  suffixIcon: error == null
                      ? null
                      : const Icon(
                          Icons.error_outline,
                          color: AppColors.danger,
                        ),
                  enabledBorder: error == null ? null : _errorBorder,
                  focusedBorder: error == null ? null : _errorBorder,
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

/// Starts empty when creating ("Selecione…"); errors look like the text
/// fields' errors.
class _TypeField extends StatelessWidget {
  const _TypeField({
    required this.initialValue,
    required this.focusNode,
    required this.onChanged,
  });

  final PropertyType? initialValue;
  final FocusNode focusNode;
  final ValueChanged<PropertyType> onChanged;

  @override
  Widget build(BuildContext context) {
    return FormField<PropertyType>(
      initialValue: initialValue,
      validator: PropertyFormRules.validateType,
      builder: (field) {
        final error = field.errorText;
        return MergeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _FieldLabel(label: 'Tipo', isRequired: true),
              DropdownButtonFormField<PropertyType>(
                initialValue: initialValue,
                focusNode: focusNode,
                isDense: true,
                hint: const Text('Selecione…'),
                decoration: InputDecoration(
                  enabledBorder: error == null ? null : _errorBorder,
                  focusedBorder: error == null ? null : _errorBorder,
                ),
                items: const [
                  DropdownMenuItem(
                    value: PropertyType.sale,
                    child: Text('Venda'),
                  ),
                  DropdownMenuItem(
                    value: PropertyType.rent,
                    child: Text('Aluguel'),
                  ),
                ],
                onChanged: (type) {
                  if (type == null) return;
                  field.didChange(type);
                  onChanged(type);
                },
              ),
              if (error != null) _ErrorLine(message: error),
            ],
          ),
        );
      },
    );
  }
}

class _ActionsBar extends StatelessWidget {
  const _ActionsBar({
    required this.isSaving,
    required this.saveLabel,
    required this.savingLabel,
    required this.onCancel,
    required this.onSave,
  });

  final bool isSaving;
  final String saveLabel;
  final String savingLabel;
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
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(savingLabel),
                        ],
                      )
                    : Text(saveLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
