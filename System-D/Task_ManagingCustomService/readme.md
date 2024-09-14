
# Task: Managing a Custom Service on Ubuntu 22.04

## demo
![Task: Managing a Custom Service on Ubuntu 22.04](custom_service.gif)

### First, we create a simple bash script for print “Hello , wold” :

```bash
#!/bin/bash

while true
do
  echo "Hello, World!"
  sleep 1
done

```

### chmod script_for_service.sh to be executable  :

```bash
chmod +x /home/ragab/embedded_linux/System-D_as_User-space_Init_process/script_for_service.sh

```

### Create a custom service file for a fictitious service called "example.service":

```bash
ragab@mint:~$ sudo systemctl edit --force --full example.service

```

**example.service File:**

```bash
[Unit]
Description=script_for_example.service
ConditionPathExists=/home/ragab/embedded_linux/System-D_as_User-space_Init_process/script_for_service.sh
ConditionFileNotEmpty=/home/ragab/embedded_linux/System-D_as_User-space_Init_process/script_for_service.sh

[Service]
ExecStartPre=/bin/echo "Starting my (script_for_service.sh) service"
ExecStartPost=/bin/echo "(script_for_service.sh) Service started successfully"
ExecStart=/home/ragab/embedded_linux/System-D_as_User-space_Init_process/script_for_service.sh
ExecReload=/home/ragab/embedded_linux/System-D_as_User-space_Init_process/script_for_service.sh
ExecStopPost=/bin/echo "(script_for_service.sh) Service stopped"
User=nobody
Group=nogroup
KillMode=process
Restart=on-failure
Type=simple

[Install]
WantedBy=multi-user.target
Alias=example.service
```

### we can also write example.service file by using vim instead

1. **Create or Edit the Service File:**
    
    ```bash
    sudo vim /etc/systemd/system/example.service
    
    ```
    
    Paste the service file content and save it.
    
2. **Reload systemd:**
    
    ```bash
    sudo systemctl daemon-reload
    
    ```
    
3. **Verify the Service File:**
    
    ```bash
    systemctl list-unit-files | grep example.service
    
    ```
    
    **output:**
    
    ```bash
    ragab@mint:~$ systemctl list-unit-files | grep example.service
    example.service                                                           disabled        enabled
    ragab@mint:~$ 
    
    ```
    
4. **Start the Service:**
    
    ```bash
    sudo systemctl start example.service
    
    ```
    
    **output:**
    
    ```bash
    ragab@mint:~$ sudo systemctl status example.service
    ● example.service - script_for_example.service
         Loaded: loaded (/etc/systemd/system/example.service; disabled; vendor preset: enabled)
         Active: active (running) since Sat 2024-09-14 04:11:32 EEST; 11min ago
       Main PID: 30518 (script_for_serv)
          Tasks: 2 (limit: 18772)
         Memory: 560.0K
            CPU: 1.806s
         CGroup: /system.slice/example.service
                 ├─30518 /bin/bash /home/ragab/embedded_linux/System-D_as_User-space_Init_process/script_for_>
                 └─39530 sleep 1
    
    Sep 14 04:22:58 mint script_for_service.sh[30518]: Hello, World!
    Sep 14 04:22:59 mint script_for_service.sh[30518]: Hello, World!
    Sep 14 04:23:00 mint script_for_service.sh[30518]: Hello, World!
    Sep 14 04:23:01 mint script_for_service.sh[30518]: Hello, World!
    Sep 14 04:23:02 mint script_for_service.sh[30518]: Hello, World!
    Sep 14 04:23:03 mint script_for_service.sh[30518]: Hello, World!
    Sep 14 04:23:04 mint script_for_service.sh[30518]: Hello, World!
    Sep 14 04:23:05 mint script_for_service.sh[30518]: Hello, World!
    Sep 14 04:23:06 mint script_for_service.sh[30518]: Hello, World!
    Sep 14 04:23:07 mint script_for_service.sh[30518]: Hello, World!
    
    ```
    
5. **Stop the Service:**
    
    ```bash
    sudo systemctl stop example.service
    
    ```
    
    **output:**
    
    ```bash
    ragab@mint:~$ sudo systemctl status example.service
    ○ example.service - script_for_example.service
         Loaded: loaded (/etc/systemd/system/example.service; disabled; vendor preset: enabled)
         Active: inactive (dead)
    
    Sep 14 04:24:00 mint script_for_service.sh[30518]: Hello, World!
    Sep 14 04:24:01 mint script_for_service.sh[30518]: Hello, World!
    Sep 14 04:24:02 mint script_for_service.sh[30518]: Hello, World!
    Sep 14 04:24:02 mint systemd[1]: Stopping script_for_example.service...
    Sep 14 04:24:02 mint echo[40237]: (script_for_service.sh) Service stopped
    Sep 14 04:24:02 mint systemd[1]: example.service: Deactivated successfully.
    Sep 14 04:24:02 mint systemd[1]: example.service: Unit process 40232 (sleep) remains running after unit s>
    Sep 14 04:24:02 mint systemd[1]: Stopped script_for_example.service.
    Sep 14 04:24:02 mint systemd[1]: example.service: Consumed 1.937s CPU time.
    Sep 14 04:24:03 mint systemd[1]: /etc/systemd/system/example.service:13: Special user nobody configured, >
    lines 1-14/14 (END)
    
    ```
    
