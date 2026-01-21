import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api/login_api.dart';
import 'LoginEntryPage.dart';
import 'MainScreen.dart';
import 'Preferences/AppPreferences.dart';
import 'TokenManager.dart';
import 'api/login_request.dart';
import 'package:google_fonts/google_fonts.dart';
import 'api/login_response.dart';
import 'api/user_model.dart';

/*class DoctorLoginPage extends StatefulWidget {
  const DoctorLoginPage({super.key});

  @override
  State<DoctorLoginPage> createState() => _DoctorLoginPageState();
}

class _DoctorLoginPageState extends State<DoctorLoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool hidePassword = true;
  bool isLoading = false;

  // ✅ LOGIC MAINTAINED (Exact copy of your functionality)
  Future<void> _login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showSnack("Enter username & password");
      return;
    }

    setState(() => isLoading = true);

    try {
      final request = LoginRequest(username: username, password: password);
      final response = await LoginApi.login(request);

      if (response.success) {
        final String doctorId = response.user.id;
        final UserModel user = response.user;
        await AppPreferences.setDoctorId(user.id);
        await AppPreferences.setUsername(user.username);
        await AppPreferences.setEmail(user.email);
        await AppPreferences.setMobile(user.mobileNo);
        await AppPreferences.setRole(user.role);
        await AppPreferences.setPassword(password);
        await AppPreferences.setLoggedIn(true);

        _showSnack("Login successful", success: true);

        Navigator.pushAndRemoveUntil(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 300),
            pageBuilder: (_, __, ___) =>
                MainScreen(doctorId: doctorId,user: user),
            transitionsBuilder: (_, animation, __, child) {
              final tween = Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeOutCubic));

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          ),
              (route) => false,
        );



      } else {
        _showSnack("Login failed");
      }
    } catch (e) {
      _showSnack("Invalid username or password");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSnack(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.inter()),
        backgroundColor: success ? const Color(0xFF0D9488) : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Light status bar for white background
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // 🏢 BRANDING
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assert/image/splashscreen.png',
                      height: 50,
                      fit: BoxFit.contain,
                      errorBuilder: (c, e, s) => const Icon(Icons.medical_services, color: Color(0xFF0D9488), size: 45),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 45),

              // 📝 TITLES
              Text(
                "Welcome Back 👋",
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2563EB),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "sign in to manage your appointments and patient records.",
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: const Color(0xFF64748B),
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 35),

              // 🔹 INPUTS
              _label("Username"),
              _modernInput(
                controller: usernameController,
                hint: "Enter your doctor username",
                icon: Icons.alternate_email_rounded,
              ),

              const SizedBox(height: 20),

              _label("Password"),
              _modernInput(
                controller: passwordController,
                hint: "Enter your secure password",
                icon: Icons.lock_person_outlined,
                obscureText: hidePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    hidePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: const Color(0xFF94A3B8),
                    size: 20,
                  ),
                  onPressed: () => setState(() => hidePassword = !hidePassword),
                ),
              ),

              const SizedBox(height: 35),

              // 🔘 BUTTON
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:const Color(0xFF2563EB),  // Deep Hospital Navy
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                      : Text(
                    "Sign In",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // ☎ SUPPORT FOOTER
              Center(
                child: Column(
                  children: [
                    Text(
                      "Having trouble signing in?",
                      style:  GoogleFonts.poppins(color: const Color(0xFF94A3B8), fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: _callSupport,
                      child: Text(
                        "Contact Hospital Support",
                        style:  GoogleFonts.poppins(
                          color: const Color(0xFF2563EB),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600, // Semi-bold label
          fontSize: 14,
          color: const Color(0xFF334155), // Medical slate
          letterSpacing: -0.1,
        ),
      ),
    );
  }


  Widget _modernInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF0F172A),
          letterSpacing: -0.1,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF94A3B8),
          ),
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF0D9488),
            size: 22,
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
      ),
    );
  }

}*/

class DoctorLoginPage extends StatefulWidget {
  final LoginType loginType;
  const DoctorLoginPage({
    super.key,
    required this.loginType,
  });


  @override
  State<DoctorLoginPage> createState() => _DoctorLoginPageState();
}

