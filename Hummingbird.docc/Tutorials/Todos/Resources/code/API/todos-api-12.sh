> curl -i -X POST localhost:8080/todos -d'{"title": "Read chapter on testing applications"}'
HTTP/1.1 201 Created
Content-Type: application/json; charset=utf-8
Content-Length: 187
Date: Sat, 6 Jan 2024 10:02:08 GMT

{"completed":false,"id":"284DC153-4FE9-458D-8A93-6CB60990B2F3","url":"http:\/\/localhost:8080\/todos\/284DC153-4FE9-458D-8A93-6CB60990B2F3","title":"Read chapter on testing applications"}