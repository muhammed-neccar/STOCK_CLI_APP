import "package:path/path.dart" as p;
import "package:sqlite3/sqlite3.dart";
import "dart:io";
import 'dart:ffi';


class Sqldb {
  late final Database db;

  void initDatabase() {
    final dbPath = p.join(Directory.current.path, "laptops.db");
    db = sqlite3.open(dbPath);

    db.execute('''
    CREATE TABLE IF NOT EXISTS laptops (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    brand TEXT NOT NULL,
    model TEXT NOT NULL,
    cpu TEXT ,
    ram TEXT,
    storage TEXT,
    gpu TEXT,
    price REAL NOT NULL,
    added_date TEXT NOT null,
    last_modified TEXT

    );
''');

    db.execute('''

  CREATE TABLE IF NOT EXISTS sales(
  sales_id INTEGER PRIMARY KEY AUTOINCREMENT,
  laptop_id INTEGER NOT NULL,
  customer_name TEXT NOT NULL,
  sale_date TEXT NOT NULL,
  price_at_sale REAL BOT NULL,
  vat REAL NOT NULL,
  total_price REAL NOT NULL,
  FOREIGN KEY (laptop_id) REFERENCES laptops(id)
  );
''');
    print("create database is sucssufly.");
  }

  void insertLaptop({
    required String brand,
    required String model,
    String? cpu,
    String? ram,
    String? storage,
    String? gpu,
    required double price,
  }) {
    final now = DateTime.now().toIso8601String();

    db.execute(
      '''
    INSERT INTO laptops (brand, model, cpu, ram, storage,gpu,
    price,added_date,last_modified)
    VALUES (?,?,?,?,?,?,?,?,?)
''',
      [brand, model, cpu, ram, storage, gpu, price, now, now],
    );
  }

  void getAllLaptops() {
    final ResultSet result = db.select("SELECT *FROM laptops");

    if (result.isEmpty) {
      print("no laptops to show");
    } else {
      print("laptops list: ");
      for (final row in result) {
        print('ID: ${row['id']} | ${row['brand']} | ${row['model']}  | ${row['storage']}  | ${row['ram']} -  \$${row['price']} -  ${row['added_date']}');
      }
    }
  }

  // UPDATE

  void updateLaptop(int id, double newPrice) {
    final now = DateTime.now().toIso8601String();

    db.execute(
      '''
     UPDATE laptops
     SET price = ? , last_modified =?
     Where id = ?
     ''',
      [newPrice, now, id],
    );

    print("laptop price updated.");
  }

  void deleteLaptop(int id) {
    db.execute("DELETE FROM laptops WHERE id = ?", [id]);
    print("laptop deleted from inventory");
  }

  /*-----------------------
        SALES METHODS
  -------------------------*/

  void sellLaptop({required int laptopId, required String customerName}) {
    final now = DateTime.now().toIso8601String();
    final Result = db.select("SELECT price FROM laptops WHERE ID = ?", [
      laptopId,
    ]);

    if (Result.isEmpty) {
      print("Laptop not found.");
      return;
    }

    final price = Result.first['price'] as double;
    final vat = price * 0.19;
    final total = price + vat;

    db.execute(
      '''
    
    INSERT INTO sales (laptop_id, customer_name,
     sale_date , price_at_sale,vat,total_price)
    VALUES (?,?,?,?,?,?)
''',
      [laptopId, customerName, now, price, vat, total],
    );

    print("sale completed. Total: \$${total.toStringAsFixed(2)}");
    print("customer name:  ${customerName}");
  }

  void monthlyReport(int month, int year) {
    final result = db.select('''
      
      SELECT s.sales_id , l.brand, l.model , s.customer_name
      s.sale_date , s.total_price FROM sales s
      JOIN laptops 1 ON s.laptop_id = l.id
''');

    print("sales Report for $month/$year: \n");

    bool hasSales = false;
    double totalRevenue = 0;

    for (final row in result) {
      final date = DateTime.parse(row['sale_date']);

      if (date.month == month && date.year == year) {
        hasSales = true;
        print('''
           Sale ID: ${row['sales_id']} | 
           ${row['brand']} ${row['model']} |
           Customer: ${row['customer_name']} | 
           Date: ${row['sale_date']} |
           Total: \$${row['total_price']}
           ''');
        totalRevenue += row['total_price'] as double;
      }
    }

    if (!hasSales) {
      print("NO sales found for this month.");
    } else {
      print("\n Total Revenue: \$${totalRevenue.toStringAsFixed(2)}");
    }
  }
}
