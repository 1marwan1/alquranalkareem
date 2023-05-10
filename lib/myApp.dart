import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:alquranalkareem/notes/cubit/note_cubit.dart';
import 'package:alquranalkareem/quran_page/cubit/audio/cubit.dart';
import 'package:alquranalkareem/quran_page/cubit/bookmarks/bookmarks_cubit.dart';
import 'package:alquranalkareem/quran_page/data/repository/quarter_repository.dart';
import 'package:alquranalkareem/quran_text/cubit/quran_text_cubit.dart';
import 'package:alquranalkareem/quran_text/cubit/surah_text_cubit.dart';
import 'package:alquranalkareem/screens/splash_screen.dart';
import 'package:arabic_numbers/arabic_numbers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:home_widget/home_widget.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workmanager/workmanager.dart';
import 'cubit/ayaRepository/aya_cubit.dart';
import 'cubit/cubit.dart';
import 'cubit/quarter/quarter_cubit.dart';
import 'cubit/sorahRepository/sorah_repository_cubit.dart';
import 'cubit/translateDataCubit/_cubit.dart';


/// Used for Background Updates using Workmanager Plugin
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) {
    print('Background task started: $taskName'); // Added print statement

    // Generate a random Zikr
    Set<int> usedIndices = {};
    int randomIndex;
    do {
      randomIndex = Random().nextInt(zikr.length);
    } while (usedIndices.contains(randomIndex));
    usedIndices.add(randomIndex);
    final randomZikr = zikr[randomIndex];


    return Future.wait<bool?>([
      HomeWidget.saveWidgetData(
        'zikr',
        randomZikr,
      ),
      HomeWidget.updateWidget(
        name: 'ZikerWidget',
        iOSName: 'ZikerWidget',
      ),
    ]).then((value) {
      print('Background task completed: $taskName'); // Added print statement
      return !value.contains(false);
    });
  });
}

/// Called when Doing Background Work initiated from Widget
@pragma("vm:entry-point")
void backgroundCallback(Uri? data) async {
  print(data);

  if (data!.host == 'zikr') {
    Set<int> usedIndices = {};
    int randomIndex;
    do {
      randomIndex = Random().nextInt(zikr.length);
    } while (usedIndices.contains(randomIndex));
    usedIndices.add(randomIndex);
    final randomZikr = zikr[randomIndex];

    await HomeWidget.saveWidgetData<String>('zikr', randomZikr);
    await HomeWidget.updateWidget(
        name: 'ZikerWidget', iOSName: 'ZikerWidget');
  }
}

