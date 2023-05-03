//IMPORTS
import com.mongodb.ConnectionString;
import org.bson.Document;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import com.mongodb.client.MongoCursor;
import com.mongodb.client.MongoDatabase;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
//END IMPORTS


public class MainTemperatura {

    public static void main(String[] args) {

        // Connect to MongoDB
        ConnectionString connectionString = new ConnectionString("mongodb://localhost:23017");
        MongoClient mongoClient = MongoClients.create(connectionString);

        MongoDatabase mongoDatabase = mongoClient.getDatabase("experiencia"); // TODO mudar o nome da BD para o que usam
        //TODO mudar nome das coleções
        MongoCollection<Document> temperatura = mongoDatabase.getCollection("temperatura");


        // Connect to MySQL user já criado no sql
        String mysqlUrl = "jdbc:mysql://localhost:3306/experiencia_ratos"; //TODO substituir "experiencia_ratos" pelo nome que usaram para a BD
        String mysqlUsername = "myuser";
        String mysqlPassword = "mypassword";

        try {
            Connection mysqlConnection = DriverManager.getConnection(mysqlUrl, mysqlUsername, mysqlPassword);
            // Loop through MongoDB documents and insert into MySQL
            MongoCursor<Document> cursorT = temperatura.find().iterator();
            while (cursorT.hasNext()) {
                Document document = cursorT.next();
                int id = document.getInteger("_id");
                String hora = document.getString("hora");
                double leitura = document.getDouble("leitura");
                int sensor = document.getInteger("sensor");

                String insertSql = "INSERT INTO mediçõestemperatura (id, hora, leitura, sensor) VALUES (?, ?, ?, ?)";
                try {

                    PreparedStatement preparedStatement = mysqlConnection.prepareStatement(insertSql);
                    preparedStatement.setInt(1, id);
                    preparedStatement.setString(2, hora);
                    preparedStatement.setDouble(3, leitura);
                    preparedStatement.setInt(4, sensor);
                    preparedStatement.executeUpdate();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }


            // Close MongoDB and MySQL connections
            mongoClient.close();
            try {
                mysqlConnection.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

    }
}
