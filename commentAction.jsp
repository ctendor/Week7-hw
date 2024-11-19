<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>

<%
    String username = (String) session.getAttribute("username");
    if (username == null) {
        out.println("<script>alert('로그인이 필요합니다.'); location.href='./login.jsp';</script>");
        return;
    }

    String content = request.getParameter("content");
    String postIdxParam = request.getParameter("post_idx");
    if (content == null || content.isEmpty() || postIdxParam == null || postIdxParam.isEmpty()) {
        out.println("<script>alert('내용을 입력해주세요.'); history.back();</script>");
        return;
    }
    int postIdx = Integer.parseInt(postIdxParam);

    String jdbcDriver = "org.mariadb.jdbc.Driver";
    String dbUrl = "jdbc:mariadb://localhost:3306/hw";
    String dbUser = "TK";
    String dbPass = "1234";

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName(jdbcDriver);
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

        String userSql = "SELECT idx FROM users WHERE username = ?";
        pstmt = conn.prepareStatement(userSql);
        pstmt.setString(1, username);
        rs = pstmt.executeQuery();

        int userIdx = 0;
        if (rs.next()) {
            userIdx = rs.getInt("idx");
        }
        rs.close();
        pstmt.close();

        String commentSql = "INSERT INTO comments (post_idx, user_idx, content, created_at) VALUES (?, ?, ?, NOW())";
        pstmt = conn.prepareStatement(commentSql);
        pstmt.setInt(1, postIdx);
        pstmt.setInt(2, userIdx);
        pstmt.setString(3, content);
        pstmt.executeUpdate();

        response.sendRedirect("postDetail.jsp?id=" + postIdx);

    } catch(Exception e) {
        e.printStackTrace();
        out.println("<script>alert('에러가 발생했습니다.'); history.back();</script>");
    } finally {
        if(rs != null) try { rs.close(); } catch(SQLException ex) {}
        if(pstmt != null) try { pstmt.close(); } catch(SQLException ex) {}
        if(conn != null) try { conn.close(); } catch(SQLException ex) {}
    }
%>
