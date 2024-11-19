<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>

<%
    String jdbcDriver = "org.mariadb.jdbc.Driver";
    String dbUrl = "jdbc:mariadb://localhost:3306/hw";
    String dbUser = "TK";
    String dbPass = "1234";

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    String username = (String) session.getAttribute("username");
    if (username == null) {
        out.println("<script>alert('로그인이 필요합니다.'); location.href='login.jsp';</script>");
        return;
    }

    String idParam = request.getParameter("id");
    if (idParam == null || idParam.isEmpty()) {
        out.println("<script>alert('잘못된 접근입니다.'); history.back();</script>");
        return;
    }
    int postId = Integer.parseInt(idParam);

    try {
        Class.forName(jdbcDriver);
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

        String sql = "SELECT p.*, u.username, u.idx as user_idx FROM posts p JOIN users u ON p.user_idx = u.idx WHERE p.idx = ?";
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
    <title><%= title %></title>
    <style>
        .post {
            width: 80%;
            margin: 0 auto;
        }
        .post h1 {
            border-bottom: 1px solid #ccc;
            padding-bottom: 10px;
        }
        .post .meta {
            margin-bottom: 20px;
            color: #777;
        }
        
        .post .content {
            min-height: 200px;
            margin-bottom: 30px;
        }
        .buttons {
            display: flex;
            text-align: right;
            margin-bottom: 20px;
        }
        .buttons a {
            text-decoration: none;
            padding: 8px 12px;
            background-color: #4285F4;
            border-radius: 4px;
            margin-left: 5px;
        }
        .buttons a:hover {
            background-color: #357AE8;
        }
    </style>
</head>
<body>
    <div class="post">
        <h1><%= title %></h1>
        <div class="meta">
            작성자: <%= writer %> | 날짜: <%= date %>
        </div>
        <div class="content">
            <%= content.replace("\n", "<br>") %>
        </div>

        <div class="buttons">
            <% if (sessionUserIdx == postUserIdx) { %>
                <a href="deletePostAction.jsp?id=<%= postId %>" onclick="return confirm('정말로 삭제하시겠습니까?');">삭제</a>
            <% } %>
        <div class="buttons">
            <% if (sessionUserIdx == postUserIdx) { %>
                <a href="postUpdatePage.jsp?id=<%= postId %>" onclick="return;">수정</a>
            <% } %>

            <a href="postList.jsp">목록으로</a>
        </div>
    </div>

</body>
</html>

<%
        } else {
            out.println("<script>alert('존재하지 않는 게시글입니다.'); history.back();</script>");
        }
    } catch(Exception e) {
        e.printStackTrace();
        out.println("<script>alert('에러가 발생했습니다.'); history.back();</script>");
    } finally {
        if(rs != null) try { rs.close(); } catch(SQLException ex) {}
        if(pstmt != null) try { pstmt.close(); } catch(SQLException ex) {}
        if(conn != null) try { conn.close(); } catch(SQLException ex) {}
    }
%>
