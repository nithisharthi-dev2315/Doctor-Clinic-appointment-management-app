import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'OtpVerifyPage.dart';

class MobileNumberPage extends StatefulWidget {
  const MobileNumberPage({super.key});

  @override
  State<MobileNumberPage> createState() => _MobileNumberPageState();
}

class _MobileNumberPageState extends State<MobileNumberPage> {
  final TextEditingController phoneController = TextEditingController();
  final FocusNode phoneFocusNode = FocusNode();

  final Map<String, List<int>> countryMobileLengthRange = {
    '+1': [10, 10],      // USA/Canada
    '+91': [10, 10],     // India
    '+44': [10, 10],     // UK
    '+61': [9, 9],       // Australia
    '+49': [10, 12],     // Germany
    '+33': [9, 9],       // France
    '+81': [10, 10],     // Japan
    '+82': [9, 10],      // South Korea
    '+86': [11, 11],     // China
    '+65': [8, 8],       // Singapore
    '+60': [9, 10],      // Malaysia
    '+63': [10, 10],     // Philippines
    '+66': [9, 9],       // Thailand
    '+971': [9, 9],      // UAE
    '+92': [10, 10],     // Pakistan
    '+880': [10, 10],    // Bangladesh
    '+94': [9, 9],       // Sri Lanka
    '+20': [10, 10],     // Egypt
    '+27': [9, 9],       // South Africa
    '+34': [9, 9],       // Spain
    '+39': [9, 10],      // Italy
    '+7': [10, 10],      // Russia
    '+55': [10, 11],     // Brazil
    '+52': [10, 10],     // Mexico
    '+90': [10, 10],     // Turkey
    '+62': [9, 12],      // Indonesia
    '+98': [10, 10],     // Iran
    '+966': [9, 9],      // Saudi Arabia
    '+93': [9, 9],       // Afghanistan
    '+213': [9, 9],      // Algeria
    '+376': [6, 6],      // Andorra
    '+244': [9, 9],      // Angola
    '+54': [10, 10],     // Argentina
    '+374': [8, 8],      // Armenia
    '+43': [10, 13],     // Austria
    '+994': [9, 9],      // Azerbaijan
    '+973': [8, 8],      // Bahrain
    '+375': [9, 9],      // Belarus
    '+32': [9, 9],       // Belgium
    '+501': [7, 7],      // Belize
    '+229': [8, 8],      // Benin
    '+975': [8, 8],      // Bhutan
    '+591': [8, 8],      // Bolivia
    '+387': [8, 8],      // Bosnia and Herzegovina
    '+267': [7, 8],      // Botswana
    '+673': [7, 7],      // Brunei
    '+359': [9, 9],      // Bulgaria
    '+226': [8, 8],      // Burkina Faso
    '+257': [8, 8],      // Burundi
    '+855': [8, 9],      // Cambodia
    '+237': [9, 9],      // Cameroon
    '+238': [7, 7],      // Cape Verde
    '+236': [8, 8],      // Central African Republic
    '+235': [8, 8],      // Chad
    '+56': [9, 9],       // Chile
    '+57': [10, 10],     // Colombia
    '+269': [7, 7],      // Comoros
    '+242': [9, 9],      // Congo
    '+506': [8, 8],      // Costa Rica
    '+385': [9, 9],      // Croatia
    '+53': [8, 8],       // Cuba
    '+357': [8, 8],      // Cyprus
    '+420': [9, 9],      // Czech Republic
    '+243': [9, 9],      // Democratic Republic of the Congo
    '+45': [8, 8],       // Denmark
    '+253': [8, 8],      // Djibouti
    '+1767': [7, 7],     // Dominica
    '+1809': [10, 10],   // Dominican Republic
    '+1829': [10, 10],   // Dominican Republic
    '+1849': [10, 10],   // Dominican Republic
    '+593': [9, 9],      // Ecuador
    '+503': [8, 8],      // El Salvador
    '+240': [9, 9],      // Equatorial Guinea
    '+291': [7, 7],      // Eritrea
    '+372': [7, 8],      // Estonia
    '+251': [9, 9],      // Ethiopia
    '+679': [7, 7],      // Fiji
    '+358': [9, 10],     // Finland
    '+241': [7, 7],      // Gabon
    '+220': [7, 7],      // Gambia
    '+995': [9, 9],      // Georgia
    '+233': [9, 9],      // Ghana
    '+350': [8, 8],      // Gibraltar
    '+30': [10, 10],     // Greece
    '+299': [6, 6],      // Greenland
    '+1473': [10, 10],   // Grenada
    '+590': [9, 9],      // Guadeloupe
    '+1671': [10, 10],   // Guam
    '+502': [8, 8],      // Guatemala
    '+224': [9, 9],      // Guinea
    '+245': [7, 7],      // Guinea-Bissau
    '+592': [7, 7],      // Guyana
    '+509': [8, 8],      // Haiti
    '+504': [8, 8],      // Honduras
    '+852': [8, 8],      // Hong Kong
    '+36': [9, 9],       // Hungary
    '+354': [7, 7],      // Iceland
    '+964': [10, 10],    // Iraq
    '+353': [9, 9],      // Ireland
    '+972': [9, 9],      // Israel
    '+225': [10, 10],    // Ivory Coast
    '+1876': [10, 10],   // Jamaica
    '+962': [9, 9],      // Jordan
    '+254': [9, 9],      // Kenya
    '+686': [5, 8],      // Kiribati
    '+383': [8, 8],      // Kosovo
    '+965': [8, 8],      // Kuwait
    '+996': [9, 9],      // Kyrgyzstan
    '+856': [8, 10],     // Laos
    '+961': [7, 8],      // Lebanon
    '+266': [8, 8],      // Lesotho
    '+231': [7, 8],      // Liberia
    '+218': [9, 10],     // Libya
    '+423': [7, 9],      // Liechtenstein
    '+370': [8, 8],      // Lithuania
    '+352': [9, 9],      // Luxembourg
    '+853': [8, 8],      // Macau
    '+389': [8, 8],      // Macedonia
    '+261': [9, 9],      // Madagascar
    '+265': [9, 9],      // Malawi
    '+960': [7, 7],      // Maldives
    '+223': [8, 8],      // Mali
    '+356': [8, 8],      // Malta
    '+692': [7, 7],      // Marshall Islands
    '+222': [8, 8],      // Mauritania
    '+230': [7, 8],      // Mauritius
    '+262': [9, 9],      // Mayotte
    '+691': [7, 7],      // Micronesia
    '+373': [8, 8],      // Moldova
    '+377': [8, 9],      // Monaco
    '+976': [8, 8],      // Mongolia
    '+382': [8, 8],      // Montenegro
    '+212': [9, 9],      // Morocco
    '+258': [9, 9],      // Mozambique
    '+95': [8, 10],      // Myanmar
    '+264': [9, 9],      // Namibia
    '+674': [7, 7],      // Nauru
    '+977': [10, 10],    // Nepal
    '+31': [9, 9],       // Netherlands
    '+687': [6, 6],      // New Caledonia
    '+64': [9, 10],      // New Zealand
    '+505': [8, 8],      // Nicaragua
    '+227': [8, 8],      // Niger
    '+234': [10, 10],    // Nigeria
    '+683': [4, 4],      // Niue
    '+850': [9, 11],     // North Korea
    '+1670': [10, 10],   // Northern Mariana Islands
    '+47': [8, 8],       // Norway
    '+968': [8, 8],      // Oman
    '+680': [7, 7],      // Palau
    '+970': [9, 9],      // Palestine
    '+507': [8, 8],      // Panama
    '+675': [8, 8],      // Papua New Guinea
    '+595': [9, 9],      // Paraguay
    '+51': [9, 9],       // Peru
    '+48': [9, 9],       // Poland
    '+351': [9, 9],      // Portugal
    '+974': [8, 8],      // Qatar
    '+40': [10, 10],     // Romania
    '+250': [9, 9],      // Rwanda
    '+290': [4, 4],      // Saint Helena
    '+1869': [10, 10],   // Saint Kitts and Nevis
    '+1758': [10, 10],   // Saint Lucia
    '+508': [6, 6],      // Saint Pierre and Miquelon
    '+1784': [10, 10],   // Saint Vincent and the Grenadines
    '+685': [5, 7],      // Samoa
    '+378': [6, 10],     // San Marino
    '+239': [7, 7],      // Sao Tome and Principe
    '+221': [9, 9],      // Senegal
    '+381': [8, 9],      // Serbia
    '+248': [7, 7],      // Seychelles
    '+232': [8, 8],      // Sierra Leone
    '+421': [9, 9],      // Slovakia
    '+386': [8, 8],      // Slovenia
    '+677': [5, 7],      // Solomon Islands
    '+252': [8, 9],      // Somalia
    '+211': [9, 9],      // South Sudan
    '+249': [9, 9],      // Sudan
    '+597': [6, 7],      // Suriname
    '+268': [8, 8],      // Swaziland
    '+46': [9, 10],      // Sweden
    '+41': [9, 9],       // Switzerland
    '+963': [9, 10],     // Syria
    '+886': [9, 9],      // Taiwan
    '+992': [9, 9],      // Tajikistan
    '+255': [9, 9],      // Tanzania
    '+228': [8, 8],      // Togo
    '+690': [5, 5],      // Tokelau
    '+676': [5, 7],      // Tonga
    '+1868': [10, 10],   // Trinidad and Tobago
    '+216': [8, 8],      // Tunisia
    '+993': [8, 8],      // Turkmenistan
    '+1649': [10, 10],   // Turks and Caicos Islands
    '+688': [5, 5],      // Tuvalu
    '+256': [9, 9],      // Uganda
    '+380': [9, 9],      // Ukraine
    '+598': [8, 8],      // Uruguay
    '+998': [9, 9],      // Uzbekistan
    '+678': [5, 7],      // Vanuatu
    '+379': [10, 10],    // Vatican City
    '+58': [10, 10],     // Venezuela
    '+84': [9, 10],      // Vietnam
    '+681': [4, 6],      // Wallis and Futuna
    '+967': [9, 9],      // Yemen
    '+260': [9, 9],      // Zambia
    '+263': [9, 9],      // Zimbabwe
  };

