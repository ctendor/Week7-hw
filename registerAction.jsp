<%@ page import="java.sql.*, java.security.MessageDigest" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    request.setCharacterEncoding("UTF-8");

    String id = request.getParameter("id");
    String username = request.getParameter("username");
    String password = request.getParameter("password");
    String passwordConfirm = request.getParameter("passwordConfirm");

    if (id.isEmpty() || username.isEmpty() || password.isEmpty() || passwordConfirm.isEmpty()) {
        out.println("모든 필드를 입력해주세요.");
        return;
    }

    if (!password.equals(passwordConfirm)) {
        out.println("비밀번호가 일치하지 않습니다.");
        return;
    }

    String hashedPassword = "";
    try {
        MessageDigest md = MessageDigest.getInstance("SHA-256");
        md.update(password.getBytes("UTF-8"));
        byte[] digest = md.digest();
        StringBuffer sb = new StringBuffer();
        for (byte b : digest) {
            sb.append(String.format("%02x", b));
        }
        hashedPassword = sb.toString();
    } catch (Exception e) {
        e.getStackTrace();
    }

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3306/hw","TK","1234");
        String sql = "INSERT INTO users (id, username, password) VALUES (?, ?, ?)";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, id);
        pstmt.setString(2, username);
        pstmt.setString(3, hashedPassword);
        int result = pstmt.executeUpdate(); // 예측 가능한 예외처리는 IF문으로 하는게 좋음. 여기서는 SELECT 문으로 라던지... 
        //try-catch는 예상 못한 예외처리가 발생한 걸 처리해주기 위함 
        
        if (result > 0) {
            out.println("회원가입이 완료되었습니다.");
            response.sendRedirect("./login.jsp");
        } else {
            out.println("회원가입에 실패하였습니다.");
        }
    } catch (SQLIntegrityConstraintViolationException e) {
        out.println("이미 존재하는 아이디입니다.");
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    }

%>
