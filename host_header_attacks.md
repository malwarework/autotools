# Override Headers
- X-Forwarded-Host
- X-HTTP-Host-Override
- Forwarded
- X-Host
- X-Forwarded-Server

## SSRF bypass
- Decimal encoding: `2130706433`
- Hex encoding: `0x7f000001`
- Octal encoding: `0177.0000.0000.0001`
- Zero: `0`
- Short form: `127.1`
- IPv6: `::1`
- IPv4 address in IPv6 format: `[0:0:0:0:0:ffff:127.0.0.1]` or `[::ffff:127.0.0.1]`
- External domain that resolves to localhost: `localtest.me`