List<String> zikr = <String>[
  'اللّهُـمَّ بِكَ أَصْـبَحْنا وَبِكَ أَمْسَـينا ، وَبِكَ نَحْـيا وَبِكَ نَمُـوتُ وَإِلَـيْكَ النُّـشُور.',
  'أَصْبَـحْـنا وَأَصْبَـحْ المُـلكُ للهِ رَبِّ العـالَمـين ، اللّهُـمَّ إِنِّـي أسْـأَلُـكَ خَـيْرَ هـذا الـيَوْم ، فَـتْحَهُ ، وَنَصْـرَهُ ، وَنـورَهُ وَبَـرَكَتَـهُ ، وَهُـداهُ ، وَأَعـوذُ بِـكَ مِـنْ شَـرِّ ما فـيهِ وَشَـرِّ ما بَعْـدَه.',
  'اللّهُـمَّ إِنِّـي أَصْبَـحْتُ أُشْـهِدُك ، وَأُشْـهِدُ حَمَلَـةَ عَـرْشِـك ، وَمَلَائِكَتَكَ ، وَجَمـيعَ خَلْـقِك ، أَنَّـكَ أَنْـتَ اللهُ لا إلهَ إلاّ أَنْـتَ وَحْـدَكَ لا شَريكَ لَـك ، وَأَنَّ ُ مُحَمّـداً عَبْـدُكَ وَرَسـولُـك.',
  'اللَّهُمَّ إِنِّي أَسْأَلُكَ عِلْمًا نَافِعًا، وَرِزْقًا طَيِّبًا، وَعَمَلًا مُتَقَبَّلًا.',
  'يَا حَيُّ يَا قيُّومُ بِرَحْمَتِكَ أسْتَغِيثُ أصْلِحْ لِي شَأنِي كُلَّهُ وَلاَ تَكِلْنِي إلَى نَفْسِي طَـرْفَةَ عَيْنٍ.',
  'حَسْبِـيَ اللّهُ لا إلهَ إلاّ هُوَ عَلَـيهِ تَوَكَّـلتُ وَهُوَ رَبُّ العَرْشِ العَظـيم.',
  'بِسـمِ اللهِ الذي لا يَضُـرُّ مَعَ اسمِـهِ شَيءٌ في الأرْضِ وَلا في السّمـاءِ وَهـوَ السّمـيعُ العَلـيم.',
  'اللَّهُمَّ عَافِنِي فِي بَدَنِي، اللَّهُمَّ عَافِنِي فِي سَمْعِي، اللَّهُمَّ عَافِنِي فِي بَصَرِي، لاَ إِلَهَ إِلاَّ أَنْتَ. اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْكُفْرِ، وَالفَقْرِ، وَأَعُوذُ بِكَ مِنْ عَذَابِ القَبْرِ، لاَ إِلَهَ إِلاَّ أَنْتَ.',
  'رَضيـتُ بِاللهِ رَبَّـاً وَبِالإسْلامِ ديـناً وَبِمُحَـمَّدٍ صلى الله عليه وسلم نَبِيّـاً.',
  'سُبْحـانَ اللهِ وَبِحَمْـدِهِ عَدَدَ خَلْـقِه ، وَرِضـا نَفْسِـه ، وَزِنَـةَ عَـرْشِـه ، وَمِـدادَ كَلِمـاتِـه.',
  'لَا إلَه إلّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءِ قَدِيرِ.',
  'سُبْحـانَ اللهِ وَبِحَمْـدِهِ.',
  'أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ.',
  'اللَّهُمَّ صَلِّ وَسَلِّمْ وَبَارِكْ على نَبِيِّنَا مُحمَّد.',
  'الْحَمْدُ للَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا، وَإِلَيْهِ النُّشُورُ.',
  'الْحَمْدُ لِلَّهِ الَّذِي عَافَانِي فِي جَسَدِي، وَرَدَّ عَلَيَّ رُوحِي، وَأَذِنَ لي بِذِكْرِهِ.',
  'الْحَمْدُ للَّهِ الَّذِي كَسَانِي هَذَا (الثَّوْبَ) وَرَزَقَنِيهِ مِنْ غَيْرِ حَوْلٍ مِنِّي وَلاَ قُوَّة.',
  'اللَّهُمَّ لَكَ الْحَمْدُ أَنْتَ كَسَوْتَنِيهِ، أَسْأَلُكَ مِنْ خَيْرِهِ وَخَيْرِ مَا صُنِعَ لَهُ، وَأَعُوذُ بِكَ مِنْ شَرِّهِ وَشَرِّ مَا صُنِعَ لَهُ.',
  'أَشْهَدُ أَنْ لاَ إِلَهَ إِلاَّ اللَّهُ وَحْدَهُ لاَ شَرِيكَ لَهُ وَأَشْهَدُ أَنَّ مُحَمَّداً عَبْدُهُ وَرَسُولُهُ.',
  'اللَّهُمَّ اجْعَلْنِي مِنَ التَّوَّابِينَ وَاجْعَلْنِي مِنَ الْمُتَطَهِّرِينَ.',
  'سُبْحانَكَ اللَّهُمَّ وَبِحَمْدِكَ، أَشْهَدُ أَنْ لاَ إِلَهَ إِلاَّ أَنْتَ، أَسْتَغْفِرُكَ وَأَتوبُ إِلَيْكَ.',
  'بِسْمِ اللَّهِ، تَوَكَّلْتُ عَلَى اللَّهِ، وَلَاَ حَوْلَ وَلَا قُوَّةَ إِلاَّ بِاللَّهِ.',
  'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ أَنْ أَضِلَّ، أَوْ أُضَلَّ، أَوْ أَزِلَّ، أَوْ أُزَلَّ، أَوْ أَظْلِمَ، أَوْ أُظْلَمَ، أَوْ أَجْهَلَ، أَوْ يُجْهَلَ عَلَيَّ.',
  'بِسْمِ اللَّهِ وَلَجْنَا، وَبِسْمِ اللَّهِ خَرَجْنَا، وَعَلَى اللَّهِ رَبِّنَا تَوَكَّلْنَا، ثُمَّ لِيُسَلِّمْ عَلَى أَهْلِهِ.',
  'اللَّهُمَّ رَبَّ هَذِهِ الدَّعْوَةِ التَّامَّةِ، وَالصَّلاَةِ الْقَائِمَةِ، آتِ مُحَمَّداً الْوَسِيلَةَ وَالْفَضِيلَةَ، وَابْعَثْهُ مَقَامَاً مَحمُوداً الَّذِي وَعَدْتَهُ، [إِنَّكَ لَا تُخْلِفُ الْمِيعَادَ].',
  'اللَّهُــمَّ إِنِّي أَعُوذُ بِكَ مِنْ عَذَابِ الْقَبْرِ، وَمِنْ عَذَابِ جَهَنَّمَ، وَمِنْ فِتْنَةِ الْمَحْيَا وَالْمَمَاتِ، وَمِنْ شَرِّ فِتْنَةِ الْمَسِيحِ الدَّجَّالِ.',
  'اللَّهُمَّ إِنِّي أَعوذُ بِكَ مِنْ عَذَابِ الْقَبْرِ، وَأَعوذُ بِكَ مِنْ فِتْنَةِ الْمَسِيحِ الدَّجَّالِ، وَأَعوذُ بِكَ مِنْ فِتْنَةِ الْمَحْيَا وَالْمَمَاتِ. اللَّهُمَّ إِنِّي أَعوذُ بِكَ مِنَ الْمَأْثَمِ وَالْمَغْرَمِ.',
  'اللَّهُمَّ إِنِّي ظَلَمْتُ نَفْسِي ظُلْماً كَثِيراً، وَلاَ يَغْفِرُ الذُّنوبَ إِلاَّ أَنْتَ، فَاغْفِرْ لِي مَغْفِرَةً مِنْ عِنْدِكَ وَارْحَمْنِي، إِنَّكَ أَنْتَ الغَفورُ الرَّحيمُ.',
  'اللَّهُمَّ اغْفِرْ لِي مَا قَدَّمْتُ، وَمَا أَخَّرْتُ، وَمَا أَسْرَرْتُ، وَمَا أَعْلَنْتُ، وَمَا أَسْرَفْتُ، وَمَا أَنْتَ أَعْلَمُ بِهِ مِنِّي. أَنْتَ الْمُقَدِّمُ، وَأَنْتَ الْمُؤَخِّرُ لاَ إِلَهَ إِلاَّ أَنْتَ.',
  'اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ، وَشُكْرِكَ، وَحُسْنِ عِبادَتِكَ.',
  'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْبُخْلِ، وَأَعوذُ بِكَ مِنَ الْجُبْنِ، وَأَعُوذُ بِكَ مِنْ أَنْ أُرَدَّ إِلَى أَرْذَلِ الْعُمُرِ، وَأَعُوذُ بِكَ مِنْ فِتْنَةِ الدُّنْيَا وَعَذَابِ الْقَبْرِ.',
  'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْجَنَّةَ وَأَعُوذُ بِكَ مِنَ النَّارِ.',
  'اللَّهُمَّ إِنِّي أَسْأَلُكَ يَا أَللَّهُ بِأَنَّكَ الْوَاحِدُ الْأَحَدُ الصَّمَدُ الَّذِي لَمْ يَلِدْ وَلَمْ يولَدْ، وَلَمْ يَكنْ لَهُ كُفُواً أَحَدٌ، أَنْ تَغْفِرَ لِي ذُنُوبِي إِنَّكَ أَنْتَ الْغَفُورُ الرَّحِّيمُ.',
  'اللَّهُمَّ إِنِّي أَسْأَلُكَ بِأَنَّ لَكَ الْحَمْدَ لَا إِلَهَ إِلاَّ أَنْتَ وَحْدَكَ لاَ شَرِيكَ لَكَ، الْمَنَّانُ، يَا بَدِيعَ السَّمَوَاتِ وَالْأَرْضِ يَا ذَا الْجَلاَلِ وَالْإِكْرَامِ، يَا حَيُّ يَا قَيُّومُ إِنِّي أَسْأَلُكَ الْجَنَّةَ وَأَعُوذُ بِكَ مِنَ النَّارِ.',
  'اللَّهُمَّ إِنِّي أَسْأَلُكَ بِأَنَّي أَشْهَدُ أَنَّكَ أَنْتَ اللَّهُ لاَ إِلَهَ إِلاَّ أَنْتَ الْأَحَدُ الصَّمَدُ الَّذِي لَمْ يَلِدْ وَلَمْ يُولَدْ وَلَمْ يَكُنْ لَهُ كُفُواً أَحَدٌ.',
  'أَسْتَغْفِرُ اللَّهَ.',
  'اللَّهُمَّ أَنْتَ السَّلاَمُ، وَمِنْكَ السَّلاَمُ، تَبَارَكْتَ يَا ذَا الْجَلاَلِ وَالْإِكْرَامِ.',
  'لاَ إِلَهَ إِلاَّ اللَّهُ وَحْدَهُ لاَ شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ [ثلاثاً]، اللَّهُمَّ لاَ مَانِعَ لِمَا أَعْطَيْتَ، وَلاَ مُعْطِيَ لِمَا مَنَعْتَ، وَلاَ يَنْفَعُ ذَا الْجَدِّ مِنْكَ الجَدُّ.',
  'سُبْحَانَ اللَّهِ، وَالْحَمْدُ لِلَّهِ، وَاللَّهُ أَكْبَرُ (ثلاثاً وثلاثين) لاَ إِلَهَ إِلاَّ اللَّهُ وَحْدَهُ لاَ شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ.',
  'لاَ إِلَهَ إِلاَّ اللَّهُ وَحْدَهُ لاَ شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ يُحْيِي وَيُمِيتُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ. عَشْرَ مَرّاتٍ بَعْدَ صَلاةِ الْمَغْرِبِ وَالصُّبْحِ.',
  'اللَّهُمَّ إِنِّي أَسْأَلُكَ عِلْماً نافِعاً، وَرِزْقاً طَيِّباً، وَعَمَلاً مُتَقَبَّلاً بَعْدَ السّلامِ مِنْ صَلاَةِ الفَجْرِ.',
  'اللَّهُمَّ إِنَّكَ خَلَقْتَ نَفْسِي وَأَنْتَ تَوَفَّاهَا، لَكَ مَمَاتُهَا وَمَحْياهَا، إِنْ أَحْيَيْتَهَا فَاحْفَظْهَا، وَإِنْ أَمَتَّهَا فَاغْفِرْ لَهَا. اللَّهُمَّ إِنِّي أَسْأَلُكَ العَافِيَةَ.',
  'اللَّهُمَّ قِنِي عَذَابَكَ يَوْمَ تَبْعَثُ عِبَادَكَ.',
  'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا.',
  'سُبْحَانَ اللَّهِ (ثلاثاً وثلاثين)\nوَالْحَمْدُ لِلَّهِ (ثلاثاً وثلاثين)\nوَاللَّهُ أَكْبَرُ (أربعاً وثلاثينَ).',
  'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا، وَكَفَانَا، وَآوَانَا، فَكَمْ مِمَّنْ لاَ كَافِيَ لَهُ وَلاَ مُؤْوِيَ.',
  'لاَ إِلَهَ إِلاَّ اللَّهُ الْوَاحِدُ الْقَهّارُ، رَبُّ السَّمَوَاتِ وَالْأَرْضِ وَمَا بَيْنَهُمَا الْعَزيزُ الْغَفَّارُ.',
  'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ غَضَبِهِ وَعِقَابِهِ، وَشَرِّ عِبَادِهِ، وَمِنْ هَمَزَاتِ الشَّياطِينِ وَأَنْ يَحْضُرُونِ.',
  'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ، وَالْعَجْزِ وَالْكَسَلِ، وَالْبُخْلِ وَالْجُبْنِ، وَضَلَعِ الدَّيْنِ وَغَلَبَةِ الرِّجَالِ.',
  'لاَ إِلَهَ إِلاَّ اللَّهُ الْعَظِيمُ الْحَلِيمُ، لاَ إِلَهَ إِلاَّ اللَّهُ رَبُّ الْعَرْشِ الْعَظِيمِ، لاَ إِلَهَ إِلاَّ اللَّهُ رَبُّ السَّمَوَاتِ وَرَبُّ الْأَرْضِ وَرَبُّ الْعَرْشِ الْكَرِيمِ.',
  'اللَّهُمَّ رَحْمَتَكَ أَرْجُو، فَلاَ تَكِلْنِي إِلَى نَفْسِي طَرْفَةَ عَيْنٍ، وَأَصْلِحْ لِي شَأْنِي كُلَّهُ، لاَ إِلَهَ إِلاَّ أَنْتَ.',
  'لاَ إِلَهَ إِلاَّ أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظّالِمِينَ.',
  'اللَّهُ اللَّهُ رَبِّي لاَ أُشْرِكُ بِهِ شَيْئاً.',
  'اللَّهُمَّ إِنَّا نَجْعَلُكَ فِي نُحُورِهِم، وَنَعُوذُ بِكَ مِنْ شُرُورِهِمْ.',
  'اللَّهُمَّ أَنْتَ عَضُدِي، وَأَنْتَ نَصِيرِي، بِكَ أَحُولُ وَبِكَ أَصُولُ، وَبِكَ أُقاتِلُ.',
  'حَسْبُنا اللَّهُ وَنِعْمَ الْوَكِيلُ.',
  'اللَّهُمَّ مُنْزِلَ الْكِتَابِ، سَرِيعَ الْحِسَابِ، اهْزِمِ الأَحْزَابَ، اللَّهُمَّ اهزِمْهُمْ وَزَلْزِلْهُمْ.',
  'اللَّهُمَّ اكْفِنِيهِمْ بِمَا شِئْتَ.',
  'اللَّهُمَّ اكْفِنِي بِحَلاَلِكَ عَنْ حَرَامِكَ، وَأَغْنِنِي بِفَضْلِكِ عَمَّنْ سِوَاكَ.',
  'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ، وَالْعَجْزِ وَالْكَسَلِ، وَالْبُخْلِ وَالْجُبْنِ، وَضَلَعِ الدَّيْنِ وَغَلَبَةِ الرِّجَالِ.',
  'اللَّهُمَّ لاَ سَهْلَ إِلاَّ مَا جَعَلْتَهُ سَهْلاً، وَأَنْتَ تَجْعَلُ الْحَزْنَ إِذَا شِئْتَ سَهْلاً.',
  'قَدَرُ اللَّهُ وَمَا شَاءَ فَعَلَ.',
  'إِنَّا لِلَّهِ وَإِنَّا إِلَيْهِ رَاجِعُونَ، اللَّهُمَّ أْجُرْنِي فِي مُصِيبَتِي، وَأَخْلِفْ لِي خَيْرَاً مِنْهَا.',
  'اللَّهُمَّ إِنِّي أَسْــــــأَلُكَ خَيْرَهَا، وَأَعُوذُ بِكَ مِنْ شَرِّهَا.',
  'اللَّهُمَّ إِنِّي أَسْأَلُكَ خَيْرَهَا، وَخَيْرَ مَا فِيهَا، وَخَيْرَ مَا أُرْسِلَتْ بِهِ، وَأَعُوذُ بِكَ مِنْ شَرِّهَا، وَشَرِّ مَا فِيهَا، وَشَرِّ مَا أُرْسِلَتْ بِهِ.',
  'سُبْحَانَ الَّذِي يُسَبِّحُ الرَّعْدُ بِحَمْدِهِ وَالْمَلاَئِكةُ مِنْ خِيفَتِهِ.',
  'اللَّهُمَّ اسْقِنَا غَيْثاً مُغِيثاً مَرِيئاً مَرِيعاً، نَافِعاً غَيْرَ ضَارٍّ، عَاجِلاً غَيْرَ آجِلٍ.',
  'اللَّهُمَّ أَغِثْنَا، اللَّهُمَّ أَغِثْنَا، اللَّهُمَّ أَغِثْنَا.',
  'اللَّهُمَّ اسْقِ عِبَادَكَ، وَبَهَائِمَكَ، وَانْشُرْ رَحْمَتَكَ، وَأَحْيِي بَلَدَكَ الْمَيِّتَ.',
  'اللَّهُمَّ صَيِّباً نَافِعاً.',
  'بِسْمِ اللَّهِ، اللَّهُمَّ جَنِّبْنَا الشَّيْطَانَ، وَجَنِّبِ الشَّيْطَانَ مَا رَزَقْتَنَا.',
  'أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ.',
  'الْحَمْدُ لِلَّهِ الَّذِي عَافَانِي مِمَّا ابْتَلاَكَ بِهِ، وَفَضَّلَنِي عَلَى كَثِيرٍ مِمَّنْ خَلَقَ تَفْضِيلاً.',
  'عَنِ ابْنِ عُمَرَ رضي الله عنه قَاَلَ: كَانَ يُعَدُّ لِرَسُولِ اللَّهِ صلى الله عليه وسلم فِي الْمَجْلِسِ الوَاحِدِ مِائَةُ مَرَّةٍ مِنْ قَبْلِ أَنْ يَقُومَ: رَبِّ اغْفِرْ لِي، وَتُبْ عَلَيَّ، إِنَّكَ أَنْتَ التَّوَّابُ الغَفُورُ.',
  'سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ، أَشْهَدُ أَنْ لاَ إِلَهَ إِلاَّ أَنْتَ، أَسْتَغْفِرُكَ وَأَتُوبُ إِلَيْكَ.',
  'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ أَنْ أُشْرِكَ بِكَ وَأَنَا أَعْلَمُ، وَأَسْتَغْفِرُكَ لِمَا لاَ أَعْلَمُ.',
  'اللَّهُمَّ لاَ طَيْرَ إِلاَّ طَيْرُكَ، وَلاَ خَيْرَ إِلاَّ خَيْرُكَ، وَلاَ إِلَهَ غَيْرُكَ.',
  'كَانَ النَّبِيُّ صلى الله عليه وسلم إِذَا أَتَاهُ الْأَمْرُ يَسُرُّهُ قَالَ: الْحَمْدُ لِلَّهِ الَّذِي بِنِعْمَتِهِ تَتِمُّ الصَّالِحَاتُ وَإِذَا أَتَاهُ الْأَمْرُ يَكْرَهُهُ قَالَ: الْحَمْدُ لِلَّهِ عَلَى كُلِّ حَالٍ.',
  'إِذَا سَمِعْتُمْ صِيَاحَ الدِّيَكَةِ فَاسْأَلُوا اللَّهَ مِنْ فَضْلِهِ؛ فَإِنَّهَا رَأَتْ مَلَكاً وَإِذَا سَمِعْتُمْ نَهِيقَ الْحِمَارِ فَتَعَوَّذُوا بِاللَّهِ مِنَ الشَّيطَانِ؛ فَإِنَّهُ رَأَى شَيْطَاناً.',
  'إِذَا سَمِعْتُمْ نُبَاحَ الْكِلاَبِ وَنَهِيقَ الْحَمِيرِ بِاللَّيْلِ فَتَعَوَّذُوا بِاللَّهِ مِنْهُنَّ؛ فَإِنَّهُنَّ يَرَيْنَ مَا لاَ تَرَوْنَ.',
  'اللَّهُمَّ لاَ تُؤَاخِذْنِي بِمَا يَقُولُونَ، وَاغْفِرْ لِي مَا لاَ يَعْلَمُونَ، [وَاجْعَلْنِي خَيْراً مِمَّا يَظُّنُّونَ].',
  '﴿رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ﴾.',
  'ضَعْ يَدَكَ عَلَى الَّذِي تَألَّمَ مِنْ جَسَدِكَ وَقُلْ: بِسْمِ اللَّهِ، ثَلاَثاً، وَقُلْ سَبْعَ مَرَّاتٍ: أَعُوذُ بِاللَّهِ وَقُدْرَتِهِ مِنْ شَرِّ مَا أَجِدُ وَأُحَاذِرُ.',
  'كَانَ النَّبيُّ صلى الله عليه وسلم إِذَا أَتَاهُ أَمْرٌ يَسُرُّهُ أَوْ يُسَرُّ بِهِ خَرَّ سَاجِداً شُكْراً لِلَّهِ تَبَارَكَ وَتَعَالَى.',
  'إِذَا رَأَى أَحَدُكُم مِنْ أَخِيهِ، أَوْ مِنْ نَفْسِهِ، أَوْ مِنْ مَالِهِ مَا يُعْجِبُهُ [فَلْيَدْعُ لَهُ بِالْبَرَكَةِ] فَإِنَّ الْعَيْنَ حَقٌّ.',
  'لاَ إِلَهَ إِلاَّ اللَّهُ.',
  'قَالَ رَسُولُ اللَّهِ صلى الله عليه وسلم: وَاللَّهِ إِنِّي لأَسْتَغفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ فِي الْيَوْمِ أَكْثَرَ مِنْ سَبْعِينَ مَرَّةٍ.',
  'وَقَالَ صلى الله عليه وسلم: يَا أَيُّهَا النَّاسُ تُوبُوا إِلَى اللَّهِ فَإِنِّي أَتُوبُ فِي الْيَوْمِ إِلَيْهِ مِائَةَ مَرَّةٍ.',
  'وَقَالَ صلى الله عليه وسلم: مَنْ قَالَ أَسْتَغْفِرُ اللَّهَ الْعَظيمَ الَّذِي لاَ إِلَهَ إِلاَّ هُوَ الْحَيُّ القَيّوُمُ وَأَتُوبُ إِلَيهِ، غَفَرَ اللَّهُ لَهُ وَإِنْ كَانَ فَرَّ مِنَ الزَّحْفِ.',
  'وَقَالَ صلى الله عليه وسلم: أَقْرَبُ مَا يَكُونُ الرَّبُّ مِنَ الْعَبْدِ فِي جَوْفِ اللَّيْلِ الآخِرِ فَإِنِ اسْتَطَعْتَ أَنْ تَكُونَ مِمَّنْ يَذْكُرُ اللَّهَ فِي تِلْكَ السَّاعَةِ فَكُنْ.',
  'وَقَالَ صلى الله عليه وسلم: أَقْرَبُ مَا يَكُونُ الْعَبْدُ مِنْ رَبِّهِ وَهُوَ سَاجِدٌ فَأَكثِرُوا الدُّعَاءَ.',
  'وَقَالَ صلى الله عليه وسلم: إِنَّهُ لَيُغَانُ عَلَى قَلْبِي وَإِنِّي لأَسْتَغْفِرُ اللَّهَ فِي الْيَوْمِ مِائَةَ مَرَّةٍ.',
  'قَالَ صلى الله عليه وسلم مَنْ قَالَ: سُبْحَانَ اللَّهِ وَبِحَمْدِهِ فِي يَوْمٍ مِائَةَ مَرَّةٍ حُطَّتْ خَطَايَاهُ وَلَوْ كَانَتْ مِثْلَ زَبَدِ الْبَحْر.',
  'وَقَالَ صلى الله عليه وسلم: لَأَنْ أَقُولَ سُبْحَانَ اللَّهِ، وَالْحَمْدُ لِلَّهِ، وَلاَ إِلَهَ إِلاَّ اللَّهُ، وَاللَّهُ أَكْبَرُ، أَحَبُّ إِلَيَّ مِمَّا طَلَعَتْ عَلَيْهِ الشَّمسُ',
  'مَنْ قَالَ: سُبْحَانَ اللَّهِ الْعَظِيمِ وَبِحَمْدِهِ غُرِسَتْ لَهُ نَخْلَةٌ فِي الْجَنَّةِ.',
  'إِنَّ أَفْضَلَ الدُّعَاءِ الْحَمْدُ لِلَّهِ، وَأَفْضَلَ الذِّكْرِ لاَ إِلَهَ إِلاَّ اللَّهُ.',
  'الباقيات الصالحات : سبحان الله والحمد لله ، ولا إله إلا الله ،والله أكبر ،و لا حول ولا قوة إلا بالله.',
  'عَنْ عَبْدِ اللَّهِ بْنِ عَمْرٍو رضي الله عنه قَالَ: رَأَيْتُ النَّبيَّ صلى الله عليه وسلم يَعْقِدُ التَّسْبِيحَ وفي زيادةٍ: بِيَمِينِهِ.',
];

