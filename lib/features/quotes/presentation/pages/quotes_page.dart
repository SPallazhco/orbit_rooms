import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit_rooms/features/quotes/presentation/pages/create_quote_page.dart';
import 'package:orbit_rooms/features/quotes/presentation/pages/quote_detail_page.dart';
import 'package:orbit_rooms/features/quotes/presentation/quote_status_label.dart';
import 'package:orbit_rooms/features/quotes/quotes_providers.dart';
import 'package:orbit_rooms/shared/widgets/app_drawer.dart';

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

class QuotesPage extends ConsumerWidget {
  const QuotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quotesAsync = ref.watch(quotesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Cotizaciones')),
      drawer: const AppDrawer(),
      body: quotesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (quotes) {
          if (quotes.isEmpty) {
            return const Center(child: Text('Todavía no tienes cotizaciones'));
          }

          return ListView.builder(
            itemCount: quotes.length,
            itemBuilder: (context, index) {
              final entry = quotes[index];
              final quote = entry.quote;
              return ListTile(
                title: Text(quote.guestName ?? 'Sin nombre todavía'),
                subtitle: Text(
                  '${entry.propertyName} — ${entry.roomName} · '
                  '${_formatDate(quote.checkInDate)} → '
                  '${_formatDate(quote.checkOutDate)}',
                ),
                trailing: Text(
                  quoteStatusLabel(quote.status),
                  style: TextStyle(
                    color: quoteStatusColor(context, quote.status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => QuoteDetailPage(quoteId: quote.id),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const CreateQuotePage())),
        child: const Icon(Icons.add),
      ),
    );
  }
}
