import 'package:flutter/material.dart';
import '../models/tiket_antrean.dart';

class TabRiwayat extends StatelessWidget {
  final List<TiketAntrean> daftarRiwayat;
  final void Function(TiketAntrean) onBatalTiket;

  TabRiwayat({
    required this.daftarRiwayat,
    required this.onBatalTiket,
  });

  @override
  Widget build(BuildContext context) {
    if (daftarRiwayat.isEmpty) {
      return Center(
        child: Text('Belum Ada Riwayat Antrean'),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: daftarRiwayat.length,
      itemBuilder: (context, index) {
        final tiket = daftarRiwayat[index];
        return Card(
          child: ListTile(
            leading: Text(tiket.nomor, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            title: Text(tiket.poli),
            subtitle: Text('Jadwal: ${tiket.tanggal.day}/${tiket.tanggal.month}/${tiket.tanggal.year}'),
            trailing: tiket.isAktif
                ? OutlinedButton(
                    child: Text('Batalkan'),
                    onPressed: () { onBatalTiket(tiket); },
                  )
                : Text('Dibatalkan', style: TextStyle(color: Colors.red)),
          ),
        );
      },
    );
  }
}
