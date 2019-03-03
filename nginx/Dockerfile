FROM nginx:1.13.12

RUN rm /etc/nginx/conf.d/default.conf
ADD ./nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]