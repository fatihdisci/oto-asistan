import 'package:flutter/material.dart';
import '../../data/models/service_log_model.dart';
import '../../core/utils/date_formatters.dart';

class ServiceCardWidget extends StatelessWidget {
  final ServiceLogModel serviceLog;
  final VoidCallback? onDelete;
  const ServiceCardWidget({super.key, required this.serviceLog, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isMaintenance = serviceLog.type == 'MAINTENANCE';
    return Card(
      child: ListTile(
        leading: Icon(isMaintenance ? Icons.build : Icons.warning, color: isMaintenance ? Colors.blue : Colors.red),
        title: Text(isMaintenance ? 'Periyodik Bakım' : 'Arıza Onarımı'),
        subtitle: Text('${DateFormatters.formatDate(serviceLog.date)} - ${serviceLog.kmAtService} KM'),
        trailing: Text('${serviceLog.costTotal.toStringAsFixed(0)} ₺', style: const TextStyle(fontWeight: FontWeight.bold)),
        onLongPress: onDelete,
      ),
    );
  }
}