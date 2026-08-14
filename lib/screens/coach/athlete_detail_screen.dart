import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/athlete_model.dart';

class AthleteDetailScreen extends StatefulWidget {
  final String athleteName;
  final String athleteEmail;

  const AthleteDetailScreen({
    super.key,
    required this.athleteName,
    required this.athleteEmail,
  });

  @override
  State<AthleteDetailScreen> createState() => _AthleteDetailScreenState();
}

class _AthleteDetailScreenState extends State<AthleteDetailScreen> {
  AthleteModel? _athlete;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAthleteData();
  }

  Future<void> _loadAthleteData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? publicData =
        prefs.getString('rolla_public_profile_${widget.athleteEmail}');

    if (publicData != null) {
      _athlete = AthleteModel.fromJson(jsonDecode(publicData));
    }

    setState(() => _isLoading = false);
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    final f = parts.isNotEmpty && parts[0].isNotEmpty ? parts[0][0] : '';
    final l = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
    return '$f$l'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FA),
        elevation: 0,
        title: const Text(
          'Detalle del Deportista',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                            color: const Color(0xFF2563EB), width: 2),
                        image: _athlete?.photoUrl != null
                            ? DecorationImage(
                                image: FileImage(File(_athlete!.photoUrl!)),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _athlete?.photoUrl == null
                          ? Center(
                              child: Text(
                                _getInitials(widget.athleteName),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.athleteName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.athleteEmail,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    if (_athlete != null) ...[
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildChip(_athlete!.category, Icons.category),
                          _buildChip(_athlete!.level, Icons.trending_up),
                          if (_athlete!.modality != null)
                            _buildChip(_athlete!.modality!, Icons.sports),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Medallero
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Medallero',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                              children: [
                                _buildMedalItem('Oro',
                                    _athlete!.goldMedals.toString(), const Color(0xFFFBBF24)),
                                _buildMedalItem('Plata',
                                    _athlete!.silverMedals.toString(), const Color(0xFFD1D5DB)),
                                _buildMedalItem('Bronce',
                                    _athlete!.bronzeMedals.toString(), const Color(0xFFB45309)),
                                _buildMedalItem('Total',
                                    _athlete!.totalMedals.toString(), Colors.white),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildInfoCard('Participaciones',
                          _athlete!.participationsCount.toString(), Icons.event),
                      if (_athlete!.birthDate != null)
                        _buildInfoCard(
                          'Fecha de nacimiento',
                          '${_athlete!.birthDate!.day}/${_athlete!.birthDate!.month}/${_athlete!.birthDate!.year}',
                          Icons.cake,
                        ),
                    ] else ...[
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFCD34D)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: Color(0xFFD97706)),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'El deportista aún no ha completado su perfil deportivo.',
                                style: TextStyle(color: Color(0xFFA16207)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF2563EB)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF2563EB),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedalItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2563EB)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}