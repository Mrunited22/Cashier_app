import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kasir Simple',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: KasirPage(),
    );
  }
}

class KasirPage extends StatefulWidget {
  @override
  _KasirPageState createState() => _KasirPageState();
}

class _KasirPageState extends State<KasirPage> {
  final List<Map<String, dynamic>> produk = [
    {'nama': 'Kopi Hitam', 'harga': 15000},
    {'nama': 'Teh Manis', 'harga': 10000},
    {'nama': 'Roti Bakar', 'harga': 12000},
    {'nama': 'Mie Goreng', 'harga': 15000},
  ];

  List<Map<String, dynamic>> keranjang = [];
  int total = 0;

  void tambahKeKeranjang(Map<String, dynamic> item) {
    setState(() {
      int index = keranjang.indexWhere((k) => k['nama'] == item['nama']);
      if (index != -1) {
        keranjang[index]['qty'] += 1;
      } else {
        keranjang.add({...item, 'qty': 1});
      }
      hitungTotal();
    });
  }

  void kurangQty(int index) {
    setState(() {
      if (keranjang[index]['qty'] > 1) {
        keranjang[index]['qty'] -= 1;
      } else {
        keranjang.removeAt(index);
      }
      hitungTotal();
    });
  }

  void tambahQty(int index) {
    setState(() {
      keranjang[index]['qty'] += 1;
      hitungTotal();
    });
  }

  void hapusItem(int index) {
    setState(() {
      keranjang.removeAt(index);
      hitungTotal();
    });
  }

  void hitungTotal() {
    total = keranjang.fold(0, (sum, item) => sum + (item['harga'] * item['qty']));
  }

  void bayar() {
    if (keranjang.isEmpty) return;
    showDialog(
      context: context,
      builder: (ctx) {
        TextEditingController bayarCtrl = TextEditingController();
        return AlertDialog(
          title: Text('Pembayaran'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Total: Rp $total'),
              TextField(
                controller: bayarCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Jumlah Bayar'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Batal')),
            ElevatedButton(
              onPressed: () {
                int bayar = int.tryParse(bayarCtrl.text) ?? 0;
                if (bayar < total) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Uang kurang!'))
                  );
                  return;
                }
                int kembalian = bayar - total;
                Navigator.pop(ctx);
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('Berhasil'),
                    content: Text('Kembalian: Rp $kembalian'),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            keranjang.clear();
                            total = 0;
                          });
                          Navigator.pop(ctx);
                        },
                        child: Text('OK'),
                      )
                    ],
                  ),
                );
              },
              child: Text('Bayar'),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kasir Simple')),
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: GridView.builder(
              padding: EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
              ),
              itemCount: produk.length,
              itemBuilder: (context, index) {
                return Card(
                  child: InkWell(
                    onTap: () => tambahKeKeranjang(produk[index]),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(produk[index]['nama'], style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Rp ${produk[index]['harga']}'),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          VerticalDivider(width: 1),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Keranjang', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: keranjang.isEmpty
                      ? Center(child: Text('Kosong'))
                      : ListView.builder(
                          itemCount: keranjang.length,
                          itemBuilder: (context, index) {
                            final item = keranjang[index];
                            return ListTile(
                              leading: CircleAvatar(child: Text('${item['qty']}')),
                              title: Text(item['nama']),
                              subtitle: Text('Rp ${item['harga'] * item['qty']}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(icon: Icon(Icons.remove_circle_outline), onPressed: () => kurangQty(index)),
                                  IconButton(icon: Icon(Icons.add_circle_outline), onPressed: () => tambahQty(index)),
                                  IconButton(icon: Icon(Icons.delete), onPressed: () => hapusItem(index)),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                Divider(),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total: Rp $total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ElevatedButton(
                        onPressed: keranjang.isEmpty ? null : bayar,
                        child: Text('BAYAR'),
                      ),
                    ],
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