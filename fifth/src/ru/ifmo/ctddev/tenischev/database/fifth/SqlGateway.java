package ru.ifmo.ctddev.tenischev.database.fifth;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * Created by kris13 on 28.11.15.
 */
public class SqlGateway implements AutoCloseable {
    protected Connection connection = null;
    protected SqlConfig sqlConfig;

    public SqlGateway(SqlConfig sqlConfig) {
        this.sqlConfig = sqlConfig;
        connect();
    }

    private void connect() {
        try {
            Class.forName("com.mysql.jdbc.Driver").newInstance();
            this.connection = DriverManager.getConnection(sqlConfig.getConnectionString());
        } catch (Exception e) {
            System.out.print(sqlConfig.getConnectionString());
            System.out.print("[Sql] Can't connect to database.");
            e.printStackTrace();
        }
    }

    public void close() throws SQLException{
        if (this.connection != null)
            this.connection.close();
    }

    protected Statement getStatement() throws SQLException {
        if (connection == null || connection.isClosed()) {
            connect();
        }
        return connection.createStatement();
    }
}