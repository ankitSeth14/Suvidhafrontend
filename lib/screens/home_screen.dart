import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'chat_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suvidha'), backgroundColor: const Color.fromARGB(255, 93, 116, 221),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
              // popping to root will let main decide to show login
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const Scaffold(body: Center(child: Text('Logged out')))),
                (route) => false
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text('Choose a domain to chat with Suvidha', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 24),
            _DomainCard(domain: 'banking', icon: Icons.account_balance),
            _DomainCard(domain: 'e-commerce', icon: Icons.shopping_cart),
            _DomainCard(domain: 'medical', icon: Icons.local_hospital),
          ],
        ),
      ),
    );
  }
}

class _DomainCard extends StatelessWidget {
  final String domain;
  final IconData icon;
  const _DomainCard({required this.domain, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(domain.toUpperCase()),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChatScreen(domain: domain)));
        },
      ),
    );
  }
}
