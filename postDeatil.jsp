 <%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>

<%
    // 데이터베이스 연결 설정 (본인의 DB 정보로 수정하세요)
    String jdbcDriver = "org.mariadb.jdbc.Driver";
    String dbUrl = "jdbc:mariadb://localhost:3306/hw";
    String dbUser = "TK";
    String dbPass = "1234";

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    // 게시글 ID 가져오기
    String idParam = request.getParameter("id");
    if (idParam == null || idParam.isEmpty()) {
        out.println("<script>alert('잘못된 접근입니다.'); history.back();</script>");
        return;
    }
    int postId = Integer.parseInt(idParam);

    try {
        Class.forName(jdbcDriver);
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

        // 게시글 정보 가져오기
        String sql = "SELECT p.*, u.username FROM posts p JOIN users u ON p.user_idx = u.idx WHERE p.idx = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, postId);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            String title = rs.getString("title");
            String content = rs.getString("content");
            String writer = rs.getString("username");
            String date = rs.getString("created_at");
            int categoryIdx = rs.getInt("category_idx");

            // 카테고리 이름 가져오기 (필요한 경우)
            String categoryName = "";
            if (categoryIdx == 1) {
                categoryName = "공지사항";
            } else if (categoryIdx == 2) {
                categoryName = "자유게시판";
            }

%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title><%= title %></title>
    <style>
        /* CSS 스타일 추가 */
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
        .comments {
            width: 80%;
            margin: 0 auto;
        }
        .comments h2 {
            border-bottom: 1px solid #ccc;
            padding-bottom: 10px;
        }
        .comment {
            border-bottom: 1px solid #eee;
            padding: 10px 0;
        }
        .comment .meta {
            color: #555;
            margin-bottom: 5px;
        }
        .comment-form {
            width: 80%;
            margin: 20px auto;
        }
        .comment-form textarea {
            width: 100%;
            height: 100px;
        }
    </style>
</head>
<body>
    <div class="post">
        <h1><%= title %></h1>
        <div class="meta">
            작성자: <%= writer %> | 날짜: <%= date %> | 카테고리: <%= categoryName %>
        </div>
        <div class="content">
            <%= content.replace("\n", "<br>") %>
        </div>
    </div>

    <!-- 댓글 목록 -->
    <div class="comments">
        <h2>댓글</h2>
        <%
            // 댓글 목록 가져오기
            rs.close();
            pstmt.close();

            String commentSql = "SELECT c.*, u.username FROM comments c JOIN users u ON c.user_idx = u.idx WHERE c.post_idx = ? ORDER BY c.idx ASC";
            pstmt = conn.prepareStatement(commentSql);
            pstmt.setInt(1, postId);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                String commentContent = rs.getString("content");
                String commentWriter = rs.getString("username");
                String commentDate = rs.getString("created_at");
        %>
        <div class="comment">
            <div class="meta">
                작성자: <%= commentWriter %> | 날짜: <%= commentDate %>
            </div>
            <div class="content">
                <%= commentContent.replace("\n", "<br>") %>
            </div>
        </div>
        <% } %>
    </div>

    <!-- 댓글 작성 폼 -->
    <div class="comment-form">
        <h2>댓글 작성</h2>
        <form method="post" action="commentAction.jsp">
            <input type="hidden" name="post_idx" value="<%= postId %>">
            <textarea name="content" required></textarea><br>
            <input type="submit" value="댓글 등록">
        </form>
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
