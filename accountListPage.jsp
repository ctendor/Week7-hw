<%@ page language="java" contentType="text/html" pageEncoding="UTF-8" %>

<%@ page import="java.sql.DriverManager" %> <%--데이터 베이스 탐색 라이브러리--%>
<%@ page import="java.sql.Connection" %><%--데이터베이스 연결 라이브러리--%>
<%@ page import="java.sql.PreparedStatement" %><%--SQL 준비 및 전송 라이브러리--%>
<%@ page import="java.sql.ResultSet" %><%--데이터베이스로부터 값 받아오기 라이브러리 --%>

<%
    //DB 통신
    Class.forName("org.mariadb.jdbc.Driver"); //Connector 파일 찾아오기 여기서 에러가 난다면, Connector파일이 없음 / DB 설치 X / DB server가 꺼져있거나

    //DB 서버 연결
    Connection connect = DriverManager.getConnection("jdbc:mariadb://localhost:3306/web","stageus","1111"); //주소, 아이디, 비밀번호
    
    //SQL 준비
    String sql = "SELECT id, name FROM account";
    PreparedStatement query = connect.prepareStatement(sql);
    
    //SQL 전송
    ResultSet result = query.executeQuery();

    //Table에 존재하는 Row의 갯수만큼 화면에 반복 출력
    //js의 createElement를 이용해서 했었음 -> 모든 페이지에 공통으로 들어가는 header나 aside에만 씀
    //jsp와 html의 스파게티 코드로 해결을 할 것. 이정도가 허용되는 스파게티 코드의 마지노선쯤 되는듯


%>

<head>

</head>

<body>
    <h1> 회원목록 </h1>
    
    <% while(result.next()) { %>
        <div>
            <span><%=result.getString("id")%></span>
            <span><%=result.getString("name")%></span>
        </div>
    <% } %>
   
</body>
