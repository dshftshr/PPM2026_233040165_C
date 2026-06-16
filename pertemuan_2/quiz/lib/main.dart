import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;

ImageProvider? _getImageProvider(String? path) {
  if (path == null || path.isEmpty) return null;
  if (kIsWeb) return NetworkImage(path);
  return FileImage(File(path));
}

Widget _buildProfileImage(String? path, {double radius = 50, IconData defaultIcon = Icons.person}) {
  final provider = _getImageProvider(path);
  return Container(
    width: radius * 2,
    height: radius * 2,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.pinkAccent.withAlpha(50),
    ),
    child: ClipOval(
      child: provider != null
          ? Image(
              key: UniqueKey(),
              image: provider,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => 
                Icon(defaultIcon, size: radius * 1.2, color: Colors.pinkAccent),
            )
          : Icon(defaultIcon, size: radius * 1.2, color: Colors.pinkAccent),
    ),
  );
}

Widget _buildExperienceSquarePlaceholder({double size = 100}) {
  return Container(
    height: size,
    width: size,
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: const Center(
      child: Icon(Icons.image_not_supported, size: 30, color: Colors.grey),
    ),
  );
}

void main() {
  runApp(const MyApp());
}

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.pink,
              brightness: Brightness.dark,
            ),
          ),
          themeMode: mode,
          home: const MainScreen(),
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1;
  
  late ProfileInfo _profileInfo;

  @override
  void initState() {
    super.initState();
    _profileInfo = ProfileInfo(
      name: 'Desi',
      bio: 'Mahasiswa Teknik Informatika UNPAS semester 6.',
      education: 'Universitas Pasundan — Semester 6\nIPK: 4.00',
      hobby: 'Menghitung Uang',
      email: 'desihafitaashri.dha@gmail.com',
      phone: '+62-83862078854',
      imagePath: null,
      experienceTitle: 'Magang di Google',
      experienceDescription: 'Bekerja sebagai Software Engineer Intern selama 3 bulan.',
      experienceImagePath: null,
    );
  }

  void _updateProfile(ProfileInfo newInfo) {
    setState(() {
      _profileInfo = newInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const PlaceholderPage(title: 'Home', icon: Icons.home),
      ProfilePage(
        info: _profileInfo,
        onEdit: () async {
          final result = await Navigator.push<ProfileInfo>(
            context,
            MaterialPageRoute(
              builder: (context) => EditProfilePage(info: _profileInfo),
            ),
          );
          if (result != null) {
            _updateProfile(result);
          }
        },
      ),
      const PlaceholderPage(title: 'Pesan', icon: Icons.message),
      const SettingsPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 1 ? 'Profil Saya' : 
                   _selectedIndex == 0 ? 'Home' :
                   _selectedIndex == 2 ? 'Pesan' : 'Pengaturan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.pink),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home), 
              title: const Text('Beranda'),
              onTap: () {
                setState(() => _selectedIndex = 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person), 
              title: const Text('Profil'),
              onTap: () {
                setState(() => _selectedIndex = 1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.work), 
              title: const Text('Edit Pengalaman'),
              onTap: () async {
                Navigator.pop(context);
                final result = await Navigator.push<ProfileInfo>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditExperiencePage(info: _profileInfo),
                  ),
                );
                if (result != null) {
                  _updateProfile(result);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.widgets),
              title: const Text('Widget Gallery'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GalleryHome()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Pengaturan'),
              onTap: () {
                setState(() => _selectedIndex = 3);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profil'),
          NavigationDestination(icon: Icon(Icons.message), label: 'Pesan'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Setting'),
        ],
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }
}

class ProfileInfo {
  String name;
  String bio;
  String education;
  String hobby;
  String email;
  String phone;
  String? imagePath;
  String experienceTitle;
  String experienceDescription;
  String? experienceImagePath;

  ProfileInfo({
    required this.name,
    required this.bio,
    required this.education,
    required this.hobby,
    required this.email,
    required this.phone,
    this.imagePath,
    required this.experienceTitle,
    required this.experienceDescription,
    this.experienceImagePath,
  });
}

class PlaceholderPage extends StatelessWidget {
  final String title;
  final IconData icon;
  const PlaceholderPage({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 100, color: Colors.pink.withAlpha(128)),
          const SizedBox(height: 16),
          Text(
            'Halaman $title',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text('Sedang dalam pengembangan...'),
        ],
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const _SettingsHeader(title: 'Akun'),
        const ListTile(
          leading: Icon(Icons.lock),
          title: Text('Privasi'),
          trailing: Icon(Icons.chevron_right),
        ),
        const ListTile(
          leading: Icon(Icons.notifications),
          title: Text('Notifikasi'),
          trailing: Icon(Icons.chevron_right),
        ),
        const _SettingsHeader(title: 'Umum'),
        const ListTile(
          leading: Icon(Icons.language),
          title: Text('Bahasa'),
          trailing: Text('Indonesia'),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.dark_mode),
          title: const Text('Mode Gelap'),
          value: themeNotifier.value == ThemeMode.dark,
          onChanged: (v) {
            themeNotifier.value = v ? ThemeMode.dark : ThemeMode.light;
          },
        ),
        const _SettingsHeader(title: 'Lainnya'),
        const ListTile(
          leading: Icon(Icons.help),
          title: Text('Bantuan'),
        ),
        const ListTile(
          leading: Icon(Icons.info),
          title: Text('Tentang Aplikasi'),
        ),
      ],
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  final String title;
  const _SettingsHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.pink.shade700,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}

class EditProfilePage extends StatefulWidget {
  final ProfileInfo info;
  const EditProfilePage({super.key, required this.info});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _educationController;
  late TextEditingController _hobbyController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _experienceTitleController;
  late TextEditingController _experienceDescriptionController;
  String? _imagePath;
  String? _experienceImagePath;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.info.name);
    _bioController = TextEditingController(text: widget.info.bio);
    _educationController = TextEditingController(text: widget.info.education);
    _hobbyController = TextEditingController(text: widget.info.hobby);
    _emailController = TextEditingController(text: widget.info.email);
    _phoneController = TextEditingController(text: widget.info.phone);
    _experienceTitleController = TextEditingController(text: widget.info.experienceTitle);
    _experienceDescriptionController = TextEditingController(text: widget.info.experienceDescription);
    _imagePath = widget.info.imagePath;
    _experienceImagePath = widget.info.experienceImagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _educationController.dispose();
    _hobbyController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _experienceTitleController.dispose();
    _experienceDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  Future<void> _pickExperienceImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _experienceImagePath = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: _buildProfileImage(_imagePath, defaultIcon: Icons.camera_alt),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nama', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bioController,
              decoration: const InputDecoration(labelText: 'Tentang Saya', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _educationController,
              decoration: const InputDecoration(labelText: 'Pendidikan', border: OutlineInputBorder()),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _hobbyController,
              decoration: const InputDecoration(labelText: 'Hobi', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Telepon', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Pengalaman',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _experienceTitleController,
              decoration: const InputDecoration(labelText: 'Judul Pengalaman', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _experienceDescriptionController,
              decoration: const InputDecoration(labelText: 'Deskripsi Pengalaman', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Gambar Pengalaman',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickExperienceImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade400),
                  image: _experienceImagePath != null
                      ? DecorationImage(
                          image: _getImageProvider(_experienceImagePath)!,
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _experienceImagePath == null
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('Upload Gambar Pengalaman', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  final newInfo = ProfileInfo(
                    name: _nameController.text,
                    bio: _bioController.text,
                    education: _educationController.text,
                    hobby: _hobbyController.text,
                    email: _emailController.text,
                    phone: _phoneController.text,
                    imagePath: _imagePath,
                    experienceTitle: _experienceTitleController.text,
                    experienceDescription: _experienceDescriptionController.text,
                    experienceImagePath: _experienceImagePath,
                  );
                  Navigator.pop(context, newInfo);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Simpan Perubahan', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  final ProfileInfo info;
  final VoidCallback onEdit;
  const ProfilePage({super.key, required this.info, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Column(
                children: [
                  _buildProfileImage(info.imagePath, defaultIcon: Icons.emoji_emotions_outlined),
                  const SizedBox(height: 12),
                  Text(
                    info.name,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Mahasiswa Teknik Informatika',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Row(
              children: [
                Expanded(child: _StatBox(label: 'Post', value: '12')),
                Expanded(child: _StatBox(label: 'Teman', value: '128')),
                Expanded(child: _StatBox(label: 'Like', value: '1.2K')),
              ],
            ),
            const SizedBox(height: 24),
            _SectionCard(
              icon: Icons.info_outline,
              title: 'Tentang Saya',
              content: info.bio,
            ),
            _SectionCard(
              icon: Icons.school,
              title: 'Pendidikan',
              content: info.education,
            ),
            _SectionCard(
              icon: Icons.favorite,
              title: 'Hobi & Minat',
              content: info.hobby,
            ),
            _SectionCard(
              icon: Icons.email,
              title: 'Kontak',
              content: '${info.email}\n${info.phone}',
            ),
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.star, color: Colors.pink, size: 28),
                        SizedBox(width: 16),
                        Text('Skills',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: const [
                        Chip(label: Text('Matematika')),
                        Chip(label: Text('Statistika')),
                        Chip(label: Text('Analitik')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Section Pengalaman
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.work, color: Colors.pink, size: 28),
                        SizedBox(width: 16),
                        Text('Pengalaman',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Gambar Pengalaman (Kotak)
                        Builder(
                          builder: (context) {
                            final imagePath = info.experienceImagePath;
                            if (imagePath != null && imagePath.isNotEmpty) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image(
                                  image: _getImageProvider(imagePath)!,
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => 
                                    _buildExperienceSquarePlaceholder(),
                                ),
                              );
                            } else {
                              return _buildExperienceSquarePlaceholder();
                            }
                          },
                        ),
                        const SizedBox(width: 16),
                        // Judul & Deskripsi
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                info.experienceTitle,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                info.experienceDescription,
                                style: const TextStyle(height: 1.4, color: Colors.black87),
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onEdit,
        child: const Icon(Icons.edit),
      ),
    );
  }

  Widget _buildExperiencePlaceholder() {
    return Container(
      height: 200,
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
            SizedBox(height: 8),
            Text('Gambar pengalaman belum diatur', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  const _SectionCard(
      {required this.icon, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.pink, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(content, style: const TextStyle(height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GalleryHome extends StatelessWidget {
  const GalleryHome({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      ('Display', Icons.image, Colors.blue),
      ('Input', Icons.edit, Colors.green),
      ('Button', Icons.smart_button, Colors.orange),
      ('Feedback', Icons.notifications, Colors.purple),
      ('Layout', Icons.dashboard, Colors.pink),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Widget Gallery')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final (name, icon, color) = categories[i];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: color,
                child: Icon(icon, color: Colors.white),
              ),
              title: Text(name),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => CategoryPage(name: name))),
            ),
          );
        },
      ),
    );
  }
}

class CategoryPage extends StatelessWidget {
  final String name;
  const CategoryPage({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final body = switch (name) {
      'Display' => const _DisplayDemo(),
      'Input' => const _InputDemo(),
      'Button' => const _ButtonDemo(),
      'Feedback' => const _FeedbackDemo(),
      'Layout' => const _LayoutDemo(),
      _ => const Center(child: Text('?')),
    };
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: body,
      ),
    );
  }
}

class _DisplayDemo extends StatelessWidget {
  const _DisplayDemo();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Card', style: TextStyle(fontWeight: FontWeight.bold)),
        const Card(
          child: ListTile(
            leading: Icon(Icons.album),
            title: Text('Judul Item'),
            subtitle: Text('Sub-judul'),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Chip', style: TextStyle(fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8,
          children: const [
            Chip(label: Text('Flutter')),
            Chip(label: Text('Dart')),
            Chip(label: Text('Mobile')),
          ],
        ),
        const SizedBox(height: 16),
        const Text('Divider', style: TextStyle(fontWeight: FontWeight.bold)),
        const Divider(thickness: 2),
        const SizedBox(height: 16),
        const Text('CircleAvatar & Icon',
            style: TextStyle(fontWeight: FontWeight.bold)),
        Row(children: const [
          CircleAvatar(child: Text('A')),
          SizedBox(width: 12),
          CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.check)),
          SizedBox(width: 12),
          Icon(Icons.star, color: Colors.amber, size: 40),
        ]),
      ],
    );
  }
}

class _InputDemo extends StatefulWidget {
  const _InputDemo();
  @override
  State<_InputDemo> createState() => _InputDemoState();
}

class _InputDemoState extends State<_InputDemo> {
  bool _checked = false;
  bool _switched = true;
  double _slider = 0.5;
  String? _dropdown = 'Apel';
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('TextField'),
        const SizedBox(height: 4),
        const TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Nama',
            hintText: 'Ketik nama Anda',
          ),
        ),
        const SizedBox(height: 16),
        CheckboxListTile(
          title: const Text('Checkbox'),
          value: _checked,
          onChanged: (v) => setState(() => _checked = v ?? false),
        ),
        SwitchListTile(
          title: const Text('Switch'),
          value: _switched,
          onChanged: (v) => setState(() => _switched = v),
        ),
        const Text('Slider'),
        Slider(value: _slider, onChanged: (v) => setState(() => _slider = v)),
        const SizedBox(height: 8),
        const Text('Dropdown'),
        DropdownButton<String>(
          value: _dropdown,
          items: ['Apel', 'Jeruk', 'Mangga']
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) => setState(() => _dropdown = v),
        ),
      ],
    );
  }
}

