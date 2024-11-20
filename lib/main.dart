import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'list_bloc.dart';
import 'button_bloc.dart';
import 'QQHsm/QQHsmEngine.dart';
import 'interfaces/i_updater.dart';
import 'samek_9B_wrapper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

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
      // home: BlocProvider(
      //   create: (context) => listBloc,
      //   child: MyHomePage(listBloc),
      // ),
      home: MultiBlocProvider(
        providers: [
          BlocProvider<ButtonBloc>(
            create: (context) => buttonBloc,
          ),
          BlocProvider<ListBloc>(
            create: (context) => listBloc,
          ),
        ],
        child: MyHomePage(listBloc, buttonBloc),
      ),

    );
  }
}

class MyHomePage extends StatelessWidget implements IUpdater {

  //final List<String> buttons = List.generate(10, (index) => 'Button $index');

  final ListBloc listBloc;
  final ButtonBloc buttonBloc;

  late List<String> buttons = [];

  late  bool  engineIsLoaded  = false;
  late  List<String> actualEvents = [];
  final String  _fileName = "assets/stateMachines/samek_9B_engine.json";
  late  QQHsmEngine hsmEngine;
  final Samek9BWrapper hsmWrapper = Samek9BWrapper();

  MyHomePage(this.listBloc, this.buttonBloc, {super.key});

  Future<String> getFileData(String path) async {
    return await rootBundle.loadString(path);
  }

  void loadHsmDescriptor() {
    getFileData(_fileName).then((String text) {
      if (text.isNotEmpty) {
        hsmEngine = QQHsmEngine(this);
        hsmEngine.create(text);
        actualEvents = hsmEngine.appEvents()!;
        print('actualEvents->$actualEvents');
        engineIsLoaded = true;

        //buttonBloc.add(AddButtonList(actualEvents));
        buttonBloc.add(AddButtonList(actualEvents));
      }
      else {
        print ('Failed to loaded $_fileName');
        return;
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    //loadHsmDescriptor();

    //buttons = List.generate(10, (index) => 'Button $index');
    //buttons = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];

    // buttons = actualEvents;
    // print('buttons->$actualEvents');

    Future.microtask(() {
      // Ensure this code runs after the build method completes
      if (context.mounted) {
        print('******* INIT ENGINE *******');
        loadHsmDescriptor();

        // context.read<ListBloc>().add(const AddItem('Initial Item'));
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
                  return ListView.separated(
                    itemCount: state.items.length,
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      return Dismissible(
                        key: UniqueKey(),
                        onDismissed: (direction) {
                          context.read<ListBloc>().add(DeleteItem(item));
                        },
                        background: Container(color: Colors.blueGrey),
                        child: ListTile(
                          title: Text(item),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const Divider(
                        height: 1,
                        color: Colors.blueAccent,
                      );
                    },
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),

          //Expanded(
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
                          onPressed: () {
                            done(state.buttons[index]);
                          },
                          child: Text(state.buttons[index]),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),

          /*
          SizedBox(
            height: 100,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: actualEvents.map((button) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        //context.read<ListBloc>().add(AddItem(button));
                        done(button);
                      },
                      child: Text(button),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        */


        ],
      ),
    );
  }

  void done (String eventName) {
    hsmEngine.done(eventName);
  }

  @override
  void trace(String event, String? log) {
    print('trace [$event] -> $log');
    String traceLog = log?? '';
    String textLine = '@$event: $traceLog';
    listBloc.add(AddItem(/*traceLog*/textLine));
  }

  @override
  void transition(String state, String event) {
    print('transition [$state] -> $event');
    //@hsmWrapper.done(state, event);
  }
}
