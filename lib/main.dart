import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(TaskManagerApp());

class TaskManagerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pengelola Kegiatan',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: TextTheme(bodyMedium: TextStyle(fontSize: 16.0)),
      ),
      home: LoginPage(),
    );
  }
}

// ----------------------------- Models ---------------------------------
class EventModel {
  String id;
  String title;
  String description;
  DateTime start;
  DateTime end;
  String? location;
  bool reminder;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.start,
    required this.end,
    this.location,
    this.reminder = false,
  });
}

// ----------------------------- LOGIN PAGE -----------------------------
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final prefs = await SharedPreferences.getInstance();
    final storedEmail = prefs.getString('email');
    final storedPass = prefs.getString('password');

    if (_emailCtrl.text == storedEmail && _passCtrl.text == storedPass) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DashboardPage()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email atau password salah.')),
      );
    }
  }

  void _goRegister() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterPage()));
  }

  void _showForgot() async {
    final prefs = await SharedPreferences.getInstance();
    final storedEmail = prefs.getString('email');
    final storedPass = prefs.getString('password');

    if (storedEmail == null) {
      _showDialog('Lupa Password', 'Belum ada akun yang terdaftar.');
    } else {
      _showDialog('Lupa Password',
          'Akun terdaftar dengan email: $storedEmail\nPassword Anda adalah: $storedPass');
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: Text('Tutup')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(maxWidth: isWide ? 500 : double.infinity),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 24),
                      FlutterLogo(size: 84),
                      SizedBox(height: 16),
                      Text('Selamat datang',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.w600)),
                      SizedBox(height: 8),
                      Text('Your Reliable Reminder App :D',
                          textAlign: TextAlign.center),
                      SizedBox(height: 24),
                      Form(
                        key: _formKey,
                        child: Column(children: [
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email)),
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return 'Email wajib diisi';
                              if (!RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$")
                                  .hasMatch(v)) return 'Format email tidak valid';
                              return null;
                            },
                          ),
                          SizedBox(height: 12),
                          TextFormField(
                            controller: _passCtrl,
                            obscureText: _obscure,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(_obscure
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                            ),
                            validator: (v) => (v == null || v.length < 6)
                                ? 'Password minimal 6 karakter'
                                : null,
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                  onPressed: _showForgot,
                                  child: Text('Lupa password?')),
                              TextButton(
                                  onPressed: _goRegister,
                                  child: Text('Daftar baru')),
                            ],
                          ),
                          SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _login,
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Text('Masuk'),
                            ),
                          ),
                        ]),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ----------------------------- REGISTER PAGE -----------------------------
