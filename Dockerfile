#FROM kong:alpine
from revomatico/docker-kong-oidc


## Change user to perform privileged actions
USER root

LABEL description="Kong + kong-oidc + jwt-keycloak + redis-cache plugin"

    
######################[make paths]######################  
ENV LOCAL_PATH="/usr/local/kong"



######################[default]######################  
RUN apk update && apk add git unzip luarocks



######################[jwt-keycloak]######################  
ENV JWT_PLUGIN_VERSION=1.1.0-1

RUN luarocks install --pin lua-resty-jwt

RUN git clone https://github.com/BGaunitz/kong-plugin-jwt-keycloak.git --branch 20200505-access-token-processing ${LOCAL_PATH}/plugin/jwt-keycloak \
 && cd ${LOCAL_PATH}/plugin/jwt-keycloak \
 && luarocks make 

RUN luarocks pack kong-plugin-jwt-keycloak ${JWT_PLUGIN_VERSION} \
 && luarocks install kong-plugin-jwt-keycloak-${JWT_PLUGIN_VERSION}.all.rock


######################[Cache]######################  
RUN git clone https://github.com/globocom/kong-plugin-proxy-cache ${LOCAL_PATH}/plugin/kong-plugin-proxy-cache \
    && cd ${LOCAL_PATH}/plugin/kong-plugin-proxy-cache \
    && luarocks make *.rockspec

RUN luarocks install kong-plugin-proxy-cache


ENV KONG_PLUGINS="bundled,oidc,jwt-keycloak,proxy-cache"


RUN chmod -R 777 /usr/local/kong

## Revert to the original non-root user
USER kong