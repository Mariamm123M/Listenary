import 'package:get/get.dart';
import 'package:listenary/model/book_model.dart';

class FavoriteBooksController extends GetxController {
  // List of recent files, you can store file names or file paths here.
  var favoriteBooks = <Book>[].obs;

  // Method to add a file to recent list
  void addBookToFavorite(Book book, [int? index]) {
    // Remove the file if it already exists to avoid duplication
    favoriteBooks.remove(book); 
    (index == null)? favoriteBooks.insert(0, book) : favoriteBooks.insert(index, book);   
  }
  void removeBookFromFavorite(book) {
    // Remove the file if it already exists to avoid duplication
    favoriteBooks.remove(book);
  }
  bool isBookInFavorite(Book book) {
    return favoriteBooks.contains(book);
  }
}
