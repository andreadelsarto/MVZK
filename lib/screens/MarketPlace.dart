import 'package:flutter/material.dart';

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Text(
          'Marketplace',
          style: TextStyle(
            color: theme.colorScheme.onBackground,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onBackground),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildSectionHeader(context, 'Themes'),
            _buildProductCard(context, 'Dark Theme', 'Unlock a sleek dark theme for your app.', '\$1.99', Icons.dark_mode),
            _buildProductCard(context, 'Colorful Theme', 'Add a burst of color to your app experience.', '\$2.99', Icons.color_lens),

            const SizedBox(height: 20),

            _buildSectionHeader(context, 'Premium Features'),
            _buildProductCard(context, 'Pro Version', 'Unlock advanced features with the Pro version.', '\$4.99', Icons.star),
            _buildProductCard(context, 'Remove Ads', 'Enjoy an ad-free experience.', '\$1.99', Icons.remove_circle_outline),

            const SizedBox(height: 20),

            _buildSectionHeader(context, 'Support Us'),
            _buildProductCard(context, 'Donate \$1', 'Support our app development.', '\$1.00', Icons.volunteer_activism),
            _buildProductCard(context, 'Donate \$5', 'Support our app development.', '\$5.00', Icons.volunteer_activism),

            const SizedBox(height: 20),

            _buildSectionHeader(context, 'Customizations'),
            _buildProductCard(context, 'Extra Colors Pack', 'Get additional color options for the app interface.', '\$0.99', Icons.palette),
            _buildProductCard(context, 'Sound Equalizer Presets', 'Unlock more sound equalizer presets.', '\$1.99', Icons.equalizer),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: theme.textTheme.headlineMedium?.copyWith(
          color: theme.colorScheme.onBackground,
          fontSize: 30,
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, String title, String description, String price, IconData icon) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        // Implementa la logica di acquisto o di interazione qui
      },
      child: Card(
        color: theme.colorScheme.surfaceVariant,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: theme.colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onBackground.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                price,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
