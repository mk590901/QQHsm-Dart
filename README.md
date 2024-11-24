# QQHsm/Dart

A other QHsm implementation.

## Introduction. A bit of theory
The application of a state machine is based on a very simple principle: need to find the state of the state machine to which it will transition from the current state under the influence of an event. When a transition occurs, the transition function is launched.

A regular flat state machine can be represented by a vector of states, each of which contains a table of transitions to the target state under the influence of an event. This table may also contain a pointer to the transition function. If a pair <current state, target state> is found in the table, the target state becomes current, and the transition function is launched. If a suitable pair is not found, the state machine remains in the previous state.

In the case of a hierarchical state machine, things are different. When transitioning from current state A to target state, transitions to intermediate states are possible. That is, the transition A..E in reality can turn into a series of transitions: to A, B, C, D, E, for example.

In Quantum Leaps (https://www.state-machine.com/), the state is a function with an event as a parameter. The result of execution is a new state in the form of a reference to a method corresponding to this state or null if the new state is not found. In the latter case, the possibility of making a transition in the parent of the current state is analyzed using a special algorithm. As a result, a chain of transitions is built through trial and error.

I came up with the idea of ​​getting rid of using a method as a state and replacing it with a data node keeps the reference to parent state and a transition table. That is, instead of executing a method, need implement search in special tree structure and return not a pointer to a method, but the name of the target state. In this case, the fundamental algorithm remains unchanged.

Actually, the solution to the problem comes down to replacing calls like __t = t(event)__ in Samek's algorithm with a call like __t = evalState(t,event)__. And that's all. Compare the code in QQHsm.dart with the QHsm class in the QQHsm folder of the presented project.

## Data structure
Data structure replacing the state as method of the class is given below:

![uml](https://github.com/user-attachments/assets/b6a855d9-3846-46fe-9216-e2d960babfea)

## Prerequisites
The HSM editor needs to be supplemented with a new compiler that generates a data structure describing the hierarchical state machine and create a file containing a set of transfer functions called when transitioning from a given state when events arrive. Naturally, it is necessary to create a framework, or rather an API, that provides sending events to the state machine and receiving a response in the form of transactions to call transfer functions.

## Goals
* The first: to simplify the application by reducing interaction with the state machine to sending events and receiving keys to call transfer functions.
* The second: getting rid of the code describing the state machine. This solution will allow removing the description of the state machine from the application and considering the state machine as an external resource. In other words, the application logic can be changed from the outside: either without changing the code, or by limiting it to minimal changes.

## Implementation
The developer receives two files as a result of compiling the scheme: a data file describing the state machine in json format and a <project name>_wrapper.dart file with prototypes of transition functions.

## Application structure
* Framework is in folders QQBridge, QQContextObject, QQHsm and QQMediator
• Description of state machine in json format is placed in the __assets folder__. This is done to simplify access to the file. Nothing prevents you from placing it in public folders Documents, Downloads, etc...
• File <project name>_wrapper.dart is in folder __scheme__.
• GUI app is main.dart

## Application description

The GUI application consists of two views:
* Horizontal list view - for placing a list of buttons corresponding to events
* Vertical list view - for tracing states when receiving events
* All manipulations with views are carried out through the corresponding __BLoBs__. If in the case of the tracing list there are no questions why this is done, then in the case of the list of buttons it is worth noting that this is done in order to avoid using a hardcoded list of events. The list of events is extracted from the json file and entered into the view list using the __ButtonBlob pattern__. If you need to check another HSM scheme, you will only need to replace the json file

By clicking on the button with event, we get the route of passing events states as an item of the vertical view.

Calling the function __initHsmEngine__ in Future.microtask(..) in HomePage widget build method initiates deserialization of the state machine from the json file into a tree structure and initialization of the state machine.

NB! As usual, was consider the diagram presented in the fourth chapter of the book __Practical Statecharts in C/C++__.

## Movie
Shows the contents of 2 files: json & launching an application using the wrapper generated by the editor.

https://github.com/user-attachments/assets/2c9c8ad1-3978-4f0a-b939-be38c3785c30


## Conclusions
The proposed approach to describing and navigating transitions in the state machine is not some kind of innovation, but represents a different interpretation of known principles.

