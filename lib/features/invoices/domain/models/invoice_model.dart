import 'package:equatable/equatable.dart';

class Invoice extends Equatable {
  final int? id;
  final String invoiceNumber;
  final int customerId;
  final String customerName; // For display convenience
  final DateTime date;
  final DateTime dueDate;
  final List<InvoiceItem> items;
  final double subtotal;
  final double tax;
  final double discount;
  final double grandTotal;
  final String status; // PAID, UNPAID, OVERDUE

  const Invoice({
    this.id,
    required this.invoiceNumber,
    required this.customerId,
    required this.customerName,
    required this.date,
    required this.dueDate,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.discount,
    required this.grandTotal,
    required this.status,
  });

  Invoice copyWith({
    int? id,
    String? invoiceNumber,
    int? customerId,
    String? customerName,
    DateTime? date,
    DateTime? dueDate,
    List<InvoiceItem>? items,
    double? subtotal,
    double? tax,
    double? discount,
    double? grandTotal,
    String? status,
  }) {
    return Invoice(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      date: date ?? this.date,
      dueDate: dueDate ?? this.dueDate,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      discount: discount ?? this.discount,
      grandTotal: grandTotal ?? this.grandTotal,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'customerId': customerId,
      'date': date.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'subtotal': subtotal,
      'tax': tax,
      'discount': discount,
      'grandTotal': grandTotal,
      'status': status,
    };
  }

  factory Invoice.fromMap(Map<String, dynamic> map, List<InvoiceItem> items, String customerName) {
    return Invoice(
      id: map['id'] as int?,
      invoiceNumber: map['invoiceNumber'] as String,
      customerId: map['customerId'] as int,
      customerName: customerName,
      date: DateTime.parse(map['date'] as String),
      dueDate: DateTime.parse(map['dueDate'] as String),
      items: items,
      subtotal: map['subtotal'] as double,
      tax: map['tax'] as double,
      discount: map['discount'] as double,
      grandTotal: map['grandTotal'] as double,
      status: map['status'] as String,
    );
  }

  @override
  List<Object?> get props => [
        id,
        invoiceNumber,
        customerId,
        customerName,
        date,
        dueDate,
        items,
        subtotal,
        tax,
        discount,
        grandTotal,
        status
      ];
}

class InvoiceItem extends Equatable {
  final int? id;
  final int? invoiceId;
  final String itemName;
  final int qty;
  final double price;
  final double tax;

  const InvoiceItem({
    this.id,
    this.invoiceId,
    required this.itemName,
    required this.qty,
    required this.price,
    required this.tax,
  });

  Map<String, dynamic> toMap(int invoiceId) {
    return {
      'id': id,
      'invoiceId': invoiceId,
      'itemName': itemName,
      'qty': qty,
      'price': price,
      'tax': tax,
    };
  }

  factory InvoiceItem.fromMap(Map<String, dynamic> map) {
    return InvoiceItem(
      id: map['id'] as int?,
      invoiceId: map['invoiceId'] as int?,
      itemName: map['itemName'] as String,
      qty: map['qty'] as int,
      price: map['price'] as double,
      tax: map['tax'] as double,
    );
  }

  @override
  List<Object?> get props => [id, invoiceId, itemName, qty, price, tax];
}
