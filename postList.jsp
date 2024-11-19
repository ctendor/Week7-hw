<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, java.util.Map, java.util.HashMap" %>

<%
    String jdbcDriver = "org.mariadb.jdbc.Driver";
    String dbUrl = "jdbc:mariadb://localhost:3306/hw";
    String dbUser = "TK";
    String dbPass = "1234";

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    String username = (String) session.getAttribute("username");

    int pageIdx = 1;
    String category = request.getParameter("category");
    if (category == null) category = "all";
    String pageParam = request.getParameter("pageIdx");
    if (pageParam != null) {
        pageIdx = Integer.parseInt(pageParam);
    }
    int limit = 10;
    int offset = (pageIdx - 1) * limit;

    Map<Integer, String> categoryMap = new HashMap<>();
    List<Map<String, String>> categoryList = new ArrayList<>();

    try {
        Class.forName(jdbcDriver);
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

        String categorySql = "SELECT idx, name FROM categories";
        pstmt = conn.prepareStatement(categorySql);
        rs = pstmt.executeQuery();
        while (rs.next()) {
            int idx = rs.getInt("idx");
            String name = rs.getString("name");
            categoryMap.put(idx, name);

            Map<String, String> categoryItem = new HashMap<>();
            categoryItem.put("idx", String.valueOf(idx));
            categoryItem.put("name", name);
            categoryList.add(categoryItem);
        }
        rs.close();
        pstmt.close();

        String countSql = "SELECT COUNT(*) FROM posts";
        if (!category.equals("all")) {
            countSql += " WHERE category_idx = ?";
        }
        pstmt = conn.prepareStatement(countSql);

        if (!category.equals("all")) {
            pstmt.setInt(1, Integer.parseInt(category));
        }
        rs = pstmt.executeQuery();
        rs.next();
        int totalPosts = rs.getInt(1);
        rs.close();
        pstmt.close();

        String sql = "SELECT p.*, u.username FROM posts p JOIN users u ON p.user_idx = u.idx";
        if (!category.equals("all")) {
            sql += " WHERE p.category_idx = ?";
        }
        sql += " ORDER BY p.idx DESC LIMIT ? OFFSET ?";
        pstmt = conn.prepareStatement(sql);

        int paramIndex = 1;
        if (!category.equals("all")) {
            pstmt.setInt(paramIndex++, Integer.parseInt(category));
        }
        pstmt.setInt(paramIndex++, limit);
        pstmt.setInt(paramIndex, offset);

        rs = pstmt.executeQuery();

%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>게시글 목록</title>
    <style> 
        .header {
            width: 80%;
            margin: 20px auto;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .header .buttons {
            display: flex;
            gap: 10px;
        }
        .header .buttons a {
            text-decoration: none;
            padding: 8px 12px;
            background-color: #4285F4;
            border-radius: 4px;
        }
        .header .buttons a:hover {
            background-color: #357AE8;
        }
        .category-form {
            width: 80%;
            margin: 20px auto;
            text-align: right;
        }
        table {
            width: 80%;
            margin: 0 auto;
            border-collapse: collapse;
        }
        th, td {
            border: 1px solid #aaaaaa;
            padding: 8px;
            text-align: center;
        }
        .pagination {
            width: 80%;
            margin: 20px auto;
            text-align: center;
        }
    </style>
</head>
<body>

    <div class="header">
        <div class="title">게시글 목록</div>
        <div class="buttons">
            <% if (username != null) { %>
                <a href="writePost.jsp">글쓰기</a>
                <a href="logoutAction.jsp">로그아웃</a>
                <a href="index.jsp">홈으로</a>
            <% } else { %>
                <a href="login.jsp">로그인</a>
                <a href="register.jsp">회원가입</a>
                <a href="index.jsp">홈으로</a>
            <% } %>
        </div>
    </div>

    <div class="category-form">
        <form method="get" action="postList.jsp">
            <select name="category">
                <option value="all" <% if(category.equals("all")) out.print("selected"); %>>전체</option>
                <% for (Map<String, String> categoryItem : categoryList) { %>
                    <option value="<%= categoryItem.get("idx") %>" <% if(category.equals(categoryItem.get("idx"))) out.print("selected"); %>><%= categoryItem.get("name") %></option>
                <% } %>
            </select>
            <input type="submit" value="검색">
        </form>
    </div>

    <table>
        <tr>
            <th>번호</th>
            <th>제목</th>
            <th>작성자</th>
            <th>날짜</th>
        </tr>
        <%
            while(rs.next()) {
                int id = rs.getInt("idx");
                String title = rs.getString("title");
                String writer = rs.getString("username"); // 작성자 이름
                String date = rs.getString("created_at");
                int postCategoryIdx = rs.getInt("category_idx");

                String categoryName = categoryMap.get(postCategoryIdx);

                if (postCategoryIdx == 1) {
                    title = "[공지] " + title;
                }
        %>
        <tr>
            <td><%= id %></td>
            <td><a href="postDetail.jsp?id=<%= id %>"><%= title %></a></td>
            <td><%= writer %></td>
            <td><%= date %></td>
        </tr>
        <% } %>
    </table>

    <div class="pagination">
        <%
            int totalPages = (int) Math.ceil(totalPosts / (double) limit);
            for (int i = 1; i <= totalPages; i++) {
                if (i == pageIdx) {
        %>
            <a href="postList.jsp?pageIdx=<%= i %>&category=<%= category %>" class="current"><%= i %></a>
        <% } else { %>
            <a href="postList.jsp?pageIdx=<%= i %>&category=<%= category %>"><%= i %></a>
        <% } } %>
    </div>

</body>
</html>

<%
    } catch(Exception e) {
        e.printStackTrace();
    } finally {
        if(rs != null) try { rs.close(); } catch(SQLException ex) {}
        if(pstmt != null) try { pstmt.close(); } catch(SQLException ex) {}
        if(conn != null) try { conn.close(); } catch(SQLException ex) {}
    }
%>
