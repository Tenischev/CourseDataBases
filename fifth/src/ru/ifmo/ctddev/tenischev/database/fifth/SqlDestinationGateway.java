package ru.ifmo.ctddev.tenischev.database.fifth;

import java.sql.SQLException;
import java.sql.Statement;
import java.util.List;

/**
 * Created by kris13 on 28.11.15.
 */
public class SqlDestinationGateway extends SqlGateway {
    public SqlDestinationGateway(SqlConfig destinationConfig) {
        super(destinationConfig);
    }

    public void generateTables(List<String> queryForCreateTables) {
        try (Statement statement = this.getStatement()) {
            for (String query : queryForCreateTables)
                statement.execute(query);
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void disableCheckForeignKeys() {
        try (Statement statement = this.getStatement()) {
            statement.execute("SET FOREIGN_KEY_CHECKS = 0;");
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void enableCheckForeignKeys() {
        try (Statement statement = this.getStatement()) {
            statement.execute("SET FOREIGN_KEY_CHECKS = 1;");
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void insertData(String sourceDatabase, List<String> tables) {
        try (Statement statement = this.getStatement()) {
            for (String table : tables)
                statement.execute(String.format("INSERT INTO `%s` SELECT * FROM `%s`.`%s`", table, sourceDatabase, table));
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
