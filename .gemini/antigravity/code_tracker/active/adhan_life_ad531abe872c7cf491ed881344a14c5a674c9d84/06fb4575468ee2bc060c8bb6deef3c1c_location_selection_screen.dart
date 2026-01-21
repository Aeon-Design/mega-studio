◊?
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adhan_life/core/services/location_service.dart';
import 'package:adhan_life/core/services/storage_service.dart';
import 'package:adhan_life/app/providers.dart';
import 'package:adhan_life/core/theme/app_colors.dart';
import 'package:adhan_life/core/theme/app_tokens.dart';
import 'package:adhan_life/core/theme/app_typography.dart';
import 'package:adhan_life/l10n/app_localizations.dart';
import 'package:geocoding/geocoding.dart';

final citySearchProvider = FutureProvider.family<List<Location>, String>((ref, query) async {
  if (query.length < 3) return [];
  // final locationService = ref.watch(locationServiceProvider);
  // Actually location_service needs a method to search cities, but it effectively uses geocoding.
  // We can use geocoding package directly or add a proxy method.
  // For simplicity MVP, we use locationFromAddress wrapper in LocationService
  // but LocationService only returns first result currently.
  // Let's modify usage or assume strict search for now, or better:
  // We'll use locationFromAddress directly here or update service.
  // For MVP let's trust LocationService.getCoordinatesFromCity returns one. 
  // Ideally we want a list. 
  try {
     List<Location> locations = await locationFromAddress(query);
     return locations;
  } catch (e) {
    return [];
  }
});

class LocationSelectionScreen extends ConsumerStatefulWidget {
  const LocationSelectionScreen({super.key});

