import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:eperimetry_vtwo/screens/admin/admin_screen.dart';
import 'package:eperimetry_vtwo/screens/admin/new_official_screen.dart';
import 'package:eperimetry_vtwo/screens/welcome_screen.dart';
import 'package:eperimetry_vtwo/utils/constants.dart';
import 'package:eperimetry_vtwo/utils/loading_screen.dart';
import 'package:eperimetry_vtwo/utils/toast_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewOfficialsScreen extends StatefulWidget {
  const ViewOfficialsScreen({super.key});

  @override
  State<ViewOfficialsScreen> createState() => _ViewOfficialsScreenState();
}

class _ViewOfficialsScreenState extends State<ViewOfficialsScreen> {
  List<Map<String, dynamic>> familyMembers = [];
  bool isLoading = true;

  String? managerId;

  @override
  void initState() {
    setState(() {
      isLoading = true;
    });
    SharedPreferences.getInstance().then((sp) {
      final secretToken = sp.getString("SECRET_TOKEN");
      setState(() {
        managerId = jsonDecode(sp.getString("currentUser")!)["managerId"];
      });

      if (secretToken == null) {
        showToast("Session Expired! Please login again.");
        Navigator.of(context).pushAndRemoveUntil(
            CupertinoPageRoute(builder: (context) {
          return const WelcomeScreen();
        }), (route) => false);
      }

      Dio()
          .get(
        Constants().allOfficialsUrl,
        options: Options(
          headers: {"Authorization": "Bearer $secretToken"},
          validateStatus: (status) => status! < 500,
        ),
      )
          .then((response) {
        if (response.statusCode == 200) {
          if (response.data["users"].length > 0) {
            for (final familyMember in response.data["users"]) {
              setState(() {
                familyMembers.add({
                  "managerId": familyMember["managerId"],
                  "phoneNumber": familyMember["phoneNumber"],
                  "managerName": familyMember["managerName"],
                  "userEmail": familyMember["userEmail"],
                  "officeName": familyMember["officeName"],
                  "role": familyMember["roleId"],
                  "status": familyMember["status"],
                });
              });
            }
          } else {
            showToast("No registered officials added by you!");
          }

          setState(() {
            isLoading = false;
          });
        } else if (response.statusCode == 401) {
          showToast("Session Expired! Please login again.");
          Navigator.of(context).pushAndRemoveUntil(
              CupertinoPageRoute(builder: (context) {
            return const WelcomeScreen();
          }), (route) => false);
        } else if (response.data["message"] != null) {
          showToast(response.data["message"]);
        } else {
          showToast("Something went wrong!");
          Navigator.of(context).pushAndRemoveUntil(
              CupertinoPageRoute(builder: (context) {
            return const AdminScreen();
          }), (route) => false);
        }
      }).catchError((error) {
        showToast("Something went wrong!");
        Navigator.of(context).pushAndRemoveUntil(
            CupertinoPageRoute(builder: (context) {
          return const AdminScreen();
        }), (route) => false);
        if (kDebugMode) {
          print(error);
        }
      });
    });

    super.initState();
  }

  Future<String> _toggleStatus(int index) async {
    final dio = Dio();

    try {
      final sp = await SharedPreferences.getInstance();
      final secretToken = sp.getString("SECRET_TOKEN");

      if (secretToken == null) {
        showToast("Session Expired! Please login again.");
        return "-1";
      }

      final response = await dio.post(
        Constants().toggleOfficialStatusUrl,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $secretToken"
          },
          validateStatus: (status) {
            return status! < 500;
          },
        ),
        data: {
          "affectedManagerId": familyMembers[index]["managerId"].toString(),
          "newStatus": familyMembers[index]["status"] == "ACTIVE" ||
                  familyMembers[index]["status"] == "WAITLIST"
              ? "INACTIVE"
              : "WAITLIST",
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          familyMembers[index]["status"] =
              familyMembers[index]["status"] == "ACTIVE" ||
                      familyMembers[index]["status"] == "WAITLIST"
                  ? "INACTIVE"
                  : "WAITLIST";
        });

