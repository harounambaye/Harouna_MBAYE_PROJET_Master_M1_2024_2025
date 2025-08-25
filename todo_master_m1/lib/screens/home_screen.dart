import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/location_weather_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _text = TextEditingController();
  final _search = TextEditingController();

  @override void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationWeatherProvider>().load();
      context.read<ProfileProvider>().load();
      final tp = context.read<TodoProvider?>();
      tp?.load();
    });
  }
  @override void dispose(){_text.dispose(); _search.dispose(); super.dispose();}

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final weather = context.watch<LocationWeatherProvider>();
    final profile = context.watch<ProfileProvider>();
    final todos = context.watch<TodoProvider?>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(auth.email ?? ''),
                accountEmail: Text(weather.loading
                    ? 'Météo…'
                    : (weather.temp!=null ? 'Temp: ${weather.temp!.toStringAsFixed(1)}°C' : 'Météo indisponible')),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: profile.file!=null ? FileImage(profile.file!) : null,
                  child: profile.file==null ? const Icon(Icons.person) : null,
                ),
                decoration: const BoxDecoration(),
              ),
              ListTile(
                leading: const Icon(Icons.list),
                title: const Text('Affichage (Toutes)'),
                onTap: (){
                  Navigator.pop(context);
                  todos?.setMode(TodoViewMode.all);
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_task),
                title: const Text('Création'),
                onTap: (){
                  Navigator.pop(context);
                  _openCreateDialog(context, todos);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Modification'),
                subtitle: const Text('Appuie long/clic • sur une tâche'),
                onTap: (){ Navigator.pop(context); },
              ),
              ListTile(
                leading: const Icon(Icons.check_circle),
                title: const Text('Accomplir'),
                subtitle: const Text('Coche la case d’une tâche'),
                onTap: (){ Navigator.pop(context); },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Suppression'),
                subtitle: const Text('Balayage à droite/gauche ou menu tâche'),
                onTap: (){ Navigator.pop(context); },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.search),
                title: const Text('Recherche'),
                onTap: (){
                  Navigator.pop(context);
                  _focusSearch();
                },
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Historique (Accomplies)'),
                onTap: (){
                  Navigator.pop(context);
                  todos?.setMode(TodoViewMode.history);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Photo de profil'),
                onTap: () async {
                  Navigator.pop(context);
                  await context.read<ProfileProvider>().pick();
                },
              ),

              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Déconnecter'),
                onTap: () async {
                  Navigator.pop(context);
                  await auth.logout();
                  if (!mounted) return;
                  Navigator.of(context).pushReplacementNamed('/');
                },
              ),
            ],
          ),
        ),
      ),
      body: todos==null
    ? const Center(child: CircularProgressIndicator())
    : ListView(
        padding: const EdgeInsets.all(16),
        children: [

          Builder(
            builder: (context) {
              final cs = Theme.of(context).colorScheme;
              final auth = context.watch<AuthProvider>();
              final lw = context.watch<LocationWeatherProvider>();
              final profile = context.watch<ProfileProvider>();

              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [cs.primary, cs.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: profile.file != null ? FileImage(profile.file!) : null,
                      child: profile.file==null ? const Icon(Icons.person, color: Colors.white) : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Bonjour 👋',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: cs.onPrimary, fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            auth.email ?? '',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: cs.onPrimary, fontWeight: FontWeight.w800,
                            ),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              Chip(
                                avatar: const Icon(Icons.place, size: 18),
                                label: Text(lw.place ?? 'Lieu inconnu'),
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              Chip(
                                avatar: const Icon(Icons.thermostat, size: 18),
                                label: Text(
                                  lw.temp != null
                                      ? '${lw.temp!.toStringAsFixed(1)} °C'
                                      : 'Météo…',
                                ),
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: ()=> context.read<LocationWeatherProvider>().load(),
                      icon: Icon(Icons.refresh, color: cs.onPrimary),
                      tooltip: 'Rafraîchir',
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),



          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.place),
                  title: Builder(
                    builder: (_) {
                      final lw = context.watch<LocationWeatherProvider>();
                      final place = lw.place;
                      final hasCoords = lw.lat != null && lw.lon != null;
                      final text = lw.loading
                          ? 'Récupération position...'
                          : (place != null
                              ? place
                              : (hasCoords
                                  ? 'Position: ${lw.lat!.toStringAsFixed(5)}, ${lw.lon!.toStringAsFixed(5)}'
                                  : (lw.error ?? 'Position indisponible')));
                      return Text(
                        text,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                  ),
                  trailing: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 96),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Rafraîchir',
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.refresh),
                          onPressed: () => context.read<LocationWeatherProvider>().load(),
                        ),
                        IconButton(
                          tooltip: 'Réglages GPS',
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.settings),
                          onPressed: () => context.read<LocationWeatherProvider>().openLocationSettings(),
                        ),
                      ],
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                const Divider(height: 1),
                Builder(
                  builder: (_) {
                    final lw = context.watch<LocationWeatherProvider>();
                    final temp = lw.temp;
                    final text = lw.loading
                        ? 'Récupération météo...'
                        : (temp != null
                            ? '${temp.toStringAsFixed(1)} °C'
                            : (lw.error ?? 'Météo indisponible'));
                    return ListTile(
                      leading: const Icon(Icons.thermostat),
                      title: Text(
                        text,
                        style: temp != null
                            ? const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
                            : const TextStyle(fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: temp != null ? const Text('Température actuelle') : null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    );
                  },
                ),
                Builder(
                  builder: (_) {
                    final lw = context.watch<LocationWeatherProvider>();
                    if (lw.error != null && lw.debugInfo != null && !lw.loading) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'Détails: ${lw.debugInfo}',
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              softWrap: true,
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.app_settings_alt, size: 18),
                                  label: const Text('Réglages app'),
                                  onPressed: () => context.read<LocationWeatherProvider>().openAppSettings(),
                                ),
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.place, size: 18),
                                  label: const Text('Tester Dakar'),
                                  onPressed: () => context.read<LocationWeatherProvider>().setManual(14.6928, -17.4467),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),


                // Barre Recherche
                TextField(
                  controller: _search,
                  decoration: InputDecoration(
                    hintText: 'Rechercher une tâche',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _search.text.isEmpty ? null : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: (){
                        _search.clear();
                        todos.setSearch('');
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (v)=> todos.setSearch(v.trim()),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _text,
                        decoration: const InputDecoration(
                          hintText: 'Nouvelle tâche',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _add(todos),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: ()=> _add(todos),
                      child: const Text('Ajouter'),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                if (todos.loading) const Center(child: CircularProgressIndicator()),

                ...todos.items.map((t)=> Dismissible(
                  key: ValueKey(t.localId),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (_) async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Supprimer ?'),
                        content: Text('Supprimer: "${t.text}"'),
                        actions: [
                          TextButton(onPressed: ()=> Navigator.pop(context, false), child: const Text('Annuler')),
                          TextButton(onPressed: ()=> Navigator.pop(context, true), child: const Text('Supprimer')),
                        ],
                      ),
                    );
                    return ok ?? false;
                  },
                  onDismissed: (_){ context.read<TodoProvider?>()!.delete(t); },
                  child: InkWell(
                    onLongPress: ()=> _openEditDialog(context, todos, t),
                    child: TodoTile(
                      item: t,
                      onChanged: (val)=> todos.toggleDone(t, val ?? false),
                    ),
                  ),
                )),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()=> _openCreateDialog(context, todos),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _focusSearch() {

  }

  void _add(TodoProvider? todos) async {
    final v = _text.text.trim();
    if (v.isEmpty || todos == null) return;
    await todos.add(v, DateTime.now());
    _text.clear();
  }

  Future<void> _openCreateDialog(BuildContext ctx, TodoProvider? todos) async {
    if (todos == null) return;
    final ctrl = TextEditingController();
    final picked = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Nouvelle tâche'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'Description'),
        ),
        actions: [
          TextButton(onPressed: ()=> Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(onPressed: ()=> Navigator.pop(ctx, true), child: const Text('Ajouter')),
        ],
      ),
    );
    if (picked == true && ctrl.text.trim().isNotEmpty) {
      await todos.add(ctrl.text.trim(), DateTime.now());
    }
  }

  Future<void> _openEditDialog(BuildContext ctx, TodoProvider? todos, item) async {
    if (todos == null) return;
    final ctrl = TextEditingController(text: item.text);
    final picked = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Modifier la tâche'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'Description'),
        ),
        actions: [
          TextButton(onPressed: ()=> Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(onPressed: ()=> Navigator.pop(ctx, true), child: const Text('Enregistrer')),
        ],
      ),
    );
    if (picked == true && ctrl.text.trim().isNotEmpty) {
      await todos.edit(item, text: ctrl.text.trim());
    }
  }
}
