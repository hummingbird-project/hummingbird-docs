> curl -i -X PATCH http://localhost:8080/todos/31B0FCCA-F084-4EB6-BCEF-002A00077549 -d '{"completed": true}'
HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8
Content-Length: 164
Date: Sat, 6 Jan 2024 11:50:01 GMT

{"title":"Brush my teeth","completed":true,"url":"http:\/\/localhost:8080\/todos\/31B0FCCA-F084-4EB6-BCEF-002A00077549","id":"31B0FCCA-F084-4EB6-BCEF-002A00077549"}

> curl -i http://localhost:8080/todos/
HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8
Content-Length: 330
Date: Sat, 6 Jan 2024 11:50:26 GMT

[{"completed":true,"url":"http:\/\/localhost:8080\/todos\/31B0FCCA-F084-4EB6-BCEF-002A00077549","id":"31B0FCCA-F084-4EB6-BCEF-002A00077549","title":"Brush my teeth"},{"completed":false,"url":"http:\/\/localhost:8080\/todos\/7BDECA4F-3A8A-49AC-A83C-5F1C6E181253","title":"Wash my hair","id":"7BDECA4F-3A8A-49AC-A83C-5F1C6E181253"}]

