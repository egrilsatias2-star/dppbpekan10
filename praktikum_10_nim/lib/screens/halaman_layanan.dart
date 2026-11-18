import 'package:flutter/material.dart';
import '../models/tiket_antrean.dart';
import '../widgets/tab_beranda.dart';
import '../widgets/tab_riwayat.dart';

class HalamanLayanan extends StatefulWidget {
  @override
  _HalamanLayananState createState() {
    return _HalamanLayananState();
  }
}

class _HalamanLayananState extends State<HalamanLayanan> {
  int _currentIndex = 0;
  String? _poliDipilih;
  DateTime? _tanggalKunjungan;
  final List<TiketAntrean> _daftarRiwayat = [];

  String _buatNomorAntrean(String poli) {
    String prefix = 'A';
    if (poli.contains('Gigi')) {
      prefix = 'B';
    } else if (poli.contains('KIA')) {
      prefix = 'C';
    } else if (poli.contains('Lansia')) {
      prefix = 'D';
    }
    int urutan = _daftarRiwayat.length + 1;
    String nomorUrut = urutan.toString().padLeft(3, '0');
    return '$prefix-$nomorUrut';
  }

  Future<void> _bukaPilihanPoli() async {
    final pilihan = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Pilih Poli Medis', style: TextStyle(fontWeight: FontWeight.bold)),
              ListTile(
                leading: Icon(Icons.medical_services, color: Color(0xFF0F766E)),
                title: Text('Poli Umum'),
                onTap: () {
                  Navigator.pop(context, 'Poli Umum');
                },
              ),
              ListTile(leading: Icon(Icons.sentiment_satisfied_alt, color: Colors.blue), title: Text('Poli Gigi & Mulut'), onTap: () { Navigator.pop(context, 'Poli Gigi & Mulut'); }),
              ListTile(leading: Icon(Icons.family_restroom, color: Colors.pink), title: Text('Poli KIA & Imunisasi'), onTap: () { Navigator.pop(context, 'Poli KIA & Imunisasi'); }),
              ListTile(leading: Icon(Icons.elderly, color: Colors.orange[800]), title: Text('Poli Lansia & PTM'), onTap: () { Navigator.pop(context, 'Poli Lansia & PTM'); }),
            ],
          ),
        );
      },
    );

    if (pilihan != null) {
      setState(() {
        _poliDipilih = pilihan;
      });
    }
  }

  Future<void> _pilihTanggalKunjungan() async {
    final sekarang = DateTime.now();
    final awalHariIni = DateTime(sekarang.year, sekarang.month, sekarang.day);

    final hasilPilihan = await showDatePicker(
      context: context,
      initialDate: awalHariIni.add(const Duration(days: 1)),
      firstDate: awalHariIni,
      lastDate: awalHariIni.add(const Duration(days: 14)),
      helpText: 'PILIH TANGGAL KUNJUNGAN BEROBAT',
      confirmText: 'PILIH',
      cancelText: 'BATAL',
    );

    if (hasilPilihan != null) {
      setState(() {
        _tanggalKunjungan = hasilPilihan;
      });
    }
  }

  Future<bool?> _tampilkanDialogKonfirmasi(String tanggalStr) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          icon: Icon(Icons.medical_information, size: 48, color: Color(0xFF0F766E)),
          title: Text('Konfirmasi Pendaftaran Antrean'),
          content: Text('Poli: $_poliDipilih\nJadwal: $tanggalStr'),
          actions: [
            TextButton(
              child: Text('Periksa Kembali'),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            ElevatedButton(
              child: Text('Ya, Daftar Antrean'),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
          ],
        );
      },
    );
  }

  void _tampilkanSnackBarSukses(TiketAntrean tiket) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Nomor antrean ${tiket.nomor} berhasil terbit!'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        persist: false,
        action: SnackBarAction(
          label: 'BATALKAN',
          textColor: Colors.amberAccent,
          onPressed: () {
            setState(() {
              tiket.isAktif = false;
            });
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  Future<void> _prosesPendaftaran() async {
    if (_poliDipilih == null || _tanggalKunjungan == null) return;
    final tanggalStr = '${_tanggalKunjungan!.day}/${_tanggalKunjungan!.month}/${_tanggalKunjungan!.year}';

    final disetujui = await _tampilkanDialogKonfirmasi(tanggalStr);

    if (disetujui == true) {
      final nomorBaru = _buatNomorAntrean(_poliDipilih!);
      final tiketBaru = TiketAntrean(
        nomor: nomorBaru,
        poli: _poliDipilih!,
        tanggal: _tanggalKunjungan!,
      );

      setState(() {
        _daftarRiwayat.insert(0, tiketBaru);
        _poliDipilih = null;
        _tanggalKunjungan = null;
        _currentIndex = 1;
      });

      _tampilkanSnackBarSukses(tiketBaru);
    }
  }

  Future<void> _konfirmasiBatalTiket(TiketAntrean tiket) async {
    final disetujui = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          icon: Icon(Icons.warning_amber_rounded, size: 48, color: Colors.red),
          title: Text('Batalkan Nomor Antrean?'),
          content: Text('Batalkan antrean ${tiket.nomor}?'),
          actions: [
            TextButton(
              child: Text('Tidak'),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            ElevatedButton(
              child: Text('Ya, Batalkan'),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
          ],
        );
      },
    );

    if (disetujui == true) {
      setState(() {
        tiket.isAktif = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('E-Puskesmas Kota Bandung'),
        backgroundColor: Color(0xFF0F766E),
        foregroundColor: Colors.white,
      ),
      body: [
        TabBeranda(
          poliDipilih: _poliDipilih,
          tanggalKunjungan: _tanggalKunjungan,
          onPilihPoli: () {
            _bukaPilihanPoli();
          },
          onPilihTanggal: () {
            _pilihTanggalKunjungan();
          },
          onSubmit: () {
            _prosesPendaftaran();
          },
        ),
        TabRiwayat(
          daftarRiwayat: _daftarRiwayat,
          onBatalTiket: (tiket) {
            _konfirmasiBatalTiket(tiket);
          },
        ),
      ][_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Riwayat',
          ),
        ],
      ),
    );
  }
}
