#!/usr/bin/env python3

import http.server
import socketserver
import io

PORT = 8080


class SimpleHttpRequestHandler(http.server.BaseHTTPRequestHandler):

  def do_HEAD(self):
    self.send_response(200)
    self.end_headers()

  # GET files only
  def do_GET(self):
    h = "User-Agent"
    print(h, self.headers[h])
    fname = self.path.strip('/')
    try:
      f = open(fname, 'r')
      filedata = str.encode(f.read())
      f.close()
    except:
      self.send_response(404)
      self.end_headers()
      #self.wfile.write("404")
      return
    self.send_response(200)
    self.end_headers()
    self.wfile.write(filedata)

  # POST files only
  def do_POST(self):
    h = "User-Agent"
    print(h, self.headers[h])
    content_length = int(self.headers['Content-Length'])
    print(self.path)
    body = self.rfile.read(content_length)
    #print(body)
    fname = self.path.strip('/')
    try:
      f = open(fname, 'w')
      f.write(body.decode())
      f.close()
    except:
      self.send_response(404)
      self.end_headers()
      return
    self.send_response(200)
    self.end_headers()
    response = io.BytesIO()
    response.write(b'Saved file. ')
    #response.write(b'Received: ')
    #Eresponse.write(body)
    self.wfile.write(response.getvalue())

#-------------------------------------------------------------------

httpd = http.server.HTTPServer(('', PORT), SimpleHttpRequestHandler)
httpd.serve_forever()
