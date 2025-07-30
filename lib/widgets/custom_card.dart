import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tursd/services/favorite_service.dart'; // Make sure this path is correct
import 'package:tursd/models/punto_turistico.dart';
import '../providers/theme_provider.dart';

class CustomCard extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String? subtitle; // Already nullable, which is good!
  final Function()? onTap;
  final dynamic item; // Already dynamic, which is good for flexibility

  const CustomCard({
    super.key,
    required this.imageUrl,
    required this.title,
    this.subtitle, // Nullable, so no 'required'
    this.onTap,
    required this.item, // This item is always required
  });

  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _elevationAnimation;
  late Animation<Offset> _positionAnimation;
  final FavoriteService _favoriteService = FavoriteService();
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _elevationAnimation = Tween<double>(
      begin: 4,
      end: 8,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _positionAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(
          0, -0.01),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _checkIsFavorite();
  }

  Future<void> _checkIsFavorite() async {
    // We need to safely access 'id' and other properties from the dynamic item
    // It's crucial that PuntoTuristico and LocalTuristico have an 'id' property.
    // Example implementation (update as needed):
    if (widget.item is PuntoTuristico) {
      final punto = widget.item as PuntoTuristico;
      final isFav = await _favoriteService.isPuntoTuristicoFavorite(punto.id);
      if (mounted) {
        setState(() {
          _isFavorite = isFav;
        });
      }
    } else if (widget.item is LocalTuristico) {
      final local = widget.item as LocalTuristico;
      final isFav = await _favoriteService.isLocalTuristicoFavorite(local.id);
      if (mounted) {
        setState(() {
          _isFavorite = isFav;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool canBeFavorite =
        widget.item is PuntoTuristico || widget.item is LocalTuristico;

    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Transform.translate(
              offset: _positionAnimation.value * MediaQuery.of(context).size.height,
              child: Card(
                color: theme.colorScheme.surface,
                elevation: _elevationAnimation.value,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: Image.asset(
                            widget.imageUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: theme.colorScheme.surfaceVariant,
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: theme.colorScheme.onSurfaceVariant,
                                  size: 50,
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (widget.subtitle != null &&
                                  widget.subtitle!.isNotEmpty)
                                Text(
                                  widget.subtitle!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Favorite button, only visible if the item can be favorited
                    if (canBeFavorite)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () async {
                            // Logic to add/remove from favorites
                            if (widget.item is PuntoTuristico) {
                              final punto = widget.item as PuntoTuristico;
                              if (_isFavorite) {
                                await _favoriteService
                                    .removePuntoTuristicoFromFavorites(punto.toMap());
                              } else {
                                await _favoriteService.addPuntoTuristicoToFavorites(
                                  {
                                    'id': punto.id,
                                    'nombre': punto.nombre,
                                    'descripcion': punto.descripcion,
                                    'imagenUrl': punto.imagenUrl, // Assuming this property exists in PuntoTuristico
                                  },
                                );
                              }
                            } else if (widget.item is LocalTuristico) {
                              final local = widget.item as LocalTuristico;
                              if (_isFavorite) {
                                await _favoriteService
                                    .removeLocalTuristicoFromFavorites(local.toMap());
                              } else {
                                await _favoriteService.addLocalTuristicoToFavorites(
                                  {
                                    'id': local.id,
                                    'nombre': local.nombre,
                                    'descripcion': local.descripcion,
                                    'imagenUrl': local.imagenUrl, // Assuming this property exists in LocalTuristico
                                  },
                                );
                              }
                            }
                            if (mounted) {
                              setState(() {
                                _isFavorite = !_isFavorite;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface.withOpacity(0.8),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: _isFavorite
                                  ? Colors.red
                                  : theme.colorScheme.onSurface.withOpacity(0.7),
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
    