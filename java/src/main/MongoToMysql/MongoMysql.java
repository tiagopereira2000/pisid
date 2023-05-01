//IMPORTS
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


public class MongoMysql {

    public static void main(String[] args) {

        // Connect to MongoDB
        MongoClient mongoClient = MongoClients.create(); // vai criar o cliente na porta 27017
        MongoDatabase mongoDatabase = mongoClient.getDatabase("experiencia_ratos"); // TODO mudar o nome da BD para o que usam
        //TODO mudar nome das coleções
        MongoCollection<Document> temperaturas = mongoDatabase.getCollection("medicoes_sala");
        MongoCollection<Document> movimentos = mongoDatabase.getCollection("medicoes_ratos");


        // Connect to MySQL user já criado no sql
        String mysqlUrl = "jdbc:mysql://localhost:3306/experiencia_ratos"; //TODO substituir "experiencia_ratos" pelo nome que usaram para a BD
        String mysqlUsername = "myuser";
        String mysqlPassword = "mypassword";

        try {
            Connection mysqlConnection = DriverManager.getConnection(mysqlUrl, mysqlUsername, mysqlPassword);
            // Loop through MongoDB documents and insert into MySQL
            MongoCursor<Document> cursorT = temperaturas.find().iterator();
            while (cursorT.hasNext()) {
                Document document = cursorT.next();
                int id = document.getInteger("_id");
                String hora = document.getString("hora");
                double leitura = document.getDouble("leitura");
                int sensor = document.getInteger("sensor");

                String insertSql = "INSERT INTO mediçõessala (id, hora, leitura, sensor) VALUES (?, ?, ?, ?)";
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