class MyApp extends StatefulWidget {
  const MyApp({
    Key? key,
    required this.theme,
  }) : super(key: key);
  final ThemeData theme;

  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();
}

class _MyAppState extends State<MyApp> {
  Set<int> usedIndices = {};

  Future<void> _saveRandomZikr() async {
    if (usedIndices.length == zikr.length) {
      usedIndices.clear();
    }

    int randomIndex;
    do {
      randomIndex = Random().nextInt(zikr.length);
    } while (usedIndices.contains(randomIndex));

    usedIndices.add(randomIndex);
    final randomZikr = zikr[randomIndex];

    try {
      await HomeWidget.saveWidgetData<String>('zikr', randomZikr);
    } on PlatformException catch (exception) {
      debugPrint('Error Saving Random Zikr. $exception');
    }
  }

  Future<void> saveHijriDate() async {
    ArabicNumbers arabicNumber = ArabicNumbers();
    // HijriCalendar.setLocal('en');
    var _today = HijriCalendar.now();
    String day = "${arabicNumber.convert(_today.hDay)}";
    String year = "${arabicNumber.convert(_today.hYear)}";
    await HomeWidget.saveWidgetData<String>('hijriDay', "$day");
    await HomeWidget.saveWidgetData<String>('hijriMonth', _today.hMonth.toString());
    await HomeWidget.saveWidgetData<String>('hijriYear', "$year");
  }

