import 'package:get/get.dart';
import 'package:listenary/model/book_model.dart';

class RecentBooksController extends GetxController {
  // List of recent files, you can store file names or file paths here.
  var recentBooks = <Book>[].obs;

  // Method to add a file to recent list
  void addBookToRecent(Book book) {
    // Remove the file if it already exists to avoid duplication
    recentBooks.remove(book);
    
    // Add the file to the start of the list
    recentBooks.insert(0, book);

    // Optional: limit the number of recent files to 10
    if (recentBooks.length > 10) {
      recentBooks.removeLast(); // Remove the last file if the list exceeds 10
    }
  }
  void removeBookFromRecent(book) {
    // Remove the file if it already exists to avoid duplication
    recentBooks.remove(book);
  }
  bool isBookInRecent(Book book) {
    return recentBooks.contains(book);
  }
}
