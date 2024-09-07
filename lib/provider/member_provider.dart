
import 'package:flutter/foundation.dart';

class MemberProvider extends ChangeNotifier{

  int _loadingIndex = -1;

  int get loadingIndex => _loadingIndex;

  // Set the loading button's index and notify listeners
  void setLoadingIndex(int index) {
    _loadingIndex = index;
    notifyListeners();
  }

  // Reset the loading index to -1 (meaning no button is loading)
  void resetLoadingIndex() {
    _loadingIndex = -1;
    notifyListeners();
  }
}