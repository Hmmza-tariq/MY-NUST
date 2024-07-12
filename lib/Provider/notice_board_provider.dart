import 'package:flutter/material.dart';

class NoticeBoardProvider with ChangeNotifier {
  String link = 'https://ceme.nust.edu.pk/downloads/student-notice-board-ug/';
  String noticeBoard = 'CEME';
  NoticeBoardProvider(String link) {
    setNoticeBoard(link);
  }
  void setNoticeBoard(String name) {
    noticeBoard = name;
    if (name == 'MCS') {
      link = 'https://mcs.nust.edu.pk/downloads/student-notice-board/';
    } else if (name == 'SMME') {
      link = 'https://smme.nust.edu.pk/downloads/student-notice-board/';
    } else if (name == 'SEECS') {
      link = 'https://seecs.nust.edu.pk/downloads/for-students/';
    } else if (name == 'NBS') {
      link = 'https://nbs.nust.edu.pk/downloads/';
    } else if (name == 'PNEC') {
      link = 'https://pnec.nust.edu.pk/downloads/';
    } else if (name == 'SNS') {
      link = 'https://sns.nust.edu.pk/downloads/';
    } else if (name == 'CAE') {
      link = 'https://cae.nust.edu.pk/downloads/';
    } else if (name == 'NBC') {
      link = 'https://nbc.nust.edu.pk/downloads/';
    } else if (name == 'SCME') {
      link = 'https://scme.nust.edu.pk/downloads/';
    } else if (name == 'MCE') {
      link = 'https://mce.nust.edu.pk/downloads/';
    } else if (name == 'IESE') {
      link = 'https://iese.nust.edu.pk/downloads/';
    } else if (name == "NICE") {
      link = 'https://nice.nust.edu.pk/downloads/';
    } else if (name == "IGIS") {
      link = 'https://igis.nust.edu.pk/downloads/';
    } else if (name == "ASAB") {
      link = 'https://asab.nust.edu.pk/downloads/';
    } else if (name == "SADA") {
      link = 'https://sada.nust.edu.pk/downloads/';
    } else if (name == "S3H") {
      link = 'https://s3h.nust.edu.pk/downloads/';
    } else {
      link = 'https://ceme.nust.edu.pk/downloads/student-notice-board-ug/';
    }
    notifyListeners();
  }
}
