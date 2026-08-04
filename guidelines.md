While writing the code make sure to follow these guidelines

1. Use dart short hands
Example
1. Null-aware Assignment (??=): name ??= "Guest";
2. Null Coalescing (??): String displayName = name ?? "Guest";
3. Conditional (Ternary) Operator (? :) : String result = age >= 18 ? "Adult" : "Minor";

2. Use dot shorthands

   1. alignment: .center, // Instead of Alignment.center,
   2.     mainAxisAlignment: .center, // Instead of MainAxisAlignment.center
   3.     crossAxisAlignment: .start, // Instead of CrossAxisAlignment.start
   4. Text(
      'Hello World',
      style: TextStyle(
      fontWeight: .bold, // Instead of FontWeight.bold
      ),
   5.   padding: .symmetric(horizontal: 16.0, vertical: 8.0), // Infers EdgeInsetsGeometry.symmetric
   6.  TextDecoration.underline = .underline 
   7. final ScrollController _scrollController = .new(); // Infers ScrollController() and you can use same for the TextEditingController
   8. Use spacing parameter instead of SizedBox for giving spacing between the items of the rows and columns
   9. 


