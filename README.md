*******start*********

#скачиваем Vagrantfile

           git clone https://github.com/MaximMiklyaev/BASH.git

#переходим в директорию:

           cd /BASH

#запускаем образ

           vagrant up

#начнем с установки веб-сервера

#ДЗ

#результаты ДЗ в файлах root otchet.txt access.log собираемая информация

#для начала развернем веб-сервер nginx (порядок развёртывания в пункте #1)

#для выполднения ДЗ необходимо три скрипта.

#переносим скрипты 0pochta.sh pochta.sh skripts.sh в 

            /var/log/nginx/

#даём права

            chmod +x /var/log/nginx/pochta.sh
            chmod +x /var/log/nginx/skripts.sh
            chmod +x /var/log/nginx/0pochta.sh

#даем выполнения каждые пять минут 0pochta.sh каждый час pochta.sh

            export EDITOR=nano

            crontab -e

            */5 * * * * /var/log/nginx/0pochta.sh
            0 * * * * /var/log/nginx/pochta.sh

#полезные команды

            дополнительно 
            mkfifo /var/spool/postfix/public/pickup
            sudo yum install postfix telnet mailx
            systemctl restart postfix.service

            проверка почты
            mailx root@localhost - написать письмо 
            ctrl+d - отправить
            mail - просмотр что присылается 
            nano /var/spool/mail/root - просмотр что присылается 
            rm /var/spool/mail/root - удаление истории

            если удалили /var/log/nginx/access.log
            > access.log
            chmod 0777 access.log


#скрипт-1

            0pochta.sh -защита от мультизапуска

#вывод скрипта

            #!/bin/bash
            
            LOCKFILE=/var/log/nginx/pochta.sh
            if [ -f $LOCKFILE ]
            then
              echo "Lockfile active, no new runs."
              exit 1 
            else
              echo "PID: $$" > $LOCKFILE
              trap 'rm -f $LOCKFILE"; exit $?' INT TERM EXIT
              echo "Simulate some activity..."
              rm -f $LOCKFILE
              trap - INT TERM EXIT
            fi

#скрипт-2

            pochta.sh скрипт производит  поиск и запуск скрипта skripts.sh и отправляет его вывод на почту root-пользователя
            его размешаем /var/log/nginx/

#вывод скрипта

            #!/bin/bash
            if
            find / -name skripts.sh -exec {} \; > otchet.txt &&
            mailx root@localhost < otchet.txt &&
            rm otchet.txt access.log
            
            then
            exit 0
            else 
            echo "file not found"
            fi

#скрипт-3

            skripts.sh исполнительный скрипт
            его размешаем /var/log/nginx/

#вывод скрипта

            #!/bin/bash
            echo "Временной диапазон":
            cat /var/log/nginx/access.log | awk '{print $4}' | head -n 1 &&  date | awk '{print $2,$3,$4,$6}' &&
            
            #1
            echo "Топ-10 клиентских URL запрашиваемых с этого сервера"
            cat /var/log/nginx/access.log | awk '{print $7}' | sort | uniq -c | sort -rn | head -n 10 > 1.1.txt && cat 1.1.txt &&
            echo "------------------------------------------------------" 
            #2
            echo "Топ-10 клиентских IP"
            cat /var/log/nginx/access.log | awk '{print $1}' | sort | uniq -c | sort -rn | head -n 10 > 2.2.txt && tail -n 10 2.2.txt &&
            echo "------------------------------------------------------"
            #3
            echo "Все коды состояния HTTP и их количество"
            cat /var/log/nginx/access.log | awk '{print $9}'| grep -v "-" | sort | uniq -c | sort -rn > 3.3.txt && cat 3.3.txt && 
            echo "------------------------------------------------------" 
            #4
            echo "Все коды состояния  4xx и 5xx"
            cat /var/log/nginx/access.log | awk '{print $9}' | grep ^4 > 4.4.txt && cat /var/log/nginx/access.log | awk '{print $9}'  | grep ^5 >> 4.4.txt && cat 4.4.txt | uniq -d -c | sort -rn > 4.5.txt && cat 4.5.txt &&
            echo "------------------------------------------------------"
            echo "all"
            rm -f 1.1.txt 2.2.txt 3.3.txt 4.4.txt 4.5.txt


*****разварачиваем веб сервер********

#1 вводим команды установки
            
            sudo -i
            yum install -y mdadm smartmontools hdparm gdisk
            yum install -y redhat-lsb-core
            yum install -y rpmdevtools
            yum install -y rpm-build
            yum install -y createrepo
            yum install -y yum-utils
            yum install -y pcre-devel
            yum install -y gcc
            wget https://nginx.org/packages/centos/8/SRPMS/nginx-1.18.0-2.el8.ngx.src.rpm
            rpm -i nginx-1.18.0-2.el8.ngx.src.rpm
            wget https://www.openssl.org/source/latest.tar.gz
            tar -xvf latest.tar.gz
            cd /root/
            yum-builddep -y rpmbuild/SPECS/nginx.spec 


#Vagrantfile поднимает VM

#подключаемся к созданной VM

           vagrant ssh

#далее заходим под SU

     sudo -i

