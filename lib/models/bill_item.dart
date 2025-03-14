class BillItem {
  final String name;
  final double price;
  final double tax;
  List<int> assignedUsers;

  BillItem({
    required this.name,
    required this.price,
    this.tax = 0,
    List<int>? assignedUsers,
  }) : this.assignedUsers = assignedUsers ?? [];

  double getTotalWithTax() {
    return price + tax;
  }

  double getPerPersonAmount() {
    return assignedUsers.isEmpty ? 0 : getTotalWithTax() / assignedUsers.length;
  }
}
