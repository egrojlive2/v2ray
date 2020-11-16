# multi-v2ray
Una Herramienta Para Administrar v2ray config json, soporta multiples usuarios && groupos manage  
![](https://img.shields.io/pypi/v/v2ray-util.svg) 
![](https://img.shields.io/docker/pulls/jrohy/v2ray.svg)
![](https://img.shields.io/github/stars/Jrohy/multi-v2ray.svg) 
![](https://img.shields.io/github/forks/Jrohy/multi-v2ray.svg) 
![](https://img.shields.io/github/license/Jrohy/multi-v2ray.svg)

## [Spanish](README_EN.md)

## Mejoras
- V2ray && Iptables Traffic Statistics
- Command line to manage
- Multiple user && port manage
- Cloudcflare cdn mode
- Support pure ipv6 VPS
- Support Docker
- Dynamic port
- Ban bittorrent
- Range port
- TcpFastOpen
- Vmess/Socks5/MTproto Compartir link
- Support protocol modify:
  - TCP
  - Fake http
  - WebSocket
  - mkcp
  - mKCP + srtp
  - mKCP + utp
  - mKCP + wechat-video
  - mKCP + dtls
  - mKCP + wireguard
  - HTTP/2
  - Socks5
  - MTProto
  - Shadowsocks
  - Quic
  - VLESS
  - VLESS_XTLS
  - Trojan

## Metodo De Uso
nueva instalacion
```
source <(curl -sL https://multi.netlify.app/v2ray.sh)
```

actualizar los archivos
```
source <(curl -sL https://multi.netlify.app/v2ray.sh) -k
```

remover y limpiar
```
source <(curl -sL https://multi.netlify.app/v2ray.sh) --remove
```

## Linea De Comandos
```bash
v2ray [-h|--help] [options]
    -h, --help           Mostrar Ayuda De Comandos
    -v, --version        Obtener Version
    start                Iniciar Servicio V2Ray
    stop                 Detener Servicio V2Ray
    restart              Reiniciar Servicio V2Ray
    status               Obtener El StatusV2Ray
    new                  Crear Un Nuevo Json Documento
    update               Actualizar v2ray A La Siguiente Version
    update.sh            Actualizar multi-v2ray A La Siguiente Version
    add                  Crear Random mkcp + (srtp|wechat-video|utp|dtls|wireguard) fake header group
    add [wechat|utp|srtp|dtls|wireguard|socks|mtproto|ss]     Crear Protocolo Especial, Puerto Random nuevo
    del                  Eliminar Puerto Grupo
    info                 Obtener v2ray Link
    port                 Modificar Puerto port
    tls                  Modificar Tls
    tfo                  Modificar tcpFastOpen
    stream               Modificar protocolo
    cdn                  cdn modo
    stats                v2ray traffic statistics
    iptables             iptables traffic statistics
    clean                Eliminar v2ray log
    log                  Mostrar v2ray log
```

## Docker Run
Configuracion Default Con Puerto Random + random header(srtp | wechat-video | utp | dtls) kcp profile  
```
docker run -d --name v2ray --privileged --restart always --network host jrohy/v2ray
```

custom v2ray config.json:
```
docker run -d --name v2ray --privileged -v /path/config.json:/etc/v2ray/config.json --restart always --network host jrohy/v2ray
```

check v2ray profile:
```
docker exec v2ray bash -c "v2ray info"
```

**warning**: if u run with centos, u should close firewall first
```
systemctl stop firewalld.service
systemctl disable firewalld.service
```

## Dependent
docker: https://hub.docker.com/r/jrohy/v2ray  
pip: https://pypi.org/project/v2ray-util/  
python3: https://github.com/Jrohy/python3-install  
acme: https://github.com/Neilpang/acme.sh
