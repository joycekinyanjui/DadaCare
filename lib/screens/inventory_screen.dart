import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InventoryItem {
  String facility;
  String category;
  String item;
  double cost;
  int available;

  InventoryItem(
    this.facility,
    this.category,
    this.item,
    this.cost,
    this.available,
  );
}

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String? doctorHospital;

  final List<InventoryItem> _allItems = [
    InventoryItem(
      "Pumwani Maternity Hospital",
      "Medications",
      "Ibuprofen 400mg",
      1935.25,
      94,
    ),
    InventoryItem(
      "Kakamega County Referral Hospital",
      "Medications",
      "Combined Oral Contraceptives",
      4758.50,
      28,
    ),
    InventoryItem(
      "Machakos Level 5 Hospital",
      "Medications",
      "Paracetamol 500mg",
      3686.77,
      86,
    ),
    InventoryItem(
      "Embu Level 5 Hospital",
      "Medications",
      "Paracetamol 500mg",
      3033.43,
      75,
    ),
    InventoryItem(
      "Mombasa County Hospital",
      "Medications",
      "Ibuprofen 400mg",
      864.49,
      3,
    ),
  ];

  List<InventoryItem> filteredItems = [];

  @override
  void initState() {
    super.initState();
    loadHospital();
  }

  Future<void> loadHospital() async {
    final prefs = await SharedPreferences.getInstance();
    doctorHospital = prefs.getString("doctor_hospital");
    if (doctorHospital != null) {
      filteredItems =
          _allItems.where((e) => e.facility == doctorHospital).toList();
    }
    setState(() {});
  }

  void showItemForm({InventoryItem? existingItem, int? index}) {
    final itemController = TextEditingController(
      text: existingItem?.item ?? '',
    );
    final categoryController = TextEditingController(
      text: existingItem?.category ?? '',
    );
    final costController = TextEditingController(
      text: existingItem?.cost.toString() ?? '',
    );
    final stockController = TextEditingController(
      text: existingItem?.available.toString() ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (ctx) => Padding(
            padding: EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  existingItem == null ? "Add Item" : "Edit Item",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: itemController,
                  decoration: const InputDecoration(labelText: 'Item Name'),
                ),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                TextField(
                  controller: costController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Cost (KES)'),
                ),
                TextField(
                  controller: stockController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Stock Available',
                  ),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {
                    final newItem = InventoryItem(
                      doctorHospital!,
                      categoryController.text,
                      itemController.text,
                      double.tryParse(costController.text) ?? 0,
                      int.tryParse(stockController.text) ?? 0,
                    );

                    setState(() {
                      if (index != null) {
                        filteredItems[index] = newItem;
                      } else {
                        filteredItems.add(newItem);
                      }
                    });

                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                  ),
                  child: Text(
                    existingItem == null ? "Add Item" : "Save Changes",
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void removeItem(int index) {
    setState(() {
      filteredItems.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: const Text("Inventory"),
        actions: [
          IconButton(
            onPressed: () => showItemForm(),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body:
          filteredItems.isEmpty
              ? const Center(child: Text("No items for your hospital."))
              : ListView.builder(
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    color: Colors.white,
                    child: ListTile(
                      onTap:
                          () => showItemForm(existingItem: item, index: index),
                      title: Text(item.item),
                      subtitle: Text(
                        "Category: ${item.category}\nCost: KES ${item.cost}\nStock: ${item.available}",
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => removeItem(index),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