  String selectedDialCode = '+91';
  int minLength = 10;
  int maxLength = 10;
  bool _isValidating = false;

  // 🔧 ENHANCED VALIDATION METHOD
  bool _validateMobileNumber(String dialCode, String number) {
    final range = countryMobileLengthRange[dialCode];
    if (range == null) {
      debugPrint('⚠️ No validation rules for dial code: $dialCode');
      return false;
    }

    final min = range[0];
    final max = range[1];
    final length = number.length;

    return length >= min && length <= max;
  }

  // 🔧 VALIDATE FORMAT (OPTIONAL: ADD COUNTRY-SPECIFIC FORMAT VALIDATION)
  bool _validateFormat(String dialCode, String number) {
    // Add country-specific format validations if needed
    switch (dialCode) {
      case '+1':
        return RegExp(r'^[2-9]\d{2}[2-9]\d{6}$').hasMatch(number); // US/Canada
      case '+44':
        return RegExp(r'^7[1-9]\d{8}$').hasMatch(number); // UK mobile starts with 7
      case '+91':
        return RegExp(r'^[6-9]\d{9}$').hasMatch(number); // India mobile starts with 6-9
      case '+86':
        return RegExp(r'^1[3-9]\d{9}$').hasMatch(number); // China mobile starts with 13-19
      default:
        return RegExp(r'^[0-9]+$').hasMatch(number); // Basic digits only check
    }
  }

