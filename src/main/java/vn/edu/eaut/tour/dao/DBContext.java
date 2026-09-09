package vn.edu.eaut.tour.dao;

import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.net.URI;
import java.sql.Connection;
import java.sql.DriverManager;
import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.TimeUnit;

public class DBContext {
    private static final String DEFAULT_URL = "jdbc:mysql://localhost:3306/tour_booking_db?useUnicode=true&characterEncoding=UTF-8&connectionCollation=utf8mb4_unicode_ci&allowPublicKeyRetrieval=true&useSSL=false";
    private static final String DEFAULT_USER = "root";
    private static final String DEFAULT_PASS = "";

    private static final int POOL_SIZE = 10;
    private static final BlockingQueue<Connection> pool = new ArrayBlockingQueue<>(POOL_SIZE);

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    private static Connection createRawConnection() throws Exception {
        // 1. Check Railway / Render / Heroku standard DATABASE_URL / MYSQL_URL
        String rawUrl = System.getenv("DATABASE_URL");
        if (rawUrl == null || rawUrl.isBlank()) {
            rawUrl = System.getenv("MYSQL_URL");
        }
        if (rawUrl != null && (rawUrl.startsWith("mysql://") || rawUrl.startsWith("jdbc:mysql://"))) {
            if (rawUrl.startsWith("mysql://")) {
                URI uri = new URI(rawUrl);
                String userInfo = uri.getUserInfo();
                String host = uri.getHost();
                int port = uri.getPort() > 0 ? uri.getPort() : 3306;
                String path = uri.getPath();
                String dbName = path.startsWith("/") ? path.substring(1) : path;
                String jdbcUrl = "jdbc:mysql://" + host + ":" + port + "/" + dbName + "?useUnicode=true&characterEncoding=UTF-8&connectionCollation=utf8mb4_unicode_ci&allowPublicKeyRetrieval=true&useSSL=false&tcpKeepAlive=true";
                String user = userInfo != null && userInfo.contains(":") ? userInfo.split(":")[0] : DEFAULT_USER;
                String pass = userInfo != null && userInfo.contains(":") ? userInfo.split(":")[1] : DEFAULT_PASS;
                return DriverManager.getConnection(jdbcUrl, user, pass);
            }
            return DriverManager.getConnection(rawUrl);
        }

        // 2. Check individual cloud variables (Railway, Render, Clever Cloud)
        String host = System.getenv("MYSQLHOST");
        if (host != null && !host.isBlank()) {
            String port = System.getenv("MYSQLPORT") != null ? System.getenv("MYSQLPORT") : "3306";
            String db = System.getenv("MYSQLDATABASE") != null ? System.getenv("MYSQLDATABASE") : "tour_booking_db";
            String user = System.getenv("MYSQLUSER") != null ? System.getenv("MYSQLUSER") : "root";
            String pass = System.getenv("MYSQLPASSWORD") != null ? System.getenv("MYSQLPASSWORD") : "";
            String jdbcUrl = "jdbc:mysql://" + host + ":" + port + "/" + db + "?useUnicode=true&characterEncoding=UTF-8&connectionCollation=utf8mb4_unicode_ci&allowPublicKeyRetrieval=true&useSSL=false&tcpKeepAlive=true";
            return DriverManager.getConnection(jdbcUrl, user, pass);
        }

        // 3. Fallback to DB_URL / DB_USER / DB_PASS or local default
        String url = System.getenv("DB_URL") != null ? System.getenv("DB_URL") : DEFAULT_URL;
        if (!url.contains("tcpKeepAlive=")) {
            url += (url.contains("?") ? "&" : "?") + "tcpKeepAlive=true";
        }
        String user = System.getenv("DB_USER") != null ? System.getenv("DB_USER") : DEFAULT_USER;
        String pass = System.getenv("DB_PASSWORD") != null ? System.getenv("DB_PASSWORD") : (System.getenv("DB_PASS") != null ? System.getenv("DB_PASS") : DEFAULT_PASS);
        return DriverManager.getConnection(url, user, pass);
    }

    public static Connection getConnection() throws Exception {
        Connection raw = pool.poll(50, TimeUnit.MILLISECONDS);
        if (raw == null || raw.isClosed() || !raw.isValid(1)) {
            raw = createRawConnection();
        }

        final Connection target = raw;
        return (Connection) Proxy.newProxyInstance(
                DBContext.class.getClassLoader(),
                new Class<?>[]{Connection.class},
                new InvocationHandler() {
                    private boolean closed = false;

                    @Override
                    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
                        if ("close".equals(method.getName())) {
                            if (!closed) {
                                closed = true;
                                if (!target.isClosed() && target.isValid(1)) {
                                    if (!target.getAutoCommit()) {
                                        target.setAutoCommit(true);
                                    }
                                    if (!pool.offer(target)) {
                                        target.close();
                                    }
                                } else {
                                    try { target.close(); } catch (Exception ignored) {}
                                }
                            }
                            return null;
                        }
                        if ("isClosed".equals(method.getName())) {
                            return closed || target.isClosed();
                        }
                        return method.invoke(target, args);
                    }
                }
        );
    }
}