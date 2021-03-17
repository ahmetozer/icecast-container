#!/bin/bash

port_regex="^((6553[0-5])|(655[0-2][0-9])|(65[0-4][0-9]{2})|(6[0-4][0-9]{3})|([1-5][0-9]{4})|([1-9][0-9]{3})|([1-9][0-9]{2})|([1-9][0-9])|([1-9]))$"

# Colors
cl_red='\033[0;31m'
cl_nc='\033[0m'
cl_cy='\e[36m'
cl_wh='\e[97m'
cl_lm='\e[95m'
cl_lg='\e[92m'

admin=${admin-"admin"}
if [ -z "$admin_password" ]; then
    admin_password=$(tr </dev/urandom -dc A-Za-z0-9 | head -c${1:-16})
    echo -e "\tAdmin user is '${cl_cy}$admin${cl_nc}' and password is:\t${cl_lg}${admin_password}${cl_nc}"
else
    echo -e "\tAdmin user is '${cl_cy}$admin${cl_nc}' and password is specified by user:\t${cl_lg}${admin_password:0:2}...${admin_password:$((${#admin_password}-2))}${cl_nc}"
fi

if [ -z "$authentication_source_password" ]; then
    authentication_source_password=$(tr </dev/urandom -dc A-Za-z0-9 | head -c${1:-16})
    echo -e "\t${cl_cy}authentication_source_password${cl_nc} password is:\t\t${cl_lg}${authentication_source_password}${cl_nc}"
else
    echo -e "\t${cl_cy}authentication_source_password${cl_nc} password is specified by user:\t${cl_lg}${authentication_source_password:0:2}***${authentication_source_password:$((${#authentication_source_password}-2))}${cl_nc}"
fi

if [ -z "$authentication_relay_password" ]; then
    authentication_relay_password=$(tr </dev/urandom -dc A-Za-z0-9 | head -c${1:-16})
    echo -e "\t${cl_cy}authentication_relay_password${cl_nc} password is:\t${cl_lg}${authentication_relay_password}${cl_nc}"
else
    echo -e "\t${cl_cy}authentication_relay_password${cl_nc} password is specified by user:\t${cl_lg}${authentication_relay_password:0:2}***${authentication_relay_password:$((${#authentication_relay_password}-2))}${cl_nc}"
fi

port=${port-"8000"}
if [[ "$port" =~ $port_regex ]]; then
    if (lsof -i :$port | grep TCP); then
        echo -e "${cl_red}Port already usage. Please select another port.${cl_nc}"
        exit 1
    else
        echo -e "\tSelected port is $port/tcp"
    fi
else
    echo -e "${cl_red}Port is must be between 0-65535${cl_nc}"
    exit 1
fi
limits_clients=${limits_clients-"100"}
limits_sources=${limits_sources-"2"}
bind_address=${bind_address-'::'}
echo -e "\tlimits_clients $limits_clients
\tlimits_sources $limits_sources
\tbind_address $bind_address"



cat <<EOF > /etc/icecast.xml
<icecast>
    <location>Earth</location>
    <admin>$admin</admin>
    <limits>
        <clients>$limits_clients</clients>
        <sources>$limits_sources</sources>
        <queue-size>524288</queue-size>
        <client-timeout>30</client-timeout>
        <header-timeout>15</header-timeout>
        <source-timeout>10</source-timeout>
        <burst-on-connect>1</burst-on-connect>
        <burst-size>65535</burst-size>
    </limits>

    <authentication>
        <source-password>$authentication_source_password</source-password>
        <relay-password>$authentication_relay_password</relay-password>

        <!-- Admin logs in with the username given below -->
        <admin-user>$admin</admin-user>
        <admin-password>$admin_password</admin-password>
    </authentication>

    <hostname>$HOSTNAME</hostname>
    <listen-socket>
        <port>$port</port>
        <bind-address>$bind_address</bind-address>
    </listen-socket>

    <http-headers>
        <header name="Access-Control-Allow-Origin" value="*" />
    </http-headers>
    <fileserve>1</fileserve>

    <paths>
        <basedir>/usr/share/icecast</basedir>
        <logdir>/var/log/icecast</logdir>
        <webroot>/usr/share/icecast/web</webroot>
        <adminroot>/usr/share/icecast/admin</adminroot>
        <alias source="/" destination="/status.xsl"/>
    </paths>

    <logging>
        <accesslog>access.log</accesslog>
        <errorlog>error.log</errorlog>
        <loglevel>3</loglevel> <!-- 4 Debug, 3 Info, 2 Warn, 1 Error -->
        <logsize>1000</logsize> <!-- Max size of a logfile -->
    </logging>

    <security>
        <chroot>0</chroot>
        <changeowner>
            <user>icecast</user>
            <group>icecast</group>
        </changeowner>
    </security>
</icecast>
EOF


exit_trap() {
    echo -e "\t${cl_lg}Stream server is closing${cl_nc}"
    PGID=$(ps -o pgid= $$ | tr -d \ )
    kill -TERM -$PGID 2>/dev/null

    echo -e "${cl_red}Server is closed${cl_nc}"
    exit 0
}
trap exit_trap INT EXIT
#Start icecast
icecast -c /etc/icecast.xml &
icecast_pid=$!
wait $icecast_pid
if [ $? -eq 1 ]; then
    echo -e "${cl_red}\tIcecast shutdown is not done in gracefully${cl_nc}"
    exit 1
fi