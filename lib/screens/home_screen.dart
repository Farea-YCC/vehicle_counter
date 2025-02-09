import 'package:vehicle_counter/imports_library.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}
class HomeScreenState extends State<HomeScreen> {
  void _addNewVehicleType() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newVehicleType = '';
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.addVehicle),
          content: TextField(
            onChanged: (value) {
              newVehicleType = value;
            },
            decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.addVehicle),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () {
                if (newVehicleType.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text(AppLocalizations.of(context)!.emptyVehicleError),
                      duration: const Duration(milliseconds: 300),
                    ),
                  );

                  return;
                }
                Provider.of<VehicleCounterProvider>(context, listen: false)
                    .addVehicle(newVehicleType);
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.add),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VehicleCounterProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        leading: IconButton(
          icon: const Icon(Icons.language),
          onPressed: () => context.read<LocaleProvider>().toggleLocale(),
          tooltip: l10n.toggleLanguage,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ResultsPage()),
              );
            },
            tooltip: l10n.viewResults,
          ),
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'reset') {
                provider.resetCounters();
              } else if (value == 'add') {
                _addNewVehicleType();
              } else if (value == 'about') {
                showDialog(
                  context: context,
                  builder: (context) => CustomDialog(
                    title: l10n.title_contact,
                    message: l10n.message_contact,
                    icon: Icons.info_outlined,
                    onClose: () => Navigator.of(context).pop(),
                    content: l10n.message_contact,
                  ),
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'reset',
                child: ListTile(
                  leading: const Icon(Icons.refresh),
                  title: Text(l10n.resetCounter),
                ),
              ),
              PopupMenuItem<String>(
                value: 'add',
                child: ListTile(
                  leading: const Icon(Icons.add),
                  title: Text(l10n.addVehicle),
                ),
              ),
              PopupMenuItem<String>(
                value: 'about',
                child: ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(l10n.aboutUs),
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: provider.counters.keys.length,
        separatorBuilder: (context, index) => const SizedBox(height: 0),
        itemBuilder: (context, index) {
          final vehicleType = provider.counters.keys.elementAt(index);
          return _buildVehicleCard(context, vehicleType);
        },
      ),
    );
  }

  Widget _buildVehicleCard(BuildContext context, String vehicleType) {
    final provider =
        Provider.of<VehicleCounterProvider>(context, listen: false);
    final directions = ['East', 'West', 'North', 'South'];
    return GestureDetector(
      onLongPress: () {
        _showDeleteConfirmationDialog(context, vehicleType);
      },
      child: Card(
        margin: const EdgeInsets.all(16),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                provider.vehicleLabels[vehicleType] ?? vehicleType,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: directions.map((direction) {
                    return _buildDirectionButton(
                      context,
                      vehicleType,
                      direction,
                    );
                  }).toList(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String vehicleType) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.deleteVehicle),
          content: Text(l10n.deleteVehicleConfirmation),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Provider.of<VehicleCounterProvider>(context, listen: false)
                    .removeVehicle(vehicleType);
                setState(() {});
                Navigator.of(context).pop();
              },
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDirectionButton(
      BuildContext context, String vehicleType, String direction) {
    final provider = Provider.of<VehicleCounterProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      child: ElevatedButton.icon(
        onPressed: () {
          provider.incrementCounter(vehicleType, direction);
        },
        icon: Icon(_getDirectionIcon(context, direction)),
        label: Text(
          '${_getDirectionLabel(l10n, direction)}: ${provider.counters[vehicleType]?[direction]}',
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        ),
      ),
    );
  }

  String _getDirectionLabel(AppLocalizations l10n, String direction) {
    switch (direction) {
      case 'East':
        return l10n.directionEast;
      case 'West':
        return l10n.directionWest;
      case 'North':
        return l10n.directionNorth;
      case 'South':
        return l10n.directionSouth;
      default:
        return direction;
    }
  }

  IconData _getDirectionIcon(BuildContext context, String direction) {
    switch (direction) {
      case 'East':
        return Icons.arrow_back;
      case 'West':
        return Icons.arrow_forward;
      case 'North':
        return Icons.arrow_upward;

      case 'South':
        return Icons.arrow_downward;

      default:
        return Icons.help;
    }
  }
}
