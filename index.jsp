<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>메인 페이지</title>
</head>
<body>
    <% 
        String username = (String) session.getAttribute("username");
        if (username != null) {
    %>
        <p>안녕하세요, <%= username %>님!</p>
        <a href="logoutAction.jsp">로그아웃</a>
    <% } else { %>
        <a href="login.jsp">로그인</a>
        <a href="register.jsp">회원가입</a>
    <% } %>
    <h1>게시판</h1>
    <a href="postList.jsp">게시글 목록 보기</a>
</body>
</html>
