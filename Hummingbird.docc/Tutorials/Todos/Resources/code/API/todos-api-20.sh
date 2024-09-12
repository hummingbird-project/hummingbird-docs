> curl -i -X PATCH http://localhost:8080/todos/31B0FCCA-F084-4EB6-BCEF-002A00077549 -d '{"completed": true}'
HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8
Content-Length: 164
Date: Mon, 9 Sep 2024 11:50:01 GMT

{"title":"Brush my teeth","completed":true,"url":"http:\/\/localhost:8080\/todos\/31B0FCCA-F084-4EB6-BCEF-002A00077549","id":"31B0FCCA-F084-4EB6-BCEF-002A00077549"}