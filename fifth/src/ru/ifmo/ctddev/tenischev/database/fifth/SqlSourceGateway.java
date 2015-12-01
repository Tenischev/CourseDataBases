package ru.ifmo.ctddev.tenischev.database.fifth;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by kris13 on 28.11.15.
 */
public class SqlSourceGateway extends SqlGateway {
    public SqlSourceGateway(SqlConfig sourceConfig) {
        super(sourceConfig);
    }

    public List<String> getQueriesCreateTable(List<String> tables) {
        List<String> ans = new ArrayList<>();
        try (Statement statement = this.getStatement()) {
            for (String table : tables)
                try (ResultSet resultSet = statement.executeQuery(String.format("SHOW CREATE TABLE `%s`;",table))){
                    if (resultSet.next())
                        ans.add(resultSet.getString(2));
                }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return ans;
    }

    public List<String> getNameTables() {
        List<String> ans = new ArrayList<>();
        try (Statement statement = this.getStatement()) {
            try (ResultSet result = statement.executeQuery("SHOW TABLES;")) {
                while (result.next())
                    ans.add(result.getString(1));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return ans;
    }
}
