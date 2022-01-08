#!/usr/bin/env python3

import io
import http.server
import os
import socketserver
#import sys

PORT = 8484


class SimpleHttpRequestHandler(http.server.BaseHTTPRequestHandler):

  def do_HEAD(self):
    self.send_response(200)
    self.end_headers()

  def do_DELETE(self):
    fname = self.path.strip('/')
    if os.path.exists(fname):
      os.remove(fname)
      self.send_response(200)
    else:
      self.send_response(404)
    self.end_headers()

  def do_GET(self):
    fname = self.path.strip('/')
    try:
      f = open(fname, 'r')
      filedata = str.encode(f.read())
      f.close()
      self.send_response(200)
      self.end_headers()
      self.wfile.write(filedata)
    except:
      self.send_response(404)
      self.end_headers()

  def do_POST(self):
    content_length = int(self.headers['Content-Length'])
    body = self.rfile.read(content_length)
    fname = self.path.strip('/')
    response = io.BytesIO()
    try:
      f = open(fname, 'w')
      f.write(body.decode())
      f.close()
      self.wfile.write(response.getvalue())
      response.write(b'Saved file. ')
      self.send_response(200)
    except:
      self.send_response(404)
    self.end_headers()

#---------------------------------------

#sys.stdout = open('PDTimer.log', 'w')
#sys.stderr = open('PDTimer.loge', 'w')

httpd = http.server.HTTPServer(('', PORT), SimpleHttpRequestHandler)
httpd.serve_forever()
