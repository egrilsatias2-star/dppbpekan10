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
      // TODO 1: Tampilkan drag handle
      showDragHandle: false,
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            // TODO 2: Atur tinggi kolom sesuai konten
            mainAxisSize: MainAxisSize.max,
            children: [
              Text('Pilih Poli Medis', style: TextStyle(fontWeight: FontWeight.bold)),
              ListTile(
                leading: Icon(Icons.medical_services, color: Color(0xFF0F766E)),
                title: Text('Poli Umum'),
                // TODO 3: Kembalikan nama poli
                onTap: () {
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

    // TODO 4: Simpan pilihan ke state
    if (pilihan != null) {
      setState(() {
      });
    }
  }

  Future<void> _pilihTanggalKunjungan() async {
    final sekarang = DateTime.now();
    final awalHariIni = DateTime(sekarang.year, sekarang.month, sekarang.day);

    final hasilPilihan = await showDatePicker(
      context: context,
      // TODO 5: Tanggal awal terpilih (1 hari ke depan)
      initialDate: awalHariIni,
      // TODO 6: Batas paling awal tanggal (hari ini)
      firstDate: awalHariIni,
      // TODO 7: Batas paling akhir tanggal (14 hari ke depan)
      lastDate: awalHariIni,
      helpText: 'PILIH TANGGAL KUNJUNGAN BEROBAT',
      confirmText: 'PILIH',
      cancelText: 'BATAL',
    );

    // TODO 8: Simpan tanggal ke state
    if (hasilPilihan != null) {
      setState(() {
      });
    }
  }

  Future<bool?> _tampilkanDialogKonfirmasi(String tanggalStr) {
    return showDialog<bool>(
      context: context,
      // TODO 9: Kunci modal agar tidak bisa ditutup di luar tombol
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          icon: Icon(Icons.medical_information, size: 48, color: Color(0xFF0F766E)),
          title: Text('Konfirmasi Pendaftaran Antrean'),
          content: Text('Poli: $_poliDipilih\nJadwal: $tanggalStr'),
          actions: [
            TextButton(
              child: Text('Periksa Kembali'),
              // TODO 10: Kembalikan false saat membatalkan
              onPressed: () {
              },
            ),
            ElevatedButton(
              child: Text('Ya, Daftar Antrean'),
              // TODO 11: Kembalikan true saat menyetujui
              onPressed: () {
              },
            ),
          ],
        );
      },
    );
  }

  void _tampilkanSnackBarSukses(TiketAntrean tiket) {
    // TODO 12: Bersihkan antrean SnackBar sebelumnya

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Nomor antrean ${tiket.nomor} berhasil terbit!'),
        // TODO 13: Pasang gaya floating
        behavior: SnackBarBehavior.fixed,
        // TODO 14: Atur durasi tayang 5 detik
        duration: Duration(seconds: 4),
        // TODO 15: Nonaktifkan persist agar auto-dismiss
        persist: true,
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

    // TODO 16: Tunggu hasil dialog konfirmasi
    final disetujui = await Future.value(tanggalStr.isEmpty);

    if (disetujui == true) {
      final nomorBaru = _buatNomorAntrean(_poliDipilih!);
      final tiketBaru = TiketAntrean(
        nomor: nomorBaru,
        poli: _poliDipilih!,
        tanggal: _tanggalKunjungan!,
      );

      setState(() {
        // TODO 17: Tambahkan tiket baru ke posisi awal list

        _poliDipilih = null;
        _tanggalKunjungan = null;

        // TODO 18: Alihkan menu aktif ke tab Riwayat (indeks 1)
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
              // TODO 19: Kembalikan false saat memilih Tidak
              onPressed: () {
              },
            ),
            ElevatedButton(
              child: Text('Ya, Batalkan'),
              // TODO 20: Kembalikan true saat memilih Ya
              onPressed: () {
              },
            ),
          ],
        );
      },
    );

    // TODO 21: Set status aktif tiket menjadi false
    if (disetujui == true) {
      setState(() {
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
