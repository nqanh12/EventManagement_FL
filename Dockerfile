# Sử dụng hình ảnh Nginx làm server
FROM nginx:alpine

# Sao chép nội dung Flutter Web build vào thư mục Nginx
COPY build/web /usr/share/nginx/html

# Expose cổng 80
EXPOSE 80

# Khởi chạy Nginx
CMD ["nginx", "-g", "daemon off;"]
