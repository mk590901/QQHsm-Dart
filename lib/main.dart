import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'list_bloc.dart';
import 'button_bloc.dart';
import 'QQHsm/QQHsmEngine.dart';
import 'interfaces/i_updater.dart';
import 'samek_9B_wrapper.dart';

void main() {
  runApp(HsmEngineDemoApp());
}

class HsmEngineDemoApp extends StatelessWidget {
  HsmEngineDemoApp({super.key});

  final ListBloc listBloc = ListBloc();
  final ButtonBloc buttonBloc = ButtonBloc();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Two Part List View with BLoC',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      home: MultiBlocProvider(
        providers: [
          BlocProvider<ButtonBloc>(
            create: (context) => buttonBloc,
          ),
          BlocProvider<ListBloc>(
            create: (context) => listBloc,
          ),
        ],
        child: HomePage(listBloc, buttonBloc),
      ),
    );
  }
}

class HomePage extends StatelessWidget implements IUpdater {
  final ListBloc listBloc;
  final ButtonBloc buttonBloc;

  late bool engineIsLoaded = false;
  late List<String> actualEvents = [];
  final String _fileName = "assets/stateMachines/samek_9B_engine.json";
  late QQHsmEngine hsmEngine;
  final Samek9BWrapper hsmWrapper = Samek9BWrapper();

  HomePage(this.listBloc, this.buttonBloc, {super.key});

  Future<String> getFileData(String path) async {
    return await rootBundle.loadString(path);
  }

  void initHsmEngine() {
    getFileData(_fileName).then((String text) {
      if (text.isNotEmpty) {
        hsmEngine = QQHsmEngine(this);
        hsmEngine.create(text);
        actualEvents = hsmEngine.appEvents()!;
        print('actualEvents->$actualEvents');
        engineIsLoaded = true;
        buttonBloc.add(AddButtonList(actualEvents));
      } else {
        print('Failed to loaded $_fileName');
        return;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Future.microtask(() {
      // Ensure this code runs after the build method completes
      if (context.mounted) {
        initHsmEngine();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hsm Engine Demo',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontStyle: FontStyle.italic,
              shadows: [
                Shadow(
                  blurRadius: 8.0,
                  color: Colors.indigo,
                  offset: Offset(3.0, 3.0),
                ),
              ],
            )),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple, Colors.lightBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.electric_bolt_sharp, color: Colors.white)),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ListBloc, ListState>(
              builder: (context, state) {
                if (state is ListLoaded) {
                  return ListView.separated(
                    itemCount: state.items.length,
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      return Dismissible(
                        key: UniqueKey(),
                        onDismissed: (direction) {
                          context.read<ListBloc>().add(DeleteItem(item));
                        },
                        background: Container(
                          color: Colors.grey,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        secondaryBackground: Container(
                          color: Colors.blueGrey,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: ListTile(
                          title: Text(
                            item,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const Divider(
                        height: 1,
                        color: Colors.blueGrey,
                      );
                    },
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
          SizedBox(
            height: 80,
            child: BlocBuilder<ButtonBloc, ButtonState>(
              builder: (context, state) {
                return Container(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.buttons.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade200,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.indigo,
                            elevation: 4.0,
                          ),
                          onPressed: () {
                            done(state.buttons[index]);
                          },
                          child: Text(
                            state.buttons[index].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 20,
                              shadows: [
                                Shadow(
                                  blurRadius: 8.0,
                                  color: Colors.indigo,
                                  offset: Offset(3.0, 3.0),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void done(String eventName) {
    hsmEngine.done(eventName);
  }

  @override
  void trace(String event, String? loggerLine) {
    String traceLog = loggerLine ?? '';
    String textLine = '@$event: $traceLog';
    listBloc.add(AddItem(textLine));
  }

  @override
  void transition(String state, String event) {
    print('transition [$state] -> $event');
  }
}