  @override
  void dispose() {
    phoneController.dispose();
    phoneFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2F5FD7),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 🔹 TOP CONTENT
                    Column(
                      children: [
                        const SizedBox(height: 24),
                        const Text(
                          'More than 300 Certified\nDoctors Available',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 🔹 IMAGE SECTION
                        SizedBox(
                          height: constraints.maxHeight * 0.62,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Transform.translate(
                                offset: Offset(0, constraints.maxHeight * 0.09),
                                child: Container(
                                  height: 260,
                                  width: 260,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.15),
                                  ),
                                ),
                              ),
                              Transform.translate(
                                offset: Offset(0, constraints.maxHeight * 0.12),
                                child: Image.asset(
                                  'assert/image/pngimg.com - doctor_PNG16022.png',
                                  height: 300,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // 🔹 BOTTOM CARD
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Please provide your mobile number to\nexperience seamless healthcare services.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 🔹 MOBILE INPUT
                          Row(
                            children: [
                              Container(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 6),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: CountryCodePicker(
                                  onChanged: (code) {
                                    final dial = code.dialCode ?? '+91';
                                    final range =
                                        countryMobileLengthRange[dial] ??
                                            [10, 10];

                                    setState(() {
                                      selectedDialCode = dial;
                                      minLength = range[0];
                                      maxLength = range[1];
                                      phoneController.clear();
                                    });

                                    debugPrint(
                                      'Country Selected: $dial | Min=$minLength | Max=$maxLength',
                                    );
                                  },
                                  initialSelection: 'IN',
                                  favorite: const ['+91', 'IN'],
                                  showFlag: true,
                                  showFlagMain: true,
                                  showFlagDialog: true,
                                  alignLeft: false,
                                ),
                              ),
                              const SizedBox(width: 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextField(
                                      controller: phoneController,
                                      focusNode: phoneFocusNode,
                                      keyboardType: TextInputType.phone,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(maxLength),
                                      ],
                                      decoration: InputDecoration(
                                        hintText:
                                        'Mobile Number ($minLength-$maxLength)',
                                        counterText: '',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        suffixIcon: phoneController.text.isNotEmpty
                                            ? IconButton(
                                          icon: Icon(
                                            _validateMobileNumber(selectedDialCode, phoneController.text)
                                                ? Icons.check_circle
                                                : Icons.error,
                                            color: _validateMobileNumber(selectedDialCode, phoneController.text)
                                                ? Colors.green
                                                : Colors.orange,
                                          ),
                                          onPressed: () {
                                            // Optional: Show validation details
                                          },
                                        )
                                            : null,
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          _isValidating = value.isNotEmpty;
                                        });

                                        debugPrint(
                                          'Dial: $selectedDialCode | Entered Length: ${value.length}',
                                        );
                                        if (value.length == maxLength) {
                                          phoneFocusNode.unfocus();
                                        }
                                      },
                                    ),

                                    // 🔹 REAL-TIME VALIDATION FEEDBACK
                                    if (phoneController.text.isNotEmpty && _isValidating)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4, left: 4),
                                        child: Text(
                                          _validateMobileNumber(selectedDialCode, phoneController.text)
                                              ? '✅ Valid length for $selectedDialCode'
                                              : '❌ Must be $minLength–$maxLength digits for $selectedDialCode',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: _validateMobileNumber(selectedDialCode, phoneController.text)
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // 🔹 COUNTRY INFO (OPTIONAL)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.blue.shade700,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Selected: $selectedDialCode | Required: $minLength–$maxLength digits',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue.shade800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          // 🔹 CONTINUE BUTTON
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2F5FD7),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                final mobile = phoneController.text.trim();

                                if (mobile.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Enter mobile number')),
                                  );
                                  return;
                                }
                                if (!_validateMobileNumber(selectedDialCode, mobile)) {
                                  final range = countryMobileLengthRange[selectedDialCode] ?? [10, 10];
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'For $selectedDialCode, mobile number must be ${range[0]}–${range[1]} digits',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }
                                if (!_validateFormat(selectedDialCode, mobile)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Invalid format for $selectedDialCode. Please check the number.',
                                      ),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                  return;
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '✅ Valid number: $selectedDialCode $mobile',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OtpVerifyPage(
                                      mobileNumber: phoneController.text.trim(),
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                'Continue',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

