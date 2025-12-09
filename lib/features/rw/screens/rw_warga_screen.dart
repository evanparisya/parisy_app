// lib/features/rw/screens/rw_warga_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parisy_app/core/constants/app_constants.dart';
import 'package:parisy_app/core/widgets/common_widgets.dart';
import 'package:parisy_app/features/management/users/controllers/user_management_controller.dart';
import 'package:parisy_app/features/management/users/models/warga_model.dart';

class RwWargaScreen extends StatefulWidget {
  const RwWargaScreen({Key? key}) : super(key: key);

  @override
  State<RwWargaScreen> createState() => _RwWargaScreenState();
}

class _RwWargaScreenState extends State<RwWargaScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    // Load data semua warga
    Future.microtask(() {
      context.read<UserManagementController>().loadAllWarga();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.primaryBlack),
        title: Text('Data Seluruh Warga (Read Only)', style: TextStyle(color: AppColors.primaryBlack, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Cari Warga',
                hintText: 'Cari nama atau email',
                prefixIcon: Icon(Icons.search, color: AppColors.neutralDarkGray),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (value) {
                // Trigger reload/filter
                context.read<UserManagementController>().loadAllWarga();
              },
            ),
          ),

          // Users list
          Expanded(
            child: Consumer<UserManagementController>(
              builder: (context, controller, _) {
                if (controller.state == UserManagementState.loading && controller.wargaList.isEmpty) {
                  return Center(child: CircularProgressIndicator());
                }

                if (controller.wargaList.isEmpty) {
                  return EmptyStateWidget(message: 'Tidak ada data warga di lingkungan RW ini.');
                }
                
                final filteredList = controller.wargaList.where((w) {
                  final query = _searchController.text.toLowerCase();
                  return w.name.toLowerCase().contains(query) || w.email.toLowerCase().contains(query);
                }).toList();

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final warga = filteredList[index];
                    return _WargaCard(warga: warga, isReadOnly: true);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// --- Helper Card Warga (Hanya Display) ---
class _WargaCard extends StatelessWidget {
  final WargaModel warga;
  final bool isReadOnly; 
  const _WargaCard({required this.warga, required this.isReadOnly});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
              child: Text(warga.subRole.substring(0, 1).toUpperCase(), style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(warga.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryBlack)),
                  Text(warga.email, style: TextStyle(fontSize: 12, color: AppColors.neutralDarkGray)),
                  SizedBox(height: 8),
                  Text('Role: ${warga.subRole.toUpperCase()}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primaryGreen)),
                  Text('Telp: ${warga.phone}', style: TextStyle(fontSize: 12, color: AppColors.neutralDarkGray)),
                  Text('Alamat: ${warga.address}', style: TextStyle(fontSize: 12, color: AppColors.neutralDarkGray), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}