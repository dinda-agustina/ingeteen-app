import 'package:flutter/material.dart';

void main() {
  runApp(const IngeTeenApp());
}

class AppColors {
  static const cream = Color(0xFFF9F5E9);
  static const navy = Color(0xFF26364D);
  static const blue = Color(0xFF7FB3FF);
  static const orange = Color(0xFFFFB31A);
  static const white = Colors.white;
  static const grey = Color(0xFF7A7F87);
  static const lightGrey = Color(0xFFE7E3D8);
}

class IngeTeenApp extends StatelessWidget {
  const IngeTeenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IngeTeen',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.cream,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.orange,
        ),
        fontFamily: 'Arial',
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (context) {
          final tabController = DefaultTabController.of(context);

          return Scaffold(
            drawer: AppDrawer(
              tabController: tabController,
            ),
            body: SafeArea(
              child: Column(
                children: [
                  _buildHeader(context),
                  _buildSearchBar(),
                  _buildTaskTitle(),
                  _buildTabBar(),
                  const Expanded(
                    child: TabBarView(
                      children: [
                        PendingTab(),
                        CompletedTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: AppColors.orange,
              foregroundColor: AppColors.navy,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddTaskPage(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
      child: Row(
        children: [
          Builder(
            builder: (context) {
              return IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: const Icon(
                  Icons.menu,
                  size: 28,
                  color: AppColors.navy,
                ),
              );
            },
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi, User!',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Yuk selesaikan tugasmu hari ini.',
                  style: TextStyle(
                    color: AppColors.grey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: AppColors.blue,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: AppColors.navy,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 8,
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Cari tugas...',
          hintStyle: const TextStyle(
            color: AppColors.grey,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.grey,
          ),
          filled: true,
          fillColor: AppColors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildTaskTitle() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 14, 20, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Tugas',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: TabBar(
        labelColor: AppColors.navy,
        unselectedLabelColor: AppColors.grey,
        indicatorColor: AppColors.orange,
        indicatorWeight: 3,
        dividerColor: Colors.transparent,
        tabs: [
          Tab(
            text: 'PENDING',
          ),
          Tab(
            text: 'COMPLETED',
          ),
        ],
      ),
    );
  }
}

// =====================================================
// DRAWER
// =====================================================

class AppDrawer extends StatelessWidget {
  final TabController tabController;

  const AppDrawer({
    super.key,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.cream,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                24,
                30,
                24,
                26,
              ),
              decoration: const BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.blue,
                    child: Icon(
                      Icons.person,
                      color: AppColors.navy,
                      size: 30,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'IngeTeen',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Task Management',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            ListTile(
              leading: const Icon(
                Icons.home_outlined,
                color: AppColors.navy,
              ),
              title: const Text(
                'Semua Tugas',
                style: TextStyle(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(
                Icons.pending_actions,
                color: AppColors.navy,
              ),
              title: const Text(
                'Pending',
                style: TextStyle(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                tabController.animateTo(0);
              },
            ),

            ListTile(
              leading: const Icon(
                Icons.task_alt,
                color: AppColors.navy,
              ),
              title: const Text(
                'Completed',
                style: TextStyle(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                tabController.animateTo(1);
              },
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(),
            ),

            ListTile(
              leading: const Icon(
                Icons.add_circle_outline,
                color: AppColors.orange,
              ),
              title: const Text(
                'Tambah Tugas',
                style: TextStyle(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddTaskPage(),
                  ),
                );
              },
            ),

            const Spacer(),

            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'IngeTeen App',
                style: TextStyle(
                  color: AppColors.grey,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// PENDING
// =====================================================

class PendingTab extends StatelessWidget {
  const PendingTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        20,
        16,
        20,
        100,
      ),
      children: const [
        TaskCard(
          title: 'Implementasi Sorting',
          description:
              'Menyelesaikan implementasi algoritma sorting.',
          course: 'Struktur Data',
          priority: 'Urgent',
          deadline: 'Besok • 23:59',
          priorityColor: Colors.redAccent,
        ),
        TaskCard(
          title: 'Laporan Praktikum',
          description:
              'Membuat laporan praktikum sistem operasi.',
          course: 'Sistem Operasi',
          priority: 'High',
          deadline: '10 Okt • 23:59',
          priorityColor: Colors.orange,
        ),
        TaskCard(
          title: 'Desain Prototype',
          description:
              'Menyelesaikan prototype aplikasi pada Figma.',
          course: 'Perancangan Web',
          priority: 'Medium',
          deadline: '12 Okt • 20:00',
          priorityColor: Colors.blue,
        ),
      ],
    );
  }
}

// =====================================================
// COMPLETED
// =====================================================

class CompletedTab extends StatelessWidget {
  const CompletedTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        20,
        16,
        20,
        100,
      ),
      children: const [
        TaskCard(
          title: 'Membuat Struktur HTML',
          description:
              'Menyelesaikan halaman profil menggunakan HTML.',
          course: 'Pemrograman Web',
          priority: 'Done',
          deadline: 'Selesai',
          priorityColor: Colors.green,
          completed: true,
        ),
        TaskCard(
          title: 'Instalasi Flutter',
          description:
              'Melakukan instalasi dan konfigurasi Flutter.',
          course: 'Pemrograman Perangkat Bergerak',
          priority: 'Done',
          deadline: 'Selesai',
          priorityColor: Colors.green,
          completed: true,
        ),
      ],
    );
  }
}

// =====================================================
// TASK CARD
// =====================================================

class TaskCard extends StatelessWidget {
  final String title;
  final String description;
  final String course;
  final String priority;
  final String deadline;
  final Color priorityColor;
  final bool completed;

  const TaskCard({
    super.key,
    required this.title,
    required this.description,
    required this.course,
    required this.priority,
    required this.deadline,
    required this.priorityColor,
    this.completed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: completed
                        ? Colors.green
                        : AppColors.navy,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(7),
                  color: completed
                      ? Colors.green
                      : Colors.transparent,
                ),
                child: completed
                    ? const Icon(
                        Icons.check,
                        size: 17,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    decoration: completed
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 9),

          Padding(
            padding: const EdgeInsets.only(left: 36),
            child: Text(
              description,
              style: const TextStyle(
                color: AppColors.grey,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),

          const SizedBox(height: 14),

          Padding(
            padding: const EdgeInsets.only(left: 36),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildTag(
                  text: priority,
                  color: priorityColor,
                ),
                _buildTag(
                  text: course,
                  color: AppColors.navy,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.only(left: 36),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: AppColors.grey,
                ),
                const SizedBox(width: 7),
                Text(
                  deadline,
                  style: const TextStyle(
                    color: AppColors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag({
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// =====================================================
// INPUT FORM
// UI ONLY
// =====================================================

class AddTaskPage extends StatelessWidget {
  const AddTaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.navy,
        elevation: 0,
        title: const Text(
          'Tambah Tugas',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          20,
          10,
          20,
          30,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Buat tugas baru',
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Lengkapi informasi tugas di bawah ini.',
              style: TextStyle(
                color: AppColors.grey,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 25),

            _buildLabel('Judul Tugas'),
            _buildTextField(
              hint: 'Masukkan judul tugas',
            ),

            const SizedBox(height: 18),

            _buildLabel('Deskripsi'),
            _buildTextField(
              hint: 'Masukkan deskripsi tugas',
              maxLines: 4,
            ),

            const SizedBox(height: 18),

            _buildLabel('Mata Kuliah'),
            _buildTextField(
              hint: 'Masukkan mata kuliah',
            ),

            const SizedBox(height: 18),

            _buildLabel('Prioritas'),
            DropdownButtonFormField<String>(
              decoration: _inputDecoration(
                hint: 'Pilih prioritas',
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Urgent',
                  child: Text('Urgent'),
                ),
                DropdownMenuItem(
                  value: 'High',
                  child: Text('High'),
                ),
                DropdownMenuItem(
                  value: 'Medium',
                  child: Text('Medium'),
                ),
                DropdownMenuItem(
                  value: 'Low',
                  child: Text('Low'),
                ),
              ],
              onChanged: (value) {},
            ),

            const SizedBox(height: 18),

            _buildLabel('Deadline'),
            _buildTextField(
              hint: 'Pilih tanggal deadline',
              suffixIcon: Icons.calendar_today_outlined,
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  foregroundColor: AppColors.navy,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  'Tambah Tugas',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.navy,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    int maxLines = 1,
    IconData? suffixIcon,
  }) {
    return TextField(
      maxLines: maxLines,
      decoration: _inputDecoration(
        hint: hint,
        suffixIcon: suffixIcon,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    IconData? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: AppColors.grey,
        fontSize: 13,
      ),
      filled: true,
      fillColor: AppColors.white,
      suffixIcon: suffixIcon == null
          ? null
          : const Icon(
              Icons.calendar_today_outlined,
              color: AppColors.grey,
            ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}