upstream puma {
  server unix:///home/deploy/apps/ruby_hello/shared/tmp/sockets/ruby_hello-puma.sock;
}

server {
  listen 80 default_server deferred;
  # server_name example.com;

  root /home/deploy/apps/ruby_hello/current/public;
  access_log /home/deploy/apps/ruby_hello/current/log/nginx.access.log;
  error_log /home/deploy/apps/ruby_hello/current/log/nginx.error.log info;

  location ^~ /assets/ {
    gzip_static on;
    expires max;
    add_header Cache-Control public;
  }

  try_files $uri/index.html $uri @puma;
  location @puma {
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_redirect off;

    proxy_pass http://puma;
  }

  error_page 500 502 503 504 /500.html;
  client_max_body_size 10M;
  keepalive_timeout 10;
}