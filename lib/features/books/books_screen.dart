// lib/features/books/books_screen.dart
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart'; // adjust relative path as neededimport 'pdf_view_screen.dart';
import 'pdf_view_screen.dart';
class BooksScreen extends StatelessWidget {
  const BooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the localized strings
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.ncertBooks),
      ),
      body: ListView(
        children: [
          _buildSubjectTile(context, "math", l10n.math),
          _buildSubjectTile(context, "science", l10n.science),
          _buildSubjectTile(context, "social_studies", l10n.socialStudies),
          _buildSubjectTile(context, "english", l10n.english),
          _buildSubjectTile(context, "hindi", l10n.hindi),
        ],
      ),
    );
  }

  Widget _buildSubjectTile(BuildContext context, String subjectKey, String localizedLabel) {
    return ListTile(
      title: Text(localizedLabel),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChapterListScreen(
              subject: subjectKey, 
              title: localizedLabel,
            ),
          ),
        );
      },
    );
  }
}

class ChapterListScreen extends StatelessWidget {
  final String subject;
  final String title; // Passed to keep the subject name localized
  
  const ChapterListScreen({
    super.key, 
    required this.subject, 
    required this.title,
  });

  List<String> getChapters() {
    switch (subject) {
      case "math":
        return [
          "jemh101.pdf", "jemh102.pdf", "jemh103.pdf", "jemh104.pdf",
          "jemh105.pdf", "jemh106.pdf", "jemh107.pdf", "jemh108.pdf",
          "jemh109.pdf", "jemh110.pdf", "jemh111.pdf", "jemh112.pdf",
          "jemh113.pdf", "jemh114.pdf", "jemh1a1.pdf", "jemh1a2.pdf",
          "jemh1an.pdf", "jemh1ps.pdf"
        ];
      case "science":
        return [
          "jesc101.pdf", "jesc102.pdf", "jesc103.pdf", "jesc104.pdf",
          "jesc105.pdf", "jesc106.pdf", "jesc107.pdf", "jesc108.pdf",
          "jesc109.pdf", "jesc110.pdf", "jesc111.pdf", "jesc112.pdf",
          "jesc113.pdf", "jesc1an.pdf", "jesc1ps.pdf"
        ];
      case "social_studies":
        return [
          "jess101.pdf", "jess102.pdf", "jess103.pdf", "jess104.pdf",
          "jess105.pdf", "jess106.pdf", "jess107.pdf", "jess1a1.pdf",
          "jess1ps.pdf"
        ];
      case "english":
        return [
          "jefp101.pdf", "jefp102.pdf", "jefp103.pdf", "jefp104.pdf",
          "jefp105.pdf", "jefp106.pdf", "jefp107.pdf", "jefp108.pdf",
          "jefp109.pdf", "jefp1ps.pdf"
        ];
      case "hindi":
        return [
          "jhsp101.pdf", "jhsp102.pdf", "jhsp103.pdf", "jhsp104.pdf",
          "jhsp105.pdf", "jhsp106.pdf", "jhsp107.pdf", "jhsp108.pdf",
          "jhsp109.pdf", "jhsp110.pdf", "jhsp111.pdf", "jhsp112.pdf",
          "jhsp113.pdf", "jhsp114.pdf", "jhsp1ps.pdf"
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final chapters = getChapters();
    return Scaffold(
      appBar: AppBar(
        title: Text("$title - Chapters"),
      ),
      body: ListView.builder(
        itemCount: chapters.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text("Chapter ${index + 1}"),
            trailing: const Icon(Icons.picture_as_pdf),
            onTap: () {
              final filePath = "assets/books/10/$subject/${chapters[index]}";
              debugPrint("NAVIGATING TO: $filePath");
              
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PdfViewScreen(
                    filePath: filePath,
                    title: "$title - Ch ${index + 1}",
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}