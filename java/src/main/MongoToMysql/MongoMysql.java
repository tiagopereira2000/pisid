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
        //TODO criar BD teste no mongo e uma coleção
        MongoClient mongoClient = MongoClients.create(); // vai criar o cliente na porta 27017
        MongoDatabase mongoDatabase = mongoClient.getDatabase("myMongoDB");
        MongoCollection<Document> mongoCollection = mongoDatabase.getCollection("myCollection");

        // Connect to MySQL
        Connection mysqlConnection = null;
        String mysqlUrl = "jdbc:mysql://localhost:3306/mySqlDB";

        //TODO Criar uma BD teste no mySQL congigurar o username e a password no file "my.ini" (XAMPP)

        String mysqlUsername = "myUsername";
        String mysqlPassword = "myPassword";
        try {
            mysqlConnection = DriverManager.getConnection(mysqlUrl, mysqlUsername, mysqlPassword);
        } catch (SQLException e) {
            e.printStackTrace();
        }

        // Loop through MongoDB documents and insert into MySQL
        MongoCursor<Document> mongoCursor = mongoCollection.find().iterator();
        while (mongoCursor.hasNext()) {
            Document document = mongoCursor.next();
            String id = document.get("_id").toString();
            String name = document.getString("name");
            int age = document.getInteger("age");
            String address = document.getString("address");

            String insertSql = "INSERT INTO myTable (id, name, age, address) VALUES (?, ?, ?, ?)";
            try {
                PreparedStatement preparedStatement = mysqlConnection.prepareStatement(insertSql);
                preparedStatement.setString(1, id);
                preparedStatement.setString(2, name);
                preparedStatement.setInt(3, age);
                preparedStatement.setString(4, address);
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
    }
}
