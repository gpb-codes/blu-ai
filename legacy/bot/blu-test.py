import json
from http.server import HTTPServer, BaseHTTPRequestHandler

class H(BaseHTTPRequestHandler):
    def do_POST(self):
        resp = json.dumps({"answer": "hola desde Blu"}).encode()
        self.send_response(200)
        self.send_header("Content-Type","application/json")
        self.send_header("Content-Length", len(resp))
        self.end_headers()
        self.wfile.write(resp)
    def log_message(self, *a): pass

HTTPServer(("0.0.0.0", 5051), H).serve_forever()