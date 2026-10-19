## 8. Веб-сервер
- **Пакет:** nginx
- **Конфигурация ресурса:** /etc/nginx/sites-available/devops-site (активна ссылка в /etc/nginx/sites-enabled/)
- **Каталог ресурса:** /var/www/devops-site (владелец: devops:devops, права: 755)
- **Сертификат:** /etc/ssl/certs/devops.crt (права: 644)
- **Закрытый ключ:** /etc/ssl/private/devops.key (владелец: root, права: 600)
- **Команда формирования сертификата:** `sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/devops.key -out /etc/ssl/certs/devops.crt -subj "/CN=devops.local" -addext "subjectAltName=DNS:devops.local"`
- **Срок действия:** 365 дней

## 9. Контейнеризация
- **Способ установки Docker Engine:** официальный репозиторий Docker (docker-ce)
- **Версия Docker:** [впиши вывод `docker --version`]
- **Участники группы docker:** devops
- **Расположение проекта на сервере:** ~/app (владелец devops)
- **Расположение файла .env и его права:** ~/app/.env (права 600)
- **Публикуемые порты и адреса:** 127.0.0.1:5000:5000 (только для локального Nginx)
- **Именованные тома:** app_db_data (для PostgreSQL)
- **Конфигурация обратного прокси-сервера:** location /app/ в /etc/nginx/sites-available/devops-site, proxy_pass http://127.0.0.1:5000/