6. **Restart the Service:**
    
    ```bash
    sudo systemctl restart example.service
    
    ```
    
    **output:**
    
    ```bash
    ragab@mint:~$ sudo systemctl status example.service
    ● example.service - script_for_example.service
         Loaded: loaded (/etc/systemd/system/example.service; disabled; vendor preset: enabled)
         Active: active (running) since Sat 2024-09-14 04:24:40 EEST; 4s ago
        Process: 40685 ExecStartPre=/bin/echo Starting my (script_for_service.sh) service (code=exited, statu>
        Process: 40687 ExecStartPost=/bin/echo (script_for_service.sh) Service started successfully (code=exi>
       Main PID: 40686 (script_for_serv)
          Tasks: 2 (limit: 18772)
         Memory: 556.0K
            CPU: 18ms
         CGroup: /system.slice/example.service
                 ├─40686 /bin/bash /home/ragab/embedded_linux/System-D_as_User-space_Init_process/script_for_>
                 └─40725 sleep 1
    
    Sep 14 04:24:40 mint systemd[1]: Starting script_for_example.service...
    Sep 14 04:24:40 mint echo[40685]: Starting my (script_for_service.sh) service
    Sep 14 04:24:40 mint echo[40687]: (script_for_service.sh) Service started successfully
    Sep 14 04:24:40 mint systemd[1]: Started script_for_example.service.
    Sep 14 04:24:40 mint script_for_service.sh[40686]: Hello, World!
    Sep 14 04:24:41 mint script_for_service.sh[40686]: Hello, World!
    Sep 14 04:24:42 mint script_for_service.sh[40686]: Hello, World!
    Sep 14 04:24:43 mint script_for_service.sh[40686]: Hello, World!
    Sep 14 04:24:44 mint script_for_service.sh[40686]: Hello, World!
    lines 1-22/22 (END)
    
    ```
    
7. **Check the Status:**
    
    ```bash
    sudo systemctl status example.service
    
    ```
    
    **output:**
    
    ```bash
    ragab@mint:~$ sudo systemctl status example.service
    ● example.service - script_for_example.service
         Loaded: loaded (/etc/systemd/system/example.service; disabled; vendor preset: enabled)
         Active: active (running) since Sat 2024-09-14 04:24:40 EEST; 48s ago
        Process: 40685 ExecStartPre=/bin/echo Starting my (script_for_service.sh) service (code=exited, statu>
        Process: 40687 ExecStartPost=/bin/echo (script_for_service.sh) Service started successfully (code=exi>
       Main PID: 40686 (script_for_serv)
          Tasks: 2 (limit: 18772)
         Memory: 556.0K
            CPU: 102ms
         CGroup: /system.slice/example.service
                 ├─40686 /bin/bash /home/ragab/embedded_linux/System-D_as_User-space_Init_process/script_for_>
                 └─41290 sleep 1
    
    Sep 14 04:25:19 mint script_for_service.sh[40686]: Hello, World!
    Sep 14 04:25:20 mint script_for_service.sh[40686]: Hello, World!
    Sep 14 04:25:21 mint script_for_service.sh[40686]: Hello, World!
    Sep 14 04:25:22 mint script_for_service.sh[40686]: Hello, World!
    Sep 14 04:25:23 mint script_for_service.sh[40686]: Hello, World!
    Sep 14 04:25:24 mint script_for_service.sh[40686]: Hello, World!
    Sep 14 04:25:25 mint script_for_service.sh[40686]: Hello, World!
    Sep 14 04:25:26 mint script_for_service.sh[40686]: Hello, World!
    Sep 14 04:25:27 mint script_for_service.sh[40686]: Hello, World!
    Sep 14 04:25:28 mint script_for_service.sh[40686]: Hello, World!
    
    ```
    
8. **Enable the Service to Start on Boot:**
    
    ```bash
    sudo systemctl enable example.service
    
    ```
    
    **output:**
    
    ```bash
    ragab@mint:~$ sudo systemctl enable  example.service
    Failed to enable unit: File /etc/systemd/system/example.service already exists.
    ragab@mint:~$ 
    
    ```
    
9. **Verify the Service is Enabled:**
    
    ```bash
    systemctl is-enabled example.service
    
    ```
    
    **output:**
    
    ```bash
    ragab@mint:~$ systemctl is-enabled example.service
    enabled
    ragab@mint:~$ 
    
    ```
    
10. **Disable the Service from Starting on Boot:**
    
    ```bash
    sudo systemctl disable example.service
    
    ```
    
    **output:**
    
    ```bash
    ragab@mint:~$ sudo systemctl disable example.service
    Removed /etc/systemd/system/multi-user.target.wants/example.service.
    ragab@mint:~$ 
    ```
    
11. **Confirm the Service is Disabled:**
    
    ```bash
    systemctl is-enabled example.service
    
    ```
    
    **output:**
    
    ```bash
    ragab@mint:~$ systemctl is-enabled example.service
    disabled
    ragab@mint:~$ 
    
    ```