import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher_string.dart';

const bool optimizeWeb = true;

const double compassOffsset = 48;
const double deg2rad = pi / 180.0;
const String schoolURL =
    'https://sites.google.com/bedfordnhk12.net/bhsbulldogs/home';

const String compassBackground = 'assets/images/background.png';
const String compassArrow = 'assets/images/arrow.png';
const int floorCount = 3;

const List<Size> dimensions = [
  Size(1628, 2238),
  Size(1561, 2042),
  Size(1599, 1717),
];

const List<String> backgrounds = [
  'assets/Floor 1/bg.PNG',
  'assets/Floor 2/bg.PNG',
  'assets/Floor 3/bg.PNG',
];

const List<String> jsons = [
  'assets/Floor 1/floor-1.json',
  'assets/Floor 2/floor-2.json',
  'assets/Floor 3/floor-3.json',
];

final List<BoxShadow> styleBoxShadow = kElevationToShadow[2]!;

const SystemUiOverlayStyle styleSystem = SystemUiOverlayStyle(
  systemNavigationBarColor: Colors.white,
  systemNavigationBarIconBrightness: Brightness.dark,
  systemNavigationBarDividerColor: Color.fromARGB(255, 250, 250, 250),
  statusBarColor: Colors.black26,
);

Future<void> openLinkInBrowser(String link) async {
  if (await canLaunchUrlString(link)) {
    await launchUrlString(link, mode: LaunchMode.externalNonBrowserApplication);
  } else {
    throw 'unable to open $link';
  }
}

const String aboutPageMarkdown = '''## What is this App?

This app was made by **Mattan Mohel** (me) for my (his) senior project in the year 2023. The app was made using the **Dart & Flutter** programming langauge / API

>> This is a tribute to all the lost souls traversing BHS, helping them find their way

## Special Thanks

Now a bit more serious, I would like to thank **Mr. Jozokos** for giving me the opprotunity to work on this project and **Mr. Fritz** for heading the computer science department at BHS these past 4 years. These guys are pretty cool

## Any Questions (Or Bugs)

If you have any questions or encounter any bugs please feel free to report them to [mattanmohel@gmail.com](mattanmohel@gmail.com) or the BHS IT Department 

> Anyways, here's an ASCII dog **ChatGPT** drew:

```
        / \\__
       (    @\\___
      /         O
     /   (_____/
    /_____/   U
```

## I hope you enjoyed! 

''';

const String manualMarkdown =
    '''### If you're here then you must have already found the control panel. If you haven't then I'm genuinely impressed at your abilities to somehow open this page

## Let's begin then 
  

> **Control Panel**
- That's where you control _everything..._

> **Floor Control** 
- switch views between the map's different floors. And no, there's no **4th floor** - try it for yourself

> **Accessibility Toggle** 
- if enabled, you will be directed through the elevator rather than the stairs

> **Popup Menu** 
- That's how you got _here_! But it can also take you to the **About Page** or the **School Website**. It's quite the versatile tool

> **Where from?** 
- This controls your **starting** position, designated by a **red point** on the map. Tell it some about yourself - it's a good listener

> **Where to?** 
- This controls your **ending** positions, designated by a **green point** on the map. It's a straightforward question, but also very much a philosophical one

Now to the **Main Screen...**

> **Compass** 
- this shows your direction of travel **relative to the school**, meaning that if the arrow points **up**, you're going **upwards** on the map, sort of like a real compass

> **Map** 
- this is the map - follow the **red line** like a moth to a light and you'll get to where you need to be in no time. Zoom in, zoom out, take a screenshot, share it, appreciate just how nice it is that you're taken care of by this nice little app of mine

> But if you're interested in the **Search Screen...**

1. Type in the name of your destination into the text field and watch as it comes up on the list. Click it to select it, and... done

2. But what if I want to gander at all the different rooms on the list? I hear you asking. Feel free to scroll

At the top, you'll find that this applications comes armed with the option to filter rooms by floor. Try any combination you like - or just deselect them all because the background also looks quite nice

Additionally, after selecting a starting position, you'll find that your **Where To** page shows you the **Nearest Bathroom and Exit** - just because I care for you so much

> I think that sums it up pretty well, so here's an ASCII kitten & cheese that **ChatGPT** drew:

```  
    /\\_/\\          _-_-_-_-_-_
   ( o.o )       /           \\
    > ^ <       |    Cheese   |
   /  -  \\       \\_ _ _ _ _ _/
  /_/   \\_\\
       ||
```

## Thank you for your time

''';
