<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>

<%
    String username = (String) session.getAttribute("username");
    if (username == null) {
        out.println("<script>alert('로그인이 필요합니다.'); location.href='login.jsp';</script>");
        return;
    }

    String jdbcDriver = "org.mariadb.jdbc.Driver";
    String dbUrl = "jdbc:mariadb://localhost:3306/hw";
    String dbUser = "TK";
    String dbPass = "1234";

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    List<Map<String, String>> categoryList = new ArrayList<>();

    try {
        Class.forName(jdbcDriver);
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

        String categorySql = "SELECT idx, name FROM categories";
        pstmt = conn.prepareStatement(categorySql);
        rs = pstmt.executeQuery();
        while (rs.next()) {
            Map<String, String> categoryItem = new HashMap<>();
            categoryItem.put("idx", String.valueOf(rs.getInt("idx")));
            categoryItem.put("name", rs.getString("name"));
            categoryList.add(categoryItem);
        }
        rs.close();
        pstmt.close();

        String sql = "SELECT p.*, u.idx as user_idx FROM posts p JOIN users u ON p.user_idx = u.idx WHERE p.idx = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, postId);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            String title = rs.getString("title");
            String content = rs.getString("content");
            String writer = rs.getString("username");
            String date = rs.getString("created_at");
            int categoryIdx = rs.getInt("category_idx");
            int postUserIdx = rs.getInt("user_idx");

            int sessionUserIdx = 0;
            String userSql = "SELECT idx FROM users WHERE username = ?";
            PreparedStatement userPstmt = conn.prepareStatement(userSql);
            userPstmt.setString(1, username);
            ResultSet userRs = userPstmt.executeQuery();
            if (userRs.next()) {
                sessionUserIdx = userRs.getInt("idx");
            }
            userRs.close();
            userPstmt.close();
        
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>게시글 작성</title>
    <style>
        /* CSS 스타일 */
        .form-container {
            width: 80%;
            margin: 0 auto;
        }
        .form-container h1 {
            text-align: center;
        }
        .form-container form {
            margin-top: 20px;
        }
        .form-container form input[type="text"],
        .form-container form select,
        .form-container form textarea {
            width: 100%;
            padding: 8px;
            margin-bottom: 10px;
        }
        .form-container form input[type="submit"] {
            width: 100%;
            padding: 10px;
            background-color: #4285F4;
            border: none;
            cursor: pointer;
        }
        .form-container form input[type="submit"]:hover {
            background-color: #357AE8;
        }
    </style>
</head>
<body>
    <div class="form-container">
        <h1>게시글 작성</h1>
        <form method="post" action="postUpdateAction.jsp">
            <label for="category">카테고리</label>
            <select name="category" id="category" required>
                <% for (Map<String, String> categoryItem : categoryList) { %>
                    <option value="<%= categoryItem.get("idx") %>"><%= categoryItem.get("name") %></option>
                <% } %>
            </select>

            <label for="title">제목</label>
            <input type="text" name="title" id="title" required>

            <label for="content">내용</label>
            <textarea name="content" id="content" rows="10" required></textarea>

            <input type="submit" value="게시글 등록">
        </form>
    </div>
</body>
</html>

<%
    } catch(Exception e) {
        e.printStackTrace();
        out.println("<script>alert('에러가 발생했습니다.'); history.back();</script>");
    } finally {
        if(rs != null) try { rs.close(); } catch(SQLException ex) {}
        if(pstmt != null) try { pstmt.close(); } catch(SQLException ex) {}
        if(conn != null) try { conn.close(); } catch(SQLException ex) {}
    }
%>
