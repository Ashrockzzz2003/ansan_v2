import 'package:dio/dio.dart';
import 'package:eperimetry_vtwo/screens/hospital_head/hshead_screen.dart';
import 'package:eperimetry_vtwo/screens/hospital_head/new_official_screen.dart';
import 'package:eperimetry_vtwo/screens/welcome_screen.dart';
import 'package:eperimetry_vtwo/utils/constants.dart';
import 'package:eperimetry_vtwo/utils/loading_screen.dart';
import 'package:eperimetry_vtwo/utils/toast_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HsHeadViewOfficialsScreen extends StatefulWidget {
  const HsHeadViewOfficialsScreen({super.key});

  @override
  State<HsHeadViewOfficialsScreen> createState() => _HsHeadViewOfficialsScreenState();
}

class _HsHeadViewOfficialsScreenState extends State<HsHeadViewOfficialsScreen> {
  final List<Map<String, dynamic>> familyMembers = [];
  bool isLoading = true;

  @override
  void initState() {
    setState(() {
      isLoading = true;
    });
    SharedPreferences.getInstance().then((sp) {
      final secretToken = sp.getString("SECRET_TOKEN");
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
            validateStatus: (status) => status! < 500),
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
          }
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
                return const HsHeadScreen();
              }), (route) => false);
        }
      }).catchError((error) {
        showToast("Something went wrong!");
        Navigator.of(context).pushAndRemoveUntil(
            CupertinoPageRoute(builder: (context) {
              return const HsHeadScreen();
            }), (route) => false);
        if (kDebugMode) {
          print(error);
        }
      });
    });
    setState(() {
      isLoading = false;
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
          "newStatus": familyMembers[index]["status"] == "ACTIVE"
              ? "INACTIVE"
              : "ACTIVE",
        },
      );

      if (response.statusCode == 200) {
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

  @override
  Widget build(BuildContext context) {
    return isLoading
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
                      return const HsHeadScreen();
                    }), (route) => false);
              },
              icon: const Icon(Icons.arrow_back_ios),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
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
                "Registered Doctors",
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
                                color:
                                Theme.of(context).colorScheme.error,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Text(
                                "No registered doctors added by you!",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.raleway(
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onError,
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
                              "You can add registered Doctors by clicking the button below.",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.raleway(
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .titleSmall,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            MaterialButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                    CupertinoPageRoute(
                                        builder: (context) {
                                          return const HsHeadNewOfficialScreen();
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
                                "New Doctor",
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
                        ))
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
                                  familyMembers[index]["role"],
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
                                                "Doctor Details",
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
                                                text: familyMembers[
                                                index]
                                                ["role"] ??
                                                    ""),
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
                            if (familyMembers[index]["status"] ==
                                "ACTIVE") ...[
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
                            ] else if (familyMembers[index]["status"] == "INACTIVE") ...[
                              ListTile(
                                onTap: () {
                                  _toggleStatus(index).then((value) {
                                    if (value == "1") {
                                      setState(() {
                                        familyMembers[index]["status"] =
                                        "ACTIVE";
                                      });
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
