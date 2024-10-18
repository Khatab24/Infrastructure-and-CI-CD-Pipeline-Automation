FROM nginx:alpine


COPY ./RedStore /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
