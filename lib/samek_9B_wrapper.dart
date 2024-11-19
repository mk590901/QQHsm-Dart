//	Class Samek9BWrapper automatically generated at 2024-10-27 09:21:41
import 'core/utilities/utils.dart';

class Samek9BWrapper {
	Map<String, void Function()> lookupTable = <String, void Function()>{};
	Samek9BWrapper () {
		createWalker();
	}

	void createWalker() {
		lookupTable[createKey("s0","Q_ENTRY")]	= s0Entry;
		lookupTable[createKey("s0","Q_EXIT")]	= s0Exit;
		lookupTable[createKey("s0","Q_INIT")]	= s0Init;
		lookupTable[createKey("s0","e")]	= s0E;
		lookupTable[createKey("s2","Q_ENTRY")]	= s2Entry;
		lookupTable[createKey("s2","Q_EXIT")]	= s2Exit;
		lookupTable[createKey("s2","Q_INIT")]	= s2Init;
		lookupTable[createKey("s2","c")]	= s2C;
		lookupTable[createKey("s2","f")]	= s2F;
		lookupTable[createKey("s21","Q_ENTRY")]	= s21Entry;
		lookupTable[createKey("s21","Q_EXIT")]	= s21Exit;
		lookupTable[createKey("s21","Q_INIT")]	= s21Init;
		lookupTable[createKey("s21","b")]	= s21B;
		lookupTable[createKey("s21","h")]	= s21H;
		lookupTable[createKey("s211","Q_ENTRY")]	= s211Entry;
		lookupTable[createKey("s211","Q_EXIT")]	= s211Exit;
		lookupTable[createKey("s211","g")]	= s211G;
		lookupTable[createKey("s1","Q_ENTRY")]	= s1Entry;
		lookupTable[createKey("s1","Q_EXIT")]	= s1Exit;
		lookupTable[createKey("s1","Q_INIT")]	= s1Init;
		lookupTable[createKey("s1","b")]	= s1B;
		lookupTable[createKey("s1","c")]	= s1C;
		lookupTable[createKey("s1","f")]	= s1F;
		lookupTable[createKey("s1","a")]	= s1A;
		lookupTable[createKey("s1","d")]	= s1D;
		lookupTable[createKey("s11","Q_ENTRY")]	= s11Entry;
		lookupTable[createKey("s11","Q_EXIT")]	= s11Exit;
		lookupTable[createKey("s11","g")]	= s11G;
	}

	void s0Entry() {
		print("inside s0Entry");
	}

	void s0Exit() {
		print("inside s0Exit");
	}

	void s0Init() {
		print("inside s0Init");
	}

	void s0E() {
		print("inside s0E");
	}

	void s2Entry() {
		print("inside s2Entry");
	}

	void s2Exit() {
		print("inside s2Exit");
	}

	void s2Init() {
		print("inside s2Init");
	}

	void s2C() {
		print("inside s2C");
	}

	void s2F() {
		print("inside s2F");
	}

	void s21Entry() {
		print("inside s21Entry");
	}

	void s21Exit() {
		print("inside s21Exit");
	}

	void s21Init() {
		print("inside s21Init");
	}

	void s21B() {
		print("inside s21B");
	}

	void s21H() {
		print("inside s21H");
	}

	void s211Entry() {
		print("inside s211Entry");
	}

	void s211Exit() {
		print("inside s211Exit");
	}

	void s211G() {
		print("inside s211G");
	}

	void s1Entry() {
		print("inside s1Entry");
	}

	void s1Exit() {
		print("inside s1Exit");
	}

	void s1Init() {
		print("inside s1Init");
	}

	void s1B() {
		print("inside s1B");
	}

	void s1C() {
		print("inside s1C");
	}

	void s1F() {
		print("inside s1F");
	}

	void s1A() {
		print("inside s1A");
	}

	void s1D() {
		print("inside s1D");
	}

	void s11Entry() {
		print("inside s11Entry");
	}

	void s11Exit() {
		print("inside s11Exit");
	}

	void s11G() {
		print("inside s11G");
	}


	void done(String state, String event) {
		void Function()? function = lookupTable[createKey(state,event)];
		if (function != null) {
			function();
		}
	}

}
