import java.io.IOException;
import java.io.OutputStream;
import java.net.InetSocketAddress;
import java.util.*;
import java.nio.file.*;
import java.net.URLDecoder;

import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;
import com.sun.net.httpserver.HttpServer;

public class PortalServer {
    
    public static final int PORT = 8080;

    public static void main(String[] args) throws Exception {
        PortalServer s = new PortalServer();
        s.server.start();
        System.out.println("server is running on port "+PORT);
    }

    private PortalConnection conn;
    private HttpServer server;
    
    public PortalServer() throws Exception {
        this.server = HttpServer.create(new InetSocketAddress(PORT), 0);
        
        this.conn = new PortalConnection();
 
        server.createContext("/", (HttpExchange t) -> {
            String response = 
               "<!doctype html>"+
               "<html lang=\"en\">"+
               "<head>"+
               "<link rel=\"stylesheet\" href=\"https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css\" integrity=\"sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T\" crossorigin=\"anonymous\">"+
               "</head><body class=\"bg-light\">"+
               "<div class=\"container\">"+ 
               "<form action=\"run\">"+      
               "<div class=\"mb-3\">"+
               "<div class=\"input-group\">"+
               "  <input type=\"text\" name=\"student\" placeholder=\"Student ID\">"+
               "  <div class=\"input-group-append\">"+
               "    <input type=\"submit\" value=\"Run\">"+
               "  </div>"+
               "</div>"+
               "</div></form>"+
               "</div></body></html>";
            byte[] bytes = response.getBytes();
            t.sendResponseHeaders(200, bytes.length);
            OutputStream os = t.getResponseBody();
            os.write(bytes);
            os.close();
        });

        server.createContext("/run", (HttpExchange t) -> {
            String response = 
               "<html lang=\"en\">\n" +
               "<head>\n" +
               "    <meta charset=\"UTF-8\">\n" +
               "    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n" +
               "    <meta http-equiv=\"X-UA-Compatible\" content=\"ie=edge\">\n" +
               "    <title>Student Portal</title>\n" +
               "    <link rel=\"stylesheet\" href=\"https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css\" integrity=\"sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T\" crossorigin=\"anonymous\">\n" +
               "</head>\n" +
               "<body class=\"bg-light\">\n" +
               "<div class=\"container\">\n" +
               "      <input type=\"text\" id=\"code\" placeholder=\"Course code\">\n" +
               "      <button id=\"register\">Register</button>\n" +
               "      <button id=\"unregister\">Unregister</button>\n" +
               "      <button id=\"getData\">Refresh Info</button>\n" +
               "      <p id=\"result\"></p>\n" +
               "      <p id=\"info\"></p>\n" +
               "</div>\n" +
               "</body>\n" +
               "<script>\n" +
               "        document.getElementById('getData').addEventListener('click', getData);\n" +
               "        document.getElementById('register').addEventListener('click', register);\n" +
               "        document.getElementById('unregister').addEventListener('click', unregister);\n" +
               "        getData();\n" +
               "        function getData(){\n" +
               "            const urlParams = new URLSearchParams(window.location.search);\n" +
               "            const stu = urlParams.get('student');\n" +
               "            fetch('info?student='+encodeURIComponent(stu))\n" +
               "                .then(function (res) {\n" +
               "                    return res.json();\n" +
               "                })\n" +
               "                .then(function (data) {\n" +
               "                    let result = `<h2>Student Info</h2>`;\n" +
               "                    \n" +
               "                    result += \n" +
               "                      `<p>Student: ${data.student}</p>\n" +
               "                       <p>Name: ${data.name}</p>\n" +
               "                       <p>Login: ${data.login}</p>\n" +
               "                       <p>Program: ${data.program}</p>\n" +
               "                       <p>Branch: ${data.branch || \"not selected\"}</p>\n" +
               "                       \n" +
               "                       <p>Read courses:<ul>\n" +
               "                       `;\n" +
               "                    \n" +
               "                    (data.finished ||  []).forEach((course) => {\n" +
               "                      result += `<li>${course.course} (${course.code}), ${course.credits} credits, grade ${course.grade}</li>`      \n" +
               "                      });\n" +
               "                      \n" +
               "                    result += `</ul></p>\n" +
               "                               <p>Registered for courses:<ul>`;\n" +
               "                    \n" +
               "                    (data.registered || []).forEach((course) => {\n" +
               "                        result += `<li>${course.course} (${course.code}), ${course.status}`;\n" +
               "                        if (course.position)\n" +
               "                            result += `, position ${course.position}`;\n" +
               "                        result += ` (<a href=\"javascript:void(0)\" onclick=\"unreg('${course.code}')\">unregister</a>)`\n"+
               "                        result += `</li>`;      \n" +
               "                      });\n" +
               "                      \n" +
               "                    result += \n" +
               "                      `</ul></p>\n" +
               "                       <p>Seminar courses passed: ${data.seminarCourses}</p>\n" +
               "                       <p>Total math credits: ${data.mathCredits}</p>\n" +
               "                       <p>Total research credits: ${data.researchCredits}</p>\n" +
               "                       <p>Total credits: ${data.totalCredits}</p>\n" +
               "                       <p>Ready for graduation: ${data.canGraduate}</p>\n" +
               "                       `;\n" +
               "                       \n" +
               "                    document.getElementById('info').innerHTML = result;\n" +
               "                }).catch(err => {\n" +
               "                    alert(`There was an error: ${err}`);\n" +
               "                })\n" +
               "        }\n" +
               "        \n" +
               "        function register(){\n" +
               "            const urlParams = new URLSearchParams(window.location.search);\n" +
               "            const stu = urlParams.get('student');\n" +
               "            const code = document.getElementById('code').value;\n" +
               "            fetch('reg?student='+encodeURIComponent(stu)+'&course='+encodeURIComponent(code))\n" +
               "                .then(function (res) {\n" +
               "                    return res.json();\n" +
               "                })\n" +
               "                .then(function (data) {\n" +
               "                    let result = `<h2>Registration result</h2>`;\n" +
               "                   \n" +
               "                    if(data.success){\n" +
               "                      result += \"Registration sucessful!\";                  \n" +
               "                    } else {\n" +
               "                      result += `Registration failed! Error: ${data.error}`;                  \n" +
               "                    }\n" +
               "                    \n" +
               "                    document.getElementById('result').innerHTML = result;\n" +
               "                    getData();\n" +
               "                }).catch(err => {\n" +
               "                    alert(`There was an error: ${err}`);\n" +
               "                })\n" +
               "        }\n" +
               "        \n" +
               "        function unreg(code){\n" +
               "            const urlParams = new URLSearchParams(window.location.search);\n" +
               "            const stu = urlParams.get('student');\n" +
               "            fetch('unreg?student='+encodeURIComponent(stu)+'&course='+encodeURIComponent(code))\n" +
               "                .then(function (res) {\n" +
               "                    return res.json();\n" +
               "                })\n" +
               "                .then(function (data) {\n" +
               "                    let result = `<h2>Unregistration result</h2>`;\n" +
               "                   \n" +
               "                    if(data.success){\n" +
               "                      result += \"Unregistration sucessful!\"; \n" +
               "                    } else {\n" +
               "                      result += `Unregistration failed! Error: ${data.error}`; \n" +
               "                    }\n" +
               "                    \n" +
               "                    document.getElementById('result').innerHTML = result;\n" +
               "                    getData();\n" +
               "                }).catch(err => {\n" +
               "                    alert(`There was an error: ${err}`);\n" +
               "                })\n" +
               "        }\n" +
               "        function unregister(){\n" +
               "            const code = document.getElementById('code').value;\n" +
               "            unreg(code);\n" +
               "        }\n" +
               "</script> \n" +
               "</html>\n";
               
               



            byte[] bytes = response.getBytes();
            //byte[] bytes = Files.readAllBytes(Paths.get("Test.html"));
            t.sendResponseHeaders(200, bytes.length);
            OutputStream os = t.getResponseBody();
            os.write(bytes);
            os.close();
        });
        
        server.createContext("/info", (HttpExchange t) -> {
            Map<String,String> input = queryToMap(t);
            try {
               byte[] bytes = conn.getInfo(input.get("student")).getBytes();
               t.sendResponseHeaders(200, bytes.length);
               OutputStream os = t.getResponseBody();
               os.write(bytes);
               os.close();
            } catch (Exception e) {
               e.printStackTrace();
               throw new RuntimeException(e);
            }
        });
        
        server.createContext("/reg", (HttpExchange t) -> {
            Map<String,String> input = queryToMap(t);
            String response = conn.register(input.get("student"),input.get("course"));
            byte[] bytes = response.getBytes();;
            t.sendResponseHeaders(200, bytes.length);
            OutputStream os = t.getResponseBody();
            os.write(bytes);
            os.close();
        });
        
        server.createContext("/unreg", (HttpExchange t) -> {
            Map<String,String> input = queryToMap(t);
            String response = conn.unregister(input.get("student"),input.get("course"));
            byte[] bytes = response.getBytes();;
            t.sendResponseHeaders(200, bytes.length);
            OutputStream os = t.getResponseBody();
            os.write(bytes);
            os.close();
        });
        
        server.setExecutor(null); // creates a default executor
    }

    public static Map<String, String> queryToMap(HttpExchange t){
       String query = t.getRequestURI().getRawQuery();
       Map<String, String> result = new HashMap<>();
       if(query==null)
         return result;
       for (String param : query.split("&")) {
           String[] entry = param.split("=", 2);
           if (entry.length > 1) {
               try {
                  result.put(URLDecoder.decode(entry[0], "UTF-8"), 
                             URLDecoder.decode(entry[1], "UTF-8"));
               } catch (Exception e) {
               }
           }else{
               result.put(entry[0], "");
           }
       }
       return result;
    }
}