# piTurtle
automatic open remote shell on an internal network with raspberryPI

# need
 - stunnel 
 - ssh 
 - vps or server on internet
 - raspberry
 
# subject
Create a stunnel connection (ssl 443) to the a server on internet and the open a remote shell inside the stunnel connection with SSH.

# stunnel
install stunnel4 on both rpi and server
```# sudo apt-get update
sudo apt-get install stunnel4
```

##### Configure server side (server)  

enable service  
```
sudo nano /etc/default/stunnel4
```
> ENABLE=1


Generate certificat
```
cd /etc/stunnel
openssl genrsa -out KeyServer.key 2048
openssl req -new -key KeyServer.key -out certif.csr
openssl x509 -req -days 3650 -in certif.csr -signkey KeyServer.key -out certserver.crt
cat KeyServer.key certserver.crt > server.pem
```

configure stunnel.conf
```
mv stunnel.conf stunnel.conf.bkp
nano stunnel.conf
```
>; It is recommended to drop root privileges if stunnel is started by root  
>chroot = /var/lib/stunnel4/  
>setuid = stunnel4  
>setgid = stunnel4  
>  
>; PID file is created inside the chroot jail (if enabled)  
>pid = /stunnel.pid  
>; pid = /stunnel.pid  
>  
>; Debugging stuff (may be useful for troubleshooting)  
>foreground = yes  
>debug = debug  
>output = /var/log/stunnel4/stunnel.log  
>  
>; TLS front-end to a web server  
>[https]  
>accept  = 443  
>connect = 7515  
>cert=/etc/stunnel/server.pem  
>key=/etc/stunnel/keyServer.key  

will create a HTTPS service on port 443  

view of the chroot   
>cd /var/lib/stunnel4/  
>/var/lib/stunnel4$ tree  
>.  
>├── stunnel.pid  
>└── var  
>    ├── log  
>    │   └── stunnel4  
>    │       └── stunnel.log  
>    └── run  
>  
>4 directories, 2 files  


Start stunnel on boot service  
```
chkconfig stunnel4 on  
/etc/init.d/stunnel4 start  
```

check port (normally 443 is up)
```
sudo netstat -tanlp | grep stunnel
```


##### Configure rpi side (client)  

upload server.pem on /etc/stunnel/  

```
sudo nano /etc/stunnel/stunnel.conf
```
>debug = info  
>output = /var/log/stunnel.log  
>  
>cert = /etc/stunnel/server.pem  
>pid = /var/run/stunnel.pid  
>client = yes  
>  
>[ssh]  
>accept = 127.0.0.1:2222  
>connect = <Ip or domain>:443  

Start stunnel  
```
stunnel /etc/stunnel/stunnel.conf
```

Check if stunnel is up  
```
sudo netstat -tanlp | grep stunnel  
```

now SSH is listen on 2222 and go up stunnel  


# Create reverse shell \o/

##### On the rpi
Create a user and a ssh key on RPI  
```
useradd remote  
cd /home/remote/.ssh/  
ssh-keygen -f remote -P ""  
```

2 files is created (private (remote) key stay on the RPI and remote.pub to DL on the server)

##### On the server 
```
useradd remote  
```
copy remote.pub in /home/remote/.ssh/ 


##### On the rpi
start ssh reverse shell
```
ssh -i /home/remote/.ssh/remote -R 2201:localhost:22 -p 2222 remote@localhost -f -N
```

and normally on the server a port is open localhost:2201 and you can ssh to it  

>netstat -tanlp | grep 2201  
>tcp        0      0 127.0.0.1:2201          0.0.0.0:*               LISTEN      >24227/sshd: remote  





