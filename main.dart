import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;//paket http ini digunakan untuk memproses permintaan ke api.

class ResiTrackingApp extends StatefulWidget {
  @override
  _ResiTrackingAppState createState() => _ResiTrackingAppState();
}//ResiTrackingApp adalah kelas utama yang mewakili aplikasi pelacakan resi. Ini mengimplementasikan StatefulWidget, yang berarti memiliki keadaan yang dapat berubah.
//Kelas _ResiTrackingAppState adalah kelas yang mengatur state dari ResiTrackingApp. Ini memiliki variabel state seperti _resiNumber, _selectedCourier, dan _trackingResult. Metode _trackResi() digunakan untuk melacak resi dan mengupdate hasil pelacakan.
//
// Antarmuka pengguna (UI) dibangun dalam metode build(). Ini mencakup dropdown untuk memilih kurir, input nomor resi, dan tombol "Track Resi". Hasil pelacakan resi ditampilkan dalam Text.
//
// Kelas ResiTrackingApp dan _ResiTrackingAppState bekerja sama untuk mengelola state dan membangun antarmuka pengguna yang interaktif untuk aplikasi pelacakan resi.

class _ResiTrackingAppState extends State<ResiTrackingApp> {
  String _resiNumber = '';
  String _selectedCourier = 'jne'; // JNE sebagai nilai awal
  String _trackingResult = '';

  Map<String, String> _courierApiUrls = {
    'jne': 'https://api.binderbyte.com/v1/track?api_key=4099debe0dcf2f5ecd13c57f5ed043a6e7ed45c8d8175455712822fd374f738a&courier=jne&awb=8825112045716759',
    'tiki': 'https://api.binderbyte.com/v1/track?api_key=4099debe0dcf2f5ecd13c57f5ed043a6e7ed45c8d8175455712822fd374f738a&courier=tiki&awb=030205696069',
    'sicepat': 'https://api.binderbyte.com/v1/track?api_key=4099debe0dcf2f5ecd13c57f5ed043a6e7ed45c8d8175455712822fd374f738a&courier=sicepat&awb=000779194122',
  };//_courierApiUrls (baris 20-23) adalah sebuah Map yang menyimpan URL API untuk masing-masing kurir. Setiap kurir memiliki URL API yang berbeda dan diakses melalui kunci yang sesuai.

  Future<void> _trackResi() async {
    String apiUrl = _courierApiUrls[_selectedCourier]! + '&awb=$_resiNumber';


    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final summary = jsonResponse['data']['summary'];

        setState(() {
          _trackingResult = '''
            Nomor Resi: ${summary['awb']}
            Kurir: ${summary['courier']}
            Status: ${summary['status']}
            Tanggal Pengiriman: ${summary['date']}
            Biaya: ${summary['amount']}
            Berat: ${summary['weight']}
            Lokasi Asal: ${jsonResponse['data']['detail']['origin']}
            Lokasi Tujuan: ${jsonResponse['data']['detail']['destination']}
            Pengirim: ${jsonResponse['data']['detail']['shipper']}
            Penerima: ${jsonResponse['data']['detail']['receiver']}
            Riwayat Pengiriman:
            ${_buildHistoryText(jsonResponse['data']['history'])}
          ''';
        });
      } else {
        setState(() {
          _trackingResult = 'Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _trackingResult = 'Error: $e';
      });
    }
  }
  //Di dalam metode _trackResi (baris 26-63), API URL diambil dari _courierApiUrls berdasarkan kurir yang dipilih (_selectedCourier). Nilai nomor resi (_resiNumber) ditambahkan ke URL menggunakan string interpolation (&awb=$_resiNumber).
// Kemudian, permintaan HTTP GET dilakukan menggunakan paket http untuk mengambil data dari URL API.


//Jika respons kode status HTTP adalah 200 , respons JSON dikura menjadi objek menggunakan jsonDecode. Informasi ringkasan seperti nomor resi, kurir, status, tanggal pengiriman, biaya, berat, lokasi asal, lokasi tujuan, pengirim, dan penerima
//   // diambil dari objek JSON dan ditetapkan ke _trackingResult. Selain itu,
//   // riwayat pengiriman juga diambil dari objek JSON menggunakan metode _buildHistoryText dan ditambahkan ke _trackingResult.
//   //Jika respons kode status HTTP bukan 200, maka pesan error ditetapkan ke _trackingResult.

  String _buildHistoryText(List<dynamic> history) {
    String result = '';
    for (var event in history) {
      result += '${event['date']} - ${event['desc']}\n';
    }
    return result;
  }
  //Metode _buildHistoryText (baris 48-56) digunakan untuk membangun teks riwayat pengiriman berdasarkan daftar riwayat yang diterima dari objek JSON.
  // Setiap entri riwayat berisi tanggal dan deskripsi yang ditambahkan ke string result.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Cek Resi'),
        ),
        body: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCourier,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedCourier = newValue!;
                      });
                    },
                    items: [
                      DropdownMenuItem<String>(
                        value: 'jne',
                        child: Text('JNE'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'tiki',
                        child: Text('TIKI'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'sicepat',
                        child: Text('SiCepat'),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _resiNumber = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Nomor Resi',
                    ),
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                _trackResi();
              },
              child: Text('Track Resi'),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Text(_trackingResult),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
//Di dalam metode build (baris 61-112), antarmuka pengguna dibangun menggunakan widget Flutter.
// Terdapat Row yang berisi DropdownButtonFormField untuk memilih kurir dan TextField untuk memasukkan nomor resi.
// Ketika nilai kurir atau nomor resi berubah, metode onChanged dipanggil untuk mengupdate nilai variabel dan memperbarui tampilan.

//Terdapat ElevatedButton yang akan memanggil metode _trackResi ketika ditekan.
// Kemudian, hasil pelacakan ditampilkan dalam Text yang ditempatkan dalam SingleChildScrollView untuk memungkinkan pengguliran jika teks terlalu panjang.

void main() {
  runApp(ResiTrackingApp());
}


//aplikasi cek resi ini hanya bisa untuk cek resi yang mengandung angka saja
//jika no resi ada hurufnya belum bisa di cek di aplikasi ini akan muncul eror


// untuk uji coba bisa menggunakan no resi ini

//jne
// 8825112045716759

// tiki
// 030205696069

// sicepat
// 000779194122
