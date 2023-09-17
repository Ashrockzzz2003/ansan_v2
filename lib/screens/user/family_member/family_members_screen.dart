import 'package:dio/dio.dart';
import 'package:eperimetry_vtwo/screens/user/new_member_screen.dart';
import 'package:eperimetry_vtwo/screens/user/questionnaire_1_family_member.dart';
import 'package:eperimetry_vtwo/screens/user/user_screen.dart';
import 'package:eperimetry_vtwo/screens/user/view_questionnaire_family_member.dart';
import 'package:eperimetry_vtwo/screens/welcome_screen.dart';
import 'package:eperimetry_vtwo/utils/constants.dart';
import 'package:eperimetry_vtwo/utils/loading_screen.dart';
import 'package:eperimetry_vtwo/utils/toast_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FamilyMembersScreen extends StatefulWidget {
  const FamilyMembersScreen({super.key});

  @override
  State<FamilyMembersScreen> createState() => _FamilyMembersScreenState();
}

class _FamilyMembersScreenState extends State<FamilyMembersScreen> {
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
        Constants().allFamilyMembersUrl,
        options: Options(
            headers: {"Authorization": "Bearer $secretToken"},
            validateStatus: (status) => status! < 500),
      )
          .then((response) {
        if (response.statusCode == 200) {
          if (response.data["data"].length > 0) {
            for (final familyMember in response.data["data"]) {
              setState(() {
                familyMembers.add({
                  "patientId": familyMember["patientId"].toString(),
                  "phoneNumber": familyMember["phoneNumber"].toString(),
                  "userName": familyMember["userName"].toString(),
                  "gender": familyMember["gender"].toString() == "M"
                      ? "Male"
                      : "Female",
                  "dob": familyMember["dob"].toString().split("T")[0],
                  "age": familyMember["age"].toString(),
                  "userEmail": familyMember["userEmail"].toString(),
                  "aadhar": familyMember["aadhar"].toString(),
                  "address": familyMember["address"].toString(),
                  "district": familyMember["district"].toString(),
                  "state": familyMember["state"].toString(),
                  "country": familyMember["country"].toString(),
                  "pincode": familyMember["pincode"].toString(),
                  "surveyLevel": familyMember["surveyLevel"].toString(),
                  "roleId": familyMember["roleId"].toString(),
                  "parentId": familyMember["parentId"].toString(),
                  "isParent": familyMember["isParent"].toString(),
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
            return const UserScreen();
          }), (route) => false);
        }
      }).catchError((error) {
        showToast("Something went wrong!");
        Navigator.of(context).pushAndRemoveUntil(
            CupertinoPageRoute(builder: (context) {
          return const UserScreen();
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

  @override
  Widget build(BuildContext context) {
    return isLoading && familyMembers.isEmpty
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
                        return const UserScreen();
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
                      "Family Members",
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
                                      "No family members found!",
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
                                    "You can add family members by clicking the button below.",
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
                                        return const NewMemberScreen();
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
                                      "Add Family Member",
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 0.0, vertical: 8.0),
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
                                  "ID: ${familyMembers[index]["patientId"]}",
                                  style: GoogleFonts.sourceCodePro(
                                    textStyle:
                                        Theme.of(context).textTheme.titleLarge,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      height: 8.0,
                                    ),
                                    Text(
                                      familyMembers[index]["userName"],
                                      style: GoogleFonts.raleway(
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Chip(
                                        padding: const EdgeInsets.all(2.0),
                                        label: Text(
                                          familyMembers[index]["surveyLevel"]
                                                      .toString() ==
                                                  "0"
                                              ? "Questionnaire 1 Pending"
                                              : familyMembers[index]
                                                              ["surveyLevel"]
                                                          .toString() ==
                                                      "1"
                                                  ? "Questionnaire 2 pending"
                                                  : "Questionnaire Done",
                                          style: GoogleFonts.raleway(
                                            fontWeight: FontWeight.w500,
                                            color: familyMembers[index]
                                                        ["surveyLevel"] ==
                                                    "0"
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
                                                        ["surveyLevel"]
                                                    .toString() ==
                                                "0"
                                            ? Theme.of(context)
                                                .colorScheme
                                                .error
                                            : Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                      ),
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
                                              children: [
                                                const SizedBox(
                                                  height: 24,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Patient Details",
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
                                                                  "patientId"] ??
                                                              ""),
                                                  decoration: InputDecoration(
                                                    prefixIcon: const Icon(
                                                        Icons.qr_code_rounded),
                                                    labelText: "PatientID",
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
                                                                  "userName"] ??
                                                              ""),
                                                  decoration: InputDecoration(
                                                    prefixIcon: const Icon(
                                                        Icons.person_rounded),
                                                    labelText: "Full Name",
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
                                                                      [
                                                                      "gender"] ==
                                                                  "M"
                                                              ? "Male"
                                                              : "Female"),
                                                  decoration: InputDecoration(
                                                    prefixIcon: familyMembers[
                                                                    index]
                                                                ["gender"] ==
                                                            "M"
                                                        ? const Icon(
                                                            Icons.male_rounded)
                                                        : const Icon(Icons
                                                            .female_rounded),
                                                    labelText: "Gender",
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
                                                            ["dob"]
                                                        .toString()
                                                        .split("T")[0],
                                                  ),
                                                  decoration: InputDecoration(
                                                    prefixIcon: const Icon(Icons
                                                        .date_range_rounded),
                                                    labelText: "Date of Birth",
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
                                                                      index]
                                                                  ["age"] ??
                                                              ""),
                                                  decoration: InputDecoration(
                                                    prefixIcon: const Icon(Icons
                                                        .access_time_filled_rounded),
                                                    labelText: "Age",
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
                                                                      index]
                                                                  ["aadhar"] ??
                                                              ""),
                                                  decoration: InputDecoration(
                                                    prefixIcon: const Icon(
                                                        Icons.badge_rounded),
                                                    labelText: "Aadhar",
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
                                                                      index]
                                                                  ["address"] ??
                                                              ""),
                                                  maxLines: null,
                                                  decoration: InputDecoration(
                                                    prefixIcon: const Icon(
                                                        Icons.home_rounded),
                                                    labelText: "Address",
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
                                                                  "district"] ??
                                                              ""),
                                                  decoration: InputDecoration(
                                                    prefixIcon: const Icon(Icons
                                                        .location_on_rounded),
                                                    labelText: "District",
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
                                                                  ["state"] ??
                                                              ""),
                                                  decoration: InputDecoration(
                                                    prefixIcon: const Icon(Icons
                                                        .local_library_rounded),
                                                    labelText: "State",
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
                                                                  ["country"] ??
                                                              ""),
                                                  decoration: InputDecoration(
                                                    prefixIcon: const Icon(Icons
                                                        .flag_circle_rounded),
                                                    labelText: "Country",
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
                                                                  ["pincode"] ??
                                                              ""),
                                                  decoration: InputDecoration(
                                                    prefixIcon: const Icon(Icons
                                                        .qr_code_2_rounded),
                                                    labelText: "Pincode",
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
                                                  height: 32,
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
                                            .primary,
                                      ),
                                    ),
                                  ),
                                  if (familyMembers[index]["surveyLevel"] ==
                                      "0") ...[
                                    ListTile(
                                      onTap: () {
                                        Navigator.of(context)
                                            .push(CupertinoPageRoute(
                                          builder: (context) {
                                            return FamilyMemberSurveyLevelOneScreen(
                                              familyMemberId:
                                                  familyMembers[index]
                                                      ["patientId"],
                                            );
                                          },
                                        ));
                                      },
                                      leading: const Icon(Icons.assignment),
                                      title: Text(
                                        "Take Questionnaire",
                                        style: GoogleFonts.raleway(
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                    ),
                                  ] else ...[
                                    ListTile(
                                      onTap: () {
                                        Navigator.of(context)
                                            .push(CupertinoPageRoute(
                                          builder: (context) {
                                            return ViewFamilyMemberSurveyLevelOneScreen(
                                              memberId: familyMembers[index]
                                                  ["patientId"],
                                            );
                                          },
                                        ));
                                      },
                                      leading: const Icon(Icons.assignment),
                                      title: Text(
                                        "View Questionnaire",
                                        style: GoogleFonts.raleway(
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                  if (familyMembers[index]["surveyLevel"]
                                          .toString() ==
                                      "2") ...[
                                    ListTile(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return Dialog(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16.0,
                                                        vertical: 16.0),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      "Patient ID",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style:
                                                          GoogleFonts.raleway(
                                                        textStyle:
                                                            Theme.of(context)
                                                                .textTheme
                                                                .titleLarge,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 8,
                                                    ),
                                                    const Divider(),
                                                    const SizedBox(
                                                      height: 16,
                                                    ),
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 16.0,
                                                          vertical: 16.0),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16.0),
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .primaryContainer
                                                            .withOpacity(0.2),
                                                      ),
                                                      child: Text(
                                                        "${familyMembers[index]["patientId"]}",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style:
                                                            GoogleFonts.raleway(
                                                          textStyle:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .titleLarge,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 16,
                                                    ),
                                                    Text(
                                                      "Please reach out to your nearest eye hospital and get the test done. Share your patient ID displayed above with them.",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style:
                                                          GoogleFonts.raleway(
                                                        textStyle:
                                                            Theme.of(context)
                                                                .textTheme
                                                                .titleSmall,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 16,
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 16.0,
                                                          vertical: 16.0,
                                                        ),
                                                        backgroundColor:
                                                            Theme.of(context)
                                                                .colorScheme
                                                                .primary,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      16.0),
                                                        ),
                                                      ),
                                                      child: Text(
                                                        "Okay",
                                                        style:
                                                            GoogleFonts.raleway(
                                                          textStyle:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .titleSmall,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onPrimary,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      leading: const Icon(
                                          Icons.medical_information_rounded),
                                      title: Text(
                                        "Take Test",
                                        style: GoogleFonts.raleway(
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                    ),
                                    ListTile(
                                      onTap: () {},
                                      leading: const Icon(Icons.assignment),
                                      title: Text(
                                        "View Reports",
                                        style: GoogleFonts.raleway(
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
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
