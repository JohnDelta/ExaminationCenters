package examination_centers.api;

import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.PUT;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.QueryParam;

@Path("/")
public class Endpoints {

	@GET
    @Path("admin-reports/classesReport")
    @Produces("application/json")
    public String getClassesReport() {
		return new ClassesReport().getJson();
    }
	
	@POST
    @Path("student-exam/exam")
    @Produces("application/json")
	@Consumes("application/json")
    public String examPut(String data) {
		return new Exam().putJson(data);
    }
	
	@GET
    @Path("student-exam/exam/{id_user}/{id_class}")
    @Produces("application/json")
    public String examGet(
    		@PathParam("id_user") String id_user, 
    		@PathParam("id_class") String id_class
	) {
		return new Exam().getJson(id_user, id_class);
    }
	
	@GET
    @Path("admin-reports/examsReport")
    @Produces("application/json")
    public String getExamsReport() {
		return new ExamsReport().getJson();
    }
	
	@GET
    @Path("admin-reports/studentsReport")
    @Produces("application/json")
    public String getStudentsReport() {
		return new StudentsReport().getJson();
    }
	
	@GET
    @Path("supervisor-classes/report/{id_user}")
    @Produces("application/json")
    public String getSupervisorClassesReport(
		@PathParam("id_user") String id_user
	) {
		return new SupervisorClassesReport().getJson(id_user);
    }
	
	@GET
    @Path("supervisor-class/report/{id_class}")
    @Produces("application/json")
    public String getSupervisorClassReport(
		@PathParam("id_class") String id_class
	) {
		return new SupervisorClassReport().getJson(id_class);
    }
	
}
