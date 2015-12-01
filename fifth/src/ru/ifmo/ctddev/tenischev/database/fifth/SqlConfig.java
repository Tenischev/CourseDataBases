package ru.ifmo.ctddev.tenischev.database.fifth;

/**
 * Created by kris13 on 28.11.15.
 */
public class SqlConfig {
    private String hostname;
    private String database;
    private String username;
    private String password;


    public SqlConfig(String hostname, String database, String username, String password) {
        this.hostname = hostname;
        this.database = database;
        this.username = username;
        this.password = password;
    }

    public String getConnectionString() {
        return String.format("jdbc:mysql://%s/%s?user=%s&password=%s", hostname, database, username, password);
    }
}
