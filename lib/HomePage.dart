import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Appointments",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          AppointmentCard(
            patientName: "Arun",
            concern: "Fitness and Nutrition",
          ),
          AppointmentCard(
            patientName: "Ram",
            concern: "Sexual Wellness",
          ),
          AppointmentCard(
            patientName: "John",
            concern: "Lifestyle Disorders",
          ),
          AppointmentCard(
            patientName: "Kumar",
            concern: "Mental Health",
          ),
        ],
      ),
    );
  }
}

/// 🔹 CARD WITH IMAGE
class AppointmentCard extends StatelessWidget {
  final String patientName;
  final String concern;

  const AppointmentCard({
    super.key,
    required this.patientName,
    required this.concern,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// STATUS
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F6EF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        "Approved",
                        style: TextStyle(
                          color: Color(0xFF2ECC71),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    /// PATIENT NAME
                    Text(
                      "Patient : $patientName",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    /// CONCERN
                    Text(
                      "Primary Concern: $concern",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 8),

                    /// TIME
                    Row(
                      children: const [
                        Icon(Icons.schedule,
                            size: 14, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          "Time: 09:00 AM",
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    /// VIDEO
                    Row(
                      children: const [
                        Icon(Icons.videocam,
                            size: 14, color: Colors.blue),
                        SizedBox(width: 4),
                        Text(
                          "Video meet",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              /// 🔹 DOCTOR IMAGE (NOT REMOVED)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  "assert/image/female-doctor-hospital.jpg",
                  height: 90,
                  width: 80,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text("Message"),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.video_call,
                    color: Colors.white, // 🔹 ICON WHITE
                  ),
                  label: const Text(
                    "Join Call",
                    style: TextStyle(
                      color: Colors.white, // 🔹 TEXT WHITE
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F5FD7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

            ],
          ),
        ],
      ),
    );
  }
}
