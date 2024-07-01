
import 'package:alarm/data/models/alarm_info.dart';
import 'package:alarm/helper/alarm_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';


final formatter = DateFormat.yMd();

class AddAlarm extends StatefulWidget {
  const AddAlarm({super.key});

  @override
  State<AddAlarm> createState() => _AddAlarmState();
}
  class _AddAlarmState extends State<AddAlarm> {
    TextEditingController hourController = TextEditingController(text: '06');
    TextEditingController minuteController = TextEditingController(text: '00');
    TextEditingController titleAlarm = TextEditingController();
    FocusNode focusNode1 = FocusNode();
    FocusNode focusNode2 = FocusNode();
    bool isFocused1 = false;
    bool isFocused2 = false;


    DateTime? alarmDateTime;
    DateTime? alarmDay;
    String? _alarmTimeString;
    Future<List<AlarmInfo>>? _alarms;


    DateTime? _selectedDate;
    int hour = 0;
    int minutes = 0;
    bool _isSoundEnabled = false;
    bool _isVibrationEnabled = false;
    bool _isSnoozeEnabled = false;

    AlarmHelper _alarmHelper = AlarmHelper();

    final formatter = DateFormat('EEE, d MMM yyyy', 'vi_VN');
    String _formatSelectedDate(DateTime selectedDate) {
      final now = DateTime.now();
      final formattedDate = formatter.format(selectedDate);

      if (selectedDate.year == now.year) {
        return formattedDate.replaceFirst('${now.year}', '');
      } else {
        return formattedDate;
      }
    }


    // Phương thức để thêm báo thức
    void _addAlarm() async {
      List<AlarmInfo> currentAlarms = await _alarmHelper.getAlarm();
      final int hour = int.tryParse(hourController.text) ?? 0;
      final int minute = int.tryParse(minuteController.text) ?? 0;
      String title = titleAlarm.text.isNotEmpty ? titleAlarm.text : "Alarm";

      if (_selectedDate != null) {
        // Kiểm tra nếu giờ và phút đã chọn là hợp lệ
        if (hour < 0 || hour >= 24 || minute < 0 || minute >= 60) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Giờ và phút không hợp lệ!'),
            ),
          );
          return;
        }

        // Lấy ngày và giờ đã chọn từ _selectedDate
        DateTime alarmDateTime = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          hour,
          minute,
        );

        // Kiểm tra ngày giờ đã chọn có lớn hơn ngày giờ hiện tại không
        if (alarmDateTime.isBefore(DateTime.now())) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Không thể chọn ngày trong quá khứ!'),
            ),
          );
          return;
        }

        // Thêm báo thức vào cơ sở dữ liệu
        var alarmInfo = AlarmInfo(
          alarmDateTime: alarmDateTime,
          gradientColorIndex: currentAlarms!.length,
          title: title,
          isPending: true,
        );
        _alarmHelper.insertAlarm(alarmInfo);
        setState(() {
          _alarms = _alarmHelper.getAlarm();
        });
        Navigator.pop(context, true);
      } else {
        // Xử lý trường hợp người dùng chưa chọn ngày
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Chưa chọn ngày'),
            content: Text('Vui lòng chọn ngày trước khi thêm báo thức.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Đóng dialog
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    }





    void moveToNextField(TextEditingController currentController, TextEditingController nextController) {
    if (currentController.text.length == 2) {
      if (currentController == hourController) {
        FocusScope.of(context).requestFocus(focusNode2);
      }
    }
  }
  @override
  void dispose() {
    // Clean up the focus nodes when the widget is disposed
    hourController.dispose();
    minuteController.dispose();
    focusNode1.dispose();
    focusNode2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      child: Scaffold(
        body: Column(
          children: [
            // Phần trên chiếm 1/3 màn hình
            Container(
              height: MediaQuery.of(context).size.height * 0.45, // Chiếm 1/3 chiều cao màn hình
              color: Colors.grey[200], // Màu nền xám
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center, // Thêm dòng này để căn giữa hàng ngang
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center, // Căn giữa các phần tử trong hàng ngan
                    children: [
                      SizedBox(
                        width: 90,
                        child: TextField(
                          controller: hourController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(2),
                            HourInputFormatter(),
                          ],
                          decoration: InputDecoration(
                            hintText: 'HH',
                            border: InputBorder.none,
                            filled: true,
                            fillColor: Colors.grey[200],
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: isFocused2 ? Colors.transparent : Colors.grey[200]!,
                                width: 2.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: isFocused2 ? Colors.transparent : Colors.grey[200]!,
                                width: 2.0,
                              ),
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 55,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                          onTap: () {
                            // Khi tap vào TextField 1
                            focusNode1.requestFocus();
                            setState(() {
                              FocusScope.of(context).unfocus();
                            });
                            if (hourController.text.isNotEmpty) {
                              hourController.selection = TextSelection(
                                baseOffset: 0,
                                extentOffset: hourController.text.length,
                              );
                            }
                          },
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              moveToNextField(hourController, minuteController);
                            }
                          },
                        ),
                      ),
                      SizedBox(width: 30,),
                      Text(
                        ':',
                        style: TextStyle(
                          fontSize: 55,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 30,),
                      SizedBox(
                        width: 70,
                        child: TextField(
                          controller: minuteController,
                          focusNode: focusNode2,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(2),
                          ],
                          decoration: InputDecoration(
                            hintText: 'MM',
                            border: InputBorder.none,
                          ),
                          style: TextStyle(
                            fontSize:55,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16,horizontal: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedDate == null
                              ? 'No date selected'
                              : _formatSelectedDate(_selectedDate!),
                          style: TextStyle(fontSize: 16), // Chỉnh font size cho Text
                        ),
                        IconButton(
                          onPressed: _presentDatePicker,
                          icon: const Icon(Icons.calendar_month),
                        ),
                      ],
                    ),
                  ),
                  Container(
                   padding: EdgeInsets.symmetric(vertical: 10,horizontal: 18),
                    child: TextField(
                      controller: titleAlarm,
                      decoration: InputDecoration(
                        hintText: 'Tên chuông báo',
                      ),
                      style: TextStyle(
                        fontSize:14,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  // ListTile for Âm thanh chuông báo
                  InkWell(
                    onTap: _navigateToNewScreen,
                    child: Container(
                      color: Colors.transparent, // This will ensure the ripple effect is visible
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 18.0),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Âm thanh chuông báo',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      Text(
                                        'Homecoming',
                                        style: const TextStyle(
                                            fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: _isSoundEnabled,
                                  onChanged: (bool value) {
                                    setState(() {
                                      _isSoundEnabled = value; // Cập nhật trạng thái
                                    });
                                  },
                                  activeTrackColor: Colors.purple,
                                  activeColor: Colors.white,
                                  inactiveTrackColor: Colors.blueGrey,
                                  inactiveThumbColor: Colors.white,
                                ),
                              ],
                            ),
                          ),
                          Divider(height: 1,indent: 17.0,endIndent: 17.0,), // Divider between ListTiles
                        ],
                      ),
                    ),
                  ),
                  // ListTile for Rung
                  InkWell(
                    onTap: _navigateToNewScreen,
                    child: Container(
                      color: Colors.transparent,
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 18.0),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Rung',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      Text(
                                        'Basic call',
                                        style: const TextStyle(
                                            fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: _isVibrationEnabled,
                                  onChanged: (bool value) {
                                    setState(() {
                                      _isVibrationEnabled = value; // Cập nhật trạng thái
                                    });
                                  },
                                  activeTrackColor: Colors.purple,
                                  activeColor: Colors.white,
                                  inactiveTrackColor: Colors.blueGrey,
                                  inactiveThumbColor: Colors.white,
                                ),
                              ],
                            ),
                          ),
                          Divider(height: 1,indent: 17.0,endIndent: 17.0,), // Divider between ListTiles// Divider between ListTiles
                        ],
                      ),
                    ),
                  ),
                  // ListTile for Tạm dừng
                  InkWell(
                    onTap: _navigateToNewScreen,
                    child: Container(
                      color: Colors.transparent,
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 18.0),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Tạm dừng',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      Text(
                                        '5 phút, 3 lần',
                                        style: const TextStyle(
                                            fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: _isSnoozeEnabled,
                                  onChanged: (bool value) {
                                    setState(() {
                                      _isSnoozeEnabled = value; // Cập nhật trạng thái
                                    });
                                  },
                                  activeTrackColor: Colors.purple,
                                  activeColor: Colors.white,
                                  inactiveTrackColor: Colors.blueGrey,
                                  inactiveThumbColor: Colors.white,
                                ),
                              ],
                            ),
                          ),
                          Divider(height: 1,indent: 17.0,endIndent: 17.0,), // Divider between ListTiles
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.grey[100],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Thoát',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 35, vertical: 20),
                      minimumSize: Size(130, 50),
                      backgroundColor: Colors.grey[100],
                      side: BorderSide.none
                    ),
                  ),
                  TextButton(
                    onPressed: (){
                      _addAlarm();
                    },
                    child: Text(
                      'Lưu',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 35, vertical: 20),
                      minimumSize: Size(130, 50),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _presentDatePicker() async {
    var pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(9999, 12, 31),
      locale: const Locale('vi', 'VN'),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }
  void _navigateToNewScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NewScreen()),
    );
  }
}
class NewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Screen'),
      ),
      body: Center(
        child: Text(
          'Welcome to the new screen!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
class HourInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final int selectionIndexFromTheRight =
        newValue.text.length - newValue.selection.end;
    final StringBuffer newText = StringBuffer();
    newText.write(newValue.text);

    // Nếu nhập vào 1 chữ số và giá trị là từ 3 đến 9, tự động thêm số 0
    if (newText.length == 1) {
      if (int.tryParse(newText.toString()) != null) {
        if (int.parse(newText.toString()) > 2) {
          return TextEditingValue(
            text: '0${newText.toString()}',
            selection: TextSelection.collapsed(offset: 2),
          );
        }
      }
    }

    // Nếu nhập vào 2 chữ số, kiểm tra giới hạn từ 00 đến 23
    if (newText.length == 2) {
      if (int.tryParse(newText.toString()) != null) {
        if (int.parse(newText.toString()) > 23) {
          return oldValue; // Không thay đổi giá trị
        }
      }
    }

    return newValue.copyWith(
      text: newText.toString(),
      selection: TextSelection.collapsed(
          offset: newText.length - selectionIndexFromTheRight),
    );
  }
}

