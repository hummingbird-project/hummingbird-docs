> curl -i -X POST localhost:8080/todos -d'{"title": "Wash my hair"}'  
HTTP/1.1 201 Created
Content-Type: application/json; charset=utf-8
Content-Length: 163
Date: Mon, 9 Sep 2024 11:48:06 GMT

{"completed":false,"title":"Wash my hair","id":"7BDECA4F-3A8A-49AC-A83C-5F1C6E181253","url":"http:\/\/localhost:8080\/todos\/7BDECA4F-3A8A-49AC-A83C-5F1C6E181253"}

> curl -i -X POST localhost:8080/todos -d'{"title": "Brush my teeth"}'
HTTP/1.1 201 Created
Content-Type: application/json; charset=utf-8
Content-Length: 165
Date: Mon, 9 Sep 2024 11:48:11 GMT

{"id":"31B0FCCA-F084-4EB6-BCEF-002A00077549","title":"Brush my teeth","completed":false,"url":"http:\/\/localhost:8080\/todos\/31B0FCCA-F084-4EB6-BCEF-002A00077549"}
