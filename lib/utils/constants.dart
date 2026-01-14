import 'package:flutter/material.dart';

const dummyImageUrl = "https://dummyimage.com/1x1/0011ff/0011ff.png";
const dummyUrl = "https://www.example.com";

const List<String> commentReactions = [
  "❤️",
  "🔥",
  "🙌",
  "👏",
  "👍",
  "😍",
  "😮",
  "😊",
];

const AssetImage defaultProfileImage = AssetImage("assets/default_pfp.png");

const List<Map<String, dynamic>> themeOptions = [
  {
    "key": "light",
    "title": "Light",
    "icon": Icons.light_mode,
  },
  {
    "key": "dark",
    "title": "Dark",
    "icon": Icons.dark_mode,
  },
  {
    "key": "system",
    "title": "System",
    "icon": Icons.brightness_4,
  }
];

const int themeColorsColumnCount = 3;
const List<List<Color?>> themeColors = [
  [Colors.yellow, Colors.red, Colors.green, Colors.blue, Colors.purple],
  [Colors.orange, Colors.pink, Colors.teal, Colors.brown, Colors.cyan],
  [Colors.indigo, Colors.lime, Colors.amber, null, null],
];