class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', _emailCtrl.text);
    await prefs.setString('password', _passCtrl.text);

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Registrasi berhasil!')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daftar Pengguna')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text('Buat akun baru',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                TextFormField(
                  controller: _emailCtrl,
                  decoration: InputDecoration(
                      labelText: 'Email', prefixIcon: Icon(Icons.email)),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email wajib diisi';
                    if (!RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$")
                        .hasMatch(v)) return 'Format email tidak valid';
                    return null;
                  },
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () =>
                            setState(() => _obscure = !_obscure),
                      )),
                  validator: (v) =>
                      (v == null || v.length < 6) ? 'Minimal 6 karakter' : null,
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _confirmCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                      labelText: 'Konfirmasi Password',
                      prefixIcon: Icon(Icons.lock_outline)),
                  validator: (v) =>
                      v != _passCtrl.text ? 'Password tidak cocok' : null,
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _register,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Daftar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --------------------------- Dashboard --------------------------------
class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // ===== Variabel utama =====
  late ScrollController _scrollController;
  List<DateTime> _dates = [];
  DateTime _selectedDate = DateTime.now();
  final Map<String, List<EventModel>> _eventsByDate = {};

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(initialScrollOffset: 2000);
    _generateInitialDates();
    }

  // ===== Generate tanggal awal =====
  void _generateInitialDates() {
    final start = DateTime.now().subtract(Duration(days: 30));
    _dates = List.generate(60, (i) => start.add(Duration(days: i)));
  }

  // ===== Tambah tanggal dinamis (infinite scroll) =====
  void _addMoreDays({required bool forward}) {
    if (forward) {
      final lastDate = _dates.last;
      final moreDates = List.generate(30, (i) => lastDate.add(Duration(days: i + 1)));
      _dates.addAll(moreDates);
    } else {
      final firstDate = _dates.first;
      final moreDates = List.generate(30, (i) => firstDate.subtract(Duration(days: i + 1)))
          .reversed
          .toList();
      _dates.insertAll(0, moreDates);
      // Jaga posisi scroll agar tidak melompat
      _scrollController.jumpTo(_scrollController.offset + (70.0 * 30));
    }
  }



  // ===== Manajemen event =====
  void _addEvent(EventModel e) {
    final key = _keyForDate(e.start);
    _eventsByDate.putIfAbsent(key, () => []);
    _eventsByDate[key]!.add(e);
    setState(() {});
  }

  void _updateEvent(EventModel updated) {
    final key = _keyForDate(updated.start);
    _eventsByDate.forEach((k, v) => v.removeWhere((ev) => ev.id == updated.id));
    _eventsByDate.putIfAbsent(key, () => []);
    _eventsByDate[key]!.add(updated);
    setState(() {});
  }

  void _deleteEvent(String id) {
    _eventsByDate.forEach((k, v) => v.removeWhere((ev) => ev.id == id));
    setState(() {});
  }

  String _keyForDate(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  List<EventModel> _eventsFor(DateTime date) {
    final key = _keyForDate(date);
    return _eventsByDate[key] ?? [];
  }

  // ===== Navigasi halaman =====
  void _openAddDialog() async {
    final result = await Navigator.push<EventModel?>(
        context, MaterialPageRoute(builder: (_) => AddEditEventPage(date: _selectedDate)));
    if (result != null) _addEvent(result);
  }

  void _openEventDetail(EventModel e) async {
    final res = await Navigator.push(
        context, MaterialPageRoute(builder: (_) => EventDetailPage(event: e)));
    if (res is EventModel) {
      _updateEvent(res);
    } else if (res == 'deleted') {
      _deleteEvent(e.id);
    }
  }

  // ===== Widget kalender horizontal =====
  Widget _buildDateScroller() {
    return SizedBox(
      height: 100,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - 100) {
            _addMoreDays(forward: true);
          }
          if (notification.metrics.pixels <= 100) {
            _addMoreDays(forward: false);
          }
          return false;
        },
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          itemCount: _dates.length,
          itemBuilder: (context, index) {
            final date = _dates[index];
            final isSelected = DateUtils.isSameDay(date, _selectedDate);

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDate = date;
                });
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                width: 70,
                margin: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.indigo : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: Colors.indigoAccent.withOpacity(0.3),
                        blurRadius: 6,
                      ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('E').format(date),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      date.day.toString(),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      DateFormat('MMM').format(date),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black54,
                        fontSize: 12,
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

  // ===== Daftar agenda =====
  Widget _buildAgendaList() {
    final events = _eventsFor(_selectedDate)..sort((a, b) => a.start.compareTo(b.start));
    if (events.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Tidak ada kegiatan di hari ini. Ketuk tombol + untuk menambah kegiatan baru.'),
        ),
      );
    }
    return ListView.separated(
      itemCount: events.length,
      separatorBuilder: (_, __) => Divider(height: 1),
      itemBuilder: (ctx, i) {
        final e = events[i];
        return ListTile(
          onTap: () => _openEventDetail(e),
          leading: Icon(Icons.event_note, semanticLabel: 'Kegiatan'),
          title: Text(e.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            '${DateFormat.Hm().format(e.start)} - ${DateFormat.Hm().format(e.end)} • ${e.location ?? '-'}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: e.reminder ? Icon(Icons.alarm, size: 18) : null,
        );
      },
    );
  }

  // ===== Build UI utama =====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          IconButton(icon: Icon(Icons.search), onPressed: () {}),
          PopupMenuButton<String>(
            onSelected: (v) {},
            itemBuilder: (_) => [
              PopupMenuItem(child: Text('Pengaturan'), value: 'settings'),
            ],
          )
        ],
      ),
      body: Column(
        children: [
          Padding(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8), child: _buildDateScroller()),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Agenda', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: _buildAgendaList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddDialog,
        child: Icon(Icons.add),
        tooltip: 'Tambah Kegiatan',
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Text('Halo, Pengguna!', style: TextStyle(color: Colors.white, fontSize: 18)),
              decoration: BoxDecoration(color: Colors.indigo),
            ),
            ListTile(leading: Icon(Icons.calendar_today), title: Text('Kalender'), onTap: () {}),
            ListTile(leading: Icon(Icons.settings), title: Text('Pengaturan'), onTap: () {}),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Keluar'),
              onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage())),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}


// ------------------------ Add / Edit Event -----------------------------
class AddEditEventPage extends StatefulWidget {
  final DateTime date;
  final EventModel? event;
  AddEditEventPage({required this.date, this.event});

  @override
  _AddEditEventPageState createState() => _AddEditEventPageState();
}

