*******start*********

#��������� Vagrantfile

           git clone https://github.com/MaximMiklyaev/BASH.git

#��������� � ����������:

           cd /BASH

#��������� �����

           vagrant up

#������ � ��������� ���-�������

#��

#���������� �� � ������ root otchet.txt access.log ���������� ����������

#��� ������ ��������� ���-������ nginx (������� ������������ � ������ #1)

#��� ����������� �� ���������� ��� �������.

#��������� ������� 0pochta.cron pochta.sh skripts.sh � 

            /var/log/nginx/

#��� �����

            chmod +x /var/log/nginx/pochta.sh
            chmod +x /var/log/nginx/skripts.sh
            chmod +x /var/log/nginx/0pochta.sh

#���� ���������� ������ ���� ����� 0pochta.sh ������ ��� pochta.sh

            export EDITOR=nano

            crontab -e

            */5 * * * * /var/log/nginx/0pochta.sh
            0 * * * * /var/log/nginx/pochta.sh

#�������� �������

            ������������� 
            mkfifo /var/spool/postfix/public/pickup
            sudo yum install postfix telnet mailx
            systemctl restart postfix.service

            �������� �����
            mailx root@localhost - �������� ������ 
            ctrl+d - ���������
            mail - �������� ��� ����������� 
            nano /var/spool/mail/root - �������� ��� ����������� 
            rm /var/spool/mail/root - �������� �������

            ���� ������� /var/log/nginx/access.log
            > access.log
            chmod 0777 access.log


#������-1

            0pochta.sh -������ �� �������������

#����� �������

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

#������-2

            pochta.sh ������ ����������  ����� � ������ ������� skripts.sh � ���������� ��� ����� �� ����� root-������������
            ��� ��������� /var/log/nginx/

#����� �������

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

#������-3

            skripts.sh �������������� ������
            ��� ��������� /var/log/nginx/

#����� �������

            #!/bin/bash
            echo "��������� ��������":
            cat /var/log/nginx/access.log | awk '{print $4}' | head -n 1 &&  date | awk '{print $2,$3,$4,$6}' &&
            
            #1
            echo "���-10 ���������� URL ������������� � ����� �������"
            cat /var/log/nginx/access.log | awk '{print $7}' | sort | uniq -c | sort -rn | head -n 10 > 1.1.txt && cat 1.1.txt &&
            echo "------------------------------------------------------" 
            #2
            echo "���-10 ���������� IP"
            cat /var/log/nginx/access.log | awk '{print $1}' | sort | uniq -c | sort -rn | head -n 10 > 2.2.txt && tail -n 10 2.2.txt &&
            echo "------------------------------------------------------"
            #3
            echo "��� ���� ��������� HTTP � �� ����������"
            cat /var/log/nginx/access.log | awk '{print $9}'| grep -v "-" | sort | uniq -c | sort -rn > 3.3.txt && cat 3.3.txt && 
            echo "------------------------------------------------------" 
            #4
            echo "��� ���� ���������  4xx � 5xx"
            cat /var/log/nginx/access.log | awk '{print $9}' | grep ^4 > 4.4.txt && cat /var/log/nginx/access.log | awk '{print $9}'  | grep ^5 >> 4.4.txt && cat 4.4.txt | uniq -d -c | sort -rn > 4.5.txt && cat 4.5.txt &&
            echo "------------------------------------------------------"
            echo "all"
            rm -f 1.1.txt 2.2.txt 3.3.txt 4.4.txt 4.5.txt


*****������������� ��� ������********

#1 ������ ������� ���������
            
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


#Vagrantfile ��������� VM

#������������ � ��������� VM

           vagrant ssh

#����� ������� ��� SU

     sudo -i

#�������� ��������� spec ���� ���� NGINX ��������� � ������������ ��� ������� 
          	
          nano /root/rpmbuild/SPECS/nginx.spec

#��������

          ctrl+w  ��� ������ ������ %build

#����� 

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

#�������� � ������ ����

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

#������

          ctrl+x ������������/���������  y

#������ RPM ������ (������ ���������)

          rpmbuild -bb /root/rpmbuild/SPECS/nginx.spec

#�������� �������� �������

          ll /root/rpmbuild/RPMS/x86_64/

#�����

          total 4364
          -rw-r--r--. 1 root root 2037864 Dec  8 09:44 nginx-1.18.0-2.el8.ngx.x86_64.rpm
          -rw-r--r--. 1 root root 2428924 Dec  8 09:44 nginx-debuginfo-1.18.0-2.el8.ngx.x86_64.rpm


#��������� nginx

          yum localinstall -y /root/rpmbuild/RPMS/x86_64/nginx-1.18.0-2.el8.ngx.x86_64.rpm

#�������� nginx

          systemctl start nginx

#�������� ������ nginx

          systemctl status nginx

#������ ���� ���������� 

          mkdir /usr/share/nginx/html/repo

#� �������� ���������� �������� nginx

          cp /root/rpmbuild/RPMS/x86_64/nginx-1.18.0-2.el8.ngx.x86_64.rpm /usr/share/nginx/html/repo/

#��������� percona-release-1.0-9.noarch.rpm

          wget https://downloads.percona.com/downloads/percona-release/percona-release-1.0-9/redhat/percona-release-1.0-9.noarch.rpm -O /usr/share/nginx/html/repo/percona-release-1.0-9.noarch.rpm

#�������������� �����������

          createrepo /usr/share/nginx/html/repo/

#�����

          Directory walk started
          Directory walk done - 2 packages
          Temporary output repo path: /usr/share/nginx/html/repo/.repodata/
          Preparing sqlite DBs
          Pool started (with 5 workers)
          Pool finished



#������������� ���� 

         nano /etc/nginx/conf.d/default.conf 

#������ location ����������� - autoindex on

          location / {
              root   /usr/share/nginx/html;
              index  index.html index.htm;
              autoindex on;
                      }

#��������� ��������� � ������������� nginx

          nginx -t
#�����

          nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
          nginx: configuration file /etc/nginx/nginx.conf test is successful

#����������

          nginx -s reload

#curl �����������

          curl -a http://127.0.0.1/repo/

#����� curl

          <html>
          <head><title>Index of /repo/</title></head>
          <body bgcolor="white">
          <h1>Index of /repo/</h1><hr><pre><a href="../">../</a>
          <a href="repodata/">repodata/</a>                                          03-Dec-2020 08:20                   -
          <a href="nginx-1.14.1-1.el7_4.ngx.x86_64.rpm">nginx-1.14.1-1.el7_4.ngx.x86_64.rpm</a>                03-Dec-2020 08:17             2003504
          <a href="percona-release-1.0-9.noarch.rpm">percona-release-1.0-9.noarch.rpm</a>                   11-Nov-2020 21:49               16664
          </pre><hr></body>
          </html>


#������� � curl

          cat >> /etc/yum.repos.d/miklyaev.repo << EOF
          [miklyaev]
          name=miklyaev-linux
          baseurl=http://127.0.0.1/repo
          gpgcheck=0
          enabled=1
          EOF

#�������� ��������� .repo

          ls /etc/yum.repos.d/

#�������� ��� ����������� ���������

          yum repolist enabled | grep miklyaev

#����� ���������� � ������ 

          miklyaev                  miklyaev-linux 

#��������� ��� � ��� ����

          yum list | grep miklyaev

#��������� ������

          yum install -y percona-release	

#����� ��������� ���������� ��������� ��

       createrepo /usr/share/nginx/html/repo/

*********end*********