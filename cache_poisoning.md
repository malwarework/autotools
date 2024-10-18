# Web Cache poisoning
Заголовок `X-Cache-Status` сигнализирует о том, что в приложении используется кэш

## Примеры настройки ключа кэширования
- `proxy_cache_key $scheme$proxy_host$uri$arg_language;` кэшируется только параметр `language` запроса
- `proxy_cache_key $scheme$proxy_host$uri$args;` кэшируются все параметры запроса

## Cache bypass
Установить в запросе один из заголовков:
- `Cache-Control: no-cache`
- `Pragma: no-cache`

## Tools
[Web Cache Vulnerability Scanner](https://github.com/Hackmanit/Web-Cache-Vulnerability-Scanner)