#начинаем настройку spec файл чтоб NGINX собирался с необходимыми нам опциями 
          	
          nano /root/rpmbuild/SPECS/nginx.spec

#нажимаем

          ctrl+w  для поиска вводим %build

#вывод 

         %build
         ./configure %{BASE_CONFIGURE_ARGS} \
             --with-cc-opt="%{WITH_CC_OPT}" \
             --with-ld-opt="%{WITH_LD_OPT}" \
             --with-debug
         make %{?_smp_mflags}
         %{__mv} %{bdir}/objs/nginx \
             %{bdir}/objs/nginx-debug
         ./configure %{BASE_CONFIGURE_ARGS} \
             --with-cc-opt="%{WITH_CC_OPT}" \
             --with-ld-opt="%{WITH_LD_OPT}"
         make %{?_smp_mflags}

#приводим к такому виду

          %build
          ./configure %{BASE_CONFIGURE_ARGS} \
              --with-cc-opt="%{WITH_CC_OPT}" \
              --with-ld-opt="%{WITH_LD_OPT}" \
              --with-openssl=/root/openssl-1.1.1h
          make %{?_smp_mflags}
          %{__mv} %{bdir}/objs/nginx \
             %{bdir}/objs/nginx-debug
          ./configure %{BASE_CONFIGURE_ARGS} \
             --with-cc-opt="%{WITH_CC_OPT}" \
             --with-ld-opt="%{WITH_LD_OPT}"
          make %{?_smp_mflags}

#вводим

          ctrl+x подтверждаем/сохраняем  y

#сборка RPM пакета (долгая прогрузка)

          rpmbuild -bb /root/rpmbuild/SPECS/nginx.spec

#проверка собраных пакетов

          ll /root/rpmbuild/RPMS/x86_64/

#вывод

          total 4364
          -rw-r--r--. 1 root root 2037864 Dec  8 09:44 nginx-1.18.0-2.el8.ngx.x86_64.rpm
          -rw-r--r--. 1 root root 2428924 Dec  8 09:44 nginx-debuginfo-1.18.0-2.el8.ngx.x86_64.rpm


#установим nginx

          yum localinstall -y /root/rpmbuild/RPMS/x86_64/nginx-1.18.0-2.el8.ngx.x86_64.rpm

#запустим nginx

          systemctl start nginx

#проверим статус nginx

          systemctl status nginx

#создаём свою директорию 

          mkdir /usr/share/nginx/html/repo

#в созданую директорию копируем nginx

          cp /root/rpmbuild/RPMS/x86_64/nginx-1.18.0-2.el8.ngx.x86_64.rpm /usr/share/nginx/html/repo/

#установка percona-release-1.0-9.noarch.rpm

          wget https://downloads.percona.com/downloads/percona-release/percona-release-1.0-9/redhat/percona-release-1.0-9.noarch.rpm -O /usr/share/nginx/html/repo/percona-release-1.0-9.noarch.rpm

#инициализируем репозиторий

          createrepo /usr/share/nginx/html/repo/

#вывод

          Directory walk started
          Directory walk done - 2 packages
          Temporary output repo path: /usr/share/nginx/html/repo/.repodata/
          Preparing sqlite DBs
          Pool started (with 5 workers)
          Pool finished



#конфигурируем файл 

         nano /etc/nginx/conf.d/default.conf 

#секцию location прописываем - autoindex on

          location / {
              root   /usr/share/nginx/html;
              index  index.html index.htm;
              autoindex on;
                      }

#проверяем синтаксис и перезапускаем nginx

          nginx -t
#вывод

          nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
          nginx: configuration file /etc/nginx/nginx.conf test is successful

#перезапуск

          nginx -s reload

#curl репозиторий

          curl -a http://127.0.0.1/repo/

#вывод curl

          <html>
          <head><title>Index of /repo/</title></head>
          <body bgcolor="white">
          <h1>Index of /repo/</h1><hr><pre><a href="../">../</a>
          <a href="repodata/">repodata/</a>                                          03-Dec-2020 08:20                   -
          <a href="nginx-1.14.1-1.el7_4.ngx.x86_64.rpm">nginx-1.14.1-1.el7_4.ngx.x86_64.rpm</a>                03-Dec-2020 08:17             2003504
          <a href="percona-release-1.0-9.noarch.rpm">percona-release-1.0-9.noarch.rpm</a>                   11-Nov-2020 21:49               16664
          </pre><hr></body>
          </html>


#добавим в curl

          cat >> /etc/yum.repos.d/miklyaev.repo << EOF
          [miklyaev]
          name=miklyaev-linux
          baseurl=http://127.0.0.1/repo
          gpgcheck=0
          enabled=1
          EOF

#проверка созданого .repo

          ls /etc/yum.repos.d/

#убедимся что репозиторий подключен

          yum repolist enabled | grep miklyaev

#вывод информации о пакете 

          miklyaev                  miklyaev-linux 

#посмотрим что в нем есть

          yum list | grep miklyaev

#установим модуль

          yum install -y percona-release	

#после изменений необходимо применять их

       createrepo /usr/share/nginx/html/repo/

*********end*********