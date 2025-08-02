    import 'dart:io';
    import 'package:sqlite3/sqlite3.dart';
    import 'package:stock_cli_app/Sqldb.dart';

    void main() {
      final db = Sqldb();
      db.initDatabase();

      startMenu(db);
    }

    enum EnProcess { add, update, delete, show, sale, monthlyReport }

    void startMenu(Sqldb db) {
      print('''
    ------------------------------------------------------
            welcome to the Inventory Mangement system
    ------------------------------------------------------
    please enter the number of the opertaion you want to perform:
    1- Add new laptop
    2- Update price laptop
    3- Delete laptop
    4- Show All Laptops
    5- sell laptop
    6- generate monthly Report
    ''');
      String again;

      do {
        runApp(db);
        stdout.write("would do you like perform another task? (y/n)");
        again = stdin.readLineSync()?.toLowerCase() ?? '';

        while (again != 'y' && again != 'n') {
          stdout.write("invalid Choice. please enter y or n: ");
          again = stdin.readLineSync()?.toLowerCase() ?? '';
        }
      } while (again == "y");
    }

    void runApp(Sqldb db) {
      while (true) {
        stdout.write("enter your choice (1-6) or enter 0 to exit: ");
        String? input = stdin.readLineSync();

        if (input == '0') {
          print("Exiting the program. Goodbye.");
          break;
        }

        int? Choice = int.tryParse(input ?? '');

        if (Choice == null || Choice < 1 || Choice > EnProcess.values.length) {
          print("invalid input, please try again.");
          continue;
        }

        EnProcess selectProcess = EnProcess.values[Choice - 1];
        userChoice(selectProcess, db);
      }
    }

    void userChoice(EnProcess process, Sqldb db) {
      switch (process) {
        case EnProcess.add:
          insertLaptop(db);
          break;
        case EnProcess.update:
          updatePrice(db);
          break;
        case EnProcess.delete:
          deleteLaptopById(db);
          break;
        case EnProcess.show:
          showAllLaptops(db);
          break;
        case EnProcess.sale:
          sellLaptop(db);
          break;
        case EnProcess.monthlyReport:
          monthlybReport(db);
          break;
      }
    }

    void insertLaptop(Sqldb db) {
      String brand, model, cpu, ram, storage, gpu;

      print("Please enter a laptop brand name: ");
      brand = stdin.readLineSync()!;

      print("Please enter a laptop model: ");
      model = stdin.readLineSync()!;

      print("Please enter the cpu name: ");
      cpu = stdin.readLineSync()!;

      print("Please enter the RAM siz: ");
      ram = stdin.readLineSync()!;

      print("Please enter the storage size(Examble: 256GB ssd): ");
      storage = stdin.readLineSync()!;

      print("Please enter the gpu name: ");
      gpu = stdin.readLineSync()!;

      double price = 0.0;

      while (true) {
        print("please enter laptop price (positive number): ");
        String? input = stdin.readLineSync();

        try {
          price = double.parse(input!);

          if (price >= 0) {
            break;
          } else {
            print("price canoot be negative.");
          }
        } catch (e) {
          print("Invalid input. please enter a valid number.");
        }
      }
      db.insertLaptop(
        brand: brand,
        model: model,
        cpu: cpu,
        ram: ram,
        storage: storage,
        gpu: gpu,
        price: price,
      );

      print("Laptop Added to stock.");
    }

    void updatePrice(Sqldb db) {
      print("please enter new price: ");
      double newPrice = double.tryParse(stdin.readLineSync()!)!;

      print("please enter new price: ");
      int id = int.tryParse(stdin.readLineSync()!)!;

      db.updateLaptop(id, newPrice);
      

      print("laptop price updated.");
    }

    void showAllLaptops(Sqldb db) {
      db.getAllLaptops();
    }

    void deleteLaptopById(Sqldb db) {
      print("please enter a deleted laptop id: ");
      int id = int.tryParse(stdin.readLineSync()!)!;
      db.deleteLaptop(id);
      print("laptop deleted.");
    }

    void sellLaptop(Sqldb db) {
      print("please enter a laptop id");
      int id = int.tryParse(stdin.readLineSync()!)!;
      print("please enter a customer  name: ");
      String customerName = stdin.readLineSync()!;
      db.sellLaptop(laptopId: id, customerName: customerName);
    }

    void monthlybReport(Sqldb db) {
      print("please enter the month number: ");
      int month = int.tryParse(stdin.readLineSync()!)!;
      print("please enter the year number: ");
      int year = int.tryParse(stdin.readLineSync()!)!;
      db.monthlyReport(month, year);

      
    }
