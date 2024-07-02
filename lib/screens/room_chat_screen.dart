import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:device_info/device_info.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sbo/models/room_message_model.dart';
import 'package:sbo/utils/assets.dart';
import 'package:sbo/utils/custom_color.dart';
import 'package:sbo/utils/custom_style.dart';
import 'package:sbo/utils/send_notification.dart';
import 'package:sbo/utils/size.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sbo/apis/api_manager.dart';
import 'package:sbo/models/result_model.dart';
import 'package:sbo/utils/connection_utils.dart';
import 'package:sbo/utils/prefs.dart';
import 'package:sbo/utils/ui_utils.dart';
import 'dart:io' as Io;


class ChatScreenRoom extends StatefulWidget {
  final String roomId;

  ChatScreenRoom({Key? key, required this.roomId}) : super(key: key);

  @override
  _ChatScreenRoomState createState() => _ChatScreenRoomState();
}

class _ChatScreenRoomState extends State<ChatScreenRoom> {
  TextEditingController _messageController = TextEditingController();
  List<Message> _messages = <Message>[];
  bool _isLoading = false;
  String? userId;
  String? attachmentUrl,imageUrl;

  @override
  void initState() {
    super.initState();
    _initializeUserId();
  }

  Future<void> _initializeUserId() async {
    SharedPreferences mPref = await SharedPreferences.getInstance();
    String? id = mPref.getString(Prefs.ID);

    setState(() {
      userId = id;
    });
    print("Initialized user ID: $userId");
    _fetchMessages(true);
  }

  void _fetchMessages(bool _loading) {
    ConnectionUtils.checkConnection().then((internet) async {
      if (internet) {
        setState(() {
          _isLoading = _loading;
        });
        try {
          final RoomMessageModel resultModel = await ApiManager.fetchMessageRoom(widget.roomId);

          if (!resultModel.error) {
            setState(() {
              _messages = resultModel.messages;
              _isLoading = false;
            });
          } else {
            setState(() {
              _isLoading = false;
            });
            UIUtils.bottomToast(context: context, text: resultModel.message, isError: true);
          }
        } catch (e) {
          setState(() {
            _isLoading = false;
          });
          UIUtils.bottomToast(context: context, text: e.toString(), isError: true);
        }
      } else {
        UIUtils.bottomToast(
          context: context,
          text: "Please check your internet connection",
          isError: true,
        );
      }
    });
  }