        showToast("Official status updated!");
        return "1";
      } else if (response.data["message"] != null) {
        showToast(response.data["message"]);
      } else if (response.statusCode == 401) {
        showToast("Session Expired! Please login again.");
        return "-1";
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      showToast("Something went wrong. Please try again later.");
      return "0";
    }

    return "0";
  }

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _managerIdController = TextEditingController();
  final TextEditingController _managerNameController = TextEditingController();
  final TextEditingController _managerEmailController = TextEditingController();
  final TextEditingController _managerPhoneController = TextEditingController();
  String? role;

  String? _mobileNumberValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter a mobile number";
    }
    if (value.length != 10) {
      return "Mobile number must be 10 digits";
    }
    return null;
  }

  String? _fieldValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "This field is required";
    }
    return null;
  }

  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your email address";
    } else if (!RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$").hasMatch(value)) {
      return "Please enter a valid email address";
    }
    return null;
  }

  Future<String> _editMember() async {
    final dio = Dio();

    try {
      final sp = await SharedPreferences.getInstance();
      final secretToken = sp.getString("SECRET_TOKEN");

      if (secretToken == null) {
        showToast("Session Expired! Please login again.");
        return "-1";
      }

      final response = await dio.post(
        Constants().editManagerDetailsUrl,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $secretToken"
          },
          validateStatus: (status) {
            return status! < 500;
          },
        ),
        data: {
          "newManagerId": _managerIdController.text.trim().toString(),
          "managerPhoneNumber": _managerPhoneController.text.trim().toString(),
          "managerName": _managerNameController.text.trim().toString(),
          "userEmail": _managerEmailController.text.trim().toString(),
          "newRole": role,
        },
      );

      if (response.statusCode == 200) {
        showToast("Official details edited successfully!");
        return "1";
      } else if (response.data["message"] != null) {
        showToast(response.data["message"]);
      } else if (response.statusCode == 401) {
        showToast("Session Expired! Please login again.");
        return "-1";
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      showToast("Something went wrong. Please try again later.");
      return "0";
    }

    return "0";
  }

  @override
  void dispose() {
    familyMembers.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return (isLoading == true || familyMembers.isEmpty)
        ? const LoadingScreen()
        : Scaffold(
            extendBodyBehindAppBar: true,
            body: CustomScrollView(
              slivers: [
                SliverAppBar.large(
                  floating: false,
                  pinned: true,
                  snap: false,
                  centerTitle: true,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  leading: IconButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                          CupertinoPageRoute(builder: (context) {
                        return const AdminScreen();
                      }), (route) => false);
                    },
                    icon: const Icon(Icons.arrow_back_ios),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    titlePadding: const EdgeInsets.symmetric(
                        horizontal: 0.0, vertical: 8.0),
                    collapseMode: CollapseMode.parallax,
                    background: Image.asset(
                      "assets/login.png",
                      color: Theme.of(context)
                          .colorScheme
                          .tertiary
                          .withOpacity(0.2),
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                    ),
                    title: Text(
                      "Registered Officials",
                      style: GoogleFonts.raleway(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        if (familyMembers.isEmpty) ...[
                          const SizedBox(
                            height: 24,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.95,
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.1),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.error,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Text(
                                    "No registered officials added by you!",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.raleway(
                                      fontWeight: FontWeight.w500,
                                      color:
                                          Theme.of(context).colorScheme.onError,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                const Divider(),
                                const SizedBox(
                                  height: 16,
                                ),
                                Text(
                                  "You can add registered Officials by clicking the button below.",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.raleway(
                                    textStyle:
                                        Theme.of(context).textTheme.titleSmall,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                MaterialButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                        CupertinoPageRoute(builder: (context) {
                                      return const NewOfficialScreen();
                                    }));
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  minWidth:
                                      MediaQuery.of(context).size.width * 0.8,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24.0, vertical: 10.0),
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  child: Text(
                                    "New Official",
                                    style: GoogleFonts.raleway(
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        // build a list view with patient id as avatar and patient name as title
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: familyMembers.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: ExpansionTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                collapsedShape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                collapsedBackgroundColor: Theme.of(context)
                                    .colorScheme
                                    .onSecondary
                                    .withOpacity(0.2),
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .onSecondary
                                    .withOpacity(0.3),
                                tilePadding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 16.0),
                                title: Text(
                                  familyMembers[index]["managerName"],
                                  style: GoogleFonts.raleway(
                                    fontWeight: FontWeight.w500,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                                subtitle: Row(
                                  children: [
                                    Chip(
                                      padding: const EdgeInsets.all(2.0),
                                      label: Text(
                                        familyMembers[index]["status"] ==
                                                "WAITLIST"
                                            ? "Waitlist"
                                            : familyMembers[index]["status"] ==
                                                    "ACTIVE"
                                                ? "Active"
                                                : "Inactive",
                                        style: GoogleFonts.raleway(
                                          fontWeight: FontWeight.w500,
                                          color: familyMembers[index]
                                                          ["status"] ==
                                                      "WAITLIST" ||
                                                  familyMembers[index]
                                                          ["status"] ==
                                                      "INACTIVE"
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .onError
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .onSecondary,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                      backgroundColor: familyMembers[index]
                                                      ["status"] ==
                                                  "WAITLIST" ||
                                              familyMembers[index]["status"] ==
                                                  "INACTIVE"
                                          ? Theme.of(context).colorScheme.error
                                          : Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                    ),
                                    const SizedBox(
                                      width: 4,
                                    ),
                                    Chip(
                                      padding: const EdgeInsets.all(2.0),
                                      label: Text(
                                        familyMembers[index]["role"] == "ADMIN"
                                            ? "Administrator"
                                            : familyMembers[index]["role"] ==
                                                    "HSHEAD"
                                                ? "Hospital Head"
                                                : familyMembers[index]
                                                            ["role"] ==
                                                        "FLWRKR"
                                                    ? "Frontline Worker"
                                                    : familyMembers[index]
                                                                ["role"] ==
                                                            "DOC"
                                                        ? "Doctor"
                                                        : "Unknown",
                                        style: GoogleFonts.raleway(
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ],
                                ),
                                children: [
                                  const Divider(
                                    thickness: 1,
                                  ),
                                  ListTile(
                                    onTap: () {
                                      showModalBottomSheet(
                                        context: context,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(16.0),
                                            topRight: Radius.circular(16.0),
                                          ),
                                        ),
                                        enableDrag: true,
                                        useSafeArea: true,
                                        isDismissible: true,
                                        showDragHandle: true,
                                        isScrollControlled: true,
                                        builder: (context) {
                                          return SingleChildScrollView(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(
                                                  height: 24,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      "Official Details",
                                                      style:
                                                          GoogleFonts.raleway(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onBackground,
                                                        textStyle:
                                                            Theme.of(context)
                                                                .textTheme
                                                                .headlineMedium,
                                                      ),
                                                    ),
                                                    IconButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      icon: Icon(
                                                        Icons.close_rounded,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onBackground,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 48,
                                                ),
                                                TextField(
                                                  controller:
                                                      TextEditingController(
                                                          text: familyMembers[
                                                                      index][
                                                                  "managerId"] ??
                                                              ""),
                                                  decoration: InputDecoration(
                                                    prefixIcon: const Icon(
                                                        Icons.qr_code_rounded),
                                                    labelText: "Manager ID",
                                                    labelStyle:
                                                        GoogleFonts.raleway(
                                                      textStyle:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .titleMedium,
                                                    ),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      borderSide: BorderSide(
                                                          color: Theme.of(
                                                                  context)
                                                              .colorScheme
                                                              .onPrimaryContainer),
                                                    ),
                                                  ),
                                                  readOnly: true,
                                                  style:
                                                      GoogleFonts.sourceCodePro(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 16,
                                                ),
                                                TextField(
                                                  controller:
                                                      TextEditingController(
                                                          text: familyMembers[
                                                                      index][
                                                                  "managerName"] ??
                                                              ""),
                                                  decoration: InputDecoration(
                                                    prefixIcon: const Icon(
                                                        Icons.person),
                                                    labelText: "Manager Name",
                                                    labelStyle:
                                                        GoogleFonts.raleway(
                                                      textStyle:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .titleMedium,
                                                    ),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      borderSide: BorderSide(
                                                          color: Theme.of(
                                                                  context)
                                                              .colorScheme
                                                              .onPrimaryContainer),
                                                    ),
                                                  ),
                                                  readOnly: true,
                                                  style: GoogleFonts.raleway(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 16,
                                                ),
                                                TextField(
                                                  controller:
                                                      TextEditingController(
                                                          text: familyMembers[
                                                                      index][
                                                                  "userEmail"] ??
                                                              ""),
                                                  decoration: InputDecoration(
                                                    prefixIcon: const Icon(
                                                        Icons.email_rounded),
                                                    labelText: "Email",
                                                    labelStyle:
                                                        GoogleFonts.raleway(
                                                      textStyle:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .titleMedium,
                                                    ),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      borderSide: BorderSide(
                                                          color: Theme.of(
                                                                  context)
                                                              .colorScheme
                                                              .onPrimaryContainer),
                                                    ),
                                                  ),
                                                  readOnly: true,
                                                  style:
                                                      GoogleFonts.sourceCodePro(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 16,
                                                ),
                                                TextField(
                                                  controller:
                                                      TextEditingController(
                                                          text: familyMembers[
                                                                      index][
                                                                  "phoneNumber"] ??
                                                              ""),
                                                  decoration: InputDecoration(
                                                    prefixIcon:
                                                        const Icon(Icons.phone),
                                                    labelText: "Phone Number",
                                                    labelStyle:
                                                        GoogleFonts.raleway(
                                                      textStyle:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .titleMedium,
                                                    ),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      borderSide: BorderSide(
                                                          color: Theme.of(
                                                                  context)
                                                              .colorScheme
                                                              .onPrimaryContainer),
                                                    ),
                                                  ),
                                                  readOnly: true,
                                                  style:
                                                      GoogleFonts.sourceCodePro(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 16,
                                                ),
                                                TextField(
                                                  controller:
                                                      TextEditingController(
                                                          text: familyMembers[
                                                                      index][
                                                                  "officeName"] ??
                                                              ""),
                                                  decoration: InputDecoration(
                                                    prefixIcon:
                                                        const Icon(Icons.home),
                                                    labelText: "Office Name",
                                                    labelStyle:
                                                        GoogleFonts.raleway(
                                                      textStyle:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .titleMedium,
                                                    ),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      borderSide: BorderSide(
                                                          color: Theme.of(
                                                                  context)
                                                              .colorScheme
                                                              .onPrimaryContainer),
                                                    ),
                                                  ),
                                                  readOnly: true,
                                                  style: GoogleFonts.raleway(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 16,
                                                ),
                                                TextField(
                                                  controller:
                                                      TextEditingController(
                                                    text: familyMembers[index]
                                                                ["role"] ==
                                                            "ADMIN"
                                                        ? "Administrator"
                                                        : familyMembers[index]
                                                                    ["role"] ==
                                                                "HSHEAD"
                                                            ? "Hospital Head"
                                                            : familyMembers[index]
                                                                        [
                                                                        "role"] ==
                                                                    "FLWRKR"
                                                                ? "Frontline Worker"
                                                                : familyMembers[index]
                                                                            [
                                                                            "role"] ==
                                                                        "DOC"
                                                                    ? "Doctor"
                                                                    : "Unknown",
                                                  ),
                                                  decoration: InputDecoration(
                                                    prefixIcon: const Icon(
                                                        Icons.person),
                                                    labelText: "Role",
                                                    labelStyle:
                                                        GoogleFonts.raleway(
                                                      textStyle:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .titleMedium,
                                                    ),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      borderSide: BorderSide(
                                                          color: Theme.of(
                                                                  context)
                                                              .colorScheme
                                                              .onPrimaryContainer),
                                                    ),
                                                  ),
                                                  readOnly: true,
                                                  style: GoogleFonts.raleway(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 16,
                                                ),
                                                const SizedBox(
                                                  height: 48,
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    leading: const Icon(Icons.person),
                                    title: Text(
                                      "View Details",
                                      style: GoogleFonts.raleway(
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondaryContainer,
                                      ),
                                    ),
                                  ),
                                  ListTile(
                                    onTap: () {
                                      setState(() {
                                        _managerIdController.text =
                                            familyMembers[index]["managerId"];
                                        _managerNameController.text =
                                            familyMembers[index]["managerName"];
                                        _managerEmailController.text =
                                            familyMembers[index]["userEmail"];
                                        _managerPhoneController.text =
                                            familyMembers[index]["phoneNumber"];

                                        role = familyMembers[index]["role"];
                                      });
                                      showModalBottomSheet(
                                        context: context,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(16.0),
                                            topRight: Radius.circular(16.0),
                                          ),
                                        ),
                                        enableDrag: true,
                                        useSafeArea: true,
                                        isDismissible: true,
                                        showDragHandle: true,
                                        isScrollControlled: true,
                                        builder: (context) {
                                          return SingleChildScrollView(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: Form(
                                              key: _formKey,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const SizedBox(
                                                    height: 24,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        "Edit Details",
                                                        style:
                                                            GoogleFonts.raleway(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onBackground,
                                                          textStyle: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .headlineMedium,
                                                        ),
                                                      ),
                                                      IconButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        icon: Icon(
                                                          Icons.close_rounded,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onBackground,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 48,
                                                  ),
                                                  const SizedBox(
                                                    height: 16,
                                                  ),
                                                  TextFormField(
                                                    keyboardType:
                                                        TextInputType.name,
                                                    style: GoogleFonts
                                                        .sourceCodePro(),
                                                    controller:
                                                        _managerIdController,
                                                    readOnly: true,
                                                    validator: _fieldValidator,
                                                    decoration: InputDecoration(
                                                      labelText: "Manager ID",
                                                      prefixIcon: const Icon(
                                                          Icons
                                                              .verified_rounded),
                                                      hintText:
                                                          "Enter a new manager ID",
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        borderSide: BorderSide(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onPrimaryContainer),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        borderSide: BorderSide(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onPrimaryContainer),
                                                      ),
                                                      errorBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        borderSide: BorderSide(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onErrorContainer),
                                                      ),
                                                      focusedErrorBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        borderSide: BorderSide(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onErrorContainer),
                                                      ),
                                                      labelStyle:
                                                          GoogleFonts.raleway(),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 24,
                                                  ),
                                                  TextFormField(
                                                    keyboardType:
                                                        TextInputType.name,
                                                    style:
                                                        GoogleFonts.raleway(),
                                                    controller:
                                                        _managerNameController,
                                                    validator: _fieldValidator,
                                                    decoration: InputDecoration(
                                                      labelText: "Manager Name",
                                                      prefixIcon: const Icon(
                                                          Icons.person_rounded),
                                                      hintText:
                                                          "Enter manager name",
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        borderSide: BorderSide(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onPrimaryContainer),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        borderSide: BorderSide(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onPrimaryContainer),
                                                      ),
                                                      errorBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        borderSide: BorderSide(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onErrorContainer),
                                                      ),
                                                      focusedErrorBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        borderSide: BorderSide(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onErrorContainer),
                                                      ),
                                                      labelStyle:
                                                          GoogleFonts.raleway(),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 24,
                                                  ),
                                                  TextFormField(
                                                    keyboardType: TextInputType
                                                        .emailAddress,
                                                    style: GoogleFonts
                                                        .sourceCodePro(),
                                                    controller:
                                                        _managerEmailController,
                                                    validator: _emailValidator,
                                                    decoration: InputDecoration(
                                                      labelText: "Email ID",
                                                      prefixIcon: const Icon(
                                                          Icons.email_rounded),
                                                      hintText:
                                                          "Please enter your Email-ID",
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        borderSide: BorderSide(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onPrimaryContainer),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        borderSide: BorderSide(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onPrimaryContainer),
                                                      ),
                                                      errorBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        borderSide: BorderSide(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onErrorContainer),
                                                      ),
                                                      focusedErrorBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        borderSide: BorderSide(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onErrorContainer),
                                                      ),
                                                      labelStyle:
                                                          GoogleFonts.raleway(),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 24,
                                                  ),
                                                  TextFormField(
                                                    keyboardType:
                                                        TextInputType.phone,
                                                    style: GoogleFonts
                                                        .sourceCodePro(),
                                                    controller:
                                                        _managerPhoneController,
                                                    validator:
                                                        _mobileNumberValidator,
                                                    decoration: InputDecoration(
                                                      labelText:
                                                          "Mobile Number",
                                                      prefixIcon: const Icon(
                                                          Icons.phone_rounded),
                                                      hintText:
                                                          "Enter mobile number",
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        borderSide: BorderSide(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onPrimaryContainer),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        borderSide: BorderSide(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onPrimaryContainer),
                                                      ),
                                                      errorBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        borderSide: BorderSide(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onErrorContainer),
                                                      ),
                                                      focusedErrorBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        borderSide: BorderSide(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onErrorContainer),
                                                      ),
                                                      labelStyle:
                                                          GoogleFonts.raleway(),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 24,
                                                  ),
                                                  if (role != "ADMIN") ...[
                                                    DropdownButtonFormField(
                                                      value: role,
                                                      items: <DropdownMenuItem<
                                                          String>>[
                                                        DropdownMenuItem(
                                                          value: "DOC",
                                                          child: Text(
                                                            "Doctor",
                                                            style: GoogleFonts
                                                                .raleway(),
                                                          ),
                                                        ),
                                                        DropdownMenuItem(
                                                          value: "FLWRKR",
                                                          child: Text(
                                                            "Frontline Worker",
                                                            style: GoogleFonts
                                                                .raleway(),
                                                          ),
                                                        ),
                                                        DropdownMenuItem(
                                                          value: "HSHEAD",
                                                          child: Text(
                                                            "Hospital Head",
                                                            style: GoogleFonts
                                                                .raleway(),
                                                          ),
                                                        ),
                                                      ],
                                                      validator:
                                                          _fieldValidator,
                                                      decoration:
                                                          InputDecoration(
                                                        labelText: "Role",
                                                        prefixIcon: const Icon(Icons
                                                            .verified_user_rounded),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          borderSide: BorderSide(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .onPrimaryContainer),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          borderSide: BorderSide(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .onPrimaryContainer),
                                                        ),
                                                        errorBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          borderSide: BorderSide(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .onErrorContainer),
                                                        ),
                                                        focusedErrorBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          borderSide: BorderSide(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .onErrorContainer),
                                                        ),
                                                        labelStyle: GoogleFonts
                                                            .raleway(),
                                                      ),
                                                      onChanged:
                                                          (String? value) {
                                                        setState(() {
                                                          role = value;
                                                        });
                                                      },
                                                    ),
                                                    const SizedBox(
                                                      height: 24,
                                                    ),
                                                  ] else ...[
                                                    // ReadOnly text field telling he's ADMIN
                                                    TextFormField(
                                                      keyboardType:
                                                          TextInputType.name,
                                                      style: GoogleFonts
                                                          .sourceCodePro(),
                                                      controller:
                                                          TextEditingController(
                                                              text:
                                                                  "Administrator"),
                                                      decoration:
                                                          InputDecoration(
                                                        labelText: "Role",
                                                        prefixIcon: const Icon(Icons
                                                            .verified_user_rounded),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          borderSide: BorderSide(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .onPrimaryContainer),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          borderSide: BorderSide(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .onPrimaryContainer),
                                                        ),
                                                        errorBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          borderSide: BorderSide(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .onErrorContainer),
                                                        ),
                                                        focusedErrorBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          borderSide: BorderSide(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .onErrorContainer),
                                                        ),
                                                        labelStyle: GoogleFonts
                                                            .raleway(),
                                                      ),
                                                      readOnly: true,
                                                    ),
                                                    const SizedBox(
                                                      height: 24,
                                                    ),
                                                  ],
                                                  MaterialButton(
                                                    onPressed: () {
                                                      if (_formKey.currentState!
                                                          .validate()) {
                                                        setState(() {
                                                          isLoading = true;
                                                        });
                                                        _editMember()
                                                            .then((value) {
                                                          if (value == "1") {
                                                            setState(() {
                                                              familyMembers[
                                                                          index]
                                                                      [
                                                                      "managerId"] =
                                                                  _managerIdController
                                                                      .text
                                                                      .trim()
                                                                      .toString();
                                                              familyMembers[
                                                                          index]
                                                                      [
                                                                      "managerName"] =
                                                                  _managerNameController
                                                                      .text
                                                                      .trim()
                                                                      .toString();
                                                              familyMembers[
                                                                          index]
                                                                      [
                                                                      "userEmail"] =
                                                                  _managerEmailController
                                                                      .text
                                                                      .trim()
                                                                      .toString();
                                                              familyMembers[
                                                                          index]
                                                                      [
                                                                      "phoneNumber"] =
                                                                  _managerPhoneController
                                                                      .text
                                                                      .trim()
                                                                      .toString();
                                                              familyMembers[
                                                                          index]
                                                                      ["role"] =
                                                                  role;
                                                              if (familyMembers[
                                                                          index]
                                                                      [
                                                                      "managerId"] !=
                                                                  managerId) {
                                                                familyMembers[
                                                                            index]
                                                                        [
                                                                        "status"] =
                                                                    "WAITLIST";
                                                              }
                                                            });
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          } else if (value ==
                                                              "0") {
                                                            setState(() {
                                                              isLoading = false;
                                                            });
                                                          }
                                                        });
                                                        setState(() {
                                                          isLoading = false;
                                                        });
                                                      }
                                                    },
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    minWidth: double.infinity,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 24.0,
                                                        vertical: 10.0),
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .secondary,
                                                    child: Text(
                                                      "Update details",
                                                      style:
                                                          GoogleFonts.raleway(
                                                        textStyle:
                                                            Theme.of(context)
                                                                .textTheme
                                                                .titleLarge,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSecondary,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 48,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    leading:
                                        const Icon(Icons.edit_note_rounded),
                                    title: Text(
                                      "Edit Details",
                                      style: GoogleFonts.raleway(
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondaryContainer,
                                      ),
                                    ),
                                  ),
                                  if ((familyMembers[index]["status"] ==
                                              "ACTIVE" ||
                                          familyMembers[index]["status"] ==
                                              "WAITLIST") &&
                                      familyMembers[index]["role"] !=
                                          "ADMIN") ...[
                                    ListTile(
                                      onTap: () {
                                        _toggleStatus(index).then((value) {
                                          if (value == "1") {
                                            setState(() {
                                              familyMembers[index]["status"] =
                                                  "INACTIVE";
                                            });
                                          }
                                        });
                                      },
                                      leading: const Icon(
                                          Icons.domain_disabled_rounded),
                                      title: Text(
                                        "Deactivate account",
                                        style: GoogleFonts.raleway(
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error,
                                        ),
                                      ),
                                    ),
                                  ] else if (familyMembers[index]["status"] ==
                                          "INACTIVE" &&
                                      familyMembers[index]["role"] !=
                                          "ADMIN") ...[
                                    ListTile(
                                      onTap: () {
                                        _toggleStatus(index).then((value) {
                                          if (value == "1") {
                                            // success
                                          }
                                        });
                                      },
                                      leading:
                                          const Icon(Icons.person_add_rounded),
                                      title: Text(
                                        "Activate account",
                                        style: GoogleFonts.raleway(
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(
                                    height: 16,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(
                          height: 48,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
