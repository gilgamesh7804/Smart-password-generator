import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/password_generator.dart';
import '../services/password_storage.dart';
import '../services/similarity_matcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _reasonController = TextEditingController();
  String? _generatedPassword;
  String? _retrievedPassword;
  Map<String, String> _savedPasswords = {};

  // Custom password settings
  int _passwordLength = 12;
  bool _includeUppercase = true;
  bool _includeLowercase = true;
  bool _includeNumbers = true;
  bool _includeSymbols = true;

  @override
  void initState() {
    super.initState();
    _loadPasswords();
  }

  Future<void> _loadPasswords() async {
    final data = await PasswordStorage.getAllPasswords();
    setState(() {
      _savedPasswords = data;
    });
  }

  Future<void> _generateAndSavePassword() async {
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) return;

    final password = PasswordGenerator.generate(
      length: _passwordLength,
      includeUppercase: _includeUppercase,
      includeLowercase: _includeLowercase,
      includeNumbers: _includeNumbers,
      includeSymbols: _includeSymbols,
    );

    await PasswordStorage.savePassword(reason, password);
    _reasonController.clear();

    setState(() {
      _generatedPassword = password;
      _retrievedPassword = null;
    });

    Future.delayed(const Duration(milliseconds: 500), _loadPasswords);
  }

  Future<void> _retrievePassword() async {
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) return;

    final result = await SimilarityMatcher.findClosestMatch(reason);
    setState(() {
      _retrievedPassword = result?.value;
      _generatedPassword = null;
    });
  }

  void _copyToClipboard(String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
  }

  void _showPasswordDialog(String reason, String password) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('🔐 Password for "$reason"'),
        content: SelectableText(password),
        actions: [
          TextButton(
            onPressed: () {
              _copyToClipboard(password);
            },
            child: const Text('Copy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String reason) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Password?'),
        content: Text(
          'Are you sure you want to delete the password for "$reason"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await PasswordStorage.deletePassword(reason);
              _loadPasswords();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedPasswordsList() {
    if (_savedPasswords.isEmpty) {
      return const Text("No passwords generated yet.");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🗂️ Generated Passwords:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ..._savedPasswords.entries.map(
          (entry) => ListTile(
            title: Text(entry.key),
            trailing: const Icon(Icons.lock_open),
            onTap: () => _showPasswordDialog(entry.key, entry.value),
            onLongPress: () => _confirmDelete(entry.key),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 40),
        const Text(
          '⚙️ Password Settings',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text("Length: $_passwordLength"),
        Slider(
          min: 6,
          max: 32,
          divisions: 26,
          label: '$_passwordLength',
          value: _passwordLength.toDouble(),
          onChanged: (val) {
            setState(() {
              _passwordLength = val.round();
            });
          },
        ),
        CheckboxListTile(
          value: _includeUppercase,
          title: const Text("Include Uppercase"),
          onChanged: (val) {
            setState(() {
              _includeUppercase = val ?? true;
            });
          },
        ),
        CheckboxListTile(
          value: _includeLowercase,
          title: const Text("Include Lowercase"),
          onChanged: (val) {
            setState(() {
              _includeLowercase = val ?? true;
            });
          },
        ),
        CheckboxListTile(
          value: _includeNumbers,
          title: const Text("Include Numbers"),
          onChanged: (val) {
            setState(() {
              _includeNumbers = val ?? true;
            });
          },
        ),
        CheckboxListTile(
          value: _includeSymbols,
          title: const Text("Include Symbols"),
          onChanged: (val) {
            setState(() {
              _includeSymbols = val ?? true;
            });
          },
        ),
        const Divider(height: 40),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Password Keeper')),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadPasswords();
          setState(() {
            _generatedPassword = null;
            _retrievedPassword = null;
          });
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Password for what?',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _generateAndSavePassword,
                    child: const Text('Generate'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _retrievePassword,
                    child: const Text('Retrieve'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_generatedPassword != null)
                Row(
                  children: [
                    Expanded(
                      child: SelectableText('✅ Generated: $_generatedPassword'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () => _copyToClipboard(_generatedPassword!),
                      tooltip: 'Copy',
                    ),
                  ],
                ),
              if (_retrievedPassword != null)
                Row(
                  children: [
                    Expanded(
                      child: SelectableText(
                        '🔎 Retrieved: $_retrievedPassword',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () => _copyToClipboard(_retrievedPassword!),
                      tooltip: 'Copy',
                    ),
                  ],
                ),
              _buildPasswordSettings(),
              _buildSavedPasswordsList(),
            ],
          ),
        ),
      ),
    );
  }
}
