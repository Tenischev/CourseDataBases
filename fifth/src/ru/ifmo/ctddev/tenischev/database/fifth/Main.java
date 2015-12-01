package ru.ifmo.ctddev.tenischev.database.fifth;

import java.sql.SQLException;
import java.util.List;

/**
 * Created by kris13 on 28.11.15.
 */
public class Main {
    private Main(String[] args) {
        SqlConfig sourceConfig = new SqlConfig("localhost", args[2], args[0], args[1]);
        SqlConfig destinationConfig = new SqlConfig("localhost", args[3], args[0], args[1]);

        try (SqlSourceGateway source = new SqlSourceGateway(sourceConfig)) {
            try (SqlDestinationGateway destination = new SqlDestinationGateway(destinationConfig)) {

            // First dirty hack
            List<String> tables = source.getNameTables();
            List<String> queriesForCreateTable = source.getQueriesCreateTable(tables);

            // Second dirty hack
            destination.disableCheckForeignKeys();
            destination.generateTables(queriesForCreateTable);
            destination.insertData(args[2], tables);
            destination.enableCheckForeignKeys();

            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public static void main(String[] args) {
        if (args.length != 4)
            System.out.println("Wrong amount arguments!");
        else
            new Main(args);
    }
}
