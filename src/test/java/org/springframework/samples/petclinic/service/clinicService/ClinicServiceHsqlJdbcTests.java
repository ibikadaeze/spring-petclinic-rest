package org.springframework.samples.petclinic.service.clinicService;

import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.annotation.DirtiesContext;

@SpringBootTest
@ActiveProfiles({"hsqldb", "jdbc"})
@TestPropertySource(properties = {"spring.sql.init.platform=hsqldb"})
@DirtiesContext(classMode = DirtiesContext.ClassMode.AFTER_CLASS)
public class ClinicServiceHsqlJdbcTests extends AbstractClinicServiceTests {
    // Leave empty if it only inherits tests from the base class
}
