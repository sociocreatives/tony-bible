import 'dart:io';

import 'package:bibleartwallpaperhd/utils/constants.dart';

class SliderModel{

  String? imageAssetPath;
  String? title;
  String? desc;

  SliderModel({this.imageAssetPath,this.title,this.desc});

  void setImageAssetPath(String getImageAssetPath){
    imageAssetPath = getImageAssetPath;
  }

  void setTitle(String getTitle){
    title = getTitle;
  }

  void setDesc(String getDesc){
    desc = getDesc;
  }

  String? getImageAssetPath() {
    return imageAssetPath;
  }

  String? getTitle() {
    return title;
  }

  String? getDesc() {
    return desc;
  }

}


List<SliderModel> getSlides(){

  List<SliderModel> slides = [];
  SliderModel sliderModel = new SliderModel();

  //1
  sliderModel.setDesc('''
  ${Constants.appName} is an online Art gallery of about 800 high 
  quality classical Bible paintings, 
  found in museums all over the world.
  ''');
  sliderModel.setTitle('Welcome to ${Constants.appName}');
  sliderModel.setImageAssetPath("assets/icon7.jpeg");
  slides.add(sliderModel);

  sliderModel = new SliderModel();

  //2
  sliderModel.setDesc('''
  Click on the slideshow button and enjoy an endless carousel of your favourite category with piano and classical background music.
  ''');
  sliderModel.setTitle("Slideshow");
  sliderModel.setImageAssetPath("assets/slideshow.png");
  slides.add(sliderModel);

  sliderModel = new SliderModel();

  //3
  sliderModel.setDesc('''
  High quality images may take long to load before they are cached to the device.
  ''');
  sliderModel.setTitle('Image Caching');
  sliderModel.setImageAssetPath("assets/icon.jpg");
  slides.add(sliderModel);

  sliderModel = new SliderModel();

  //4
  if(Platform.isAndroid){
    sliderModel.setDesc('''
  Through the setting tab on the home page, you can change the Slideshow speed for Automatic Wallpaper change duration, music selection and shuffling control.
  ''');
    sliderModel.setImageAssetPath("assets/settings1.jpeg");
  }else{
    sliderModel.setDesc('''
  Through the setting tab on the home page, you can change the Slideshow speed and enjoy smooth transitions, music selection and shuffling control. 
  ''');
    sliderModel.setImageAssetPath("assets/settings2.jpeg");
  }
  sliderModel.setTitle("Settings");
  slides.add(sliderModel);

  sliderModel = new SliderModel();



  //5
  sliderModel.setDesc('''
  Make sure to read the Privacy and Terms Conditions. The links are found on the home screen menu.
  ''');
  sliderModel.setTitle('Privacy & Terms Of Use');
  sliderModel.setImageAssetPath("assets/menu.jpg");
  slides.add(sliderModel);

  sliderModel = new SliderModel();

  return slides;
}