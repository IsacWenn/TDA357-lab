public class TestPortal {

   // enable this to make pretty printing a bit more compact
   private static final boolean COMPACT_OBJECTS = false;

   // This class creates a portal connection and runs a few operation

   public static void main(String[] args) {
      try{
          PortalConnection c = new PortalConnection();

          // Write your tests here. Add/remove calls to pause() as desired.
          // Use println instead of prettyPrint to get more compact output (if your raw JSON is already readable)

          // TEST 1: PRINT INFO OF STUDENT.
          System.out.println("############################# TEST 1 #############################");
          System.out.println("PRINT INFO OF STUDENT.");
          prettyPrint(c.getInfo("2222222222"));
          pause();

          // TEST 2: REGISTER STUDENT TO AN UNLIMITED COURSE AND CHECK BY PRINTING.
          scuffedCLS();
          System.out.println("############################# TEST 2 #############################");
          System.out.println("REGISTER STUDENT TO AN UNLIMITED COURSE AND CHECK BY PRINTING.");
          System.out.println(c.register("2222222222", "TTT111"));
          prettyPrint(c.getInfo("2222222222"));
          pause();

          // TEST 3: REGISTER THE SAME STUDENT AGAIN AND CHECK THE ERROR RESPONSE.
          scuffedCLS();
          System.out.println("############################# TEST 3 #############################");
          System.out.println("REGISTER THE SAME STUDENT AGAIN AND CHECK THE ERROR RESPONSE.");
          System.out.println(c.register("2222222222", "TTT111"));
          pause();

          // TEST 4: UNREGISTER A STUDENT FROM A COURSE TWICE AND CHECK THAT THE STUDENT NO LONGER IS REGISTERED
          //         TO THAT COURSE AND THAT THE ERROR RESPONSE WORKS.
          scuffedCLS();
          System.out.println("############################# TEST 4 #############################");
          System.out.println("UNREGISTER A STUDENT FROM A COURSE TWICE AND CHECK THAT THE STUDENT NO LONGER IS REGISTERED");
          System.out.println("TO THAT COURSE AND THAT THE ERROR RESPONSE WORKS.");
          System.out.println(c.unregister("2222222222", "'TTT111'"));
          System.out.println(c.unregister("2222222222", "'TTT111'"));
          prettyPrint(c.getInfo("2222222222"));
          pause();

          // TEST 5: REGISTER A STUDENT FOR A COURSE THEY HAVE NOT FULFILLED THE REQUIREMENTS FOR.
          scuffedCLS();
          System.out.println("############################# TEST 5 #############################");
          System.out.println("REGISTER A STUDENT FOR A COURSE THEY HAVE NOT FULFILLED THE REQUIREMENTS FOR. ");
          System.out.println(c.register("5555555555", "CCC555"));
          System.out.println("Student 5555555555 has been registered to course CCC555");
          pause();

          // TEST 6: UNREGISTER A STUDENT FROM A LIMITED COURSE THAT THEY ARE ALREADY REGISTERED TO AND HAS AT LEAST
          //         TWO OTHER STUDENTS IN THE WAITING QUEUE. THEN REGISTER THE SAME STUDENT ONCE AGAIN AND CHECK THAT
          //         THEY GET THE CORRECT LAST POSITION IN THE WAITINGLIST.
          scuffedCLS();
          System.out.println("############################# TEST 6 #############################");
          System.out.println("UNREGISTER A STUDENT FROM A LIMITED COURSE THAT THEY ARE ALREADY REGISTERED TO AND HAS AT LEAST");
          System.out.println("TWO OTHER STUDENTS IN THE WAITING QUEUE. THEN REGISTER THE SAME STUDENT ONCE AGAIN AND CHECK THAT");
          System.out.println("THEY GET THE CORRECT LAST POSITION IN THE WAITINGLIST.");
          System.out.println(c.unregister("1111111111", "'TTT555'"));
          System.out.println(c.register("1111111111", "TTT555"));
          prettyPrint(c.getInfo("1111111111"));
          pause();

          // TEST 7: UNREGISTER AND REGISTER THE SAME STUDENT FOR THE SAME LIMITED COURSE AND CHECK THAT THE STUDENT IS
          //         FIRST REMOVED AND THEN ENDS UP IN THE SAME POSITION AS BEFORE.
          scuffedCLS();
          System.out.println("############################# TEST 7 #############################");
          System.out.println("UNREGISTER AND REGISTER THE SAME STUDENT FOR THE SAME LIMITED COURSE AND CHECK THAT THE STUDENT IS");
          System.out.println("FIRST REMOVED AND THEN ENDS UP IN THE SAME POSITION AS BEFORE.");
          System.out.println(c.unregister("1111111111", "'TTT555'"));
          prettyPrint(c.getInfo("1111111111"));
          System.out.println(c.register("1111111111", "TTT555"));
          prettyPrint(c.getInfo("1111111111"));
          pause();

          // TEST 8: UNREGISTER A STUDENT FROM AN OVERFULL COURSE AND CHECK THAT NO STUDENT
          //         WAS REMOVED FROM THE QUEUE AND THEN REGISTERED TO THE COURSE.
          scuffedCLS();
          System.out.println("############################# TEST 8 #############################");
          System.out.println("UNREGISTER A STUDENT FROM AN OVERFULL COURSE AND CHECK THAT NO STUDENT");
          System.out.println("WAS REMOVED FROM THE QUEUE AND THEN REGISTERED TO THE COURSE.");
          System.out.println("\n Student 3333333333 is in the first place in the  waiting-list for course" +
                  "\n TTT444 and that course is overfull. We will remove student 2222222222 from the course and " +
                  "\n check that 3333333333 is still in the same place in the queue." +
                  "\n ");
          prettyPrint(c.getInfo("3333333333"));
          System.out.println(c.unregister("2222222222", "'TTT444'"));
          prettyPrint(c.getInfo("3333333333"));
          pause();

          // TEST 9: UNREGISTER WITH THE SQL INJECTION CAUSING ALL (OR ALMOST ALL) REGISTRATIONS TO DISAPPEAR.
          scuffedCLS();
          System.out.println("############################# TEST 9 #############################");
          System.out.println("UNREGISTER WITH THE SQL INJECTION CAUSING ALL (OR ALMOST ALL) REGISTRATIONS TO DISAPPEAR.");
          System.out.println(c.unregister("5555555555", "'CCC222') OR (1=1"));
          prettyPrint(c.getInfo("5555555555"));
          pause();

      } catch (ClassNotFoundException e) {
         System.err.println("ERROR!\nYou do not have the Postgres JDBC driver (e.g. postgresql-42.5.1.jar) in your runtime classpath!");
      } catch (Exception e) {
         e.printStackTrace();
      }
   }
   
   
   
   public static void pause() throws Exception{
     System.out.println("PRESS ENTER");
     while(System.in.read() != '\n');
   }
   
   // This is a truly horrible and bug-riddled hack for printing JSON. 
   // It is used only to avoid relying on additional libraries.
   // If you are a student, please avert your eyes.
   public static void prettyPrint(String json){
      System.out.print("Raw JSON:");
      System.out.println(json);
      System.out.println("Pretty-printed (possibly broken):");
      
      int indent = 0;
      json = json.replaceAll("\\r?\\n", " ");
      json = json.replaceAll(" +", " "); // This might change JSON string values :(
      json = json.replaceAll(" *, *", ","); // So can this
      
      for(char c : json.toCharArray()){
        if (c == '}' || c == ']') {
          indent -= 2;
          breakline(indent); // This will break string values with } and ]
        }
        
        System.out.print(c);
        
        if (c == '[' || c == '{') {
          indent += 2;
          breakline(indent);
        } else if (c == ',' && !COMPACT_OBJECTS) 
           breakline(indent);
      }
      
      System.out.println();
   }
   
   public static void breakline(int indent){
     System.out.println();
     for(int i = 0; i < indent; i++)
       System.out.print(" ");
   }

   private static void scuffedCLS(){
       System.out.println(
               "\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n"
       );
   }
}
