<%@ page language="java" contentType="text/html" pageEncoding="UTF-8" %>

<%@ page import="java.sql.DriverManager" %> <%--데이터 베이스 탐색 라이브러리--%>
<%@ page import="java.sql.Connection" %><%--데이터베이스 연결 라이브러리--%>
<%@ page import="java.sql.PreparedStatement" %><%--SQL 준비 및 전송 라이브러리--%>

<%
    request.setCharacterEncoding("UTF-8");
    String idValue = request.getParameter("id");
    String pwValue = request.getParameter("pw");
    String nameValue = request.getParameter("name");

    //DB 통신
    Class.forName("org.mariadb.jdbc.Driver"); //Connector 파일 찾아오기 여기서 에러가 난다면, Connector파일이 없음 / DB 설치 X / DB server가 꺼져있거나

    //DB 서버 연결
    Connection connect = DriverManager.getConnection("jdbc:mariadb://localhost:3306/web","stageus","1234"); //주소, 아이디, 비밀번호
    
    //SQL 준비
    String sql = "INSERT INTO account(id, password, name) VALUES(?, ?, ?)";
    PreparedStatement query = connect.prepareStatement(sql);
    query.setString(1, idValue);
    query.setString(2, pwValue);
    query.setString(3, nameValue);

    //SQL 전송
    query.executeUpdate();

%>

<script>
    alert("회원가입에 성공하였습니다!")
    location.href = "./index.jsp";
</script>