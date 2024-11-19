<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    request.setCharacterEncoding("UTF-8");
    HttpSession loginSession = request.getSession();
    loginSession.removeAttribute("username");
    response.sendRedirect("index.jsp");
%>