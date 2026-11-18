import 'package:flutter/material.dart';

void main() {
  runApp(const TesAkhirApp());
}

class LaporanPju {
  final String nomorTiket;
  final String alamat;
  final String kecamatan;
  final DateTime tanggal;
  bool aktif;

  LaporanPju({
    required this.nomorTiket,
    required this.alamat,
    required this.kecamatan,
    required this.tanggal,
    this.aktif = true,
  });
}

class TesAkhirApp extends StatelessWidget {
  const TesAkhirApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lapor Lampu PJU Padam',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F766E)),
      ),
      home: const HalamanLaporan(),
    );
  }
}

class HalamanLaporan extends StatefulWidget {
  const HalamanLaporan({super.key});

  @override
  State<HalamanLaporan> createState() => _HalamanLaporanState();
}

class _HalamanLaporanState extends State<HalamanLaporan> {
  final TextEditingController _alamatController = TextEditingController();
  final List<String> _daftarKecamatan = const [
    'Coblong',
    'Sukasari',
    'Lengkong',
    'Sumur Bandung',
    'Buahbatu',
  ];
  final List<LaporanPju> _riwayat = [];
  String? _kecamatan;
  DateTime? _tanggalPadam;
  int _nomorUrut = 1;
  int _tabAktif = 0;

  @override
  void dispose() {
    _alamatController.dispose();
    super.dispose();
  }

  Future<String?> _pilihKecamatan() {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pilih Kecamatan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                for (final kecamatan in _daftarKecamatan)
                  ListTile(
                    leading: const Icon(Icons.location_city),
                    title: Text(kecamatan),
                    onTap: () => Navigator.pop(sheetContext, kecamatan),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pilihTanggal() async {
    final sekarang = DateTime.now();
    final awal = DateTime(sekarang.year, sekarang.month, sekarang.day);
    final hasil = await showDatePicker(
      context: context,
      initialDate: _tanggalPadam ?? awal,
      firstDate: awal.subtract(const Duration(days: 365)),
      lastDate: awal,
      helpText: 'PILIH TANGGAL LAMPU PADAM',
      cancelText: 'BATAL',
      confirmText: 'PILIH',
    );
    if (hasil != null) {
      setState(() => _tanggalPadam = hasil);
    }
  }

  Future<bool?> _konfirmasiPengiriman() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(Icons.lightbulb_outline, size: 48),
          title: const Text('Konfirmasi Aduan PJU'),
          content: Text(
            'Alamat: ${_alamatController.text.trim()}\n'
            'Kecamatan: $_kecamatan\n'
            'Tanggal padam: ${_formatTanggal(_tanggalPadam!)}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('BATAL'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('KIRIM ADUAN'),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _konfirmasiPembatalan(LaporanPju laporan) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(Icons.warning_amber_rounded, size: 48),
          title: const Text('Batalkan Aduan?'),
          content: Text(
            'Aduan ${laporan.nomorTiket} akan dibatalkan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('TIDAK'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('YA, BATALKAN'),
            ),
          ],
        );
      },
    );
  }

  String _formatTanggal(DateTime tanggal) {
    return '${tanggal.day}/${tanggal.month}/${tanggal.year}';
  }

  void _batalkanLaporan(LaporanPju laporan) {
    setState(() => laporan.aktif = false);
  }

  void _tampilkanSnackBar(LaporanPju laporan) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Aduan diterbitkan: ${laporan.nomorTiket}'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
          persist: false,
          action: SnackBarAction(
            label: 'BATALKAN',
            textColor: Colors.amberAccent,
            onPressed: () => _batalkanLaporan(laporan),
          ),
        ),
      );
  }

  Future<void> _kirimAduan() async {
    final alamat = _alamatController.text.trim();
    if (alamat.isEmpty || _kecamatan == null || _tanggalPadam == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lengkapi alamat, kecamatan, dan tanggal terlebih dahulu'),
        ),
      );
      return;
    }

    final disetujui = await _konfirmasiPengiriman();
    if (disetujui != true) return;

    final nomor = 'PJU-BDG-${_nomorUrut.toString().padLeft(3, '0')}';
    _nomorUrut++;
    final laporan = LaporanPju(
      nomorTiket: nomor,
      alamat: alamat,
      kecamatan: _kecamatan!,
      tanggal: _tanggalPadam!,
    );

    setState(() {
      _riwayat.insert(0, laporan);
      _alamatController.clear();
      _kecamatan = null;
      _tanggalPadam = null;
      _tabAktif = 1;
    });

    _tampilkanSnackBar(laporan);
  }

  Future<void> _batalDariRiwayat(LaporanPju laporan) async {
    final disetujui = await _konfirmasiPembatalan(laporan);
    if (disetujui == true) {
      _batalkanLaporan(laporan);
    }
  }

  Widget _formAduan() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Formulir Aduan Lampu PJU',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _alamatController,
                  decoration: const InputDecoration(
                    labelText: 'Alamat lokasi',
                    hintText: 'Contoh: Jl. Dago No. 10',
                    prefixIcon: Icon(Icons.home_outlined),
                    border: OutlineInputBorder(),
                  ),
                  minLines: 1,
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    child: Icon(Icons.location_city),
                  ),
                  title: const Text('Kecamatan'),
                  subtitle: Text(_kecamatan ?? 'Belum dipilih'),
                  trailing: OutlinedButton(
                    onPressed: () async {
                      final pilihan = await _pilihKecamatan();
                      if (pilihan != null) {
                        setState(() => _kecamatan = pilihan);
                      }
                    },
                    child: const Text('Pilih'),
                  ),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    child: Icon(Icons.calendar_month),
                  ),
                  title: const Text('Tanggal Lampu Padam'),
                  subtitle: Text(
                    _tanggalPadam == null
                        ? 'Belum ditentukan'
                        : _formatTanggal(_tanggalPadam!),
                  ),
                  trailing: OutlinedButton(
                    onPressed: _pilihTanggal,
                    child: const Text('Pilih'),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _kirimAduan,
                    icon: const Icon(Icons.send),
                    label: const Text('Kirim Aduan'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _riwayatAduan() {
    if (_riwayat.isEmpty) {
      return const Center(child: Text('Belum ada laporan aduan'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _riwayat.length,
      itemBuilder: (context, index) {
        final laporan = _riwayat[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: laporan.aktif
                  ? Colors.amber.shade100
                  : Colors.grey.shade300,
              child: Icon(
                Icons.lightbulb,
                color: laporan.aktif ? Colors.orange : Colors.grey,
              ),
            ),
            title: Text(
              laporan.nomorTiket,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${laporan.alamat}\n'
              '${laporan.kecamatan} - ${_formatTanggal(laporan.tanggal)}',
            ),
            isThreeLine: true,
            trailing: laporan.aktif
                ? TextButton(
                    onPressed: () => _batalDariRiwayat(laporan),
                    child: const Text('Batalkan'),
                  )
                : const Text(
                    'Dibatalkan',
                    style: TextStyle(color: Colors.red),
                  ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lapor Lampu PJU Padam'),
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
      ),
      body: _tabAktif == 0 ? _formAduan() : _riwayatAduan(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabAktif,
        onDestinationSelected: (index) => setState(() => _tabAktif = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.add_alert_outlined),
            selectedIcon: Icon(Icons.add_alert),
            label: 'Buat Aduan',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'Riwayat',
          ),
        ],
      ),
    );
  }
}
