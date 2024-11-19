<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
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

        int sessionUserIdx = 0;
        if (rs.next()) {
            sessionUserIdx = rs.getInt("idx");
        } else {
            out.println("<script>alert('사용자 정보를 찾을 수 없습니다.'); history.back();</script>");
            return;
        }
        rs.close();
        pstmt.close();

        String postSql = "SELECT user_idx FROM posts WHERE idx = ?";
        pstmt = conn.prepareStatement(postSql);
        pstmt.setInt(1, postId);
        rs = pstmt.executeQuery();

        int postUserIdx = 0;
        if (rs.next()) {
            postUserIdx = rs.getInt("user_idx");
        } else {
            out.println("<script>alert('존재하지 않는 게시글입니다.'); history.back();</script>");
            return;
        }
        rs.close();
        pstmt.close();

        if (sessionUserIdx != postUserIdx) {
            out.println("<script>alert('삭제 권한이 없습니다.'); history.back();</script>");
            return;
        }

        String deleteSql = "DELETE FROM posts WHERE idx = ?";
        pstmt = conn.prepareStatement(deleteSql);
        pstmt.setInt(1, postId);
        int result = pstmt.executeUpdate();

        if (result > 0) {
            out.println("<script>alert('게시글이 삭제되었습니다.'); location.href='postList.jsp';</script>");
        } else {
            out.println("<script>alert('삭제 실패했습니다.'); history.back();</script>");
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