  @override
  void initState() {
    super.initState();
    if(Platform.isIOS || Platform.isAndroid) {
      // Initialize Workmanager
      final workManager = Workmanager();
      workManager.initialize(
        callbackDispatcher, // Your callbackDispatcher function
        isInDebugMode: false, // Set to false in production builds
      );
      HomeWidget.setAppGroupId('group.com.alheekmah.alquranalkareem.widget');
      saveHijriDate();
      Timer.periodic(const Duration(minutes: 1), (timer) async {
        await _saveRandomZikr();
        await _updateWidget();
      });
      HomeWidget.registerBackgroundCallback(backgroundCallback);
      // _startBackgroundUpdate();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // HomeWidget.widgetClicked.listen(_launchedFromWidget);
  }

  @override
  void dispose() async {
    super.dispose();
  }

  Future<void> _updateWidget() async {
    try {
      await HomeWidget.updateWidget(
          name: 'ZikerWidget', iOSName: 'ZikerWidget');
    } on PlatformException catch (exception) {
      debugPrint('Error Updating Widget. $exception');
    }
  }

  void _startBackgroundUpdate() {
    Workmanager().registerPeriodicTask('1', 'widgetBackgroundUpdate',
        frequency: const Duration(minutes: 1));
  }

  void _stopBackgroundUpdate() {
    Workmanager().cancelByUniqueName('1');
  }
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //     statusBarColor: Theme.of(context).primaryColorDark
    // ));
    // page.QuranCubit cubit = page.QuranCubit.get(context);

    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    return ThemeProvider(
      defaultThemeId: 'green',
      saveThemesOnChange: true,
      loadThemeOnInit: false,
      onInitCallback: (controller, previouslySavedThemeFuture) async {
        String? savedTheme = await previouslySavedThemeFuture;
        if (savedTheme != null) {
          controller.setTheme(savedTheme);
        } else {
          Brightness platformBrightness =
              SchedulerBinding.instance.window.platformBrightness ??
                  Brightness.light;
          if (platformBrightness == Brightness.dark) {
            controller.setTheme('dark');
          } else {
            controller.setTheme('green');
          }
          controller.forgetSavedTheme();
        }
      },
      themes: <AppTheme>[
        AppTheme(
          id: 'green',
          description: "My Custom Theme",
          data: ThemeData(
            colorScheme: const ColorScheme(
                brightness: Brightness.light,
                primary: Color(0xff232c13),
                onPrimary: Color(0xff161f07),
                secondary: Color(0xff39412a),
                onSecondary: Color(0xff39412a),
                error: Color(0xff91a57d),
                onError: Color(0xff91a57d),
                background: Color(0xfff3efdf),
                onBackground: Color(0xfff3efdf),
                surface: Color(0xff91a57d),
                onSurface: Color(0xff91a57d),),
            primaryColor: const Color(0xff232c13),
            primaryColorLight: const Color(0xff39412a),
            primaryColorDark: const Color(0xff161f07),
            dialogBackgroundColor: const Color(0xfff2f1da),
            dividerColor: const Color(0xffcdba72),
            highlightColor: const Color(0xff91a57d).withOpacity(0.3),
            indicatorColor: const Color(0xffcdba72),
            scaffoldBackgroundColor: const Color(0xff232c13),
            canvasColor: const Color(0xfff3efdf),
            hoverColor: const Color(0xfff2f1da).withOpacity(0.3),
            disabledColor: const Color(0Xffffffff),
            hintColor: const Color(0xff232c13),
            focusColor: const Color(0xff91a57d),
            secondaryHeaderColor: const Color(0xff39412a),
            cardColor: const Color(0xff232c13),
            textSelectionTheme: TextSelectionThemeData(
                selectionColor: const Color(0xff91a57d).withOpacity(0.3),
                selectionHandleColor: const Color(0xff91a57d)),
            cupertinoOverrideTheme: const CupertinoThemeData(
              primaryColor: Color(0xff606c38),
            ),
          ),
        ),
        AppTheme(
          id: 'blue',
          description: "My Custom Theme",
          data: ThemeData(
            colorScheme: const ColorScheme(
              brightness: Brightness.light,
              primary: Color(0xffbc6c25),
              onPrimary: Color(0xff814714),
              secondary: Color(0xfffcbb76),
              onSecondary: Color(0xfffcbb76),
              error: Color(0xff606c38),
              onError: Color(0xff606c38),
              background: Color(0xfffefae0),
              onBackground: Color(0xfffefae0),
              surface: Color(0xff606c38),
              onSurface: Color(0xff606c38),),
            primaryColor: const Color(0xffbc6c25),
            primaryColorLight: const Color(0xfffcbb76),
            primaryColorDark: const Color(0xff814714),
            dialogBackgroundColor: const Color(0xfffefae0),
            dividerColor: const Color(0xfffcbb76),
            highlightColor: const Color(0xfffcbb76).withOpacity(0.3),
            indicatorColor: const Color(0xfffcbb76),
            scaffoldBackgroundColor: const Color(0xff814714),
            canvasColor: const Color(0xffF2E5D5),
            hoverColor: const Color(0xffF2E5D5).withOpacity(0.3),
            disabledColor: const Color(0Xffffffff),
            hintColor: const Color(0xff814714),
            focusColor: const Color(0xffbc6c25),
            secondaryHeaderColor: const Color(0xffbc6c25),
            cardColor: const Color(0xff814714),
            textSelectionTheme: TextSelectionThemeData(
                selectionColor: const Color(0xff606c38).withOpacity(0.3),
                selectionHandleColor: const Color(0xff606c38)),
            cupertinoOverrideTheme: const CupertinoThemeData(
              primaryColor: Color(0xff606c38),
            ),
          ),
        ),
        AppTheme(
          id: 'dark',
          description: "My Custom Theme",
          data: ThemeData(
            colorScheme: const ColorScheme(
              brightness: Brightness.light,
              primary: Color(0xff3F3F3F),
              onPrimary: Color(0xff252526),
              secondary: Color(0xff4d4d4d),
              onSecondary: Color(0xff4d4d4d),
              error: Color(0xff91a57d),
              onError: Color(0xff91a57d),
              background: Color(0xff19191a),
              onBackground: Color(0xff3F3F3F),
              surface: Color(0xff91a57d),
              onSurface: Color(0xff91a57d),),
            primaryColor: const Color(0xff3F3F3F),
            primaryColorLight: const Color(0xff4d4d4d),
            primaryColorDark: const Color(0xff010101),
            dialogBackgroundColor: const Color(0xff3F3F3F),
            dividerColor: const Color(0xff91a57d),
            highlightColor: const Color(0xff91a57d).withOpacity(0.3),
            indicatorColor: const Color(0xff91a57d),
            scaffoldBackgroundColor: const Color(0xff252526),
            canvasColor: const Color(0xfff3efdf),
            hoverColor: const Color(0xfff2f1da).withOpacity(0.3),
            disabledColor: const Color(0Xffffffff),
            hintColor: const Color(0xff252526),
            focusColor: const Color(0xff91a57d),
            secondaryHeaderColor: const Color(0xff91a57d),
            cardColor: const Color(0xfff3efdf),
            textSelectionTheme: TextSelectionThemeData(
                selectionColor: const Color(0xff91a57d).withOpacity(0.3),
                selectionHandleColor: const Color(0xff91a57d)),
            cupertinoOverrideTheme: const CupertinoThemeData(
              primaryColor: Color(0xff606c38),
            ),
          ),
        ),
      ],
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: MultiBlocProvider(
          providers: [
            BlocProvider<QuranCubit>(
              create: (BuildContext context) => QuranCubit(),
            ),
            BlocProvider<AudioCubit>(
              create: (BuildContext context) => AudioCubit(),
            ),
            BlocProvider<NotesCubit>(
              create: (BuildContext context) => NotesCubit(),
            ),
            BlocProvider<BookmarksCubit>(
              create: (BuildContext context) => BookmarksCubit(),
            ),
            BlocProvider<QuranTextCubit>(
              create: (BuildContext context) => QuranTextCubit(),
            ),
            BlocProvider<TranslateDataCubit>(
              create: (BuildContext context) => TranslateDataCubit(),
            ),
            BlocProvider<QuarterCubit>(
              create: (BuildContext context) => QuarterCubit(QuarterRepository())..getAllQuarters(),
            ),
            BlocProvider<SurahTextCubit>(
              create: (BuildContext context) => SurahTextCubit()..loadQuranData(),
            ),
            BlocProvider<SorahRepositoryCubit>(
              create: (BuildContext context) => SorahRepositoryCubit()..loadSorahs(),
            ),
            BlocProvider<AyaCubit>(
              create: (BuildContext context) => AyaCubit()..getAllAyas(),
            ),
          ],
          child: SplashScreen(),
          // child: const HomePage(),
        ),

      ),
    );
  }
}
