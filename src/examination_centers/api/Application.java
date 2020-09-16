package examination_centers.api;

import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

import jakarta.ws.rs.ApplicationPath;
import jakarta.ws.rs.Path;

@ApplicationPath("/ExaminationCenters")
@Path("/")
public class Application {
	public Set<Class<?>> getClasses() { 
		return new HashSet<Class<?>>(Arrays.asList(Endpoints.class)); 
	} 
}
