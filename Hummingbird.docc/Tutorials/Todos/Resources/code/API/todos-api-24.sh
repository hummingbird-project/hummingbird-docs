> curl -i -X DELETE http://localhost:8080/todos/7BDECA4F-3A8A-49AC-A83C-5F1C6E181253 
HTTP/1.1 200 OK
Content-Length: 0
Date: Sat, 6 Jan 2024 11:51:47 GMT

> curl -i http://localhost:8080/todos/7BDECA4F-3A8A-49AC-A83C-5F1C6E181253 
HTTP/1.1 204 No Content
Date: Sat, 6 Jan 2024 11:51:59 GMT

> curl -i -X DELETE http://localhost:8080/todos/                                    
HTTP/1.1 200 OK
Content-Length: 0
Date: Sat, 6 Jan 2024 11:52:19 GMT
