<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.security.MessageDigest" %>


<%
    request.setCharacterEncoding("UTF-8");

    String id = request.getParameter("id");
    String password = request.getParameter("password");

    if (id.isEmpty() || password.isEmpty()) {
        out.println("아이디와 비밀번호를 모두 입력해주세요.");
        return;
    }


    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;


    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3306/hw","TK","1234");

        String hashedPassword = "";
        MessageDigest md = MessageDigest.getInstance("SHA-256");
        md.update(password.getBytes("UTF-8"));
        byte[] digest = md.digest();
        StringBuffer sb = new StringBuffer();
        for (byte b : digest) {
            sb.append(String.format("%02x", b));
        }

        hashedPassword = sb.toString();
        String sql = "SELECT username FROM users WHERE id = ? AND password = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, id);
        pstmt.setString(2, hashedPassword); 

        rs = pstmt.executeQuery();
        out.println(rs.toString());
        if (rs.next()) {
            session.setAttribute("username", rs.getString("username"));
            response.sendRedirect("./index.jsp");
        } else {
            out.println("아이디 또는 비밀번호가 잘못되었습니다.");
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    }
%>