<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    String username = (String) session.getAttribute("username");
    if (username == null) {
        out.println("<script>alert('로그인이 필요합니다.'); location.href='login.jsp';</script>");
        return;
    }

    String categoryIdxParam = request.getParameter("category");
    String title = request.getParameter("title");
    String content = request.getParameter("content");

    if (categoryIdxParam == null || title == null || content == null ||
        categoryIdxParam.isEmpty() || title.isEmpty() || content.isEmpty()) {
        out.println("<script>alert('모든 필드를 입력해주세요.'); history.back();</script>");
        return;
    }

    int categoryIdx = Integer.parseInt(categoryIdxParam);

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
        } else {
            out.println("<script>alert('사용자 정보를 찾을 수 없습니다.'); history.back();</script>");
            return;
        }
        rs.close();
        pstmt.close();

        String postSql = "INSERT INTO posts (user_idx, category_idx, title, content, created_at) VALUES (?, ?, ?, ?, NOW())";
        pstmt = conn.prepareStatement(postSql);
        pstmt.setInt(1, userIdx);
        pstmt.setInt(2, categoryIdx);
        pstmt.setString(3, title);
        pstmt.setString(4, content);
        pstmt.executeUpdate();

        response.sendRedirect("postList.jsp");

    } catch(Exception e) {
        e.printStackTrace();
        out.println("<script>alert('에러가 발생했습니다.'); history.back();</script>");
    } finally {
        if(rs != null) try { rs.close(); } catch(SQLException ex) {}
        if(pstmt != null) try { pstmt.close(); } catch(SQLException ex) {}
        if(conn != null) try { conn.close(); } catch(SQLException ex) {}
    }
%>
