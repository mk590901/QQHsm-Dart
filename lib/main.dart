import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'list_bloc.dart';
import 'QQHsm/QQHsmEngine.dart';
import 'interfaces/i_updater.dart';
import 'samek_9B_wrapper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Two Part List View with BLoC',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (context) => ListBloc(),
        child: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget implements IUpdater {

  //final List<String> buttons = List.generate(10, (index) => 'Button $index');

  late List<String> buttons = [];

  late  bool  engineIsLoaded  = false;
  late  List<String> actualEvents = [];
  final String  _fileName = "assets/stateMachines/samek_9B_engine.json";
  late  QQHsmEngine hsmEngine;
  final Samek9BWrapper hsmWrapper = Samek9BWrapper();

  MyHomePage({super.key});

  Future<String> getFileData(String path) async {
    return await rootBundle.loadString(path);
  }

  void loadHsmDescriptor() {
    getFileData(_fileName).then((String text) {
      if (text.isNotEmpty) {
        hsmEngine = QQHsmEngine(this);
        hsmEngine.create(text);
        actualEvents = hsmEngine.appEvents()!;
        engineIsLoaded = true;
      }
      else {
        print ('Failed to loaded $_fileName');
        return;
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    buttons = List.generate(10, (index) => 'Button $index');

    Future.microtask(() {
      // Ensure this code runs after the build method completes
      if (context.mounted) {
        print('******* INIT ENGINE *******');

        loadHsmDescriptor();

        context.read<ListBloc>().add(const AddItem('Initial Item'));
      // ApplicationHolder.holder()?.initSimulator(() {
      //   print ('******* REFRESH SIMULATION WIDGET *******');
      //   simulationWidget.refresh();
      // });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Two Part List View with BLoC'),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ListBloc, ListState>(
              builder: (context, state) {
                if (state is ListLoaded) {
                  return ListView.builder(
                    itemCount: state.items.length,
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      return Dismissible(
                        key: UniqueKey(),
                        onDismissed: (direction) {
                          context.read<ListBloc>().add(DeleteItem(item));
                        },
                        background: Container(color: Colors.red),
                        child: ListTile(
                          title: Text(item),
                        ),
                      );
                    },
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
          SizedBox(
            height: 100,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: buttons.map((button) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<ListBloc>().add(AddItem(button));
                      },
                      child: Text(button),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void trace(String event, String? log) {
    print('trace [$event] -> $log');
  }

  @override
  void transition(String state, String event) {
    print('transition [$state] -> $event');
    //@hsmWrapper.done(state, event);
  }
}

/*
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Two Part List View with BLoC',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider(
        create: (context) => ListBloc(),
        child: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final List<String> buttons = List.generate(10, (index) => 'Button $index');

  MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Two Part List View with BLoC'),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ListBloc, ListState>(
              builder: (context, state) {
                if (state is ListLoaded) {
                  return ListView.builder(
                    itemCount: state.items.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(state.items[index]),
                      );
                    },
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
          SizedBox(
            height: 100,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: buttons.map((button) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<ListBloc>().add(AddItem(button));
                      },
                      child: Text(button),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

*/