import java.sql.Connection;
import java.sql.DriverManager;
import java.io.FileInputStream;
import java.io.InputStream;
import java.util.Properties;

public class DBConnectTest {

    public static void main(String[] args) {

        Properties prop = new Properties();

        try (InputStream input = new FileInputStream("db.properties")) {

            // Read db.properties
            prop.load(input);

            String server   = prop.getProperty("db.server");
            String port     = prop.getProperty("db.port");
            String database = prop.getProperty("db.database");
            String username = prop.getProperty("db.username");
            String password = prop.getProperty("db.password");

            // Build JDBC URL
            String connectionUrl =
                    "jdbc:sqlserver://" + server + ":" + port +
                    ";databaseName=" + database +
                    ";user=" + username +
                    ";password=" + password +
                    ";encrypt=true" +
                    ";trustServerCertificate=true" +
                    ";loginTimeout=30";

            System.out.println("Attempting database connection...");

            // Connect
            try (Connection connection =
                         DriverManager.getConnection(connectionUrl)) {

                System.out.println("Database connection successful.");

            }

        } catch (Exception e) {

            System.err.println("Database connection failed.");
            e.printStackTrace();
        }
    }
}