class _AddEditEventPageState extends State<AddEditEventPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _locCtrl;
  late DateTime _start;
  late DateTime _end;
  bool _reminder = false;

  @override
  void initState() {
    super.initState();
    final e = widget.event;
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _locCtrl = TextEditingController(text: e?.location ?? '');
    _start = e?.start ?? DateTime(widget.date.year, widget.date.month, widget.date.day, 9);
    _end = e?.end ?? _start.add(Duration(hours: 1));
    _reminder = e?.reminder ?? false;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    final date = await showDatePicker(context: context, initialDate: isStart ? _start : _end, firstDate: DateTime(2000), lastDate: DateTime(2100));
    if (date == null) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(isStart ? _start : _end));
    if (time == null) return;
    setState(() {
      final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      if (isStart) {
        _start = dt;
        if (!_end.isAfter(_start)) _end = _start.add(Duration(hours: 1));
      } else {
        _end = dt;
        if (!_end.isAfter(_start)) _start = _end.subtract(Duration(hours: 1));
      }
    });
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      final id = widget.event?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
      final ev = EventModel(id: id, title: _titleCtrl.text, description: _descCtrl.text, start: _start, end: _end, location: _locCtrl.text, reminder: _reminder);
      Navigator.pop(context, ev);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.event == null ? 'Tambah Kegiatan' : 'Edit Kegiatan')),
      body: SafeArea(child: SingleChildScrollView(padding: EdgeInsets.all(16), child: Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          TextFormField(controller: _titleCtrl, decoration: InputDecoration(labelText: 'Judul', prefixIcon: Icon(Icons.title)), validator: (v) => (v==null||v.isEmpty)? 'Judul wajib diisi' : null),
          SizedBox(height: 12),
          TextFormField(controller: _descCtrl, decoration: InputDecoration(labelText: 'Deskripsi', prefixIcon: Icon(Icons.description)), maxLines: 3),
          SizedBox(height: 12),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => _pickDateTime(isStart: true), child: Text('Mulai: ${DateFormat('yyyy-MM-dd HH:mm').format(_start)}'))),
          ]),
          SizedBox(height: 8),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => _pickDateTime(isStart: false), child: Text('Selesai: ${DateFormat('yyyy-MM-dd HH:mm').format(_end)}'))),
          ]),
          SizedBox(height: 12),
          TextFormField(controller: _locCtrl, decoration: InputDecoration(labelText: 'Lokasi (opsional)', prefixIcon: Icon(Icons.place))),
          SizedBox(height: 12),
          SwitchListTile(value: _reminder, onChanged: (v) => setState(() => _reminder = v), title: Text('Tambahkan pengingat')),
          SizedBox(height: 16),
          ElevatedButton(onPressed: _save, child: Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Simpan'))),
        ]),
      ))),
    );
  }
}

// ------------------------ Event Detail -------------------------------
class EventDetailPage extends StatelessWidget {
  final EventModel event;
  EventDetailPage({required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detail Kegiatan')),
      body: SafeArea(child: Padding(padding: EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(event.title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
        SizedBox(height: 8),
        Row(children: [Icon(Icons.access_time), SizedBox(width: 8), Text('${DateFormat('yyyy-MM-dd HH:mm').format(event.start)} - ${DateFormat('yyyy-MM-dd HH:mm').format(event.end)}')]),
        SizedBox(height: 8),
        Row(children: [Icon(Icons.place), SizedBox(width: 8), Text(event.location ?? '- (tidak ada lokasi)')]),
        SizedBox(height: 12),
        Text('Deskripsi', style: TextStyle(fontWeight: FontWeight.w600)),
        SizedBox(height: 6),
        Expanded(child: SingleChildScrollView(child: Text(event.description.isNotEmpty ? event.description : '-'))),
        SizedBox(height: 12),
        Row(children: [
          Expanded(child: OutlinedButton.icon(onPressed: () async {
            // Edit: open AddEditEventPage prefilled
            final updated = await Navigator.push<EventModel?>(context, MaterialPageRoute(builder: (_) => AddEditEventPage(date: event.start, event: event)));
            if (updated != null) Navigator.pop(context, updated);
          }, icon: Icon(Icons.edit), label: Text('Edit'))),
          SizedBox(width: 8),
          Expanded(child: OutlinedButton.icon(onPressed: () => _confirmDelete(context), icon: Icon(Icons.delete), label: Text('Hapus'))),
        ]),
        SizedBox(height: 8),
        ElevatedButton.icon(onPressed: () => _setupReminder(context), icon: Icon(Icons.alarm_add), label: Text('Tambahkan Pengingat')),
      ]))),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(context: context, builder: (c) => AlertDialog(
      title: Text('Hapus Kegiatan'),
      content: Text('Anda yakin ingin menghapus kegiatan ini?'),
      actions: [TextButton(onPressed: () => Navigator.pop(c), child: Text('Batal')), TextButton(onPressed: () { Navigator.pop(c); Navigator.pop(context, 'deleted'); }, child: Text('Hapus'))],
    ));
  }

  void _setupReminder(BuildContext context) {
    // Placeholder: in real app integrate local notifications
    showDialog(context: context, builder: (c) => AlertDialog(
      title: Text('Pengingat'),
      content: Text('Demo: pengingat akan diaktifkan (butuh integrasi notifikasi lokal).'),
      actions: [TextButton(onPressed: () => Navigator.pop(c), child: Text('OK'))],
    ));
  }
}