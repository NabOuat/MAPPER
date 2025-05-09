import 'package:flutter/material.dart';

class CountryCode {
  final String name;
  final String dialCode;
  final String code;

  const CountryCode({
    required this.name,
    required this.dialCode,
    required this.code,
  });
}

class CountryCodeSelector extends StatefulWidget {
  final Function(CountryCode) onChanged;
  final String initialSelection;
  final List<String> favorites;

  const CountryCodeSelector({
    super.key,
    required this.onChanged,
    this.initialSelection = 'FR',
    this.favorites = const ['FR', 'US', 'CA'],
  });

  @override
  State<CountryCodeSelector> createState() => _CountryCodeSelectorState();
}

class _CountryCodeSelectorState extends State<CountryCodeSelector> {
  late CountryCode _selectedCountry;
  
  // Liste simplifiée des pays les plus courants
  final List<CountryCode> _countries = const [
    CountryCode(name: 'France', dialCode: '+33', code: 'FR'),
    CountryCode(name: 'États-Unis', dialCode: '+1', code: 'US'),
    CountryCode(name: 'Canada', dialCode: '+1', code: 'CA'),
    CountryCode(name: 'Royaume-Uni', dialCode: '+44', code: 'GB'),
    CountryCode(name: 'Allemagne', dialCode: '+49', code: 'DE'),
    CountryCode(name: 'Espagne', dialCode: '+34', code: 'ES'),
    CountryCode(name: 'Italie', dialCode: '+39', code: 'IT'),
    CountryCode(name: 'Belgique', dialCode: '+32', code: 'BE'),
    CountryCode(name: 'Suisse', dialCode: '+41', code: 'CH'),
    CountryCode(name: 'Maroc', dialCode: '+212', code: 'MA'),
    CountryCode(name: 'Algérie', dialCode: '+213', code: 'DZ'),
    CountryCode(name: 'Tunisie', dialCode: '+216', code: 'TN'),
    CountryCode(name: 'Sénégal', dialCode: '+221', code: 'SN'),
    CountryCode(name: 'Côte d\'Ivoire', dialCode: '+225', code: 'CI'),
    CountryCode(name: 'Cameroun', dialCode: '+237', code: 'CM'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedCountry = _findCountryByCode(widget.initialSelection);
  }

  CountryCode _findCountryByCode(String code) {
    return _countries.firstWhere(
      (country) => country.code == code,
      orElse: () => _countries.first,
    );
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Text(
                        'Sélectionner un pays',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                if (widget.favorites.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Favoris',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  ...widget.favorites.map((code) {
                    final country = _findCountryByCode(code);
                    return _buildCountryTile(country);
                  }),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Tous les pays',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ],
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: _countries.length,
                    itemBuilder: (context, index) {
                      final country = _countries[index];
                      if (widget.favorites.contains(country.code)) {
                        return const SizedBox.shrink();
                      }
                      return _buildCountryTile(country);
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCountryTile(CountryCode country) {
    return ListTile(
      title: Text(country.name),
      trailing: Text(country.dialCode),
      onTap: () {
        setState(() {
          _selectedCountry = country;
        });
        widget.onChanged(country);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _showCountryPicker,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _selectedCountry.dialCode,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.arrow_drop_down,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
