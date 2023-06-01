import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:senior_project/app_data.dart';
import 'package:senior_project/util/background.dart';
import 'package:senior_project/util/room.dart';
import 'package:senior_project/util/constants.dart' as constants;
import 'package:senior_project/util/toggle.dart';

enum SearchType {
  start,
  end,
}

class SearchButton extends StatefulWidget {
  const SearchButton({
    super.key,
    this.hintText = 'Search...',
    this.rounding = 20,
    this.height = 30,
    this.leadingIcon,
    this.horizontalPadding = 0,
    this.verticalPadding = 0,
    this.borderRadius = 40,
    required this.searchType,
    required this.terms,
  });

  final SearchType searchType;
  final String hintText;
  final double height;
  final double rounding;
  final IconData? leadingIcon;
  final List<Room> terms;
  final double verticalPadding;
  final double horizontalPadding;
  final double borderRadius;

  @override
  State<StatefulWidget> createState() => SearchButtonState();
}

class SearchButtonState extends State<SearchButton> {
  SearchButtonState();

  Room? searchRoom;
  List<Room> recents = [];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: widget.verticalPadding,
        horizontal: widget.horizontalPadding,
      ),
      child: SizedBox(
        height: widget.height,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return Scaffold(
                          body: SearchScreen(this),
                        );
                      },
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                  ),
                ),
                child: Row(
                  children: [
                    if (widget.leadingIcon != null) Icon(widget.leadingIcon!),
                    if (widget.leadingIcon == null) const Icon(Icons.search),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: Text(
                          searchRoom != null
                              ? "${searchRoom!.name} - Floor ${searchRoom!.floor}"
                              : widget.hintText,
                        ),
                      ),
                    ),
                    if (searchRoom != null)
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: InkWell(
                          onTap: () => setText(null),
                          child: const Icon(Icons.clear),
                        ),
                      )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InheritedState get state => InheritedState.of(context);

  void setText(Room? room) {
    switch (widget.searchType) {
      case SearchType.start:
        InheritedState.of(context).setStartPoint(room);
        break;
      case SearchType.end:
        InheritedState.of(context).setEndPoint(room);
        break;
    }

    if (room == null) {
      setState(() => searchRoom = null);
      return;
    }

    int index = recents.indexOf(room);

    if (index != -1) {
      recents.removeAt(index);
    } else if (recents.length >= 5) {
      recents.removeAt(0);
    }

    searchRoom = room;
    setState(() => recents.add(room));
  }
}

class SearchScreen extends StatefulWidget {
  SearchScreen(this.searchState, {super.key});

  final TextEditingController searchController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  final SearchButtonState searchState;

  @override
  State<StatefulWidget> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  _SearchScreenState();

  List<Room> _filteredRooms = [];
  final List<bool> _floorFilter = [true, true, true];

  @override
  void initState() {
    _filteredRooms = List.from(_button.terms);
    widget.searchController.addListener(() => _updateSuggestions());
    super.initState();
  }

  @override
  void dispose() {
    widget.focusNode.dispose();
    widget.searchController.dispose();
    super.dispose();
  }

  SearchButton get _button => widget.searchState.widget;
  InheritedState get _state => widget.searchState.state;

  void _exitSearch(BuildContext context, Room? result) {
    widget.searchState.setText(result);
    Navigator.of(context).pop();
  }

  void _updateSuggestions() {
    setState(() {
      _filteredRooms = _button.terms.where((term) {
        return _floorFilter[term.floor - 1] &&
            term.type != RoomType.none &&
            term.name
                .toLowerCase()
                .contains(widget.searchController.text.trim().toLowerCase());
      }).toList();
      _filteredRooms.sort((r1, r2) => r1.name.compareTo(r2.name));
    });
  }

  void _buildTab(List<Widget> suggestions, String title, List<Room> rooms) {
    suggestions.add(
      SizedBox(
        height: 55,
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          textColor: Colors.black,
          title: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );

    suggestions.add(
      const Divider(
        height: 20,
        thickness: 2,
      ),
    );

    for (Room room in rooms) {
      suggestions.add(
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 4,
          ),
          child: SizedBox(
            height: 100,
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              tileColor: Colors.redAccent,
              textColor: Colors.white,
              title: Text(
                '${room.name} - Floor ${room.floor}',
              ),
              subtitle: Text(room.description),
              onTap: () => _exitSearch(context, room),
            ),
          ),
        ),
      );