class _DoctorLoginPageState extends State<DoctorLoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();



  bool hidePassword = true;
  bool isLoading = false;

  // 🔐 LOGIN LOGIC (UNCHANGED)
  Future<void> _login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showSnack("Enter username & password");
      return;
    }

    setState(() => isLoading = true);

    try {
      final request = LoginRequest(username: username, password: password);
      final response = await LoginApi.login(request);

      debugPrint("🔐 LOGIN API CALLED");
      debugPrint("🔐 Username: $username");

      if (response.success) {
        final user = response.user;

        // ✅ STORE VALUES
        await AppPreferences.setDoctorId(user.id);
        await AppPreferences.setUsername(user.username);
        await AppPreferences.setEmail(user.email);
        await AppPreferences.setMobile(user.mobileNo);
        await AppPreferences.setRole(user.role);
        await AppPreferences.setPassword(password);
        await AppPreferences.setLoggedIn(true);

        // 🔍 VERIFY STORED VALUES
        debugPrint("✅ LOGIN SUCCESS — STORED VALUES");
        debugPrint("🆔 DoctorId: ${AppPreferences.getDoctorId()}");
        debugPrint("👤 Username: ${AppPreferences.getUsername()}");
        debugPrint("📧 Email: ${AppPreferences.getEmail()}");
        debugPrint("📱 Mobile: ${AppPreferences.getMobile()}");
        debugPrint("🎭 Role: ${AppPreferences.getRole()}");
        debugPrint("🔐 IsLoggedIn: ${AppPreferences.isLoggedIn()}");

        _showSnack("Login successful", success: true);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => MainScreen(
              doctorId: user.id,
              user: user,
            ),
          ),
              (_) => false,
        );
      } else {
        debugPrint("❌ LOGIN FAILED — API returned success=false");
        _showSnack("Login failed");
      }
    } catch (e) {
      debugPrint("❌ LOGIN ERROR: $e");
      _showSnack("Invalid username or password");
    } finally {
      setState(() => isLoading = false);
    }
  }



  Future<void> _clinicLogin() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showSnack("Enter username & password");
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await LoginApi.clinicLogin(
        LoginRequest(username: username, password: password),
      );

      if (response.success) {
        final clinic = response.clinic;

        await AppPreferences.setclinicId(clinic.id);
        await AppPreferences.setUsername(clinic.username);
        await AppPreferences.setEmail(clinic.email ?? "");
        await AppPreferences.setMobile(clinic.mobileNo);
        await AppPreferences.setRole(clinic.role);
        await AppPreferences.setclinicname(clinic.clinicName);
        await AppPreferences.setPassword(password);
        await AppPreferences.setLoggedIn(true);
        await TokenManager.saveToken(response.accessToken);

        final userModel = clinicUserToUserModel(clinic);

        _showSnack("Login successful", success: true);
        await TokenManager.loadTokenFromPrefs();


        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => MainScreen(
              doctorId: clinic.id,
              user:   userModel,
            ),
          ),
              (_) => false,
        );
      } else {
        _showSnack("Login failed");
      }
    } catch (e) {
      _showSnack("Invalid username or password");
    } finally {
      setState(() => isLoading = false);
    }
  }




  void _showSnack(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor:
        success ? const Color(0xFF0D9488) : Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    const bgGradientTop = Color(0xFFDFF6FF);
    const bgGradientBottom = Color(0xFFFFFFFF);

    const primaryBlue = Color(0xFF1E88E5);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 🔹 TOP GRADIENT AREA
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 70, bottom: 40),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [bgGradientTop, bgGradientBottom],
              ),
            ),
            child: Column(
              children: [
                Image.asset(
                  "assert/image/splashscreen.png",
                  height: 110,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 18),
            /*    Text(
                  "Doctor Login",
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: primaryBlue,
                  ),
                ),*/
              ],
            ),
          ),

          // 🔹 FORM AREA
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 25),

                  Text(
                    "Welcome Back 👋",
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 30),

                  _label("Username"),
                  _roundedInput(
                    controller: usernameController,
                    hint: "Enter username",
                    icon: Icons.person_outline,
                  ),

                  const SizedBox(height: 20),

                  _label("Password"),
                  _roundedInput(
                    controller: passwordController,
                    hint: "Enter password",
                    icon: Icons.lock_outline,
                    obscure: hidePassword,
                    suffix: IconButton(
                      icon: Icon(
                        hidePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        size: 20,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() => hidePassword = !hidePassword);
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 🔹 LOGIN BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : widget.loginType == LoginType.doctor
                          ? _login
                          : _clinicLogin,

                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : Text(
                        "Login",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // ☎ SUPPORT FOOTER
                  Center(
                    child: Column(
                      children: [
                        Text(
                          "Having trouble signing in?",
                          style:  GoogleFonts.poppins(color: const Color(0xFF94A3B8), fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: _callSupport,
                          child: Text(
                            "Contact Hospital Support",
                            style:  GoogleFonts.poppins(
                              color: const Color(0xFF2563EB),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 LABEL WIDGET
  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 4),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF757575),
        ),
      ),
    );
  }

  // 🔹 INPUT FIELD WIDGET
  Widget _roundedInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFF2E7D32),
          width: 1.3,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: GoogleFonts.poppins(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            fontSize: 13,
            color: const Color(0xFF9E9E9E),
          ),
          border: InputBorder.none,
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF2E7D32),
            size: 22,
          ),
          suffixIcon: suffix,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
    );
  }
}





Future<void> _callSupport() async {
  const phoneNumber = "9429692742";

  final Uri uri = Uri.parse("tel:$phoneNumber");

  if (!await launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
  )) {
    debugPrint("Could not launch dialer");
  }
}