  void _sendMessage(String content,String type) {
    ConnectionUtils.checkConnection().then((internet) async {
      if (internet) {
        setState(() {
          _isLoading = false;
        });
        try {
          final ResultModel resultModel = await ApiManager.sendMessageRoom(
            userId!,
            content,
            type,
            widget.roomId,
          );

          if (!resultModel.error) {
            setState(() {
              _isLoading = false;
              if(type == "text"){
                _messageController.text = "";
              } else {
                attachmentUrl = "";
                imageUrl = "";
              }
              _fetchMessages(false);
              SendNotification.getGroupToken("New Message", "You have a New Group Message", widget.roomId, "Group");
            });
          } else {
            setState(() {
              _isLoading = false;
            });
            UIUtils.bottomToast(context: context, text: resultModel.message, isError: true);
          }
        } catch (e) {
          setState(() {
            _isLoading = false;
          });
          UIUtils.bottomToast(context: context, text: e.toString(), isError: true);
        }
      } else {
        UIUtils.bottomToast(
          context: context,
          text: "Please check your internet connection",
          isError: true,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Group "+ widget.roomId,
          style: CustomStyle.inputTextStyle.copyWith(fontWeight: FontWeight.w700,fontSize: 15.0),
        ),
        actions: [
          GestureDetector(
            onTap: (){
              addSchoolPopup();
            },
              child: SvgPicture.asset(Assets.editUserIcon)
          ),
          SizedBox(width: 20,)
        ],
      ),
      body: _isLoading ? Center(child: CircularProgressIndicator()) : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              reverse: true,
              itemBuilder: (context, index) {
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  String validateBase64String(String base64String) {
    // Remove any non-printable or non-ASCII characters
    String cleanedBase64 = base64String.replaceAll(RegExp(r'[^A-Za-z0-9+/=]'), '');

    // Add padding if necessary
    while (cleanedBase64.length % 4 != 0) {
      cleanedBase64 += '=';
    }
    return cleanedBase64;
  }

  addSchoolPopup() async {
    final _formKey = GlobalKey<FormState>();
    String? _radioValue;
    TextEditingController _bnameController = TextEditingController();

    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => StatefulBuilder(
            builder: (context, setAlert) {
              return AlertDialog(
                backgroundColor: Colors.white,
                content: Container(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Center(
                                child: Text(
                                  "Group Name",
                                  style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 16.0,fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: (){
                                Navigator.of(context).pop();
                              },
                              child: Icon(Icons.close_rounded,color: CustomColor.primaryColor,),
                            )
                          ],
                        ),

                        SizedBox(height: 20.0,),
                        TextFormField(
                          controller: _bnameController,
                          keyboardType: TextInputType.text,
                          cursorColor: CustomColor.primaryColor,
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: 'Group Name',
                            labelStyle: CustomStyle.inputTextStyle.copyWith(fontSize: 16.0,fontWeight: FontWeight.w700,color: CustomColor.blackColor),
                            border: UIUtils.textinputborder,
                            contentPadding: UIUtils.textinputPadding,
                            errorBorder: UIUtils.errorBorder,
                            enabledBorder: UIUtils.textinputborder,
                            focusedBorder: UIUtils.focusedBorder,
                            filled: false,
                            counterText: '',
                            hintText: "Enter Group Name",
                            hintStyle: CustomStyle.hintTextStyle.copyWith(fontSize: 12.0,fontWeight: FontWeight.w500),
                            // fillColor: CustomColor.editTextColor,
                          ),
                          style: CustomStyle.inputTextStyle,
                          textAlign: TextAlign.start,
                          autovalidateMode: AutovalidateMode.disabled,
                          validator: (value){
                            if(value!.isEmpty || value.length < 3){
                              return 'Enter valid Group name';
                            }

                            return null;
                          },
                        ),
                        SizedBox(height: 30,),
                        GestureDetector(
                          onTap: (){
                            if(_bnameController.text.isEmpty){
                              UIUtils.bottomToast(context: context, text: "Please Enter Group Name", isError: true);
                            }else{
                              Navigator.of(context).pop();
                              UpdateType(_bnameController.text.trim());
                            }

                          },
                          child: Container(
                            height: 55.0,
                            decoration: BoxDecoration(
                              color: CustomColor.primaryColor,
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Center(
                              child: Text(
                                "Update",
                                style: CustomStyle.inputTextStyle.copyWith(fontWeight: FontWeight.w800,fontSize: 14.0,color: CustomColor.whiteColor),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
        )
    );
  }


  void UpdateType(String name) {

    ConnectionUtils.checkConnection().then((intenet) async {
      if (intenet) {
        setState(() {
          _isLoading = true;
        });
        try{


          final ResultModel resultModel = await ApiManager.UpdateGroupName(
            userId!,
            widget.roomId,
            name,
          );

          if(resultModel.error == false) {
            setState(() {
              _isLoading = false;
            });
            Navigator.of(context).pop();
          } else{
            setState(() {
              _isLoading = false;
            });
            UIUtils.bottomToast(context: context, text: resultModel.message, isError: true);
          }
        }
        on Exception catch(_,e){
          setState(() {
            _isLoading = false;
          });
          UIUtils.bottomToast(context: context, text: e.toString(), isError: true);
        }
      }
      else {
        // No-Internet Case
        UIUtils.bottomToast(context: context, text: "Please check your internet connection", isError: true);
      }
    });
  }

  Widget _buildMessage(Message message) {
    bool isSender = message.senderId == userId;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      child: Align(
        alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
        child: message.type == "text" ? Container(
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
          decoration: BoxDecoration(
            color: isSender ? CustomColor.primaryColor : Colors.grey[200],
            borderRadius: isSender
                ? BorderRadius.only(
              topLeft: Radius.circular(10.0),
              bottomLeft: Radius.circular(10.0),
              bottomRight: Radius.circular(10.0),
            )
                : BorderRadius.only(
              topRight: Radius.circular(10.0),
              bottomLeft: Radius.circular(10.0),
              bottomRight: Radius.circular(10.0),
            ),
          ),
          child: Text(
            message.content,
            style: TextStyle(color: isSender ? Colors.white : Colors.black),
          ),
        ) : message.type == "Image" ? Container(
          height: 150,
          width: 150,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                  fit: BoxFit.cover,
                  image: Image.memory(base64Decode(message.content),height: 150,width: 150,fit: BoxFit.cover,).image)
          ),
        ) : Container(
          padding: EdgeInsets.only(left: 10.0,right: 10.0,top: 5.0,bottom: 5.0),
          width: MediaQuery.of(context).size.width/1.5,
          decoration: BoxDecoration(
            color: CustomColor.downloadprimaryColor,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  getDocumentName(message),
                  style: CustomStyle.inputTextStyle.copyWith(color: CustomColor.blackColor,fontSize: 14,fontWeight: FontWeight.w500),
                ),
              ),
              addHorizontalSpace(10.0),
              IconButton(
                  onPressed: (){
                    String extenstion = ".pdf";
                    if(message.type == "PDF"){
                      setState(() {
                        extenstion = ".pdf";
                      });
                    } else if(message.type == "Document"){
                      setState(() {
                        extenstion = ".docx";
                      });
                    } else {
                      setState(() {
                        extenstion = ".pdf";
                      });
                    }
                    checkStoragePermission(message.content, DateTime.now().millisecondsSinceEpoch.toString()+extenstion);
                  },
                  icon: const Icon(Icons.file_download_rounded,color: CustomColor.primaryColor,)
              ),
            ],
          ),
        ),
      ),
    );
  }

  getDocumentName(Message message){
    String fileName = "";

    if (message.type != "Image" && message.type != "text") {
      try {
        // Print the base64 content for debugging
        print("Base64 Content: ${message.content}");
        print("Base64 Length: ${message.content.length}");

        // Validate the base64 string
        String validatedBase64 = validateBase64String(message.content);

        // Print the validated base64 content
        print("Validated Base64 Content: $validatedBase64");
        print("Validated Base64 Length: ${validatedBase64.length}");

        // Decode the base64 content
        Uint8List decodedData = base64Decode(validatedBase64);
        String decodedString = utf8.decode(decodedData);

        // Debugging: Print the decoded string to inspect its format
        print("Decoded String: $decodedString");

        // Extract the file name using a regular expression
        RegExp fileNameRegExp = RegExp(r'filename="(.+?)"');
        setState(() {
          fileName = fileNameRegExp.firstMatch(decodedString)?.group(1) ?? 'unknown';
        });

        // Debugging: Print the extracted file name
        print("Extracted File Name: $fileName");
      } catch (e) {
        print('Error decoding base64 data: $e');
      }
    }

    return fileName;
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          GestureDetector(
              onTap: (){
                checkPermission();
              },
              child: SvgPicture.asset(Assets.attachmentIcon)),
          addHorizontalSpace(5.0),
          GestureDetector(
              onTap: (){
                pickCameraImage();
              },
              child: SvgPicture.asset(Assets.cameraIcon)),
          addHorizontalSpace(10.0),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Write your message",
                hintStyle: CustomStyle.inputTextStyle.copyWith(color: Colors.grey,fontSize: 14,fontWeight: FontWeight.w500),
                fillColor: CustomColor.chatboxColor,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide(color: Colors.transparent)
                ),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide(color: Colors.transparent)
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 15.0),
              ),
            ),
          ),
          addHorizontalSpace(10),
          ElevatedButton(
            onPressed: () {
              if(_messageController.text.trim().isNotEmpty) {
                _sendMessage(_messageController.text.trim(),"text");
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.all(15),
              backgroundColor: CustomColor.primaryColor,
            ),
            child: SvgPicture.asset(Assets.sendIcon),
          ),
          // IconButton(
          //   icon: Icon(Icons.send),
          //   onPressed: _sendMessage,
          // ),
        ],
      ),
    );
  }

  checkPermission() async{
    if (Io.Platform.isAndroid) {
      DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      final androidInfo = await deviceInfoPlugin.androidInfo;
      debugPrint('MY_SDK : ${androidInfo.version.sdkInt}');
      if (androidInfo.version.sdkInt >= 33) {
        final status = await Permission.photos.request();
        // final status2 = await Permission.camera.request();
        if (status == PermissionStatus.granted) {
          print('Permission granted.');
          openProfileImage();
        } else if (status == PermissionStatus.denied) {
          print(
              'Permission denied. Show a dialog and again ask for the permission');
          await Permission.storage.shouldShowRequestRationale;
        }
      }
      else{
        final status = await Permission.storage.request();
        // final status2 = await Permission.camera.request();
        if (status == PermissionStatus.granted) {
          print('Permission granted.');
          openProfileImage();
        } else if (status == PermissionStatus.denied) {
          print(
              'Permission denied. Show a dialog and again ask for the permission');
          await Permission.storage.shouldShowRequestRationale;
        }
      }
    }
  }

  checkStoragePermission(String file,String fileName) async{
    if (Io.Platform.isAndroid) {
      DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      final androidInfo = await deviceInfoPlugin.androidInfo;
      debugPrint('MY_SDK : ${androidInfo.version.sdkInt}');
      if (androidInfo.version.sdkInt >= 33) {
        final status = await Permission.storage.request();
        // final status2 = await Permission.camera.request();
        if (status == PermissionStatus.granted) {
          print('Permission granted.');
          decodeAndSaveFile(file,fileName);
        } else if (status == PermissionStatus.denied) {
          print(
              'Permission denied. Show a dialog and again ask for the permission');
          await Permission.storage.shouldShowRequestRationale;
        }
      }
      else{
        final status = await Permission.storage.request();
        // final status2 = await Permission.camera.request();
        if (status == PermissionStatus.granted) {
          print('Permission granted.');
          decodeAndSaveFile(file,fileName);
        } else if (status == PermissionStatus.denied) {
          print(
              'Permission denied. Show a dialog and again ask for the permission');
          await Permission.storage.shouldShowRequestRationale;
        }
      }
    }
  }

  Future<void> decodeAndSaveFile(String base64String, String fileName) async {
    try {
      Uint8List decodedBytes = base64Decode(base64String);

      // Request storage permission
      if (await Permission.storage.request().isGranted) {
        // Get the application documents directory
        Directory? downloadsDir = await getExternalStorageDirectory();
        String downloadsPath = downloadsDir!.path;

        // Save the file in the downloads directory
        File file = File('$downloadsPath/$fileName');

        // Write the bytes to the file
        await file.writeAsBytes(decodedBytes);

        // Notify the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File saved to $downloadsPath/$fileName')),
        );
      } else {
        // Handle permission denial
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Storage permission denied')),
        );
      }
    } catch (e) {
      print('Error decoding and saving file: $e');
    }
  }

  openProfileImage() async {
    setState(() {
      attachmentUrl = "";
    });

    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
        allowMultiple: false
    );
    String _fileType = '';
    if (result != null) {
      setState(() {
        String fileName = result.files.first.name;
        print("fileName ${fileName}");

        String? filePath = result.files.first.path;
        final bytes = Io.File(filePath!).readAsBytesSync();

        String extension = result.files.first.extension ?? '';
        setState(() {
          _fileType = _getFileType(extension);
        });

        attachmentUrl = base64Encode(bytes);
      });

      _sendMessage(attachmentUrl!, _fileType);
    } else {

    }
    setState(() {});
  }

  pickCameraImage() async {
    setState(() {
      imageUrl = "";
    });

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera,imageQuality: 100);
    if (pickedFile != null) {
      setState(() {
        final bytes = Io.File(pickedFile.path).readAsBytesSync();
        imageUrl = base64Encode(bytes);

        final file = Io.File(pickedFile.path);
        final fileSize = file.lengthSync(); // File size in bytes

        print("File size: $fileSize bytes");
      });

      _sendMessage(imageUrl!, "Image");
    } else {

    }

    setState(() {});
  }


  String _getFileType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
      case 'png':
        return 'Image';
      case 'pdf':
        return 'PDF';
      case 'doc':
      case 'docx':
        return 'Document';
      default:
        return 'Unknown';
    }
  }
}
