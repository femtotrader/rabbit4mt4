curl -i -H "Content-Type: application/json" -X POST -d '{"jsonrpc": "2.0", "method": "AccountHistory", "params": ["-1"], "id": "f9ae6397-d436-4147-b834-de3d33101ca0"}' http://127.0.0.1:5000/api/v1/rpc/mt4_demo01_123456

pause
REM http://curl.haxx.se/download.html
REM http://www.confusedbycode.com/curl/