class _ButtonDemo extends StatelessWidget {
  const _ButtonDemo();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(onPressed: () {}, child: const Text('Elevated')),
        const SizedBox(height: 8),
        FilledButton(onPressed: () {}, child: const Text('Filled')),
        const SizedBox(height: 8),
        OutlinedButton(onPressed: () {}, child: const Text('Outlined')),
        const SizedBox(height: 8),
        TextButton(onPressed: () {}, child: const Text('Text Button')),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.send),
          label: const Text('Dengan Icon'),
        ),
        const SizedBox(height: 8),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.favorite, color: Colors.red),
        ),
      ],
    );
  }
}

class _FeedbackDemo extends StatelessWidget {
  const _FeedbackDemo();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Halo dari SnackBar!')),
            );
          },
          child: const Text('Tampilkan SnackBar'),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Konfirmasi'),
                content: const Text('Yakin ingin lanjut?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Ya'),
                  ),
                ],
              ),
            );
          },
          child: const Text('Tampilkan Dialog'),
        ),
        const SizedBox(height: 16),
        const Text('Progress Indicator:'),
        const SizedBox(height: 8),
        const LinearProgressIndicator(value: 0.6),
        const SizedBox(height: 12),
        const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}

class _LayoutDemo extends StatelessWidget {
  const _LayoutDemo();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Stack — widget bertumpuk'),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: Stack(
            children: [
              Container(width: double.infinity, color: Colors.blue.shade100),
              Positioned(
                top: 12,
                left: 12,
                child: Container(width: 50, height: 50, color: Colors.red),
              ),
              const Positioned(
                bottom: 12,
                right: 12,
                child: Icon(Icons.star, size: 40, color: Colors.amber),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text('Wrap — auto-pindah baris saat penuh'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(
              8,
                  (i) => Container(
                padding: const EdgeInsets.all(12),
                color: Colors.pink.shade100,
                child: Text('Item ${i + 1}'),
              )),
        ),
        const SizedBox(height: 16),
        const Text('GridView (count: 3)'),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: List.generate(
                6,
                    (i) => Container(
                  color: Colors.purple.shade100,
                  alignment: Alignment.center,
                  child: Text('${i + 1}'),
                )),
          ),
        ),
      ],
    );
  }
}

class EditExperiencePage extends StatefulWidget {
  final ProfileInfo info;
  const EditExperiencePage({super.key, required this.info});

  @override
  State<EditExperiencePage> createState() => _EditExperiencePageState();
}

class _EditExperiencePageState extends State<EditExperiencePage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.info.experienceTitle);
    _descriptionController = TextEditingController(text: widget.info.experienceDescription);
    _imagePath = widget.info.experienceImagePath;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Pengalaman'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                  image: _imagePath != null
                      ? DecorationImage(
                          image: _getImageProvider(_imagePath)!,
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _imagePath == null
                    ? const Icon(Icons.add_a_photo, size: 50, color: Colors.grey)
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Judul Pengalaman',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi Singkat',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  final newInfo = ProfileInfo(
                    name: widget.info.name,
                    bio: widget.info.bio,
                    education: widget.info.education,
                    hobby: widget.info.hobby,
                    email: widget.info.email,
                    phone: widget.info.phone,
                    imagePath: widget.info.imagePath,
                    experienceTitle: _titleController.text,
                    experienceDescription: _descriptionController.text,
                    experienceImagePath: _imagePath,
                  );
                  Navigator.pop(context, newInfo);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Simpan Perubahan', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
