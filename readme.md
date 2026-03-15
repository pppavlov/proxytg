# proxytg

Docker-репозиторий для запуска Telegram MTProto proxy на базе `mtg`.

## Быстрый старт

1. Подготовить `.env`:

```bash
cp .env.example .env
```

2. Поднять прокси:

```bash
./scripts/up.sh
```

3. Получить ссылку для Telegram:

```bash
cat access.txt
```

## Что внутри

- `docker-compose.yml` - сервис `mtg-proxy`
- `.env.example` - переменные окружения
- `scripts/render-config.sh` - генерация `MTG_SECRET` и `config.toml`
- `scripts/up.sh` - подготовка + запуск
- `scripts/down.sh` - остановка
- `scripts/logs.sh` - логи
- `scripts/print-links.sh` - генерация `tg://` и `https://t.me/proxy` ссылок

## Переменные в `.env`

- `MTG_IMAGE` - Docker image (по умолчанию `nineseconds/mtg:2`)
- `MTG_HOST_PORT` - внешний порт на сервере (по умолчанию `3443`)
- `MTG_BIND_PORT` - порт внутри контейнера (по умолчанию `3128`)
- `MTG_FAKE_TLS_DOMAIN` - домен для маскировки TLS (по умолчанию `cloudflare.com`)
- `MTG_SECRET` - секрет прокси (если пусто, будет сгенерирован автоматически)
- `PUBLIC_HOST` - внешний IP/домен сервера для генерации ссылки (если пусто, будет попытка автоопределения)

## Управление

```bash
./scripts/up.sh
./scripts/logs.sh
./scripts/down.sh
```

или напрямую:

```bash
docker compose up -d
docker compose logs -f --tail=100 mtg-proxy
docker compose down
```

## Проверка

```bash
docker compose ps
ss -lnt | grep -E ":3443|:443" || true
cat access.txt
```

## Важно про порт 443

На этом сервере `443` уже занят, поэтому по умолчанию используется `3443`.
Если хотите перевести прокси на `443`, освободите порт и поменяйте в `.env`:

```bash
MTG_HOST_PORT=443
```

после чего перезапустите:

```bash
./scripts/up.sh
```

## Безопасность (минимум)

- Используйте SSH-ключи и отключите парольный вход `root`.
- Откройте в firewall только нужный порт прокси и `22/tcp`.
- Периодически ротируйте `MTG_SECRET` и перезапускайте прокси.
