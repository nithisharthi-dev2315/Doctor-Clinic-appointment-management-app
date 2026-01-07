import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'AddEnquiryPage.dart';
import 'BookSessionDialog.dart';
import 'TransferDoctorDialog.dart';
import 'TransferPatientDialog.dart';
import 'api/Appointment.dart';
import 'model/appointment_request.dart';

class PatientDetailsPage extends StatelessWidget {
  final AppointmentRequest patient;
  final Appointment appointment;
  final String doctorId;

  const PatientDetailsPage({
    super.key,
    required this.patient,
    required this.appointment,
    required this.doctorId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),

      /// 🔹 APP BAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Patient Details",
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F172A),
          ),
        ),
        iconTheme:
        const IconThemeData(color: Color(0xFF0F172A)),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _actionButtons(context),
            const SizedBox(height: 20),
            _detailsCard(),
          ],
        ),
      ),
    );
  }

  /// 🔹 DETAILS CARD
  Widget _detailsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        children: [
          _infoRow("Customer", patient.name),
          _infoRow("Age", patient.age.toString()),
          _infoRow("Gender", patient.gender),
          _infoRow(
            "Concern",
            appointment.primaryConcern ?? "-",
          ),
          _infoRow(
            "Status",
            appointment.status.toUpperCase(),
            isStatus: true,
          ),
          _infoRow(
            "ChiefComplaint",
            appointment.chiefComplaints ?? "-",
          ),
          _infoRow(
            "Notes",
            appointment.notes ?? "-",
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
      String label,
      String value, {
        bool isStatus = false,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isStatus
                    ? const Color(0xFF2563EB)
                    : const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 ACTION BUTTONS (GRID STYLE)
  Widget _actionButtons(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _gridBtn(
              "Add Enquiry",
              const Color(0xFF16A34A),
                  () => _showAddEnquiryDialog(context),
            ),
            const SizedBox(width: 12),
            _gridBtn(
              "Book Session",
              const Color(0xFF2563EB),
                  () => _showBookSessionDialog(context),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _gridBtn(
              "Transfer",
              const Color(0xFF7C3AED),
                  () async {
                final result = await showGeneralDialog<bool>(
                  context: context,
                  barrierDismissible: false,
                  barrierLabel: "TransferPatient",
                  barrierColor: Colors.transparent,
                  transitionDuration: const Duration(milliseconds: 250),

                  pageBuilder: (context, animation, secondaryAnimation) {
                    return Stack(
                      children: [
                        /// 🔥 BLACK BLUR BACKGROUND
                        BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            color: Colors.black.withOpacity(0.45),
                          ),
                        ),

                        /// ✅ CENTER DIALOG
                        Center(
                          child: Material(
                            color: Colors.transparent,
                            child: TransferPatientDialog(
                              appointmentId: appointment.id,
                              patientName: patient.name,
                              patientMobile: patient.phone,
                              patientEmail: patient.email,
                              age: patient.age,
                              gender: patient.gender,
                              treatment:
                              appointment.primaryConcern ?? "",
                            ),
                          ),
                        ),
                      ],
                    );
                  },

                  transitionBuilder: (_, animation, __, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween(begin: 0.95, end: 1.0).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOut,
                          ),
                        ),
                        child: child,
                      ),
                    );
                  },
                );

                if (result == true && context.mounted) {
                  Navigator.pop(context, true);
                }
              },
            ),

            const SizedBox(width: 12),
            _gridBtn(
              "Doctor Transfer",
              const Color(0xFFDC2626),
                  () async {
                final result = await showGeneralDialog<bool>(
                  context: context,
                  barrierDismissible: false,
                  barrierLabel: "DoctorTransfer",
                  barrierColor: Colors.transparent,
                  transitionDuration: const Duration(milliseconds: 250),

                  pageBuilder: (context, animation, secondaryAnimation) {
                    return Stack(
                      children: [
                        /// 🔥 BLACK BLUR BACKGROUND
                        BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            color: Colors.black.withOpacity(0.45),
                          ),
                        ),

                        /// ✅ CENTER DIALOG
                        Center(
                          child: Material(
                            color: Colors.transparent,
                            child: TransferDoctorDialog(
                              appointmentId: appointment.id,
                              patientName: patient.name,
                            ),
                          ),
                        ),
                      ],
                    );
                  },

                  transitionBuilder: (_, animation, __, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween(begin: 0.95, end: 1.0).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOut,
                          ),
                        ),
                        child: child,
                      ),
                    );
                  },
                );

                if (result == true && context.mounted) {
                  Navigator.pop(context, true);
                }
              },
            ),

          ],
        ),
      ],
    );
  }

  /// 🔹 GRID BUTTON
  Widget _gridBtn(
      String text,
      Color color,
      VoidCallback onTap,
      ) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        onPressed: onTap,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }



  void _showAddEnquiryDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "AddEnquiry",
      barrierColor: Colors.transparent, // ❌ avoid flat black
      transitionDuration: const Duration(milliseconds: 250),

      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
          child: Stack(
            children: [

              /// 🔥 BLACK BLUR BACKGROUND
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.black.withOpacity(0.45),
                ),
              ),

              /// ✅ CENTER DIALOG
              Center(
                child: Material(
                  color: Colors.transparent,
                  child: AddEnquiryDialog(
                    appointmentId: appointment.id,
                    doctorId: doctorId,
                  ),
                ),
              ),
            ],
          ),
        );
      },

      /// 🎯 FADE + SCALE (DIALOG STYLE)
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.95,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
            ),
            child: child,
          ),
        );
      },
    );
  }


  void _showBookSessionDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "BookSession",
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 250),

      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
          child: Stack(
            children: [

              /// 🔥 BLACK BLUR BACKGROUND
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.black.withOpacity(0.45),
                ),
              ),

              /// ✅ CENTERED DIALOG
              Center(
                child: Material(
                  color: Colors.transparent,
                  child: BookSessionDialog(
                    appointmentId: appointment.id,
                    patientName: patient.name,
                    phone: patient.phone,
                    email: patient.email,
                    concern: appointment.primaryConcern ?? "",
                    doctorUsername:
                    appointment.doctorAssignedUsername,
                  ),
                ),
              ),
            ],
          ),
        );
      },

      /// 🎯 DIALOG ANIMATION (FADE + SCALE)
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.95,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
            ),
            child: child,
          ),
        );
      },
    );
  }

}