      if (rooms.length > 1) {
        suggestions.add(
          const Divider(
            height: 15,
          ),
        );
      }
    }
  }

  List<Widget> _buildSuggestionTiles(BuildContext context) {
    List<Widget> suggestions = [];

    if (_state.start != null &&
        _button.searchType == SearchType.end &&
        widget.searchController.text.isEmpty &&
        !_floorFilter.any((floor) => !floor)) {
      Room? nearestBathroom = _state.getNearestOf(RoomType.bathroom);
      Room? nearestEntrance = _state.getNearestOf(RoomType.exit);
      Room? nearestWayUp = _state.getNearestOf(
          _state.accesibilitySetting ? RoomType.elevator : RoomType.stairs);

      if (nearestBathroom != null) {
        _buildTab(suggestions, 'Nearest Bathroom', [nearestBathroom]);
      }
      if (nearestEntrance != null) {
        _buildTab(suggestions, 'Nearest Exit', [nearestEntrance]);
      }
      if (nearestWayUp != null) {
        _buildTab(
            suggestions,
            _state.accesibilitySetting ? 'Nearest Elevator' : 'Nearest Stairs',
            [nearestWayUp]);
      }
    }

    if (widget.searchState.searchRoom != null &&
        widget.searchState.recents.isNotEmpty &&
        widget.searchController.text.isEmpty) {
      _buildTab(
        suggestions,
        'Recent Searches',
        widget.searchState.recents.reversed.toList(),
      );
    }

    _buildTab(
      suggestions,
      _filteredRooms.isNotEmpty ? 'Search all rooms...' : 'No matching results',
      _filteredRooms,
    );

    return suggestions;
  }

  Flexible _createFilterButton(int floorIndex) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Toggle(
          onToggle: () {
            setState(() {
              _floorFilter[floorIndex] = !_floorFilter[floorIndex];
              _updateSuggestions();
            });
          },
          toggleValue: () {
            return _floorFilter[floorIndex];
          },
          child: Center(
            child: Text(
              'Floor ${floorIndex + 1}',
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            if (!kIsWeb || !constants.optimizeWeb)
              Align(
                alignment: Alignment.topLeft,
                child: CustomPaint(
                  painter: BackgroundPainter(width: 0.2),
                ),
              ),
            SafeArea(
              child: Container(
                height: 130, //65,
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                decoration: BoxDecoration(
                  boxShadow: constants.styleBoxShadow,
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                      // bottom: Radius.circular(15),
                      ),
                ),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                          border: Border(
                            bottom: BorderSide(color: Colors.black12),
                          ),
                        ),
                        child: TextField(
                          style: const TextStyle(
                            color: Colors.black54,
                            height: 1.5,
                          ),
                          cursorHeight: 25,
                          autofocus: true,
                          controller: widget.searchController,
                          focusNode: widget.focusNode,
                          onTapOutside: (_) => FocusScope.of(context).unfocus(),
                          onSubmitted: (result) {
                            _exitSearch(
                                context,
                                _filteredRooms.isNotEmpty
                                    ? _filteredRooms.first
                                    : null);
                          },
                          textAlign: TextAlign.left,
                          cursorColor: Colors.black87,
                          decoration: InputDecoration(
                            iconColor: Colors.white,
                            hintText: 'Where To?',
                            hintStyle: const TextStyle(
                              color: Colors.black,
                            ),
                            filled: false,
                            prefixIconColor: Colors.black26,
                            prefixIcon: InkWell(
                              child: const Icon(Icons.arrow_back),
                              onTap: () => _exitSearch(
                                  context, widget.searchState.searchRoom),
                            ),
                            border: const OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _createFilterButton(0),
                            _createFilterButton(1),
                            _createFilterButton(2),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                children: _buildSuggestionTiles(context),
              ),
            )
          ],
        ),
      ],
    );
  }
}
