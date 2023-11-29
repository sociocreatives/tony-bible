
class BibleNumericRef {
  static String bibleNumericRefFrom(String book) {
    return _bookToNumber(book);
  }

  static String _bookToNumber(String book){
    if(book == "Genesis"){return "0";}
    else if(book == "Exodus"){return "1";}
    else if(book == "Leviticus"){return "2";}
    else if(book == "Numbers"){return "3";}
    else if(book == "Deuteronomy"){return "4";}
    else if(book == "Joshua"){return "5";}
    else if(book == "Judges"){return "6";}
    else if(book == "Ruth"){return "7";}
    else if(book == "1 Samuel"){return "8";}
    else if(book == "2 Samuel"){return "9";}
    else if(book == "1 Kings"){return "10";}
    else if(book == "2 Kings"){return "11";}
    else if(book == "1 Chronicles"){return "12";}
    else if(book == "2 Chronicles"){return "13";}
    else if(book == "Ezra"){return "14";}
    else if(book == "Nehemiah"){return "15";}
    else if(book == "Esther"){return "16";}
    else if(book == "Job"){return "17";}
    else if(book == "Psalms"){return "18";}
    else if(book == "Proverbs"){return "19";}
    else if(book == "Ecclesiastes"){return "20";}
    else if(book == "Song of Solomon"){return "21";}
    else if(book == "Isaiah"){return "22";}
    else if(book == "Jeremiah"){return "23";}
    else if(book == "Lamentations"){return "24";}
    else if(book == "Ezekiel"){return "25";}
    else if(book == "Daniel"){return "26";}
    else if(book == "Hosea"){return "27";}
    else if(book == "Joel"){return "28";}
    else if(book == "Amos"){return "19";}
    else if(book == "Obadiah"){return "30";}
    else if(book == "Jonah"){return "31";}
    else if(book == "Micah"){return "32";}
    else if(book == "Nahum"){return "33";}
    else if(book == "Habakkuk"){return "34";}
    else if(book == "Zephaniah"){return "35";}
    else if(book == "Haggai"){return "36";}
    else if(book == "Zechariah"){return "37";}
    else if(book == "Malachi"){return "38";}
    else if(book == "Matthew"){return "39";}
    else if(book == "Mark"){return "40";}
    else if(book == "Luke"){return "41";}
    else if(book == "John"){return "42";}
    else if(book == "Acts of the Apostles"){return "43";}
    else if(book == "Romans"){return "44";}
    else if(book == "1 Corinthians"){return "45";}
    else if(book == "2 Corinthians"){return "46";}
    else if(book == "Galatians"){return "47";}
    else if(book == "Ephesians"){return "48";}
    else if(book == "Philippians"){return "49";}
    else if(book == "Colossians"){return "50";}
    else if(book == "1 Thessalonians"){return "51";}
    else if(book == "2 Thessalonians"){return "52";}
    else if(book == "1 Timothy"){return "53";}
    else if(book == "2 Timothy"){return "54";}
    else if(book == "Titus"){return "55";}
    else if(book == "Philemon"){return "56";}
    else if(book == "Hebrews"){return "57";}
    else if(book == "James"){return "58";}
    else if(book == "1 Peter"){return "59";}
    else if(book == "2 Peter"){return "60";}
    else if(book == "1 John"){return "61";}
    else if(book == "2 John"){return "62";}
    else if(book == "3 John"){return "63";}
    else if(book == "Jude"){return "64";}
    else if(book == "Revelation"){return "65";}
    else{return "66";}
  }
}
