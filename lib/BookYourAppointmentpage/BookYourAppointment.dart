import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../Apiservice/appointment_api_service.dart';
import '../model/ConcernModel.dart';
import '../model/appointment_request.dart';

class BookAppointmentPage extends StatefulWidget {
  final String doctorId;
  final String doctorUsername;

  const BookAppointmentPage({
    super.key,
    required this.doctorId,
    required this.doctorUsername,
  });

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final couponController = TextEditingController();


  String? gender;
  String? language;
  String? concern;

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String? dateError;
  String? timeError;
  String? phoneError;

  String selectedDialCode = '+91';
  int minLength = 10;
  int maxLength = 10;

  List<ConcernModel> concerns = [];
  ConcernModel? selectedConcern;
  bool loadingConcern = true;


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



  /// ---------------- DATE PICKER ----------------
  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
        dateError = null;
      });
    }
  }

  /// ---------------- TIME PICKER ----------------
  Future<void> pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        selectedTime = time;
        timeError = null;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadConcerns();
  }

  Future<void> loadConcerns() async {
    try {
      final data = await AppointmentApiService.getConcerns();
      setState(() {
        concerns = data;
        loadingConcern = false;
      });
    } catch (e) {
      loadingConcern = false;
      debugPrint(e.toString());
    }
  }
  Widget _concernDropdown() {
    return DropdownButtonFormField<ConcernModel>(
      value: selectedConcern,

      hint: Text(
        "Select your primary concern",
        style: GoogleFonts.poppins(
          fontSize: 13,
          color: Colors.grey,
        ),
      ),

      validator: (v) =>
      v == null ? "Please select a primary concern" : null,

      items: concerns
          .map(
            (e) => DropdownMenuItem<ConcernModel>(
          value: e,
          child: Text(
            e.concern,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      )
          .toList(),

      onChanged: (v) {
        setState(() => selectedConcern = v);
      },

      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),

      decoration: InputDecoration(
        isDense: true, // ✅ compact height
        filled: true,  // ✅ white background
        fillColor: Colors.white,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10, // 🔽 smaller height
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black), // 🔥 black focus
        ),

        errorStyle: GoogleFonts.poppins(
          fontSize: 11,
          color: Colors.red,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            CupertinoIcons.back,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title:  Text(
          "Add Patient",
          style: GoogleFonts.poppins(
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// FULL NAME
                _label("Full Name"),
                _smallTextField(
                  controller: nameController,
                  hint: "John Doe",
                  validator: (v) =>
                  v == null || v.trim().isEmpty ? "Name is required" : null,
                ),

                const SizedBox(height: 14),

                /// AGE + GENDER
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label("Age"),
                          _ageField(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label("Gender"),
                          _smallDropdown(
                            value: gender,
                            hint: "Select",
                            items: const ["Male", "Female", "Other"],
                            validator: (v) =>
                            v == null ? "Please select gender" : null,
                            onChanged: (v) => setState(() => gender = v),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                /// PHONE + EMAIL
                _phoneFieldWithCountryCode(),

                const SizedBox(height: 16),
                _label("Gmail"),
                _smallTextField(
                  controller: emailController,
                  hint:  "you@example.com",
                  keyboard: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return "Email is required";
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                        .hasMatch(v)) {
                      return "Invalid email";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                /// LANGUAGE
                _label("Preferred Language"),
                _smallDropdown(
                  value: language,
                  hint: "Select your preferred language",
                  items: const ["English", "Tamil", "Hindi"],
                  validator: (v) =>
                  v == null ? "Please select your preferred language" : null,
                  onChanged: (v) => setState(() => language = v),
                ),

                const SizedBox(height: 16),

                /// CONCERN
                _label("Primary Concern"),

                loadingConcern
                    ? const CircularProgressIndicator()
                    : _concernDropdown(),


                const SizedBox(height: 16),

                /// DATE + TIME
                Row(
                  children: [
                    Expanded(child: _dateField()),
                    const SizedBox(width: 14),
                    Expanded(child: _timeField()),
                  ],
                ),

                const SizedBox(height: 16),

                /// COUPON
                _label("Coupon Code (optional)"),
                _smallTextField(
                  controller: couponController,
                  hint: "Enter coupon code (if any)",
                ),

                const SizedBox(height: 25),

                /// SUBMIT
                SizedBox(
                  height: 52,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "Submit Appointment",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white, // ✅ White text
                      ),
                    ),

                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

  }

  /// ---------------- SUBMIT ----------------

  void _onSubmit() {
    final valid = _formKey.currentState!.validate();

    setState(() {
      phoneError = phoneController.text.isEmpty
          ? "Phone number is required"
          : phoneController.text.length < minLength ||
          phoneController.text.length > maxLength
          ? "Enter valid phone number"
          : null;

      dateError =
      selectedDate == null ? "Preferred date is required" : null;
      timeError =
      selectedTime == null ? "Preferred time is required" : null;
    });

    if (valid &&
        phoneError == null &&
        dateError == null &&
        timeError == null) {
      submitAppointment();
    }
  }


  Future<void> submitAppointment() async {
    if (selectedConcern == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Please select primary concern",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Color(0xFF0D9488),
          behavior: SnackBarBehavior.floating,
          elevation: 4,
        ),
      );
      return;
    }

    final request = AppointmentRequest(
      name: nameController.text.trim(),
      age: int.parse(ageController.text.trim()),
      gender: gender!,
      phone: phoneController.text.trim(),
      email: emailController.text.trim(),
      primaryConcern: selectedConcern!.concern,
      date: DateFormat("yyyy-MM-dd").format(selectedDate!),
      time: convertTo24Hour(selectedTime!),
      whatsAppOptIn: false,
      language: language!,
      couponCode:
      couponController.text.trim().isEmpty ? null : couponController.text,
      doctorId: widget.doctorId,
      doctorUsername: widget.doctorUsername,
    );

    // 🔍 DEBUG PRINT
    debugPrint("REQUEST DATA:");
    debugPrint(request.toJson().toString());

    try {
      final response =
      await AppointmentApiService.createAppointment(request);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            " Appointment added successfully",
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: Color(0xFF0D9488),
          behavior: SnackBarBehavior.floating,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );


      Navigator.pop(context, true);
    } catch (e) {
      debugPrint("API ERROR: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Something went wrong",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF0D9488), // ✅ updated color (teal)
          behavior: SnackBarBehavior.floating,
          elevation: 4,
        ),
      );
    }

  }
  String convertTo24Hour(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }


  Widget _phoneFieldWithCountryCode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Phone / WhatsApp"),

        Container(
          height: 45, // 🔽 smaller height
          decoration: BoxDecoration(
            border: Border.all(
              color: phoneError != null ? Colors.red : Colors.grey,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8), // 🔽 smaller radius
            color: Colors.white,
          ),
          child: Row(
            children: [
              // 🔹 Country code picker (compact)
              CountryCodePicker(
                initialSelection: 'IN',
                favorite: const ['+91', 'IN'],
                padding: EdgeInsets.zero,
                textStyle: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                onChanged: (code) {
                  final dial = code.dialCode ?? '+91';
                  final range =
                      countryMobileLengthRange[dial] ?? [10, 10];

                  setState(() {
                    selectedDialCode = dial;
                    minLength = range[0];
                    maxLength = range[1];
                    phoneController.clear();
                    phoneError = null;
                  });
                },
              ),

              // 🔹 Phone input
              Expanded(
                child: TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: maxLength,

                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),

                  decoration: InputDecoration(
                    isDense: true, // ✅ compact
                    hintText: "Enter phone number",
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                    border: InputBorder.none,
                    counterText: "",
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 8,
                    ),
                  ),

                  onChanged: (_) => setState(() => phoneError = null),
                ),
              ),
            ],
          ),
        ),

        // 🔹 Error text (small)
        if (phoneError != null)
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              phoneError!,
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontSize: 11,
              ),
            ),
          ),
      ],
    );
  }






  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF0F172A),
        ),
      ),
    );
  }


  Widget _smallTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      validator: validator,

      // 🔹 Smaller input text
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),

      decoration: InputDecoration(
        isDense: true, // ✅ makes field compact
        hintText: hint,

        // 🔹 Smaller hint text
        hintStyle: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: Colors.grey,
        ),

        // 🔹 Error text
        errorStyle: GoogleFonts.poppins(
          fontSize: 11,
          color: Colors.red,
        ),

        // 🔹 Reduce height using padding
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 15,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), // smaller radius
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue),
        ),
      ),
    );
  }



  Widget _ageField() {
    return TextFormField(
      controller: ageController,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(3),
      ],
      validator: (v) {
        if (v == null || v.isEmpty) return "Age is required";
        final age = int.tryParse(v);
        if (age == null) return "Enter valid age";
        if (age < 1 || age > 120) return "Age must be between 1 and 120";
        return null;
      },

      // 🔹 Smaller input text
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),

      decoration: InputDecoration(
        isDense: true,
        hintText: "Age",

        hintStyle: GoogleFonts.poppins(
          fontSize: 13,
          color: Colors.grey,
        ),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue),
        ),

        errorStyle: GoogleFonts.poppins(
          fontSize: 11,
          color: Colors.red,
        ),
      ),
    );
  }



  Widget _smallDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      validator: validator,
      onChanged: onChanged,

      // 🔹 Hint text
      hint: Text(
        hint,
        style: GoogleFonts.poppins(
          fontSize: 13,
          color: Colors.grey,
        ),
      ),

      // 🔹 Dropdown items
      items: items
          .map(
            (e) => DropdownMenuItem<String>(
          value: e,
          child: Text(
            e,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      )
          .toList(),

      decoration: InputDecoration(
        isDense: true, // ✅ compact height
        filled: true, // ✅ white background
        fillColor: Colors.white,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10, // 🔽 reduce for more compact
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.grey,
            width: 1.2,
          ),
        ),

        errorStyle: GoogleFonts.poppins(
          fontSize: 11,
          color: Colors.red,
        ),
      ),

      // 🔹 Selected value style
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
    );
  }


  Widget _dateField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label("Preferred Date"),
      const SizedBox(height: 4),
      InkWell(
        onTap: pickDate,
        child: _pickerBox(
          text: selectedDate == null
              ? "dd-mm-yyyy"
              : DateFormat("dd-MM-yyyy").format(selectedDate!),
          icon: Icons.calendar_month,
          error: dateError != null,
        ),
      ),
    ],
  );

  Widget _timeField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label("Preferred Time"),
      const SizedBox(height: 4),
      InkWell(
        onTap: pickTime,
        child: _pickerBox(
          text: selectedTime == null
              ? "--:--"
              : selectedTime!.format(context),
          icon: Icons.access_time,
          error: timeError != null,
        ),
      ),
    ],
  );

  Widget _pickerBox({
    required String text,
    required IconData icon,
    required bool error,
  }) {
    return Container(
      height: 50, // 🔽 smaller height
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: error ? Colors.red : Colors.grey,
          width: 1,
        ),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          Icon(
            icon,
            size: 18, // 🔽 smaller icon
            color: Colors.grey[700],
          ),
        ],
      ),
    );
  }


  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    phoneController.dispose();
    emailController.dispose();
    couponController.dispose();
    super.dispose();
  }
}
