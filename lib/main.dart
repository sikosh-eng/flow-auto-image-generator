import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

void main() {
  runApp(const FlowAutoGenerator());
}

class FlowAutoGenerator extends StatelessWidget {
  const FlowAutoGenerator({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flow Auto Generator',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const GeneratorPage(),
    );
  }
}

class GeneratorPage extends StatefulWidget {
  const GeneratorPage({super.key});

  @override
  State<GeneratorPage> createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage> {
  final TextEditingController promptController =
      TextEditingController();

  List<String> prompts = [];

  int completed = 0;

  bool running = false;

  String aspectRatio = '16:9';
  String quality = 'High';
  String fps = '30 FPS';

  void parsePrompts() {
    final text = promptController.text.trim();

    if (text.isEmpty) return;

    setState(() {
      prompts = text
          .split(RegExp(r'\n+'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      completed = 0;
    });
  }

  Future<void> startGeneration() async {
    parsePrompts();

    if (prompts.isEmpty) return;

    setState(() {
      running = true;
    });

    /*
      Здесь будет подключена автоматизация Google Flow.

      Для каждого prompt:

      1. Открыть Flow
      2. Выбрать Image generation
      3. Установить aspectRatio
      4. Установить quality
      5. Вставить prompt
      6. Нажать Generate
      7. Дождаться результата
      8. Нажать Download
      9. Перейти к следующему prompt
    */

    for (int i = 0; i < prompts.length; i++) {
      if (!running) break;

      await Future.delayed(
        const Duration(seconds: 2),
      );

      setState(() {
        completed = i + 1;
      });
    }

    setState(() {
      running = false;
    });
  }

  void stopGeneration() {
    setState(() {
      running = false;
    });
  }

  Future<void> downloadAll() async {
    final directory =
        await getApplicationDocumentsDirectory();

    final files = directory
        .listSync()
        .whereType<File>()
        .where(
          (file) =>
              file.path.endsWith('.png') ||
              file.path.endsWith('.jpg') ||
              file.path.endsWith('.jpeg'),
        )
        .toList();

    if (files.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Нет готовых изображений'),
        ),
      );

      return;
    }

    final archive = Archive();

    for (final file in files) {
      final bytes = await file.readAsBytes();

      final filename =
          file.path.split('/').last;

      archive.addFile(
        ArchiveFile(
          filename,
          bytes.length,
          bytes,
        ),
      );
    }

    final zipData =
        ZipEncoder().encode(archive);

    if (zipData == null) return;

    final zipFile = File(
      '${directory.path}/Flow_Images.zip',
    );

    await zipFile.writeAsBytes(zipData);

    await Share.shareXFiles(
      [XFile(zipFile.path)],
      text: 'Generated images from Flow',
    );
  }

  Widget settingCard({
    required String title,
    required String value,
    required IconData icon,
    required List<String> values,
    required Function(String) onChanged,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 12),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            DropdownButton<String>(
              value: value,
              items: values
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(item),
                    ),
                  )
                  .toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  onChanged(newValue);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = prompts.isEmpty
        ? 0.0
        : completed / prompts.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '✦ Flow Auto Generator',
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,

            children: [
              const Text(
                'AI IMAGE GENERATOR',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Automatic Google Flow generation',
              ),

              const SizedBox(height: 20),

              const Text(
                'PROMPTS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: promptController,
                maxLines: 10,

                decoration: InputDecoration(
                  hintText:
                      'Paste your prompts here...\n\n'
                      'Prompt 1\n'
                      'Prompt 2\n'
                      'Prompt 3',

                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'SETTINGS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              settingCard(
                title: 'Format',
                value: aspectRatio,
                icon: Icons.aspect_ratio,
                values: const [
                  '9:16',
                  '16:9',
                  '1:1',
                  '4:3',
                ],
                onChanged: (value) {
                  setState(() {
                    aspectRatio = value;
                  });
                },
              ),

              settingCard(
                title: 'Quality',
                value: quality,
                icon: Icons.high_quality,
                values: const [
                  'Low',
                  'Medium',
                  'High',
                  'Ultra',
                ],
                onChanged: (value) {
                  setState(() {
                    quality = value;
                  });
                },
              ),

              settingCard(
                title: 'FPS',
                value: fps,
                icon: Icons.speed,
                values: const [
                  '24 FPS',
                  '30 FPS',
                  '60 FPS',
                ],
                onChanged: (value) {
                  setState(() {
                    fps = value;
                  });
                },
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          running
                              ? null
                              : startGeneration,
                      icon: const Icon(
                        Icons.play_arrow,
                      ),
                      label: const Text(
                        'START',
                      ),
                      style:
                          ElevatedButton.styleFrom(
                        padding:
                            const EdgeInsets.all(16),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          running
                              ? stopGeneration
                              : null,
                      icon: const Icon(
                        Icons.stop,
                      ),
                      label: const Text(
                        'STOP',
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Card(
                child: Padding(
                  padding:
                      const EdgeInsets.all(16),

                  child: Column(
                    children: [
                      const Text(
                        'PROGRESS',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        '$completed / ${prompts.length}',
                        style:
                            const TextStyle(
                          fontSize: 28,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      LinearProgressIndicator(
                        value: progress,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: downloadAll,
                icon: const Icon(
                  Icons.archive,
                ),
                label: const Text(
                  'DOWNLOAD ALL',
                ),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.all(16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
