import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:text_summarizer_app/function/summary_processing.dart';

import '../result_screen.dart';
import 'firebase_service.dart';

class DocumentProcessor {
  Future<void> extractTextFromDocumentAndProcess({
    required BuildContext context,
    required File documentFile,
    required int selectedLanguageIndex,
    required int selectedModeIndex,
    required int selectedToneIndex,
  }) async {
    try {
      // Extract text from the document
      String documentText = await extractTextFromDocument(documentFile);
      List<Map<String, dynamic>> historicalData = await FirebaseService().getHistoricalData();
      SummaryProcessor summaryProcessor = SummaryProcessor();

      // Call the appropriate method based on the input type
      if (documentText.isNotEmpty) {
        // Pass the extracted text to combinedData in SummaryProcessor
        String generatedSummary =
        await summaryProcessor.generateSummaryFromText(
          summary: documentText,
          selectedlanguageIndex: selectedLanguageIndex,
          selectedModeIndex: selectedModeIndex,
          selectedToneIndex: selectedToneIndex,
          historicalData: historicalData, // Provide historical data here
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(summary: generatedSummary),
          ),
        );
      } else {
        print('Error: Extracted document text is empty.');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<String> extractTextFromDocument(File documentFile) async {
    try {
      // Extract text from a PDF document using syncfusion_flutter_pdf
      PdfDocument document = PdfDocument(inputBytes: documentFile.readAsBytesSync());
      String text = PdfTextExtractor(document).extractText();
      document.dispose();

      // Filter out links, emails, and consecutive spaces
      text = removeLinks(text);
      text = removeEmails(text);
      text = removeConsecutiveSpaces(text);

      return text;
    } catch (error) {
      print('Error extracting text from document: $error');
      throw Exception('Failed to extract text from document');
    }
  }

  String removeLinks(String text) {
    // Regular expression to match URLs
    RegExp urlRegExp = RegExp(r'https?://\S+|www\.\S+');

    // Replace URLs with an empty string
    return text.replaceAll(urlRegExp, '');
  }

  String removeEmails(String text) {
    // Regular expression to match email addresses
    RegExp emailRegExp = RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b');

    // Replace emails with an empty string
    return text.replaceAll(emailRegExp, '');
  }

  String removeConsecutiveSpaces(String text) {
    // Regular expression to match consecutive spaces
    RegExp consecutiveSpacesRegExp = RegExp(r'\s+');

    // Replace consecutive spaces with a single space
    return text.replaceAll(consecutiveSpacesRegExp, ' ');
  }
}
