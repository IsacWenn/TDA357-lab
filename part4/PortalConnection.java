
import org.json.JSONArray;
import org.json.JSONObject;
import org.json.JSONTokener;

import java.sql.*; // JDBC stuff.
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;
import java.util.Properties;

public class PortalConnection {

    // Set this to e.g. "portal" if you have created a database named portal
    // Leave it blank to use the default database of your database user
    static final String DBNAME = "";
    // For connecting to the portal database on your local machine
    static final String DATABASE = "jdbc:postgresql://localhost/"+DBNAME;
    static final String USERNAME = "postgres";
    static final String PASSWORD = "postgres";

    // For connecting to the chalmers database server (from inside chalmers)
    // static final String DATABASE = "jdbc:postgresql://brage.ita.chalmers.se/";
    // static final String USERNAME = "tda357_nnn";
    // static final String PASSWORD = "yourPasswordGoesHere";


    // This is the JDBC connection object you will be using in your methods.
    private Connection conn;

    public PortalConnection() throws SQLException, ClassNotFoundException {
        this(DATABASE, USERNAME, PASSWORD);
    }

    // Initializes the connection, no need to change anything here
    public PortalConnection(String db, String user, String pwd) throws SQLException, ClassNotFoundException {
        Class.forName("org.postgresql.Driver");
        Properties props = new Properties();
        props.setProperty("user", user);
        props.setProperty("password", pwd);
        conn = DriverManager.getConnection(db, props);
    }


    // Register a student on a course, returns a tiny JSON document (as a String)
    public String register(String student, String courseCode){
        try (PreparedStatement ps = conn.prepareStatement(
            "INSERT INTO Registrations VALUES (?, ?);");) {
            ps.setString(1, student);
            ps.setString(2, courseCode);
            ps.executeUpdate();
            return "{\"success\":true}";
        } catch (SQLException e) {
            return "{\"success\":false, \"error\":\""+getError(e)+"\"}";
        }
    }

    // Unregister a student from a course, returns a tiny JSON document (as a String)
    public String unregister(String student, String courseCode){
        try (PreparedStatement ps = conn.prepareStatement(
                "DELETE FROM Registrations WHERE (student=? AND course=" + courseCode + ");")) {
            ps.setString(1, student); // SQL Injection safe. String concatenation is not safe though.
            System.out.println(ps);
            int affectedRows = ps.executeUpdate();
            if (affectedRows == 0)
                return "{\"success\":false, \"error\":\"zero rows has been deleted\"}";
            else
                return "{\"success\":true}";
        } catch (SQLException e) {
            return "{\"success\":false, \"error\":\""+getError(e)+"\"}";
        }
    }

    // Return a JSON document containing lots of information about a student, it should validate against the schema found in information_schema.json
    public String getInfo(String student) throws SQLException{

        JSONObject info = new JSONObject();

        try(PreparedStatement st = conn.prepareStatement(
            // replace this with something more useful
            "SELECT jsonb_build_object('student',idnr,'name',name,'login',login,'program',program,'branch',branch)" +
                    " AS jsondata FROM BasicInformation WHERE idnr=?"
            )){

            st.setString(1, student);
            ResultSet rs = st.executeQuery();

            if(!rs.next())
              return "{\"student\":\"does not exist :(\"}";

            JSONObject result = new JSONObject(new JSONTokener(rs.getString("jsondata")));

            for(String key : JSONObject.getNames(result))
                info.put(key, result.get(key));
        } catch (SQLException e) {
            return "{\"success\":false, \"error\":\""+getError(e)+"\"}";
        }

        try(PreparedStatement f = conn.prepareStatement(
                "SELECT jsonb_build_object('code',course,'grade',grade) AS jsondata" +
                        " FROM Taken WHERE student=?"
            );
            PreparedStatement r = conn.prepareStatement(
                    "SELECT jsonb_build_object('code',course,'status',status) AS jsondata" +
                            " FROM Registrations WHERE student=?"
            );
        ){
            f.setString(1, student);
            ResultSet finished = f.executeQuery();

            r.setString(1, student);
            ResultSet registered = r.executeQuery();


            JSONObject courses = coursesToMap();

            JSONArray finished_courses = new JSONArray();

            while (finished.next()) {
                JSONObject course = new JSONObject(new JSONTokener(finished.getString("jsondata")));
                JSONObject course_info = (JSONObject) courses.get((String) course.get("code"));
                course.put("course", course_info.get("name"));
                course.put("credits", course_info.get("credits"));
                finished_courses.put(course);
            }
            info.put("finished", finished_courses);

            JSONArray registered_courses = new JSONArray();

            JSONObject coursePositions = coursePositionsToMap(student);

            while (registered.next()) {
                JSONObject course = new JSONObject(new JSONTokener(registered.getString("jsondata")));
                JSONObject course_info = (JSONObject) courses.get((String) course.get("code"));
                course.put("course", course_info.get("name"));
                if (Objects.equals((String) course.get("status"), "waiting")) {
                    course.put("position",((JSONObject) coursePositions.get(
                            (String) course.get("code"))).get("position"));
                }
                registered_courses.put(course);
            }

            info.put("registered", registered_courses);
        }

        try (PreparedStatement p = conn.prepareStatement(
                "SELECT jsonb_build_object('seminarCourses',seminarCourses,'mathCredits',mathCredits," +
                        "'researchCredits',researchCredits,'totalCredits',totalCredits,'canGraduate',qualified) AS " +
                        "jsondata FROM PathToGraduation WHERE student=?"
        )){
            p.setString(1, student);
            ResultSet path = p.executeQuery();
            path.next();
            JSONObject result = new JSONObject(new JSONTokener(path.getString("jsondata")));

            for (String key : JSONObject.getNames(result))
                info.put(key, result.get(key));
        }

        return info.toString();
    }

    private JSONObject coursePositionsToMap(String student) {
        JSONObject coursePositions = new JSONObject();
        try (PreparedStatement cqp = conn.prepareStatement(
                "SELECT jsonb_build_object('code',course,'position',place) AS jsondata " +
                        "FROM CourseQueuePositions WHERE student=?")){
            cqp.setString(1, student);
            ResultSet coursePositions_ = cqp.executeQuery();

            while (coursePositions_.next()){
                JSONObject result = new JSONObject(new JSONTokener(coursePositions_.getString("jsondata")));
                JSONObject position = new JSONObject();
                position.put("position", result.get("position"));
                coursePositions.put((String) result.get("code"), position);
            }
        } catch (SQLException e) {
            System.out.println("ERROR in coursePositionsToMap");
        }
        return coursePositions;
    }

    private JSONObject coursesToMap() {
        JSONObject courses = new JSONObject();
        try(PreparedStatement c = conn.prepareStatement(
                "SELECT jsonb_build_object('name',name,'code',code,'credits',credits) AS jsondata FROM Courses"
        )){
            ResultSet courses_ = c.executeQuery();

            while(courses_.next()){
                JSONObject result = new JSONObject(new JSONTokener(courses_.getString("jsondata")));
                JSONObject course = new JSONObject();
                course.put("name", result.get("name"));
                course.put("credits", result.get("credits"));
                courses.put((String) result.get("code"), course);
            }
        } catch (SQLException e) {
            System.out.println("Error in coursesToMap");
        }
        return courses;
    }

    // This is a hack to turn an SQLException into a JSON string error message. No need to change.

    public static String getError(SQLException e){
       String message = e.getMessage();
       int ix = message.indexOf('\n');
       if (ix > 0) message = message.substring(0, ix);
       message = message.replace("\"","\\\"");
       return message;
    }

}