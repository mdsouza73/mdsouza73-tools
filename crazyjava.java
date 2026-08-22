import java.sql.Connection;
import java.sql.DriverManager;
import java.io.FileInputStream;
import java.io.InputStream;
import java.util.Properties;

public class DBConnectTest {

    public static void main(String[] args) {

        // Check that the properties file path was provided
        if (args.length != 1) {
            System.err.println("Usage: java DBConnectTest <path-to-db.properties>");
            System.exit(1);
        }

        String configPath = args[0];

        Properties prop = new Properties();

        try (InputStream input = new FileInputStream(configPath)) {

            // Read db.properties
            prop.load(input);

            String server   = prop.getProperty("db.server");
            String port     = prop.getProperty("db.port");
            String database = prop.getProperty("db.database");
            String username = prop.getProperty("db.username");
            String password = prop.getProperty("db.password");

            // Build JDBC connection URL
            String connectionUrl =
                    "jdbc:sqlserver://" + server + ":" + port +
                    ";databaseName=" + database +
                    ";user=" + username +
                    ";password=" + password +
                    ";encrypt=true" +
                    ";trustServerCertificate=true" +
                    ";loginTimeout=30";

            System.out.println("Attempting database connection...");

            // Establish database connection
            try (Connection connection =
                         DriverManager.getConnection(connectionUrl)) {

                System.out.println("Database connection successful.");

            }

        } catch (Exception e) {

            System.err.println("Database connection failed.");
            e.printStackTrace();
            System.exit(1);
        }
    }
}