  @override
  ConsumerState<LocationSelectionScreen> createState() => _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends ConsumerState<LocationSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  // Store pair of Location and Placemark
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.length < 3) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _searchResults = [];
    });

    try {
      // First get locations (coordinates)
      List<Location> locations = await locationFromAddress(query);
      
      if (locations.isEmpty) {
        setState(() {
          _isLoading = false;
          _searchResults = [];
        });
        return;
      }

      final results = <Map<String, dynamic>>[];
      
      // We'll take up to 5 locations
      final limitedLocations = locations.take(5).toList();
      
      for (final loc in limitedLocations) {
        try {
          List<Placemark> placemarks = await placemarkFromCoordinates(loc.latitude, loc.longitude);
          if (placemarks.isNotEmpty) {
            results.add({
              'location': loc,
              'place': placemarks.first,
            });
          }
        } catch (e) {
          // Ignore individual errors
        }
      }

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
      
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Could not find city. Please try differently.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectLocation(Placemark place, double lat, double lng) async {
    final storage = ref.read(storageServiceProvider);
    
    String finalCity = place.locality ?? place.administrativeArea ?? place.name ?? "Custom Location";
    String? country = place.isoCountryCode;

    await storage.setManualCity(finalCity);
    await storage.setManualCoordinates(lat, lng);
    if (country != null) await storage.setManualCountry(country);
    await storage.setIsManualLocation(true);

    if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Location set to $finalCity')));
       Navigator.pop(context);
    }
  }

  Future<void> _useCurrentLocation() async {
     try {
       setState(() => _isLoading = true);
       final locationService = ref.read(locationServiceProvider);
       await locationService.getCurrentPosition();
       
       final storage = ref.read(storageServiceProvider);
       await storage.setIsManualLocation(false);
       
       if (mounted) {
         Navigator.pop(context);
       }
     } catch (e) {
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
         setState(() => _isLoading = false);
       }
     }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isManual = ref.watch(storageServiceProvider).getIsManualLocation();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.selectCity),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppTokens.spacing16),
        child: Column(
          children: [
            // Current Location Option
            ListTile(
              leading: Icon(Icons.my_location, color: !isManual ? AppColors.primary : null),
              title: Text(l10n.valCurrentLocation),
              trailing: !isManual ? const Icon(Icons.check, color: AppColors.primary) : null,
              onTap: _isLoading ? null : _useCurrentLocation,
              tileColor: !isManual ? AppColors.primary.withValues(alpha: 0.1) : null,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            const SizedBox(height: AppTokens.spacing16),
            
            // Search Box
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: l10n.searchCity,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    _performSearch(_searchController.text);
                  },
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (val) {
                _performSearch(val);
              },
            ),
             const SizedBox(height: AppTokens.spacing16),

            // Results
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _error != null 
                    ? Center(child: Text(_error!, style: const TextStyle(color: AppColors.error)))
                    : _searchResults.isEmpty 
                      ? Center(child: Text(l10n.searchCity, style: const TextStyle(color: AppColors.textSecondary)))
                      : ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final item = _searchResults[index];
                            final Placemark place = item['place'];
                            final Location loc = item['location'];
                            
                            final name = "${place.locality ?? place.administrativeArea ?? ''}, ${place.country ?? ''}";
                            
                            return ListTile(
                              leading: const Icon(Icons.location_city),
                              title: Text(name),
                              onTap: () => _selectLocation(place, loc.latitude, loc.longitude),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
µ *cascade08µ∏*cascade08∏∑ *cascade08∑¬*cascade08¬√ *cascade08√Ã*cascade08ÃÕ *cascade08Õ’*cascade08’ﬁ *cascade08ﬁ˚*cascade08˚ê *cascade08êí*cascade08íû *cascade08ûü*cascade08ü† *cascade08†¢*cascade08¢£ *cascade08£¶*cascade08¶ß *cascade08ß®*cascade08®´ *cascade08´¨*cascade08¨≠ *cascade08≠Ø*cascade08Ø± *cascade08±≥*cascade08≥¥ *cascade08¥µ*cascade08µè *cascade08è…*cascade08…Ÿ *cascade08ŸÈ*cascade08È”9 *cascade08”9’9*cascade08’9÷9 *cascade08÷9◊9*cascade08◊9î: *cascade08î:ï:*cascade08ï:ô: *cascade08ô:ö:*cascade08ö:õ: *cascade08õ:ù:*cascade08ù:£: *cascade08£:¶:*cascade08¶:©: *cascade08©:´:*cascade08´:≤: *cascade08≤:≥:*cascade08≥:“: *cascade08“:”:*cascade08”:ÿ: *cascade08ÿ:⁄:*cascade08⁄:Â: *cascade08Â:Ê:*cascade08Ê:Î: *cascade08Î:Ì:*cascade08Ì:ı: *cascade08ı:¯:*cascade08¯:∑; *cascade08∑;∏;*cascade08∏;Ω; *cascade08Ω;æ;*cascade08æ;ø; *cascade08ø;¿;*cascade08¿;¡; *cascade08¡;ƒ;*cascade08ƒ;«; *cascade08«;»;*cascade08»;…; *cascade08…; ;*cascade08 ;—; *cascade08—;“;*cascade08“;”; *cascade08”;’;*cascade08’;÷; *cascade08÷;ÿ;*cascade08ÿ;›; *cascade08›;ﬂ;*cascade08ﬂ;·; *cascade08·;‚;*cascade08‚;Ë; *cascade08Ë;Ó;*cascade08Ó;Ô; *cascade08Ô;Ò;*cascade08Ò;Ú; *cascade08Ú;ˆ;*cascade08ˆ;˜; *cascade08˜;˘;*cascade08˘;˛; *cascade08˛;Ä<*cascade08Ä<Å< *cascade08Å<Ç<*cascade08Ç<Ñ< *cascade08Ñ<Ü<*cascade08Ü<á< *cascade08á<â<*cascade08â<ä< *cascade08ä<è<*cascade08è<Ä> *cascade08Ä>Ç>*cascade08Ç>É> *cascade08É>Ñ>*cascade08Ñ>í> *cascade08í>ñ>*cascade08ñ>ò> *cascade08ò>ô>*cascade08ô>õ> *cascade08õ>ú>*cascade08ú>ù> *cascade08ù>û>*cascade08û>§> *cascade08§>•>*cascade08•>©> *cascade08©>™>*cascade08™>Ø> *cascade08Ø>∞>*cascade08∞>≥> *cascade08≥>¥>*cascade08¥>µ> *cascade08µ>∂>*cascade08∂>◊? *cascade08"(ad531abe872c7cf491ed881344a14c5a674c9d842Åfile:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life/lib/features/settings/presentation/screens/location_selection_screen.dart:7file:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life