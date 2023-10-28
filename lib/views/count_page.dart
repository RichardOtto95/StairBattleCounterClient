import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CountPage extends StatefulWidget {
  const CountPage({super.key});

  @override
  State<CountPage> createState() => _CountPageState();
}

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rnd = Random();
String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

class _CountPageState extends State<CountPage> {
  String? deviceId;

  Future<String?> _getId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    deviceId = prefs.getString("HASH");

    if (deviceId == null) {
      await prefs.setString("HASH", getRandomString(10));
      deviceId = prefs.getString("HASH")!;
      print("hash: $deviceId");
    }

    return deviceId;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getData() {
    return FirebaseFirestore.instance.collection("sections").where(
      "status",
      whereIn: ["OPEN", "CLOSED", "ACCURATE"],
    ).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Batalha da Escada",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xff116D6E),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: FutureBuilder(
          future: _getId(),
          builder: (context, deviceSnap) {
            print("deviceId: ${deviceId}");
            if (!deviceSnap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: getData(),
              builder: (context, sectionSnap) {
                if (!sectionSnap.hasData) {
                  print("deviceId2: ${deviceId}");
                  return const Center(child: CircularProgressIndicator());
                } else {
                  if (sectionSnap.data!.docs.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      alignment: Alignment.center,
                      child: const Text(
                        "Não há nenhuma sessão aberta agora",
                        style: TextStyle(
                          color: Color(0xff321E1E),
                          fontSize: 28,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                    );
                  }
                  Section section =
                      Section.fromDoc(sectionSnap.data!.docs.first);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Spacer(flex: 5),
                      Text(
                        "Votação ${section.status == "CLOSED" ? "fechada" : section.status == "OPEN" ? "aberta" : "apurada"}",
                        style: const TextStyle(
                          color: Color(0xff321E1E),
                          fontSize: 28,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                      const Spacer(flex: 5),
                      Text(
                        section.firstCompetitor,
                        style: const TextStyle(
                          color: Color(0xff321E1E),
                          fontSize: 28,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                      const Spacer(flex: 7),
                      if (section.status == "OPEN" ||
                          section.status == "CLOSED")
                        PrimaryButton(
                          enable: section.status == "OPEN" &&
                              !section.voters.contains(deviceId),
                          onTap: () {
                            getConfirmPopup(section: section);
                          },
                        ),
                      if (section.status == "ACCURATE")
                        Result(
                          bigger: section.firstCompetitorVotes >
                              section.secondCompetitorVotes,
                          value: section.firstCompetitorVotes,
                        ),
                      const Spacer(flex: 10),
                      Container(
                        width: MediaQuery.of(context).size.width - 30,
                        height: 3,
                        decoration: BoxDecoration(
                          color: const Color(0xffcfcfcf),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      const Spacer(flex: 8),
                      Text(
                        section.secondCompetitor,
                        style: const TextStyle(
                          color: Color(0xff321E1E),
                          fontSize: 28,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                      const Spacer(flex: 5),
                      if (section.status == "OPEN" ||
                          section.status == "CLOSED")
                        PrimaryButton(
                          enable: section.status == "OPEN" &&
                              !section.voters.contains(deviceId),
                          onTap: () {
                            getConfirmPopup(section: section, first: false);
                          },
                        ),
                      if (section.status == "ACCURATE")
                        Result(
                          bigger: section.secondCompetitorVotes >
                              section.firstCompetitorVotes,
                          value: section.secondCompetitorVotes,
                        ),
                      const Spacer(flex: 10),
                    ],
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }

  getConfirmPopup({required Section section, bool first = true}) {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (context) {
        return AlertDialog(
          elevation: 5,
          title: Text(
            first ? section.firstCompetitor : section.secondCompetitor,
          ),
          content: Text(
            "Tem certeza de que deseja votar em ${first ? section.firstCompetitor : section.secondCompetitor}?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Não",
                style: TextStyle(color: Color(0xffCD1818)),
              ),
            ),
            TextButton(
              child: const Text(
                "Sim",
                style: TextStyle(color: Color(0xff116D6E)),
              ),
              onPressed: () async {
                OverlayEntry entry = overlayProgressIndicator();
                Overlay.of(context).insert(entry);
                try {
                  await FirebaseFirestore.instance
                      .collection("sections")
                      .doc(section.id)
                      .update(first
                          ? {
                              "first_competitor_votes": FieldValue.increment(1),
                              "voters": FieldValue.arrayUnion([deviceId])
                            }
                          : {
                              "second_competitor_votes":
                                  FieldValue.increment(1),
                              "voters": FieldValue.arrayUnion([deviceId])
                            });
                  entry.remove();
                } catch (e) {
                  Fluttertoast.showToast(msg: "Não foi possível votar");
                }
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}

class Section {
  Section({
    required this.createdAt,
    required this.firstCompetitor,
    required this.secondCompetitor,
    required this.firstCompetitorVotes,
    required this.secondCompetitorVotes,
    required this.voters,
    required this.status,
    this.id,
  });

  DateTime createdAt;

  String firstCompetitor;

  String secondCompetitor;

  int firstCompetitorVotes;

  int secondCompetitorVotes;

  /// Can be: [OPEN, CLOSED, ACCURATE, FINISHED]
  String status;

  String? id;

  List<String> voters;

  factory Section.fromDoc(DocumentSnapshot doc) => Section(
        id: doc.id,
        createdAt: doc.get("created_at").toDate(),
        firstCompetitor: doc.get("first_competitor"),
        secondCompetitor: doc.get("second_competitor"),
        firstCompetitorVotes: doc.get("first_competitor_votes"),
        secondCompetitorVotes: doc.get("second_competitor_votes"),
        voters: List.from(doc.get("voters")),
        status: doc.get("status"),
      );

  Map<String, dynamic> toJson() => {
        "created_at": createdAt,
        "first_competitor": firstCompetitor,
        "second_competitor": secondCompetitor,
        "first_competitorVotes": firstCompetitorVotes,
        "second_competitorVotes": secondCompetitorVotes,
        "voters": voters,
        "status": status,
      };
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.onTap,
    this.width = 150,
    this.height = 50,
    this.color = const Color(0xff116D6E),
    this.enable = true,
    this.label = "Votar",
  });

  final double width;

  final double height;

  final Color color;

  final bool enable;

  final String label;

  final void Function() onTap;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: InkWell(
        onTap: enable ? onTap : null,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: Colors.white),
            color: enable ? const Color(0xff116D6E) : const Color(0xff917B7B),
            boxShadow: enable
                ? [
                    BoxShadow(
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                      color: Colors.black.withOpacity(.3),
                    ),
                  ]
                : [],
          ),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Result extends StatelessWidget {
  const Result({
    super.key,
    required this.bigger,
    required this.value,
  });

  final bool bigger;

  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      width: 131,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        color: Colors.white,
        border: Border.all(
          color: const Color(0xff917B7B),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 6,
            offset: const Offset(0, 3),
            color: Colors.black.withOpacity(.3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        value.toString(),
        style: TextStyle(
          color: bigger ? const Color(0xff116D6E) : const Color(0xffCD1818),
          fontSize: 28,
        ),
      ),
    );
  }
}

overlayProgressIndicator() => OverlayEntry(
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.black.withOpacity(.3),
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      ),
    );
