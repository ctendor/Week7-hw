<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>회원가입</title>
</head>
<body>
    <form action="registerAction.jsp" method="post">
        아이디: <input type="text" name="id" required><br>
        사용자 이름: <input type="text" name="username" required><br>
        비밀번호: <input type="password" name="password" required><br>
        비밀번호 확인: <input type="password" name="passwordConfirm" required><br>
        <input type="submit" value="회원가입">
    </form>
</body>
</html>
