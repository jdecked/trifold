FROM nginx:1.13.12

RUN rm /etc/nginx/conf.d/default.conf
ADD ./nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
ENTRYPOINT ["nginx","-g","daemon off;"]