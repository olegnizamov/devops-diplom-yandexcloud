## Дипломный практикум в YandexCloud

**Цели:**

1. Зарегистрировать доменное имя (любое на ваш выбор в любой доменной зоне).
2. Подготовить инфраструктуру с помощью Terraform на базе облачного провайдера YandexCloud.
3. Настроить внешний Reverse Proxy на основе Nginx и LetsEncrypt.
4. Настроить кластер MySQL.
5. Установить WordPress.
6. Развернуть Gitlab CE и Gitlab Runner.
7. Настроить CI/CD для автоматического развёртывания приложения.
8. Настроить мониторинг инфраструктуры с помощью стека: Prometheus, Alert Manager и Grafana.

### **Этапы выполнения:**

***1. Регистрация доменного имени***

Подойдет любое доменное имя на ваш выбор в любой доменной зоне.
ПРИМЕЧАНИЕ: Далее в качестве примера используется домен `you.domain` замените его вашим доменом.
Рекомендуемые регистраторы:

• [nic.ru](https://www.nic.ru/)
• [reg.ru](https://www.reg.ru/)

*Цель:*

1. Получить возможность выписывать [TLS сертификаты](https://letsencrypt.org/) для веб-сервера.

*Ожидаемые результаты:*

1. У вас есть доступ к личному кабинету на сайте регистратора.
2. Вы зарезистрировали домен и можете им управлять (редактировать dns записи в рамках этого домена).

```
Ответ:
Было зарегистрировано доменное имя: bitrixdemo24.ru в регистраторе reg.ru
Возможность прописывать dns записи и редактировать ААА записи:
```
![](diplom.1.png)

```
Ответ:
В YandexCloud арендован статический адрес для проекта
```
![](diplom.2.png)

***2. Создание инфраструктуры***

Для начала необходимо подготовить инфраструктуру в YC при помощи [Terraform](https://www.terraform.io/).

*Особенности выполнения:*

* Бюджет купона ограничен, что следует иметь в виду при проектировании инфраструктуры и использовании ресурсов;
* Следует использовать последнюю стабильную версию Terraform.

*Предварительная подготовка:*

1. Создайте сервисный аккаунт, который будет в дальнейшем использоваться Terraform для работы с инфраструктурой с необходимыми и достаточными правами. Не стоит использовать права суперпользователя
2. Подготовьте [backend](https://www.terraform.io/language/settings/backends) для Terraform:

а. Рекомендуемый вариант: [Terraform Cloud](https://app.terraform.io/)
б. Альтернативный вариант: S3 bucket в созданном YC аккаунте.

```
Ответ:
Выбран вариант с S3 bucket в YC
```
![](diplom.3.png)

3. Настройте [workspaces](https://www.terraform.io/language/state/workspaces)

а. Рекомендуемый вариант: создайте два workspace: *stage* и  *prod* . В случае выбора этого варианта все последующие шаги должны учитывать факт существования нескольких workspace.
б. Альтернативный вариант: используйте один workspace, назвав его  *stage* . Пожалуйста, не используйте workspace, создаваемый Terraform-ом по-умолчанию (default).
```
Ответ:
Выбран вариант с 2 workspace stage и prod
```


4. Создайте VPC с подсетями в разных зонах доступности.
5. Убедитесь, что теперь вы можете выполнить команды `terraform destroy` и `terraform apply` без дополнительных ручных действий.
6. В случае использования [Terraform Cloud](https://app.terraform.io/) в качестве [backend](https://www.terraform.io/language/settings/backends) убедитесь, что применение изменений успешно проходит, используя web-интерфейс Terraform cloud.

*Цель:*

1. Повсеместно применять IaaC подход при организации (эксплуатации) инфраструктуры.
2. Иметь возможность быстро создавать (а также удалять) виртуальные машины и сети. С целью экономии денег на вашем аккаунте в YandexCloud.

*Ожидаемые результаты:*

1. Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий.
2. Полученная конфигурация инфраструктуры является предварительной, поэтому в ходе дальнейшего выполнения задания возможны изменения.

---
[Terraform](./terraform)
```
Ответ: 
- meta.txt - Содержит перечень пользователей и их открытые ключи, которые будут создаваться в виртуальных машинах;
- gitlab.tf - Содержат gitlab манифест для создания виртуальной машины в YC.
- runner.tf - Содержат gitlab-runner манифест для создания виртуальной машины в YC.
- wordpress.tf - Содержат wordpress манифест для создания виртуальной машины в YC.
- nginx.tf - Содержат nginx манифест для создания виртуальной машины в YC.
- monitoring.tf - Содержат monitoring манифест для создания виртуальной машины в YC.
- mysql.tf - Содержат манифест для создания виртуальной машины в YC для базы данных.
- network.tf - Содержит настройки сетей.
- providers.tf - Содержит настройки для подключения к провайдеру.
- variables.tf - Содержит описание переменных - по сути содержит только ip адрес.
```
![](diplom.4.png)

![](diplom.5.png)



***3. Установка Nginx и LetsEncrypt***

Необходимо разработать Ansible роль для установки Nginx и LetsEncrypt.
Для получения LetsEncrypt сертификатов во время тестов своего кода пользуйтесь [тестовыми сертификатами](https://letsencrypt.org/docs/staging-environment/), так как количество запросов к боевым серверам LetsEncrypt [лимитировано](https://letsencrypt.org/docs/rate-limits/).

*Рекомендации:*

• Имя сервера: `you.domain`
• Характеристики: 2vCPU, 2 RAM, External address (Public) и Internal address.

*Цель:*

1. Создать reverse proxy с поддержкой TLS для обеспечения безопасного доступа к веб-сервисам по HTTPS.

*Ожидаемые результаты:*

1. В вашей доменной зоне настроены все A-записи на внешний адрес этого сервера:

* `https://www.you.domain` (WordPress)
* `https://gitlab.you.domain` (Gitlab)
* `https://grafana.you.domain` (Grafana)
* `https://prometheus.you.domain` (Prometheus)
* `https://alertmanager.you.domain` (Alert Manager)

3. Настроены все upstream для выше указанных URL, куда они сейчас ведут на этом шаге не важно, позже вы их отредактируете и укажите верные значения.
4. В браузере можно открыть любой из этих URL и увидеть ответ сервера (502 Bad Gateway). На текущем этапе выполнение задания это нормально!

---

```
Ответ: 
Все роли находятся в resultansible и разделены по сервисам. 
Текущая версия ansible на компе 2.9.6
В файле hosts находится inventory для playbook и переменные для ansible ssh proxy.
В рамках текущего шага выполняем playbook nginx.yml. 
Он установит и настроит nginx, letsEncrypt на nginx машину. И перекинет ключи для авторизации на машинках внутри сети.
```
![](diplom.6.png)

![](diplom.7.png)

![](diplom.8.png)

![](diplom.9.png)

![](diplom.10.png)

![](diplom.11.png)

<details><summary>Ansible</summary>

``` 
olegnizamov@olegnizamov:~/projects/devops-diplom-yandexcloud/resultansible$ ansible-playbook nginx.yml -i hosts
[WARNING]:  * Failed to parse /home/olegnizamov/projects/devops-diplom-yandexcloud/resultansible/hosts with yaml plugin: Syntax Error while loading YAML.   did not find expected <document start>  The error appears to be in
'/home/olegnizamov/projects/devops-diplom-yandexcloud/resultansible/hosts': line 2, column 1, but may be elsewhere in the file depending on the exact syntax problem.  The offending line appears to be:  [nginx] bitrixdemo24.ru
letsencrypt_email=ol.nizamov@yandex.ru domain_name=bitrixdemo24.ru ^ here
[WARNING]:  * Failed to parse /home/olegnizamov/projects/devops-diplom-yandexcloud/resultansible/hosts with ini plugin: /home/olegnizamov/projects/devops-diplom-yandexcloud/resultansible/hosts:23: Section [mysql:vars] not valid for undefined group:
mysql
[WARNING]: Unable to parse /home/olegnizamov/projects/devops-diplom-yandexcloud/resultansible/hosts as an inventory source
[WARNING]: No inventory was parsed, only implicit localhost is available
[WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'

PLAY [nginx] *********************************************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************************************************************************************************************************************
ok: [bitrixdemo24.ru]

TASK [install_nginx_letsencrypt : Upgrade system] ********************************************************************************************************************************************************************************************************
ok: [bitrixdemo24.ru]

TASK [install_nginx_letsencrypt : Install nginx] *********************************************************************************************************************************************************************************************************
ok: [bitrixdemo24.ru]

TASK [install_nginx_letsencrypt : install letsencrypt] ***************************************************************************************************************************************************************************************************
ok: [bitrixdemo24.ru]

TASK [install_nginx_letsencrypt : create letsencrypt directory] ******************************************************************************************************************************************************************************************
ok: [bitrixdemo24.ru]

TASK [install_nginx_letsencrypt : Remove default nginx config] *******************************************************************************************************************************************************************************************
ok: [bitrixdemo24.ru]

TASK [install_nginx_letsencrypt : Install system nginx config] *******************************************************************************************************************************************************************************************
ok: [bitrixdemo24.ru]

TASK [install_nginx_letsencrypt : Install nginx site for letsencrypt requests] ***************************************************************************************************************************************************************************
ok: [bitrixdemo24.ru]

TASK [install_nginx_letsencrypt : Reload nginx to activate letsencrypt site] *****************************************************************************************************************************************************************************
changed: [bitrixdemo24.ru]

TASK [install_nginx_letsencrypt : Create letsencrypt certificate nginx] **********************************************************************************************************************************************************************************
ok: [bitrixdemo24.ru]

TASK [install_nginx_letsencrypt : Create letsencrypt certificate gitlab] *********************************************************************************************************************************************************************************
ok: [bitrixdemo24.ru]

TASK [install_nginx_letsencrypt : Create letsencrypt certificate grafana] ********************************************************************************************************************************************************************************
ok: [bitrixdemo24.ru]

TASK [install_nginx_letsencrypt : Create letsencrypt certificate prometheus] *****************************************************************************************************************************************************************************
ok: [bitrixdemo24.ru]

TASK [install_nginx_letsencrypt : Create letsencrypt certificate alertmanager] ***************************************************************************************************************************************************************************
ok: [bitrixdemo24.ru]

TASK [install_nginx_letsencrypt : Generate dhparams] *****************************************************************************************************************************************************************************************************
ok: [bitrixdemo24.ru]

TASK [install_nginx_letsencrypt : Install nginx site for specified site] *********************************************************************************************************************************************************************************
ok: [bitrixdemo24.ru]

TASK [install_nginx_letsencrypt : Reload nginx to activate specified site] *******************************************************************************************************************************************************************************
changed: [bitrixdemo24.ru]

TASK [install_nginx_letsencrypt : Add letsencrypt cronjob for cert renewal] ******************************************************************************************************************************************************************************
ok: [bitrixdemo24.ru]

TASK [install_proxy : install privoxy] *******************************************************************************************************************************************************************************************************************
ok: [bitrixdemo24.ru]

TASK [install_proxy : configure privoxy] *****************************************************************************************************************************************************************************************************************
ok: [bitrixdemo24.ru]

TASK [install_proxy : start privoxy] *********************************************************************************************************************************************************************************************************************
ok: [bitrixdemo24.ru]

PLAY RECAP ***********************************************************************************************************************************************************************************************************************************************
bitrixdemo24.ru            : ok=21   changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

olegnizamov@olegnizamov:~/projects/devops-diplom-yandexcloud/resultansible$ ansible-playbook nginx.yml -i hosts
[WARNING]:  * Failed to parse /home/olegnizamov/projects/devops-diplom-yandexcloud/resultansible/hosts with yaml plugin: Syntax Error while loading YAML.   did not find expected <document start>  The error appears to be in
'/home/olegnizamov/projects/devops-diplom-yandexcloud/resultansible/hosts': line 2, column 1, but may be elsewhere in the file depending on the exact syntax problem.  The offending line appears to be:  [nginx] bitrixdemo24.ru
letsencrypt_email=ol.nizamov@yandex.ru domain_name=bitrixdemo24.ru ^ here
[WARNING]:  * Failed to parse /home/olegnizamov/projects/devops-diplom-yandexcloud/resultansible/hosts with ini plugin: /home/olegnizamov/projects/devops-diplom-yandexcloud/resultansible/hosts:23: Section [mysql:vars] not valid for undefined group:
mysql
[WARNING]: Unable to parse /home/olegnizamov/projects/devops-diplom-yandexcloud/resultansible/hosts as an inventory source
[WARNING]: No inventory was parsed, only implicit localhost is available
[WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'

PLAY [nginx] *********************************************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************************************************************************************************************************************
Warning: the ECDSA host key for 'bitrixdemo24.ru' differs from the key for the IP address '51.250.83.27'
Offending key for IP in /home/olegnizamov/.ssh/known_hosts:13
Matching host key in /home/olegnizamov/.ssh/known_hosts:15
Are you sure you want to continue connecting (yes/no)? yes
ok: [bitrixdemo24.ru]

TASK [install_nginx_letsencrypt : Upgrade system] ********************************************************************************************************************************************************************************************************
ok: [bitrixdemo24.ru]

TASK [install_nginx_letsencrypt : Install nginx] *********************************************************************************************************************************************************************************************************
ok: [bitrixdemo24.ru]

TASK [install_nginx_letsencrypt : install letsencrypt] ***************************************************************************************************************************************************************************************************
ok: [bitrixdemo24.ru]

TASK [install_nginx_letsencrypt : create letsencrypt directory] ******************************************************************************************************************************************************************************************
ok: [bitrixdemo24.ru]

TASK [install_nginx_letsencrypt : Remove default nginx config] *******************************************************************************************************************************************************************************************
ok: [bitrixdemo24.ru]

TASK [install_nginx_letsencrypt : Install system nginx config] *******************************************************************************************************************************************************************************************
ok: [bitrixdemo24.ru]

TASK [install_nginx_letsencrypt : Install nginx site for letsencrypt requests] ***************************************************************************************************************************************************************************
ok: [bitrixdemo24.ru]

TASK [install_nginx_letsencrypt : Reload nginx to activate letsencrypt site] *****************************************************************************************************************************************************************************
changed: [bitrixdemo24.ru]

TASK [install_nginx_letsencrypt : Create letsencrypt certificate nginx] **********************************************************************************************************************************************************************************
ok: [bitrixdemo24.ru]

TASK [install_nginx_letsencrypt : Create letsencrypt certificate gitlab] *********************************************************************************************************************************************************************************
ok: [bitrixdemo24.ru]

TASK [install_nginx_letsencrypt : Create letsencrypt certificate grafana] ********************************************************************************************************************************************************************************
ok: [bitrixdemo24.ru]

TASK [install_nginx_letsencrypt : Create letsencrypt certificate prometheus] *****************************************************************************************************************************************************************************
ok: [bitrixdemo24.ru]

TASK [install_nginx_letsencrypt : Create letsencrypt certificate alertmanager] ***************************************************************************************************************************************************************************
ok: [bitrixdemo24.ru]

TASK [install_nginx_letsencrypt : Generate dhparams] *****************************************************************************************************************************************************************************************************
ok: [bitrixdemo24.ru]

TASK [install_nginx_letsencrypt : Install nginx site for specified site] *********************************************************************************************************************************************************************************
ok: [bitrixdemo24.ru]

TASK [install_nginx_letsencrypt : Reload nginx to activate specified site] *******************************************************************************************************************************************************************************
changed: [bitrixdemo24.ru]

TASK [install_nginx_letsencrypt : Add letsencrypt cronjob for cert renewal] ******************************************************************************************************************************************************************************
ok: [bitrixdemo24.ru]

TASK [install_proxy : install privoxy] *******************************************************************************************************************************************************************************************************************
ok: [bitrixdemo24.ru]

TASK [install_proxy : configure privoxy] *****************************************************************************************************************************************************************************************************************
ok: [bitrixdemo24.ru]

TASK [install_proxy : start privoxy] *********************************************************************************************************************************************************************************************************************
ok: [bitrixdemo24.ru]

TASK [install_node_exporter : Assert usage of systemd as an init system] *********************************************************************************************************************************************************************************
ok: [bitrixdemo24.ru] => {
    "changed": false,
    "msg": "All assertions passed"
}

TASK [install_node_exporter : Get systemd version] *******************************************************************************************************************************************************************************************************
ok: [bitrixdemo24.ru]

TASK [install_node_exporter : Set systemd version fact] **************************************************************************************************************************************************************************************************
ok: [bitrixdemo24.ru]

TASK [install_node_exporter : Naive assertion of proper listen address] **********************************************************************************************************************************************************************************
ok: [bitrixdemo24.ru] => {
    "changed": false,
    "msg": "All assertions passed"
}

TASK [install_node_exporter : Assert collectors are not both disabled and enabled at the same time] ******************************************************************************************************************************************************

TASK [install_node_exporter : Assert that TLS key and cert path are set] *********************************************************************************************************************************************************************************
skipping: [bitrixdemo24.ru]

TASK [install_node_exporter : Check existence of TLS cert file] ******************************************************************************************************************************************************************************************
skipping: [bitrixdemo24.ru]

TASK [install_node_exporter : Check existence of TLS key file] *******************************************************************************************************************************************************************************************
skipping: [bitrixdemo24.ru]

TASK [install_node_exporter : Assert that TLS key and cert are present] **********************************************************************************************************************************************************************************
skipping: [bitrixdemo24.ru]

TASK [install_node_exporter : Check if node_exporter is installed] ***************************************************************************************************************************************************************************************
ok: [bitrixdemo24.ru]

TASK [install_node_exporter : Gather currently installed node_exporter version (if any)] *****************************************************************************************************************************************************************
skipping: [bitrixdemo24.ru]

TASK [install_node_exporter : Get latest release] ********************************************************************************************************************************************************************************************************
skipping: [bitrixdemo24.ru]

TASK [install_node_exporter : Set node_exporter version to {{ _latest_release.json.tag_name[1:] }}] ******************************************************************************************************************************************************
skipping: [bitrixdemo24.ru]

TASK [install_node_exporter : Get checksum list from github] *********************************************************************************************************************************************************************************************
ok: [bitrixdemo24.ru -> localhost]

TASK [install_node_exporter : Get checksum for amd64 architecture] ***************************************************************************************************************************************************************************************
skipping: [bitrixdemo24.ru] => (item=3919266f1dbad5f7e5ce7b4207057fc253a8322f570607cc0f3e73f4a53338e3  node_exporter-1.1.2.darwin-amd64.tar.gz) 
skipping: [bitrixdemo24.ru] => (item=5b0195e203dedd3a8973cd1894a55097554a4af6d8f4f0614c2c67d6670ea8ae  node_exporter-1.1.2.linux-386.tar.gz) 
ok: [bitrixdemo24.ru -> localhost] => (item=8c1f6a317457a658e0ae68ad710f6b4098db2cad10204649b51e3c043aa3e70d  node_exporter-1.1.2.linux-amd64.tar.gz)
skipping: [bitrixdemo24.ru] => (item=eb5e7d16f18bb3272d0d832986fc8ac6cb0b6c42d487c94e15dabb10feae8e04  node_exporter-1.1.2.linux-arm64.tar.gz) 
skipping: [bitrixdemo24.ru] => (item=41892e451e80160491a1cc7bbe6bccd6cb842ae8340e1bc6e32f72cefb1aee80  node_exporter-1.1.2.linux-armv5.tar.gz) 
skipping: [bitrixdemo24.ru] => (item=1cc1bf4cacb84d6c228d9ce8045b5b00b73afd954046f7b2add428a04d14daee  node_exporter-1.1.2.linux-armv6.tar.gz) 
skipping: [bitrixdemo24.ru] => (item=a9fe816eb7b976b1587d6d654c437f7d78349f70686fa22ae33e94fe84281af2  node_exporter-1.1.2.linux-armv7.tar.gz) 
skipping: [bitrixdemo24.ru] => (item=a99ab2cdc62db25ff01d184e21ad433e3949cd791fc2c80b6bacc6b90d5a62c2  node_exporter-1.1.2.linux-mips.tar.gz) 
skipping: [bitrixdemo24.ru] => (item=22d9c2a5363502c79e0645ba02eafd9561b33d1e0e819ce4df3fcf7dc96e3792  node_exporter-1.1.2.linux-mips64.tar.gz) 
skipping: [bitrixdemo24.ru] => (item=a66b70690c3c4fff953905a041c74834f96be85a806e74a1cc925e607ef50a26  node_exporter-1.1.2.linux-mips64le.tar.gz) 
skipping: [bitrixdemo24.ru] => (item=f7fba791cbc758b021d0e9a2400c82d1f29337e568ab00edc84b053ca467ea3c  node_exporter-1.1.2.linux-mipsle.tar.gz) 
skipping: [bitrixdemo24.ru] => (item=294c0b05dff4f368512449de7268e3f06de679a9343e9885044adc702865080b  node_exporter-1.1.2.linux-ppc64.tar.gz) 
skipping: [bitrixdemo24.ru] => (item=d1d201b16d757980db654bb9e448ab0c81ca4c2715243c3fa4305bef5967bd41  node_exporter-1.1.2.linux-ppc64le.tar.gz) 
skipping: [bitrixdemo24.ru] => (item=6007420f425d08626c05de2dbe0e8bb785a16bba1b02c01cb06d37d7fab3bc97  node_exporter-1.1.2.linux-s390x.tar.gz) 
skipping: [bitrixdemo24.ru] => (item=0596e9c1cc358e6fcc60cb83f0d1ba9a37ccee11eca035429c9791c0beb04389  node_exporter-1.1.2.netbsd-386.tar.gz) 
skipping: [bitrixdemo24.ru] => (item=46c964efd336f0e35f62c739ce9edf5409911e7652604e411c9b684eb9c48386  node_exporter-1.1.2.netbsd-amd64.tar.gz) 
skipping: [bitrixdemo24.ru] => (item=d81f86f57a4ed167a4062aa47f8a70b35c146c86bc8e40924c9d1fc3644ec8e6  node_exporter-1.1.2.openbsd-amd64.tar.gz) 

TASK [install_node_exporter : Create the node_exporter group] ********************************************************************************************************************************************************************************************
changed: [bitrixdemo24.ru]

TASK [install_node_exporter : Create the node_exporter user] *********************************************************************************************************************************************************************************************
changed: [bitrixdemo24.ru]

TASK [install_node_exporter : Download node_exporter binary to local folder] *****************************************************************************************************************************************************************************
changed: [bitrixdemo24.ru -> localhost]

TASK [install_node_exporter : Unpack node_exporter binary] ***********************************************************************************************************************************************************************************************
changed: [bitrixdemo24.ru -> localhost]

TASK [install_node_exporter : Propagate node_exporter binaries] ******************************************************************************************************************************************************************************************
changed: [bitrixdemo24.ru]

TASK [install_node_exporter : propagate locally distributed node_exporter binary] ************************************************************************************************************************************************************************
skipping: [bitrixdemo24.ru]

TASK [install_node_exporter : Install selinux python packages [RHEL]] ************************************************************************************************************************************************************************************
skipping: [bitrixdemo24.ru]

TASK [install_node_exporter : Install selinux python packages [Fedora]] **********************************************************************************************************************************************************************************
skipping: [bitrixdemo24.ru]

TASK [install_node_exporter : Install selinux python packages [clearlinux]] ******************************************************************************************************************************************************************************
skipping: [bitrixdemo24.ru]

TASK [install_node_exporter : Copy the node_exporter systemd service file] *******************************************************************************************************************************************************************************
changed: [bitrixdemo24.ru]

TASK [install_node_exporter : Create node_exporter config directory] *************************************************************************************************************************************************************************************
skipping: [bitrixdemo24.ru]

TASK [install_node_exporter : Copy the node_exporter config file] ****************************************************************************************************************************************************************************************
skipping: [bitrixdemo24.ru]

TASK [install_node_exporter : Create textfile collector dir] *********************************************************************************************************************************************************************************************
changed: [bitrixdemo24.ru]

TASK [install_node_exporter : Allow node_exporter port in SELinux on RedHat OS family] *******************************************************************************************************************************************************************
skipping: [bitrixdemo24.ru]

TASK [install_node_exporter : Ensure Node Exporter is enabled on boot] ***********************************************************************************************************************************************************************************
changed: [bitrixdemo24.ru]

RUNNING HANDLER [install_node_exporter : restart node_exporter] ******************************************************************************************************************************************************************************************
changed: [bitrixdemo24.ru]

PLAY RECAP ***********************************************************************************************************************************************************************************************************************************************
bitrixdemo24.ru            : ok=37   changed=11   unreachable=0    failed=0    skipped=15   rescued=0    ignored=0   
```
</details>

**4. Установка кластера MySQL**

Необходимо разработать Ansible роль для установки кластера MySQL.

*Рекомендации:*

• Имена серверов: `db01.you.domain` и `db02.you.domain`
• Характеристики: 4vCPU, 4 RAM, Internal address.

*Цель:*

1. Получить отказоустойчивый кластер баз данных MySQL.

*Ожидаемые результаты:*

1. MySQL работает в режиме репликации Master/Slave.
2. В кластере автоматически создаётся база данных c именем `wordpress`.
3. В кластере автоматически создаётся пользователь `wordpress` с полными правами на базу `wordpress` и паролем `wordpress`.

*Вы должны понимать, что в рамках обучения это допустимые значения, но в боевой среде использование подобных значений не приемлимо! Считается хорошей практикой использовать логины и пароли повышенного уровня сложности. В которых будут содержаться буквы верхнего и нижнего регистров, цифры, а также специальные символы!*

---

```
Ответ: 

Уточнение - изначально нейминги баз были другие, поэтому на предыдующих скриншотах нейминг был другой. Изменил на db01 и db02
Так же использовал решение с гилхаба - https://github.com/geerlingguy/ansible-role-mysql, ибо если умный человек с 1000 звезд сделал задачу, зачем мне ее делать хуже?))
Выполняем playbook mysql.yml.
Настройки на базу данных находятся в resultansible/roles/install_mysql/defaults/main.yml

# Databases.
mysql_databases: 
   - name: wordpress
     collation: utf8_general_ci
     encoding: utf8
     replicate: 1

# Users.
mysql_users: 
   - name: wordpress
     host: '%'
     password: wordpress
     priv: '*.*:ALL PRIVILEGES'

   - name: repuser
     password: repuser
     priv: '*.*:REPLICATION SLAVE,REPLICATION CLIENT'

Дополнительно в файле `hosts` передаются переменные для настройки репликации базы  между db01 и db02
```
![](diplom.12.png)

![](diplom.13.png)

![](diplom.14.png)

![](diplom.15.png)

![](diplom.16.png)

<details><summary>Ansible</summary>

```
Ответ: 
olegnizamov@olegnizamov:~/projects/devops-diplom-yandexcloud/resultansible$ ansible-playbook mysql.yml -i hosts

PLAY [mysql] *********************************************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************************************************************************************************************************************
The authenticity of host 'db01.bitrixdemo24.ru (<no hostip for proxy command>)' can't be established.
ECDSA key fingerprint is SHA256:Fsdhr7XJ/WyYpg8uqvftF9vlmVAhtrGwD+1yvvvIPCI.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
ok: [db02.bitrixdemo24.ru]
ok: [db01.bitrixdemo24.ru]

TASK [install_mysql : include_tasks] *********************************************************************************************************************************************************************************************************************
included: /home/olegnizamov/projects/devops-diplom-yandexcloud/resultansible/roles/install_mysql/tasks/variables.yml for db01.bitrixdemo24.ru, db02.bitrixdemo24.ru

TASK [install_mysql : Include OS-specific variables.] ****************************************************************************************************************************************************************************************************
ok: [db01.bitrixdemo24.ru] => (item=/home/olegnizamov/projects/devops-diplom-yandexcloud/resultansible/roles/install_mysql/vars/Debian.yml)
ok: [db02.bitrixdemo24.ru] => (item=/home/olegnizamov/projects/devops-diplom-yandexcloud/resultansible/roles/install_mysql/vars/Debian.yml)

TASK [install_mysql : Define mysql_packages.] ************************************************************************************************************************************************************************************************************
ok: [db01.bitrixdemo24.ru]
ok: [db02.bitrixdemo24.ru]

TASK [install_mysql : Define mysql_daemon.] **************************************************************************************************************************************************************************************************************
ok: [db01.bitrixdemo24.ru]
ok: [db02.bitrixdemo24.ru]

TASK [install_mysql : Define mysql_slow_query_log_file.] *************************************************************************************************************************************************************************************************
ok: [db01.bitrixdemo24.ru]
ok: [db02.bitrixdemo24.ru]

TASK [install_mysql : Define mysql_log_error.] ***********************************************************************************************************************************************************************************************************
ok: [db01.bitrixdemo24.ru]
ok: [db02.bitrixdemo24.ru]

TASK [install_mysql : Define mysql_syslog_tag.] **********************************************************************************************************************************************************************************************************
ok: [db01.bitrixdemo24.ru]
ok: [db02.bitrixdemo24.ru]

TASK [install_mysql : Define mysql_pid_file.] ************************************************************************************************************************************************************************************************************
ok: [db01.bitrixdemo24.ru]
ok: [db02.bitrixdemo24.ru]

TASK [install_mysql : Define mysql_config_file.] *********************************************************************************************************************************************************************************************************
ok: [db01.bitrixdemo24.ru]
ok: [db02.bitrixdemo24.ru]

TASK [install_mysql : Define mysql_config_include_dir.] **************************************************************************************************************************************************************************************************
ok: [db01.bitrixdemo24.ru]
ok: [db02.bitrixdemo24.ru]

TASK [install_mysql : Define mysql_socket.] **************************************************************************************************************************************************************************************************************
ok: [db01.bitrixdemo24.ru]
ok: [db02.bitrixdemo24.ru]

TASK [install_mysql : Define mysql_supports_innodb_large_prefix.] ****************************************************************************************************************************************************************************************
ok: [db01.bitrixdemo24.ru]
ok: [db02.bitrixdemo24.ru]

TASK [install_mysql : include_tasks] *********************************************************************************************************************************************************************************************************************
skipping: [db01.bitrixdemo24.ru]
skipping: [db02.bitrixdemo24.ru]

TASK [install_mysql : include_tasks] *********************************************************************************************************************************************************************************************************************
included: /home/olegnizamov/projects/devops-diplom-yandexcloud/resultansible/roles/install_mysql/tasks/setup-Debian.yml for db01.bitrixdemo24.ru, db02.bitrixdemo24.ru

TASK [install_mysql : Check if MySQL is already installed.] **********************************************************************************************************************************************************************************************
ok: [db01.bitrixdemo24.ru]
ok: [db02.bitrixdemo24.ru]

TASK [install_mysql : Update apt cache if MySQL is not yet installed.] ***********************************************************************************************************************************************************************************
ok: [db02.bitrixdemo24.ru]
ok: [db01.bitrixdemo24.ru]

TASK [install_mysql : Ensure MySQL Python libraries are installed.] **************************************************************************************************************************************************************************************
changed: [db02.bitrixdemo24.ru]
changed: [db01.bitrixdemo24.ru]

TASK [install_mysql : Ensure MySQL packages are installed.] **********************************************************************************************************************************************************************************************
changed: [db02.bitrixdemo24.ru]
changed: [db01.bitrixdemo24.ru]

TASK [install_mysql : Ensure MySQL is stopped after initial install.] ************************************************************************************************************************************************************************************
changed: [db02.bitrixdemo24.ru]
changed: [db01.bitrixdemo24.ru]

TASK [install_mysql : Delete innodb log files created by apt package after initial install.] *************************************************************************************************************************************************************
changed: [db01.bitrixdemo24.ru] => (item=ib_logfile0)
changed: [db02.bitrixdemo24.ru] => (item=ib_logfile0)
changed: [db01.bitrixdemo24.ru] => (item=ib_logfile1)
changed: [db02.bitrixdemo24.ru] => (item=ib_logfile1)

TASK [install_mysql : include_tasks] *********************************************************************************************************************************************************************************************************************
skipping: [db02.bitrixdemo24.ru]
skipping: [db01.bitrixdemo24.ru]

TASK [install_mysql : Check if MySQL packages were installed.] *******************************************************************************************************************************************************************************************
ok: [db01.bitrixdemo24.ru]
ok: [db02.bitrixdemo24.ru]

TASK [install_mysql : include_tasks] *********************************************************************************************************************************************************************************************************************
included: /home/olegnizamov/projects/devops-diplom-yandexcloud/resultansible/roles/install_mysql/tasks/configure.yml for db01.bitrixdemo24.ru, db02.bitrixdemo24.ru

TASK [install_mysql : Get MySQL version.] ****************************************************************************************************************************************************************************************************************
ok: [db01.bitrixdemo24.ru]
ok: [db02.bitrixdemo24.ru]

TASK [install_mysql : Copy my.cnf global MySQL configuration.] *******************************************************************************************************************************************************************************************
changed: [db01.bitrixdemo24.ru]
changed: [db02.bitrixdemo24.ru]

TASK [install_mysql : Verify mysql include directory exists.] ********************************************************************************************************************************************************************************************
skipping: [db01.bitrixdemo24.ru]
skipping: [db02.bitrixdemo24.ru]

TASK [install_mysql : Copy my.cnf override files into include directory.] ********************************************************************************************************************************************************************************

TASK [install_mysql : Create slow query log file (if configured).] ***************************************************************************************************************************************************************************************
skipping: [db01.bitrixdemo24.ru]
skipping: [db02.bitrixdemo24.ru]

TASK [install_mysql : Create datadir if it does not exist] ***********************************************************************************************************************************************************************************************
changed: [db02.bitrixdemo24.ru]
changed: [db01.bitrixdemo24.ru]

TASK [install_mysql : Set ownership on slow query log file (if configured).] *****************************************************************************************************************************************************************************
skipping: [db01.bitrixdemo24.ru]
skipping: [db02.bitrixdemo24.ru]

TASK [install_mysql : Create error log file (if configured).] ********************************************************************************************************************************************************************************************
skipping: [db01.bitrixdemo24.ru]
skipping: [db02.bitrixdemo24.ru]

TASK [install_mysql : Set ownership on error log file (if configured).] **********************************************************************************************************************************************************************************
skipping: [db01.bitrixdemo24.ru]
skipping: [db02.bitrixdemo24.ru]

TASK [install_mysql : Ensure MySQL is started and enabled on boot.] **************************************************************************************************************************************************************************************
changed: [db01.bitrixdemo24.ru]
changed: [db02.bitrixdemo24.ru]

TASK [install_mysql : include_tasks] *********************************************************************************************************************************************************************************************************************
included: /home/olegnizamov/projects/devops-diplom-yandexcloud/resultansible/roles/install_mysql/tasks/secure-installation.yml for db01.bitrixdemo24.ru, db02.bitrixdemo24.ru

TASK [install_mysql : Ensure default user is present.] ***************************************************************************************************************************************************************************************************
[WARNING]: Module did not set no_log for update_password
changed: [db01.bitrixdemo24.ru]
changed: [db02.bitrixdemo24.ru]

TASK [install_mysql : Copy user-my.cnf file with password credentials.] **********************************************************************************************************************************************************************************
changed: [db01.bitrixdemo24.ru]
changed: [db02.bitrixdemo24.ru]

TASK [install_mysql : Disallow root login remotely] ******************************************************************************************************************************************************************************************************
ok: [db01.bitrixdemo24.ru] => (item=DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1'))
ok: [db02.bitrixdemo24.ru] => (item=DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1'))

TASK [install_mysql : Get list of hosts for the root user.] **********************************************************************************************************************************************************************************************
ok: [db01.bitrixdemo24.ru]
ok: [db02.bitrixdemo24.ru]

TASK [install_mysql : Update MySQL root password for localhost root account (5.7.x).] ********************************************************************************************************************************************************************
changed: [db01.bitrixdemo24.ru] => (item=localhost)
changed: [db02.bitrixdemo24.ru] => (item=localhost)

TASK [install_mysql : Update MySQL root password for localhost root account (< 5.7.x).] ******************************************************************************************************************************************************************
skipping: [db01.bitrixdemo24.ru] => (item=localhost) 
skipping: [db02.bitrixdemo24.ru] => (item=localhost) 

TASK [install_mysql : Copy .my.cnf file with root password credentials.] *********************************************************************************************************************************************************************************
changed: [db01.bitrixdemo24.ru]
changed: [db02.bitrixdemo24.ru]

TASK [install_mysql : Get list of hosts for the anonymous user.] *****************************************************************************************************************************************************************************************
ok: [db01.bitrixdemo24.ru]
ok: [db02.bitrixdemo24.ru]

TASK [install_mysql : Remove anonymous MySQL users.] *****************************************************************************************************************************************************************************************************

TASK [install_mysql : Remove MySQL test database.] *******************************************************************************************************************************************************************************************************
ok: [db01.bitrixdemo24.ru]
ok: [db02.bitrixdemo24.ru]

TASK [install_mysql : include_tasks] *********************************************************************************************************************************************************************************************************************
included: /home/olegnizamov/projects/devops-diplom-yandexcloud/resultansible/roles/install_mysql/tasks/databases.yml for db01.bitrixdemo24.ru, db02.bitrixdemo24.ru

TASK [install_mysql : Ensure MySQL databases are present.] ***********************************************************************************************************************************************************************************************
changed: [db02.bitrixdemo24.ru] => (item={'name': 'wordpress', 'collation': 'utf8_general_ci', 'encoding': 'utf8', 'replicate': 1})
changed: [db01.bitrixdemo24.ru] => (item={'name': 'wordpress', 'collation': 'utf8_general_ci', 'encoding': 'utf8', 'replicate': 1})

TASK [install_mysql : include_tasks] *********************************************************************************************************************************************************************************************************************
included: /home/olegnizamov/projects/devops-diplom-yandexcloud/resultansible/roles/install_mysql/tasks/users.yml for db01.bitrixdemo24.ru, db02.bitrixdemo24.ru

TASK [install_mysql : Ensure MySQL users are present.] ***************************************************************************************************************************************************************************************************
changed: [db01.bitrixdemo24.ru] => (item=None)
changed: [db02.bitrixdemo24.ru] => (item=None)
changed: [db01.bitrixdemo24.ru] => (item=None)
changed: [db01.bitrixdemo24.ru]
changed: [db02.bitrixdemo24.ru] => (item=None)
changed: [db02.bitrixdemo24.ru]

TASK [install_mysql : include_tasks] *********************************************************************************************************************************************************************************************************************
included: /home/olegnizamov/projects/devops-diplom-yandexcloud/resultansible/roles/install_mysql/tasks/replication.yml for db01.bitrixdemo24.ru, db02.bitrixdemo24.ru

TASK [install_mysql : Ensure replication user exists on master.] *****************************************************************************************************************************************************************************************
skipping: [db02.bitrixdemo24.ru]
changed: [db01.bitrixdemo24.ru]

TASK [install_mysql : Check slave replication status.] ***************************************************************************************************************************************************************************************************
skipping: [db01.bitrixdemo24.ru]
ok: [db02.bitrixdemo24.ru]

TASK [install_mysql : Check master replication status.] **************************************************************************************************************************************************************************************************
skipping: [db01.bitrixdemo24.ru]
ok: [db02.bitrixdemo24.ru -> db01.bitrixdemo24.ru]

TASK [install_mysql : Configure replication on the slave.] ***********************************************************************************************************************************************************************************************
skipping: [db01.bitrixdemo24.ru]
changed: [db02.bitrixdemo24.ru]

TASK [install_mysql : Start replication.] ****************************************************************************************************************************************************************************************************************
skipping: [db01.bitrixdemo24.ru]
changed: [db02.bitrixdemo24.ru]

RUNNING HANDLER [install_mysql : restart mysql] **********************************************************************************************************************************************************************************************************
[WARNING]: Ignoring "sleep" as it is not used in "systemd"
[WARNING]: Ignoring "sleep" as it is not used in "systemd"
changed: [db01.bitrixdemo24.ru]
changed: [db02.bitrixdemo24.ru]

PLAY RECAP ***********************************************************************************************************************************************************************************************************************************************
db01.bitrixdemo24.ru       : ok=42   changed=15   unreachable=0    failed=0    skipped=14   rescued=0    ignored=0   
db02.bitrixdemo24.ru       : ok=45   changed=16   unreachable=0    failed=0    skipped=11   rescued=0    ignored=0   
```
</details>


**5. Установка WordPress**

Необходимо разработать Ansible роль для установки WordPress.

*Рекомендации:*

• Имя сервера: `app.you.domain`
• Характеристики: 4vCPU, 4 RAM, Internal address.

*Цель:*

1. Установить [WordPress](https://wordpress.org/download/). Это система управления содержимым сайта ([CMS](https://ru.wikipedia.org/wiki/%D0%A1%D0%B8%D1%81%D1%82%D0%B5%D0%BC%D0%B0_%D1%83%D0%BF%D1%80%D0%B0%D0%B2%D0%BB%D0%B5%D0%BD%D0%B8%D1%8F_%D1%81%D0%BE%D0%B4%D0%B5%D1%80%D0%B6%D0%B8%D0%BC%D1%8B%D0%BC)) с открытым исходным кодом.

По данным W3techs, WordPress используют 64,7% всех веб-сайтов, которые сделаны на CMS. Это 41,1% всех существующих в мире сайтов. Эту платформу для своих блогов используют The New York Times и Forbes. Такую популярность WordPress получил за удобство интерфейса и большие возможности.

*Ожидаемые результаты:*

1. Виртуальная машина на которой установлен WordPress и Nginx/Apache (на ваше усмотрение).
2. В вашей доменной зоне настроена A-запись на внешний адрес reverse proxy:

* `https://www.you.domain` (WordPress)

3. На сервере `you.domain` отредактирован upstream для выше указанного URL и он смотрит на виртуальную машину на которой установлен WordPress.
4. В браузере можно открыть URL `https://www.you.domain` и увидеть главную страницу WordPress.

---

```
Ответ: 
Для установки `WordPress` служит playbook `wordpress.yml`.  
Playbook устанавливает и настраивает `nginx`,  `php`, `wordpress`. 
В файле `wordpress.yml` так же передаются переменные, необходимые для корректной настройки wordpress.


- name: download WordPress
  get_url:
    url: "{{ download_url }}"
    dest: "/tmp/latest.tar.gz"
    
- name: unpack WordPress installation
  shell: "tar xvfz /tmp/latest.tar.gz -C {{ wpdirectory }} && chown -R www-data:www-data {{ wpdirectory }}"
  
  
Удачно скомунизжено с ansible роли по установке WP.
В целом в самой роли мне понравилась автоматическая установка с настройка wp-config.php  
```

![](diplom.20.png)

![](diplom.17.png)

![](diplom.18.png)

![](diplom.19.png) - тут не правильный скрин - DB host = db01

![](diplom.21.png)

![](diplom.22.png)

![](diplom.23.png)

![](diplom.24.png)


<details><summary>Ansible</summary>

```
olegnizamov@olegnizamov:~/projects/devops-diplom-yandexcloud/resultansible$ ansible-playbook wordpress.yml -i hosts

PLAY [app] ***********************************************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************************************************************************************************************************************
The authenticity of host 'app.bitrixdemo24.ru (<no hostip for proxy command>)' can't be established.
ECDSA key fingerprint is SHA256:FbLlSPQlPDHmeJswMbua3BrmnB6l1zfG+zy/MOx93Xk.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
ok: [app.bitrixdemo24.ru]

TASK [nginx : Install nginx] *****************************************************************************************************************************************************************************************************************************
changed: [app.bitrixdemo24.ru]

TASK [nginx : Disable default site] **********************************************************************************************************************************************************************************************************************
changed: [app.bitrixdemo24.ru]

TASK [php : Upgrade system] ******************************************************************************************************************************************************************************************************************************
ok: [app.bitrixdemo24.ru]

TASK [php : install php7.4] ******************************************************************************************************************************************************************************************************************************
[DEPRECATION WARNING]: Invoking "apt" only once while using a loop via squash_actions is deprecated. Instead of using a loop to supply multiple items and specifying `pkg: "{{ item }}"`, please use `pkg: ['php7.4', 'php7.4-cgi', 'php-fpm', 
'php7.4-memcache', 'php7.4-memcached', 'php7.4-mysql', 'php7.4-gd', 'php7.4-curl', 'php7.4-xmlrpc']` and remove the loop. This feature will be removed in version 2.11. Deprecation warnings can be disabled by setting deprecation_warnings=False in 
ansible.cfg.
changed: [app.bitrixdemo24.ru] => (item=['php7.4', 'php7.4-cgi', 'php-fpm', 'php7.4-memcache', 'php7.4-memcached', 'php7.4-mysql', 'php7.4-gd', 'php7.4-curl', 'php7.4-xmlrpc'])

TASK [php : change listen socket] ************************************************************************************************************************************************************************************************************************
changed: [app.bitrixdemo24.ru]

TASK [wordpress : Install git] ***************************************************************************************************************************************************************************************************************************
changed: [app.bitrixdemo24.ru]

TASK [wordpress : install nginx configuration] ***********************************************************************************************************************************************************************************************************
changed: [app.bitrixdemo24.ru]

TASK [wordpress : activate site configuration] ***********************************************************************************************************************************************************************************************************
changed: [app.bitrixdemo24.ru]

TASK [wordpress : download WordPress] ********************************************************************************************************************************************************************************************************************
changed: [app.bitrixdemo24.ru]

TASK [wordpress : creating directory for WordPress] ******************************************************************************************************************************************************************************************************
changed: [app.bitrixdemo24.ru]

TASK [wordpress : unpack WordPress installation] *********************************************************************************************************************************************************************************************************
[WARNING]: Consider using the unarchive module rather than running 'tar'.  If you need to use command because unarchive is insufficient you can add 'warn: false' to this command task or set 'command_warnings=False' in ansible.cfg to get rid of this
message.
changed: [app.bitrixdemo24.ru]

TASK [wordpress : wordpress php] *************************************************************************************************************************************************************************************************************************
changed: [app.bitrixdemo24.ru]

RUNNING HANDLER [nginx : restart nginx] ******************************************************************************************************************************************************************************************************************
changed: [app.bitrixdemo24.ru]

RUNNING HANDLER [php : restart php-fpm] ******************************************************************************************************************************************************************************************************************
changed: [app.bitrixdemo24.ru]

PLAY RECAP ***********************************************************************************************************************************************************************************************************************************************
app.bitrixdemo24.ru        : ok=15   changed=13   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

olegnizamov@olegnizamov:~/projects/devops-diplom-yandexcloud/resultansible$ 
```
</details>



**6. Установка Gitlab CE и Gitlab Runner**

Необходимо настроить CI/CD систему для автоматического развертывания приложения при изменении кода.

*Рекомендации:*

• Имена серверов: `gitlab.you.domain` и `runner.you.domain`
• Характеристики: 4vCPU, 4 RAM, Internal address.

*Цель:*

1. Построить pipeline доставки кода в среду эксплуатации, то есть настроить автоматический деплой на сервер app.you.domain при коммите в репозиторий с WordPress.
   Подробнее о [Gitlab CI](https://about.gitlab.com/stages-devops-lifecycle/continuous-integration/)

*Ожидаемый результат:*

1. Интерфейс Gitlab доступен по https.
2. В вашей доменной зоне настроена A-запись на внешний адрес reverse proxy:

* `https://gitlab.you.domain` (Gitlab)

3. На сервере `you.domain` отредактирован upstream для выше указанного URL и он смотрит на виртуальную машину на которой установлен Gitlab.
4. При любом коммите в репозиторий с WordPress и создании тега (например, v1.0.0) происходит деплой на виртуальную машину.

---
```
Ответ: 
Для установки Gitlab создан playbook gitlab.
Используем роль -  https://github.com/geerlingguy/ansible-role-gitlab

Однако необходимо обновиться перед использованием gitlab, поэтому дописываем
- name: Update and upgrade apt packages
  become: true
  apt:
    upgrade: yes
    update_cache: yes
    
Иначе будет такая ошибка:
TASK [gitlab : Install GitLab dependencies (Debian).] ****************************************************************************************************************************************************************************************************
fatal: [gitlab.bitrixdemo24.ru]: FAILED! => {"cache_update_time": 1640351283, "cache_updated": false, "changed": false, "msg": "'/usr/bin/apt-get -y -o \"Dpkg::Options::=--force-confdef\" -o \"Dpkg::Options::=--force-confold\"      install 'gnupg2'' failed: E: Failed to fetch http://mirror.yandex.ru/ubuntu/pool/universe/g/gnupg2/gnupg2_2.2.19-3ubuntu2.1_all.deb  404  Not Found [IP: 192.168.10.20 8118]\nE: Unable to fetch some archives, maybe run apt-get update or try with --fix-missing?\n", "rc": 100, "stderr": "E: Failed to fetch http://mirror.yandex.ru/ubuntu/pool/universe/g/gnupg2/gnupg2_2.2.19-3ubuntu2.1_all.deb  404  Not Found [IP: 192.168.10.20 8118]\nE: Unable to fetch some archives, maybe run apt-get update or try with --fix-missing?\n", "stderr_lines": ["E: Failed to fetch http://mirror.yandex.ru/ubuntu/pool/universe/g/gnupg2/gnupg2_2.2.19-3ubuntu2.1_all.deb  404  Not Found [IP: 192.168.10.20 8118]", "E: Unable to fetch some archives, maybe run apt-get update or try with --fix-missing?"], "stdout": "Reading package lists...\nBuilding dependency tree...\nReading state information...\nThe following NEW packages will be installed:\n  gnupg2\n0 upgraded, 1 newly installed, 0 to remove and 4 not upgraded.\nNeed to get 4584 B of archives.\nAfter this operation, 51.2 kB of additional disk space will be used.\nIgn:1 http://mirror.yandex.ru/ubuntu focal-updates/universe amd64 gnupg2 all 2.2.19-3ubuntu2.1\nErr:1 http://mirror.yandex.ru/ubuntu focal-updates/universe amd64 gnupg2 all 2.2.19-3ubuntu2.1\n  404  Not Found [IP: 192.168.10.20 8118]\n", "stdout_lines": ["Reading package lists...", "Building dependency tree...", "Reading state information...", "The following NEW packages will be installed:", "  gnupg2", "0 upgraded, 1 newly installed, 0 to remove and 4 not upgraded.", "Need to get 4584 B of archives.", "After this operation, 51.2 kB of additional disk space will be used.", "Ign:1 http://mirror.yandex.ru/ubuntu focal-updates/universe amd64 gnupg2 all 2.2.19-3ubuntu2.1", "Err:1 http://mirror.yandex.ru/ubuntu focal-updates/universe amd64 gnupg2 all 2.2.19-3ubuntu2.1", "  404  Not Found [IP: 192.168.10.20 8118]"]}

По умолчанию пользователь:
GitLab's default administrator account details are below; be sure to login immediately after installation and change these credentials!
root
5iveL!fe

Если не удается залогиниться с указанными учетными данными, следует на instans gitlab.bitrixdemo24.ru 
выполнить команду sudo gitlab-rake "gitlab:password:reset[root]", которая сбросит пароль пользователя root и запросит новый.

Заходим и создаем новый проект для wordpress (не забыв сделать gitignore для файла https://github.com/github/gitignore/blob/main/WordPress.gitignore).

Для установки Gitlab Runner следует выполнить playbook - runner. 
В файле `\roles\gitlab-runner\defaults\main.yml` 
необходимо указать gitlab_runner_coordinator_url (адрес сервера GitLab), 
а также gitlab_runner_registration_token (его можно узнать в интерфейсе гитлаба) - к примеру GR1348941Agsg8TnxXHURMxs8yPXZ.


Добавляем код wordpress (заходим на сервер wp и настраиваем гит)
vi .gitignore
sudo git init
sudo git config --global --add safe.directory /var/www/wordpress
sudo git remote add origin http://gitlab.bitrixdemo24.ru/gitlab-instance-7a3cf0a0/wordpress.git


Для обратной задачи - deploy из GitLab  в app.bitrixdemo24.ru была разработана следующая job:

before_script:
  - eval $(ssh-agent -s)
  - echo "$ssh_key" | tr -d '\r' | ssh-add -
  - mkdir -p ~/.ssh
  - chmod 700 ~/.ssh

stages:         
  - deploy

deploy-job:      
  stage: deploy
  only:
    - tags
  script:
    - ssh -o StrictHostKeyChecking=no olegnizamov@app.bitrixdemo24.ru sudo chown olegnizamov /var/www/wordpress/ -R
    - rsync -vz -e "ssh -o StrictHostKeyChecking=no" ./* olegnizamov@app.bitrixdemo24.ru:/var/www/wordpress/
    - ssh -o StrictHostKeyChecking=no olegnizamov@app.bitrixdemo24.ru sudo chown www-data /var/www/wordpress/ -R
### я бы конечно сделал через git pull, но судя по работам других ребят с этим не заморачиваются


При любом коммите в репозиторий с WordPress и создании тега (например, v1.0.0) - тут как я понял логическое И)
```

![](diplom.25.png)

![](diplom.26.png)

![](diplom.27.png)

![](diplom.28.png)

![](diplom.29.png)

![](diplom.30.png)

![](diplom.31.png)

![](diplom.32.png)

![](diplom.33.png)

![](diplom.34.png)

![](diplom.35.png)

![](diplom.36.png)

![](diplom.37.png)

![](diplom.38.png)

![](diplom.39.png)


<details><summary>Ansible</summary>

```
olegnizamov@olegnizamov:~/projects/devops-diplom-yandexcloud/resultansible$ ansible-playbook gitlab.yml -i hosts

PLAY [gitlab] ********************************************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************************************************************************************************************************************
ok: [gitlab.bitrixdemo24.ru]

TASK [gitlab : Update and upgrade apt packages] **********************************************************************************************************************************************************************************************************
[WARNING]: The value True (type bool) in a string field was converted to 'True' (type string). If this does not look like what you expect, quote the entire value to ensure it does not change.
changed: [gitlab.bitrixdemo24.ru]

TASK [gitlab : Include OS-specific variables.] ***********************************************************************************************************************************************************************************************************
ok: [gitlab.bitrixdemo24.ru]

TASK [gitlab : Check if GitLab configuration file already exists.] ***************************************************************************************************************************************************************************************
ok: [gitlab.bitrixdemo24.ru]

TASK [gitlab : Check if GitLab is already installed.] ****************************************************************************************************************************************************************************************************
ok: [gitlab.bitrixdemo24.ru]

TASK [gitlab : Install GitLab dependencies.] *************************************************************************************************************************************************************************************************************
ok: [gitlab.bitrixdemo24.ru]

TASK [gitlab : Install GitLab dependencies (Debian).] ****************************************************************************************************************************************************************************************************
changed: [gitlab.bitrixdemo24.ru]

TASK [gitlab : Download GitLab repository installation script.] ******************************************************************************************************************************************************************************************
changed: [gitlab.bitrixdemo24.ru]

TASK [gitlab : Install GitLab repository.] ***************************************************************************************************************************************************************************************************************
changed: [gitlab.bitrixdemo24.ru]

TASK [gitlab : Define the Gitlab package name.] **********************************************************************************************************************************************************************************************************
skipping: [gitlab.bitrixdemo24.ru]

TASK [gitlab : Install GitLab] ***************************************************************************************************************************************************************************************************************************
changed: [gitlab.bitrixdemo24.ru]

TASK [gitlab : Reconfigure GitLab (first run).] **********************************************************************************************************************************************************************************************************
changed: [gitlab.bitrixdemo24.ru]

TASK [gitlab : Create GitLab SSL configuration folder.] **************************************************************************************************************************************************************************************************
skipping: [gitlab.bitrixdemo24.ru]

TASK [gitlab : Create self-signed certificate.] **********************************************************************************************************************************************************************************************************
skipping: [gitlab.bitrixdemo24.ru]

TASK [gitlab : Copy GitLab configuration file.] **********************************************************************************************************************************************************************************************************
changed: [gitlab.bitrixdemo24.ru]

RUNNING HANDLER [gitlab : restart gitlab] ****************************************************************************************************************************************************************************************************************
changed: [gitlab.bitrixdemo24.ru]

PLAY RECAP ***********************************************************************************************************************************************************************************************************************************************
gitlab.bitrixdemo24.ru     : ok=13   changed=8    unreachable=0    failed=0    skipped=3    rescued=0    ignored=0   

olegnizamov@olegnizamov:~/projects/devops-diplom-yandexcloud/resultansible$ 

olegnizamov@olegnizamov:~/projects/devops-diplom-yandexcloud/resultansible$ ansible-playbook runner.yml -i hosts

PLAY [runner] ********************************************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************************************************************************************************************************************
The authenticity of host 'runner.bitrixdemo24.ru (<no hostip for proxy command>)' can't be established.
ECDSA key fingerprint is SHA256:SjhJAxbPwPWGRpsKI745yRFhamkT5exmG8R1k4XQV4A.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : Load platform-specific variables] **************************************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (Container) Pull Image from Registry] **********************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (Container) Define Container volume Path] ******************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (Container) List configured runners] ***********************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (Container) Check runner is registered] ********************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : configured_runners?] ***************************************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : verified_runners?] *****************************************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (Container) Register GitLab Runner] ************************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru] => (item={'name': 'runner', 'state': 'present', 'executor': 'shell', 'output_limit': 4096, 'concurrent_specific': '0', 'docker_image': '', 'tags': [], 'run_untagged': True, 'protected': False, 'docker_privileged': False, 'locked': 'false', 'docker_network_mode': 'bridge', 'env_vars': []}) 

TASK [gitlab-runner : Create .gitlab-runner dir] *********************************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : Ensure config.toml exists] *********************************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : Set concurrent option] *************************************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : Add listen_address to config] ******************************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : Add log_format to config] **********************************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : Add sentry dsn to config] **********************************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : Add session server listen_address to config] ***************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : Add session server advertise_address to config] ************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : Add session server session_timeout to config] **************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : Get existing config.toml] **********************************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : Get pre-existing runner configs] ***************************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : Create temporary directory] ********************************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : Write config section for each runner] **********************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : Assemble new config.toml] **********************************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (Container) Start the container] ***************************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (Debian) Get Gitlab repository installation script] ********************************************************************************************************************************************************************************
changed: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (Debian) Install Gitlab repository] ************************************************************************************************************************************************************************************************
changed: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (Debian) Update gitlab_runner_package_name] ****************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (Debian) Set gitlab_runner_package_name] *******************************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (Debian) Install GitLab Runner] ****************************************************************************************************************************************************************************************************
changed: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (Debian) Install GitLab Runner] ****************************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (Debian) Remove ~/gitlab-runner/.bash_logout on debian buster and ubuntu focal] ****************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : Ensure /etc/systemd/system/gitlab-runner.service.d/ exists] ************************************************************************************************************************************************************************
changed: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : Add reload command to GitLab Runner system service] ********************************************************************************************************************************************************************************
changed: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : Configure graceful stop for GitLab Runner system service] **************************************************************************************************************************************************************************
changed: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : Force systemd to reread configs] ***************************************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (RedHat) Get Gitlab repository installation script] ********************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (RedHat) Install Gitlab repository] ************************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (RedHat) Update gitlab_runner_package_name] ****************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (RedHat) Set gitlab_runner_package_name] *******************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (RedHat) Install GitLab Runner] ****************************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : Ensure /etc/systemd/system/gitlab-runner.service.d/ exists] ************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : Add reload command to GitLab Runner system service] ********************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : Configure graceful stop for GitLab Runner system service] **************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : Force systemd to reread configs] ***************************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (MacOS) Check gitlab-runner executable exists] *************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (MacOS) Set fact -> gitlab_runner_exists] ******************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (MacOS) Get existing version] ******************************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (MacOS) Set fact -> gitlab_runner_existing_version] ********************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (MacOS) Precreate gitlab-runner log directory] *************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (MacOS) Download GitLab Runner] ****************************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (MacOS) Setting Permissions for gitlab-runner executable] **************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (MacOS) Install GitLab Runner] *****************************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (MacOS) Start GitLab Runner] *******************************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (MacOS) Stop GitLab Runner] ********************************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (MacOS) Download GitLab Runner] ****************************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (MacOS) Setting Permissions for gitlab-runner executable] **************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (MacOS) Start GitLab Runner] *******************************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (Arch) Set gitlab_runner_package_name] *********************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (Arch) Install GitLab Runner] ******************************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : Ensure /etc/systemd/system/gitlab-runner.service.d/ exists] ************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : Add reload command to GitLab Runner system service] ********************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : Configure graceful stop for GitLab Runner system service] **************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : Force systemd to reread configs] ***************************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (Unix) List configured runners] ****************************************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (Unix) Check runner is registered] *************************************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (Unix) Register GitLab Runner] *****************************************************************************************************************************************************************************************************
included: /home/olegnizamov/projects/devops-diplom-yandexcloud/resultansible/roles/gitlab-runner/tasks/register-runner.yml for runner.bitrixdemo24.ru

TASK [gitlab-runner : remove config.toml file] ***********************************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : Create .gitlab-runner dir] *********************************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : Ensure config.toml exists] *********************************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : Construct the runner command without secrets] **************************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : Register runner to GitLab] *********************************************************************************************************************************************************************************************************
changed: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : Create .gitlab-runner dir] *********************************************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : Ensure config.toml exists] *********************************************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : Set concurrent option] *************************************************************************************************************************************************************************************************************
changed: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : Add listen_address to config] ******************************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : Add log_format to config] **********************************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : Add sentry dsn to config] **********************************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : Add session server listen_address to config] ***************************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : Add session server advertise_address to config] ************************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : Add session server session_timeout to config] **************************************************************************************************************************************************************************************
[DEPRECATION WARNING]: evaluating 'gitlab_runner_session_server_session_timeout' as a bare variable, this behaviour will go away and you might need to add |bool to the expression in the future. Also see CONDITIONAL_BARE_VARS configuration toggle. 
This feature will be removed in version 2.12. Deprecation warnings can be disabled by setting deprecation_warnings=False in ansible.cfg.
changed: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : Get existing config.toml] **********************************************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : Get pre-existing runner configs] ***************************************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : Create temporary directory] ********************************************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : Write config section for each runner] **********************************************************************************************************************************************************************************************
included: /home/olegnizamov/projects/devops-diplom-yandexcloud/resultansible/roles/gitlab-runner/tasks/config-runner.yml for runner.bitrixdemo24.ru
included: /home/olegnizamov/projects/devops-diplom-yandexcloud/resultansible/roles/gitlab-runner/tasks/config-runner.yml for runner.bitrixdemo24.ru

TASK [gitlab-runner : conf[1/2]: Create temporary file] **************************************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[1/2]: Isolate runner configuration] *******************************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : include_tasks] *********************************************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru] => (item={'name': 'runner', 'state': 'present', 'executor': 'shell', 'output_limit': 4096, 'concurrent_specific': '0', 'docker_image': '', 'tags': [], 'run_untagged': True, 'protected': False, 'docker_privileged': False, 'locked': 'false', 'docker_network_mode': 'bridge', 'env_vars': []}) 

TASK [gitlab-runner : conf[1/2]: Remove runner config] ***************************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru] => (item={'name': 'runner', 'state': 'present', 'executor': 'shell', 'output_limit': 4096, 'concurrent_specific': '0', 'docker_image': '', 'tags': [], 'run_untagged': True, 'protected': False, 'docker_privileged': False, 'locked': 'false', 'docker_network_mode': 'bridge', 'env_vars': []}) 

TASK [gitlab-runner : conf[2/2]: Create temporary file] **************************************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: Isolate runner configuration] *******************************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : include_tasks] *********************************************************************************************************************************************************************************************************************
included: /home/olegnizamov/projects/devops-diplom-yandexcloud/resultansible/roles/gitlab-runner/tasks/update-config-runner.yml for runner.bitrixdemo24.ru

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set concurrent limit option] *******************************************************************************************************************************************************************************
changed: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set coordinator URL] ***************************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set clone URL] *********************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set environment option] ************************************************************************************************************************************************************************************
changed: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set pre_clone_script] **************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set pre_build_script] **************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set tls_ca_file] *******************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set post_build_script] *************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set runner executor option] ********************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set runner shell option] ***********************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set runner executor section] *******************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set output_limit option] ***********************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set runner docker image option] ****************************************************************************************************************************************************************************
changed: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set docker helper image option] ****************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set docker privileged option] ******************************************************************************************************************************************************************************
changed: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set docker wait_for_services_timeout option] ***************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set docker tlsverify option] *******************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set docker shm_size option] ********************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set docker disable_cache option] ***************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set docker DNS option] *************************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set docker DNS search option] ******************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set docker pull_policy option] *****************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set docker volumes option] *********************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set docker devices option] *********************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set runner docker network option] **************************************************************************************************************************************************************************
changed: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set custom_build_dir section] ******************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set docker custom_build_dir-enabled option] ****************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set cache section] *****************************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set cache s3 section] **************************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set cache gcs section] *************************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set cache azure section] ***********************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set cache type option] *************************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set cache path option] *************************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set cache shared option] ***********************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set cache s3 server addresss] ******************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set cache s3 access key] ***********************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set cache s3 secret key] ***********************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set cache s3 bucket name option] ***************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set cache s3 bucket location option] ***********************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set cache s3 insecure option] ******************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set cache gcs bucket name] *********************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set cache gcs credentials file] ****************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set cache gcs access id] ***********************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set cache gcs private key] *********************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set cache azure account name] ******************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set cache azure account key] *******************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set cache azure container name] ****************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set cache azure storage domain] ****************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set ssh user option] ***************************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set ssh host option] ***************************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set ssh port option] ***************************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set ssh password option] ***********************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set ssh identity file option] ******************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set virtualbox base name option] ***************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set virtualbox base snapshot option] ***********************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set virtualbox base folder option] *************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set virtualbox disable snapshots option] *******************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set builds dir file option] ********************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set cache dir file option] *********************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Ensure directory permissions] ******************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru] => (item=) 
skipping: [runner.bitrixdemo24.ru] => (item=) 

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Ensure directory access test] ******************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru] => (item=) 
skipping: [runner.bitrixdemo24.ru] => (item=) 

TASK [gitlab-runner : conf[2/2]: runner[1/1]: Ensure directory access fail on error] *********************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru] => (item={'changed': False, 'skipped': True, 'skip_reason': 'Conditional result was False', 'item': '', 'ansible_loop_var': 'item'}) 
skipping: [runner.bitrixdemo24.ru] => (item={'changed': False, 'skipped': True, 'skip_reason': 'Conditional result was False', 'item': '', 'ansible_loop_var': 'item'}) 

TASK [gitlab-runner : include_tasks] *********************************************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : conf[2/2]: Remove runner config] ***************************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru] => (item={'name': 'runner', 'state': 'present', 'executor': 'shell', 'output_limit': 4096, 'concurrent_specific': '0', 'docker_image': '', 'tags': [], 'run_untagged': True, 'protected': False, 'docker_privileged': False, 'locked': 'false', 'docker_network_mode': 'bridge', 'env_vars': []}) 

TASK [gitlab-runner : Assemble new config.toml] **********************************************************************************************************************************************************************************************************
changed: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (Windows) Check gitlab-runner executable exists] ***********************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (Windows) Set fact -> gitlab_runner_exists] ****************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (Windows) Get existing version] ****************************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (Windows) Set fact -> gitlab_runner_existing_version] ******************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (Windows) Ensure install directory exists] *****************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (Windows) Download GitLab Runner] **************************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (Windows) Install GitLab Runner] ***************************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (Windows) Install GitLab Runner] ***************************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (Windows) Make sure runner is stopped] *********************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (Windows) Download GitLab Runner] **************************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (Windows) List configured runners] *************************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (Windows) Check runner is registered] **********************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (Windows) Register GitLab Runner] **************************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru] => (item={'name': 'runner', 'state': 'present', 'executor': 'shell', 'output_limit': 4096, 'concurrent_specific': '0', 'docker_image': '', 'tags': [], 'run_untagged': True, 'protected': False, 'docker_privileged': False, 'locked': 'false', 'docker_network_mode': 'bridge', 'env_vars': []}) 

TASK [gitlab-runner : (Windows) Create .gitlab-runner dir] ***********************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (Windows) Ensure config.toml exists] ***********************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (Windows) Set concurrent option] ***************************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (Windows) Add listen_address to config] ********************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (Windows) Add sentry dsn to config] ************************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (Windows) Add session server listen_address to config] *****************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (Windows) Add session server advertise_address to config] **************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (Windows) Add session server session_timeout to config] ****************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (Windows) Get existing config.toml] ************************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (Windows) Get pre-existing global config] ******************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (Windows) Get pre-existing runner configs] *****************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (Windows) Create temporary directory] **********************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (Windows) Write config section for each runner] ************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru] => (item=concurrent = 4
check_interval = 0

) 
skipping: [runner.bitrixdemo24.ru] => (item=  name = "runner"
  output_limit = 4096
  url = "http://gitlab.bitrixdemo24.ru"
  token = "t1fWg1t_tNhChJwx7gmJ"
  executor = "shell"
  [runners.cache]
  session_timeout = 1800
) 

TASK [gitlab-runner : (Windows) Create temporary file config.toml] ***************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (Windows) Write global config to file] *********************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (Windows) Create temporary file runners-config.toml] *******************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (Windows) Assemble runners files in config dir] ************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (Windows) Assemble new config.toml] ************************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (Windows) Verify config] ***********************************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

TASK [gitlab-runner : (Windows) Start GitLab Runner] *****************************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

RUNNING HANDLER [gitlab-runner : restart_gitlab_runner] **************************************************************************************************************************************************************************************************
changed: [runner.bitrixdemo24.ru]

RUNNING HANDLER [gitlab-runner : restart_gitlab_runner_macos] ********************************************************************************************************************************************************************************************
skipping: [runner.bitrixdemo24.ru]

PLAY RECAP ***********************************************************************************************************************************************************************************************************************************************
runner.bitrixdemo24.ru     : ok=82   changed=16   unreachable=0    failed=0    skipped=110  rescued=0    ignored=0   

olegnizamov@olegnizamov:~/projects/devops-diplom-yandexcloud/resultansible$ 

```
</details>

**7. Установка Prometheus, Alert Manager, Node Exporter и Grafana**

Необходимо разработать Ansible роль для установки Prometheus, Alert Manager и Grafana.

*Рекомендации:*

• Имя сервера: `monitoring.you.domain`
• Характеристики: 4vCPU, 4 RAM, Internal address.

*Цель:*

1. Получение метрик со всей инфраструктуры.

*Ожидаемые результаты:*

1. Интерфейсы Prometheus, Alert Manager и Grafana доступены по https.
2. В вашей доменной зоне настроены A-записи на внешний адрес reverse proxy:
   • `https://grafana.you.domain` (Grafana)
   • `https://prometheus.you.domain` (Prometheus)
   • `https://alertmanager.you.domain` (Alert Manager)
3. На сервере `you.domain` отредактированы upstreams для выше указанных URL и они смотрят на виртуальную машину на которой установлены Prometheus, Alert Manager и Grafana.
4. На всех серверах установлен Node Exporter и его метрики доступны Prometheus.
5. У Alert Manager есть необходимый [набор правил](https://awesome-prometheus-alerts.grep.to/rules.html) для создания алертов.
6. В Grafana есть дашборд отображающий метрики из Node Exporter по всем серверам.
7. В Grafana есть дашборд отображающий метрики из MySQL (*).
8. В Grafana есть дашборд отображающий метрики из WordPress (*).

*Примечание: дашборды со звёздочкой являются опциональными заданиями повышенной сложности их выполнение желательно, но не обязательно.*

---
```
Ответ: 

Для настройки данных служб следует использовать playbook nodeexporter.yml, который установит Node Exporter на хосты. 
После запускаем monitoring.yml для установки Prometheus, Alert Manager и Grafana. 
```


![](diplom.40.png)

![](diplom.41.png)

![](diplom.42.png)

![](diplom.43.png)

![](diplom.44.png)

![](diplom.45.png)

![](diplom.46.png)

![](diplom.47.png)

![](diplom.48.png)

![](diplom.49.png)

<details><summary>Ansible</summary>

```
olegnizamov@olegnizamov:~/projects/devops-diplom-yandexcloud/resultansible$ ansible-playbook monitoring.yml -i hosts

PLAY [monitoring] ****************************************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************************************************************************************************************************************
The authenticity of host 'monitoring.bitrixdemo24.ru (<no hostip for proxy command>)' can't be established.
ECDSA key fingerprint is SHA256:7PGEHXBcGCixKqI4WjubWwppoOuXtCmzyRCRYvADQHA.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes     
ok: [monitoring.bitrixdemo24.ru]

TASK [monitoring : Prepare For Install Prometheus] *******************************************************************************************************************************************************************************************************
included: /home/olegnizamov/projects/devops-diplom-yandexcloud/resultansible/roles/monitoring/tasks/prepare.yml for monitoring.bitrixdemo24.ru

TASK [monitoring : Allow Ports] **************************************************************************************************************************************************************************************************************************
skipping: [monitoring.bitrixdemo24.ru] => (item=9090/tcp) 
skipping: [monitoring.bitrixdemo24.ru] => (item=9093/tcp) 
skipping: [monitoring.bitrixdemo24.ru] => (item=9094/tcp) 
skipping: [monitoring.bitrixdemo24.ru] => (item=9100/tcp) 
skipping: [monitoring.bitrixdemo24.ru] => (item=9094/udp) 

TASK [monitoring : Disable SELinux] **********************************************************************************************************************************************************************************************************************
skipping: [monitoring.bitrixdemo24.ru]

TASK [monitoring : Stop SELinux] *************************************************************************************************************************************************************************************************************************
skipping: [monitoring.bitrixdemo24.ru]

TASK [monitoring : Allow TCP Ports] **********************************************************************************************************************************************************************************************************************
changed: [monitoring.bitrixdemo24.ru] => (item=9090)
changed: [monitoring.bitrixdemo24.ru] => (item=9093)
changed: [monitoring.bitrixdemo24.ru] => (item=9094)
changed: [monitoring.bitrixdemo24.ru] => (item=9100)

TASK [monitoring : Allow UDP Ports] **********************************************************************************************************************************************************************************************************************
changed: [monitoring.bitrixdemo24.ru]

TASK [monitoring : Install Prometheus] *******************************************************************************************************************************************************************************************************************
included: /home/olegnizamov/projects/devops-diplom-yandexcloud/resultansible/roles/monitoring/tasks/install_prometheus.yml for monitoring.bitrixdemo24.ru

TASK [monitoring : Create User prometheus] ***************************************************************************************************************************************************************************************************************
changed: [monitoring.bitrixdemo24.ru]

TASK [monitoring : Create directories for prometheus] ****************************************************************************************************************************************************************************************************
changed: [monitoring.bitrixdemo24.ru] => (item=/tmp/prometheus)
changed: [monitoring.bitrixdemo24.ru] => (item=/etc/prometheus)
changed: [monitoring.bitrixdemo24.ru] => (item=/var/lib/prometheus)

TASK [monitoring : Download And Unzipped Prometheus] *****************************************************************************************************************************************************************************************************
changed: [monitoring.bitrixdemo24.ru]

TASK [monitoring : Copy Bin Files From Unzipped to Prometheus] *******************************************************************************************************************************************************************************************
changed: [monitoring.bitrixdemo24.ru] => (item=prometheus)
changed: [monitoring.bitrixdemo24.ru] => (item=promtool)

TASK [monitoring : Copy Conf Files From Unzipped to Prometheus] ******************************************************************************************************************************************************************************************
changed: [monitoring.bitrixdemo24.ru] => (item=console_libraries)
changed: [monitoring.bitrixdemo24.ru] => (item=consoles)
changed: [monitoring.bitrixdemo24.ru] => (item=prometheus.yml)

TASK [monitoring : Create File for Prometheus Systemd] ***************************************************************************************************************************************************************************************************
changed: [monitoring.bitrixdemo24.ru]

TASK [monitoring : copy config] **************************************************************************************************************************************************************************************************************************
changed: [monitoring.bitrixdemo24.ru]

TASK [monitoring : copy alert] ***************************************************************************************************************************************************************************************************************************
changed: [monitoring.bitrixdemo24.ru]

TASK [monitoring : Systemctl Prometheus Start] ***********************************************************************************************************************************************************************************************************
changed: [monitoring.bitrixdemo24.ru]

TASK [monitoring : Install Alertmanager] *****************************************************************************************************************************************************************************************************************
included: /home/olegnizamov/projects/devops-diplom-yandexcloud/resultansible/roles/monitoring/tasks/install_alertmanager.yml for monitoring.bitrixdemo24.ru

TASK [monitoring : Create User Alertmanager] *************************************************************************************************************************************************************************************************************
changed: [monitoring.bitrixdemo24.ru]

TASK [monitoring : Create Directories For Alertmanager] **************************************************************************************************************************************************************************************************
changed: [monitoring.bitrixdemo24.ru] => (item=/tmp/alertmanager)
changed: [monitoring.bitrixdemo24.ru] => (item=/etc/alertmanager)
changed: [monitoring.bitrixdemo24.ru] => (item=/var/lib/prometheus/alertmanager)

TASK [monitoring : Download And Unzipped Alertmanager] ***************************************************************************************************************************************************************************************************
changed: [monitoring.bitrixdemo24.ru]

TASK [monitoring : Copy Bin Files From Unzipped to Alertmanager] *****************************************************************************************************************************************************************************************
changed: [monitoring.bitrixdemo24.ru] => (item=alertmanager)
changed: [monitoring.bitrixdemo24.ru] => (item=amtool)

TASK [monitoring : Copy Conf File From Unzipped to Alertmanager] *****************************************************************************************************************************************************************************************
changed: [monitoring.bitrixdemo24.ru]

TASK [monitoring : Create File for Alertmanager Systemd] *************************************************************************************************************************************************************************************************
changed: [monitoring.bitrixdemo24.ru]

TASK [monitoring : Systemctl Alertmanager Start] *********************************************************************************************************************************************************************************************************
changed: [monitoring.bitrixdemo24.ru]

TASK [grafana : Allow Ports] *****************************************************************************************************************************************************************************************************************************
skipping: [monitoring.bitrixdemo24.ru]

TASK [grafana : Disable SELinux] *************************************************************************************************************************************************************************************************************************
skipping: [monitoring.bitrixdemo24.ru]

TASK [grafana : Stop SELinux] ****************************************************************************************************************************************************************************************************************************
skipping: [monitoring.bitrixdemo24.ru]

TASK [grafana : Add Repository] **************************************************************************************************************************************************************************************************************************
skipping: [monitoring.bitrixdemo24.ru]

TASK [grafana : Install Grafana on RedHat Family] ********************************************************************************************************************************************************************************************************
skipping: [monitoring.bitrixdemo24.ru]

TASK [grafana : Allow TCP Ports] *************************************************************************************************************************************************************************************************************************
changed: [monitoring.bitrixdemo24.ru]

TASK [grafana : Import Grafana Apt Key] ******************************************************************************************************************************************************************************************************************
changed: [monitoring.bitrixdemo24.ru]

TASK [grafana : Add APT Repository] **********************************************************************************************************************************************************************************************************************
changed: [monitoring.bitrixdemo24.ru]

TASK [grafana : Install Grafana on Debian Family] ********************************************************************************************************************************************************************************************************
changed: [monitoring.bitrixdemo24.ru]

RUNNING HANDLER [monitoring : systemd reload] ************************************************************************************************************************************************************************************************************
ok: [monitoring.bitrixdemo24.ru]

RUNNING HANDLER [grafana : grafana systemd] **************************************************************************************************************************************************************************************************************
changed: [monitoring.bitrixdemo24.ru]

PLAY RECAP ***********************************************************************************************************************************************************************************************************************************************
monitoring.bitrixdemo24.ru : ok=28   changed=23   unreachable=0    failed=0    skipped=8    rescued=0    ignored=0   

olegnizamov@olegnizamov:~/projects/devops-diplom-yandexcloud/resultansible$ ansible-playbook nodeexporter.yml -i hosts
[WARNING]: Could not match supplied host pattern, ignoring: MySQL

PLAY [MySQL app gitlab runner monitoring] ****************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************************************************************************************************************************************
ok: [monitoring.bitrixdemo24.ru]
ok: [app.bitrixdemo24.ru]
ok: [runner.bitrixdemo24.ru]
ok: [gitlab.bitrixdemo24.ru]

TASK [install_node_exporter : Assert usage of systemd as an init system] *********************************************************************************************************************************************************************************
ok: [app.bitrixdemo24.ru] => {
    "changed": false,
    "msg": "All assertions passed"
}
ok: [gitlab.bitrixdemo24.ru] => {
    "changed": false,
    "msg": "All assertions passed"
}
ok: [runner.bitrixdemo24.ru] => {
    "changed": false,
    "msg": "All assertions passed"
}
ok: [monitoring.bitrixdemo24.ru] => {
    "changed": false,
    "msg": "All assertions passed"
}

TASK [install_node_exporter : Get systemd version] *******************************************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]
ok: [app.bitrixdemo24.ru]
ok: [gitlab.bitrixdemo24.ru]
ok: [monitoring.bitrixdemo24.ru]

TASK [install_node_exporter : Set systemd version fact] **************************************************************************************************************************************************************************************************
ok: [app.bitrixdemo24.ru]
ok: [gitlab.bitrixdemo24.ru]
ok: [runner.bitrixdemo24.ru]
ok: [monitoring.bitrixdemo24.ru]

TASK [install_node_exporter : Naive assertion of proper listen address] **********************************************************************************************************************************************************************************
ok: [app.bitrixdemo24.ru] => {
    "changed": false,
    "msg": "All assertions passed"
}
ok: [gitlab.bitrixdemo24.ru] => {
    "changed": false,
    "msg": "All assertions passed"
}
ok: [runner.bitrixdemo24.ru] => {
    "changed": false,
    "msg": "All assertions passed"
}
ok: [monitoring.bitrixdemo24.ru] => {
    "changed": false,
    "msg": "All assertions passed"
}

TASK [install_node_exporter : Assert collectors are not both disabled and enabled at the same time] ******************************************************************************************************************************************************

TASK [install_node_exporter : Assert that TLS key and cert path are set] *********************************************************************************************************************************************************************************
skipping: [app.bitrixdemo24.ru]
skipping: [gitlab.bitrixdemo24.ru]
skipping: [runner.bitrixdemo24.ru]
skipping: [monitoring.bitrixdemo24.ru]

TASK [install_node_exporter : Check existence of TLS cert file] ******************************************************************************************************************************************************************************************
skipping: [app.bitrixdemo24.ru]
skipping: [gitlab.bitrixdemo24.ru]
skipping: [runner.bitrixdemo24.ru]
skipping: [monitoring.bitrixdemo24.ru]

TASK [install_node_exporter : Check existence of TLS key file] *******************************************************************************************************************************************************************************************
skipping: [app.bitrixdemo24.ru]
skipping: [gitlab.bitrixdemo24.ru]
skipping: [runner.bitrixdemo24.ru]
skipping: [monitoring.bitrixdemo24.ru]

TASK [install_node_exporter : Assert that TLS key and cert are present] **********************************************************************************************************************************************************************************
skipping: [app.bitrixdemo24.ru]
skipping: [gitlab.bitrixdemo24.ru]
skipping: [runner.bitrixdemo24.ru]
skipping: [monitoring.bitrixdemo24.ru]

TASK [install_node_exporter : Check if node_exporter is installed] ***************************************************************************************************************************************************************************************
ok: [runner.bitrixdemo24.ru]
ok: [app.bitrixdemo24.ru]
ok: [gitlab.bitrixdemo24.ru]
ok: [monitoring.bitrixdemo24.ru]

TASK [install_node_exporter : Gather currently installed node_exporter version (if any)] *****************************************************************************************************************************************************************
skipping: [app.bitrixdemo24.ru]
skipping: [gitlab.bitrixdemo24.ru]
skipping: [runner.bitrixdemo24.ru]
skipping: [monitoring.bitrixdemo24.ru]

TASK [install_node_exporter : Get latest release] ********************************************************************************************************************************************************************************************************
skipping: [app.bitrixdemo24.ru]

TASK [install_node_exporter : Set node_exporter version to {{ _latest_release.json.tag_name[1:] }}] ******************************************************************************************************************************************************
skipping: [app.bitrixdemo24.ru]

TASK [install_node_exporter : Get checksum list from github] *********************************************************************************************************************************************************************************************
ok: [app.bitrixdemo24.ru -> localhost]

TASK [install_node_exporter : Get checksum for amd64 architecture] ***************************************************************************************************************************************************************************************
skipping: [app.bitrixdemo24.ru] => (item=3919266f1dbad5f7e5ce7b4207057fc253a8322f570607cc0f3e73f4a53338e3  node_exporter-1.1.2.darwin-amd64.tar.gz) 
skipping: [app.bitrixdemo24.ru] => (item=5b0195e203dedd3a8973cd1894a55097554a4af6d8f4f0614c2c67d6670ea8ae  node_exporter-1.1.2.linux-386.tar.gz) 
ok: [app.bitrixdemo24.ru -> localhost] => (item=8c1f6a317457a658e0ae68ad710f6b4098db2cad10204649b51e3c043aa3e70d  node_exporter-1.1.2.linux-amd64.tar.gz)
skipping: [app.bitrixdemo24.ru] => (item=eb5e7d16f18bb3272d0d832986fc8ac6cb0b6c42d487c94e15dabb10feae8e04  node_exporter-1.1.2.linux-arm64.tar.gz) 
skipping: [app.bitrixdemo24.ru] => (item=41892e451e80160491a1cc7bbe6bccd6cb842ae8340e1bc6e32f72cefb1aee80  node_exporter-1.1.2.linux-armv5.tar.gz) 
skipping: [gitlab.bitrixdemo24.ru] => (item=3919266f1dbad5f7e5ce7b4207057fc253a8322f570607cc0f3e73f4a53338e3  node_exporter-1.1.2.darwin-amd64.tar.gz) 
skipping: [gitlab.bitrixdemo24.ru] => (item=5b0195e203dedd3a8973cd1894a55097554a4af6d8f4f0614c2c67d6670ea8ae  node_exporter-1.1.2.linux-386.tar.gz) 
ok: [gitlab.bitrixdemo24.ru -> localhost] => (item=8c1f6a317457a658e0ae68ad710f6b4098db2cad10204649b51e3c043aa3e70d  node_exporter-1.1.2.linux-amd64.tar.gz)
skipping: [app.bitrixdemo24.ru] => (item=1cc1bf4cacb84d6c228d9ce8045b5b00b73afd954046f7b2add428a04d14daee  node_exporter-1.1.2.linux-armv6.tar.gz) 
skipping: [gitlab.bitrixdemo24.ru] => (item=eb5e7d16f18bb3272d0d832986fc8ac6cb0b6c42d487c94e15dabb10feae8e04  node_exporter-1.1.2.linux-arm64.tar.gz) 
skipping: [app.bitrixdemo24.ru] => (item=a9fe816eb7b976b1587d6d654c437f7d78349f70686fa22ae33e94fe84281af2  node_exporter-1.1.2.linux-armv7.tar.gz) 
skipping: [runner.bitrixdemo24.ru] => (item=3919266f1dbad5f7e5ce7b4207057fc253a8322f570607cc0f3e73f4a53338e3  node_exporter-1.1.2.darwin-amd64.tar.gz) 
skipping: [gitlab.bitrixdemo24.ru] => (item=41892e451e80160491a1cc7bbe6bccd6cb842ae8340e1bc6e32f72cefb1aee80  node_exporter-1.1.2.linux-armv5.tar.gz) 
skipping: [app.bitrixdemo24.ru] => (item=a99ab2cdc62db25ff01d184e21ad433e3949cd791fc2c80b6bacc6b90d5a62c2  node_exporter-1.1.2.linux-mips.tar.gz) 
skipping: [app.bitrixdemo24.ru] => (item=22d9c2a5363502c79e0645ba02eafd9561b33d1e0e819ce4df3fcf7dc96e3792  node_exporter-1.1.2.linux-mips64.tar.gz) 
skipping: [gitlab.bitrixdemo24.ru] => (item=1cc1bf4cacb84d6c228d9ce8045b5b00b73afd954046f7b2add428a04d14daee  node_exporter-1.1.2.linux-armv6.tar.gz) 
skipping: [app.bitrixdemo24.ru] => (item=a66b70690c3c4fff953905a041c74834f96be85a806e74a1cc925e607ef50a26  node_exporter-1.1.2.linux-mips64le.tar.gz) 
skipping: [runner.bitrixdemo24.ru] => (item=5b0195e203dedd3a8973cd1894a55097554a4af6d8f4f0614c2c67d6670ea8ae  node_exporter-1.1.2.linux-386.tar.gz) 
skipping: [gitlab.bitrixdemo24.ru] => (item=a9fe816eb7b976b1587d6d654c437f7d78349f70686fa22ae33e94fe84281af2  node_exporter-1.1.2.linux-armv7.tar.gz) 
skipping: [app.bitrixdemo24.ru] => (item=f7fba791cbc758b021d0e9a2400c82d1f29337e568ab00edc84b053ca467ea3c  node_exporter-1.1.2.linux-mipsle.tar.gz) 
ok: [runner.bitrixdemo24.ru -> localhost] => (item=8c1f6a317457a658e0ae68ad710f6b4098db2cad10204649b51e3c043aa3e70d  node_exporter-1.1.2.linux-amd64.tar.gz)
skipping: [gitlab.bitrixdemo24.ru] => (item=a99ab2cdc62db25ff01d184e21ad433e3949cd791fc2c80b6bacc6b90d5a62c2  node_exporter-1.1.2.linux-mips.tar.gz) 
skipping: [app.bitrixdemo24.ru] => (item=294c0b05dff4f368512449de7268e3f06de679a9343e9885044adc702865080b  node_exporter-1.1.2.linux-ppc64.tar.gz) 
skipping: [app.bitrixdemo24.ru] => (item=d1d201b16d757980db654bb9e448ab0c81ca4c2715243c3fa4305bef5967bd41  node_exporter-1.1.2.linux-ppc64le.tar.gz) 
skipping: [gitlab.bitrixdemo24.ru] => (item=22d9c2a5363502c79e0645ba02eafd9561b33d1e0e819ce4df3fcf7dc96e3792  node_exporter-1.1.2.linux-mips64.tar.gz) 
skipping: [app.bitrixdemo24.ru] => (item=6007420f425d08626c05de2dbe0e8bb785a16bba1b02c01cb06d37d7fab3bc97  node_exporter-1.1.2.linux-s390x.tar.gz) 
skipping: [app.bitrixdemo24.ru] => (item=0596e9c1cc358e6fcc60cb83f0d1ba9a37ccee11eca035429c9791c0beb04389  node_exporter-1.1.2.netbsd-386.tar.gz) 
skipping: [gitlab.bitrixdemo24.ru] => (item=a66b70690c3c4fff953905a041c74834f96be85a806e74a1cc925e607ef50a26  node_exporter-1.1.2.linux-mips64le.tar.gz) 
skipping: [runner.bitrixdemo24.ru] => (item=eb5e7d16f18bb3272d0d832986fc8ac6cb0b6c42d487c94e15dabb10feae8e04  node_exporter-1.1.2.linux-arm64.tar.gz) 
skipping: [gitlab.bitrixdemo24.ru] => (item=f7fba791cbc758b021d0e9a2400c82d1f29337e568ab00edc84b053ca467ea3c  node_exporter-1.1.2.linux-mipsle.tar.gz) 
skipping: [app.bitrixdemo24.ru] => (item=46c964efd336f0e35f62c739ce9edf5409911e7652604e411c9b684eb9c48386  node_exporter-1.1.2.netbsd-amd64.tar.gz) 
skipping: [app.bitrixdemo24.ru] => (item=d81f86f57a4ed167a4062aa47f8a70b35c146c86bc8e40924c9d1fc3644ec8e6  node_exporter-1.1.2.openbsd-amd64.tar.gz) 
skipping: [runner.bitrixdemo24.ru] => (item=41892e451e80160491a1cc7bbe6bccd6cb842ae8340e1bc6e32f72cefb1aee80  node_exporter-1.1.2.linux-armv5.tar.gz) 
skipping: [runner.bitrixdemo24.ru] => (item=1cc1bf4cacb84d6c228d9ce8045b5b00b73afd954046f7b2add428a04d14daee  node_exporter-1.1.2.linux-armv6.tar.gz) 
skipping: [runner.bitrixdemo24.ru] => (item=a9fe816eb7b976b1587d6d654c437f7d78349f70686fa22ae33e94fe84281af2  node_exporter-1.1.2.linux-armv7.tar.gz) 
skipping: [gitlab.bitrixdemo24.ru] => (item=294c0b05dff4f368512449de7268e3f06de679a9343e9885044adc702865080b  node_exporter-1.1.2.linux-ppc64.tar.gz) 
skipping: [gitlab.bitrixdemo24.ru] => (item=d1d201b16d757980db654bb9e448ab0c81ca4c2715243c3fa4305bef5967bd41  node_exporter-1.1.2.linux-ppc64le.tar.gz) 
skipping: [gitlab.bitrixdemo24.ru] => (item=6007420f425d08626c05de2dbe0e8bb785a16bba1b02c01cb06d37d7fab3bc97  node_exporter-1.1.2.linux-s390x.tar.gz) 
skipping: [gitlab.bitrixdemo24.ru] => (item=0596e9c1cc358e6fcc60cb83f0d1ba9a37ccee11eca035429c9791c0beb04389  node_exporter-1.1.2.netbsd-386.tar.gz) 
skipping: [gitlab.bitrixdemo24.ru] => (item=46c964efd336f0e35f62c739ce9edf5409911e7652604e411c9b684eb9c48386  node_exporter-1.1.2.netbsd-amd64.tar.gz) 
skipping: [runner.bitrixdemo24.ru] => (item=a99ab2cdc62db25ff01d184e21ad433e3949cd791fc2c80b6bacc6b90d5a62c2  node_exporter-1.1.2.linux-mips.tar.gz) 
skipping: [monitoring.bitrixdemo24.ru] => (item=3919266f1dbad5f7e5ce7b4207057fc253a8322f570607cc0f3e73f4a53338e3  node_exporter-1.1.2.darwin-amd64.tar.gz) 
skipping: [monitoring.bitrixdemo24.ru] => (item=5b0195e203dedd3a8973cd1894a55097554a4af6d8f4f0614c2c67d6670ea8ae  node_exporter-1.1.2.linux-386.tar.gz) 
skipping: [runner.bitrixdemo24.ru] => (item=22d9c2a5363502c79e0645ba02eafd9561b33d1e0e819ce4df3fcf7dc96e3792  node_exporter-1.1.2.linux-mips64.tar.gz) 
ok: [monitoring.bitrixdemo24.ru -> localhost] => (item=8c1f6a317457a658e0ae68ad710f6b4098db2cad10204649b51e3c043aa3e70d  node_exporter-1.1.2.linux-amd64.tar.gz)
skipping: [gitlab.bitrixdemo24.ru] => (item=d81f86f57a4ed167a4062aa47f8a70b35c146c86bc8e40924c9d1fc3644ec8e6  node_exporter-1.1.2.openbsd-amd64.tar.gz) 
skipping: [runner.bitrixdemo24.ru] => (item=a66b70690c3c4fff953905a041c74834f96be85a806e74a1cc925e607ef50a26  node_exporter-1.1.2.linux-mips64le.tar.gz) 
skipping: [monitoring.bitrixdemo24.ru] => (item=eb5e7d16f18bb3272d0d832986fc8ac6cb0b6c42d487c94e15dabb10feae8e04  node_exporter-1.1.2.linux-arm64.tar.gz) 
skipping: [monitoring.bitrixdemo24.ru] => (item=41892e451e80160491a1cc7bbe6bccd6cb842ae8340e1bc6e32f72cefb1aee80  node_exporter-1.1.2.linux-armv5.tar.gz) 
skipping: [runner.bitrixdemo24.ru] => (item=f7fba791cbc758b021d0e9a2400c82d1f29337e568ab00edc84b053ca467ea3c  node_exporter-1.1.2.linux-mipsle.tar.gz) 
skipping: [monitoring.bitrixdemo24.ru] => (item=1cc1bf4cacb84d6c228d9ce8045b5b00b73afd954046f7b2add428a04d14daee  node_exporter-1.1.2.linux-armv6.tar.gz) 
skipping: [runner.bitrixdemo24.ru] => (item=294c0b05dff4f368512449de7268e3f06de679a9343e9885044adc702865080b  node_exporter-1.1.2.linux-ppc64.tar.gz) 
skipping: [monitoring.bitrixdemo24.ru] => (item=a9fe816eb7b976b1587d6d654c437f7d78349f70686fa22ae33e94fe84281af2  node_exporter-1.1.2.linux-armv7.tar.gz) 
skipping: [runner.bitrixdemo24.ru] => (item=d1d201b16d757980db654bb9e448ab0c81ca4c2715243c3fa4305bef5967bd41  node_exporter-1.1.2.linux-ppc64le.tar.gz) 
skipping: [monitoring.bitrixdemo24.ru] => (item=a99ab2cdc62db25ff01d184e21ad433e3949cd791fc2c80b6bacc6b90d5a62c2  node_exporter-1.1.2.linux-mips.tar.gz) 
skipping: [runner.bitrixdemo24.ru] => (item=6007420f425d08626c05de2dbe0e8bb785a16bba1b02c01cb06d37d7fab3bc97  node_exporter-1.1.2.linux-s390x.tar.gz) 
skipping: [monitoring.bitrixdemo24.ru] => (item=22d9c2a5363502c79e0645ba02eafd9561b33d1e0e819ce4df3fcf7dc96e3792  node_exporter-1.1.2.linux-mips64.tar.gz) 
skipping: [runner.bitrixdemo24.ru] => (item=0596e9c1cc358e6fcc60cb83f0d1ba9a37ccee11eca035429c9791c0beb04389  node_exporter-1.1.2.netbsd-386.tar.gz) 
skipping: [monitoring.bitrixdemo24.ru] => (item=a66b70690c3c4fff953905a041c74834f96be85a806e74a1cc925e607ef50a26  node_exporter-1.1.2.linux-mips64le.tar.gz) 
skipping: [runner.bitrixdemo24.ru] => (item=46c964efd336f0e35f62c739ce9edf5409911e7652604e411c9b684eb9c48386  node_exporter-1.1.2.netbsd-amd64.tar.gz) 
skipping: [monitoring.bitrixdemo24.ru] => (item=f7fba791cbc758b021d0e9a2400c82d1f29337e568ab00edc84b053ca467ea3c  node_exporter-1.1.2.linux-mipsle.tar.gz) 
skipping: [runner.bitrixdemo24.ru] => (item=d81f86f57a4ed167a4062aa47f8a70b35c146c86bc8e40924c9d1fc3644ec8e6  node_exporter-1.1.2.openbsd-amd64.tar.gz) 
skipping: [monitoring.bitrixdemo24.ru] => (item=294c0b05dff4f368512449de7268e3f06de679a9343e9885044adc702865080b  node_exporter-1.1.2.linux-ppc64.tar.gz) 
skipping: [monitoring.bitrixdemo24.ru] => (item=d1d201b16d757980db654bb9e448ab0c81ca4c2715243c3fa4305bef5967bd41  node_exporter-1.1.2.linux-ppc64le.tar.gz) 
skipping: [monitoring.bitrixdemo24.ru] => (item=6007420f425d08626c05de2dbe0e8bb785a16bba1b02c01cb06d37d7fab3bc97  node_exporter-1.1.2.linux-s390x.tar.gz) 
skipping: [monitoring.bitrixdemo24.ru] => (item=0596e9c1cc358e6fcc60cb83f0d1ba9a37ccee11eca035429c9791c0beb04389  node_exporter-1.1.2.netbsd-386.tar.gz) 
skipping: [monitoring.bitrixdemo24.ru] => (item=46c964efd336f0e35f62c739ce9edf5409911e7652604e411c9b684eb9c48386  node_exporter-1.1.2.netbsd-amd64.tar.gz) 
skipping: [monitoring.bitrixdemo24.ru] => (item=d81f86f57a4ed167a4062aa47f8a70b35c146c86bc8e40924c9d1fc3644ec8e6  node_exporter-1.1.2.openbsd-amd64.tar.gz) 

TASK [install_node_exporter : Create the node_exporter group] ********************************************************************************************************************************************************************************************
changed: [runner.bitrixdemo24.ru]
changed: [gitlab.bitrixdemo24.ru]
changed: [monitoring.bitrixdemo24.ru]
changed: [app.bitrixdemo24.ru]

TASK [install_node_exporter : Create the node_exporter user] *********************************************************************************************************************************************************************************************
changed: [app.bitrixdemo24.ru]
changed: [gitlab.bitrixdemo24.ru]
changed: [runner.bitrixdemo24.ru]
changed: [monitoring.bitrixdemo24.ru]

TASK [install_node_exporter : Download node_exporter binary to local folder] *****************************************************************************************************************************************************************************

ok: [gitlab.bitrixdemo24.ru -> localhost]
ok: [app.bitrixdemo24.ru -> localhost]
ok: [monitoring.bitrixdemo24.ru -> localhost]
ok: [runner.bitrixdemo24.ru -> localhost]

TASK [install_node_exporter : Unpack node_exporter binary] ***********************************************************************************************************************************************************************************************
skipping: [gitlab.bitrixdemo24.ru]
skipping: [app.bitrixdemo24.ru]
skipping: [monitoring.bitrixdemo24.ru]
skipping: [runner.bitrixdemo24.ru]

TASK [install_node_exporter : Propagate node_exporter binaries] ******************************************************************************************************************************************************************************************
changed: [runner.bitrixdemo24.ru]
changed: [monitoring.bitrixdemo24.ru]
changed: [app.bitrixdemo24.ru]
changed: [gitlab.bitrixdemo24.ru]

TASK [install_node_exporter : propagate locally distributed node_exporter binary] ************************************************************************************************************************************************************************
skipping: [app.bitrixdemo24.ru]
skipping: [runner.bitrixdemo24.ru]
skipping: [gitlab.bitrixdemo24.ru]
skipping: [monitoring.bitrixdemo24.ru]

TASK [install_node_exporter : Install selinux python packages [RHEL]] ************************************************************************************************************************************************************************************
skipping: [app.bitrixdemo24.ru]
skipping: [gitlab.bitrixdemo24.ru]
skipping: [runner.bitrixdemo24.ru]
skipping: [monitoring.bitrixdemo24.ru]

TASK [install_node_exporter : Install selinux python packages [Fedora]] **********************************************************************************************************************************************************************************
skipping: [app.bitrixdemo24.ru]
skipping: [runner.bitrixdemo24.ru]
skipping: [gitlab.bitrixdemo24.ru]
skipping: [monitoring.bitrixdemo24.ru]

TASK [install_node_exporter : Install selinux python packages [clearlinux]] ******************************************************************************************************************************************************************************
skipping: [app.bitrixdemo24.ru]
skipping: [gitlab.bitrixdemo24.ru]
skipping: [runner.bitrixdemo24.ru]
skipping: [monitoring.bitrixdemo24.ru]

TASK [install_node_exporter : Copy the node_exporter systemd service file] *******************************************************************************************************************************************************************************
changed: [runner.bitrixdemo24.ru]
changed: [app.bitrixdemo24.ru]
changed: [gitlab.bitrixdemo24.ru]
changed: [monitoring.bitrixdemo24.ru]

TASK [install_node_exporter : Create node_exporter config directory] *************************************************************************************************************************************************************************************
skipping: [app.bitrixdemo24.ru]
skipping: [gitlab.bitrixdemo24.ru]
skipping: [runner.bitrixdemo24.ru]
skipping: [monitoring.bitrixdemo24.ru]

TASK [install_node_exporter : Copy the node_exporter config file] ****************************************************************************************************************************************************************************************
skipping: [app.bitrixdemo24.ru]
skipping: [gitlab.bitrixdemo24.ru]
skipping: [runner.bitrixdemo24.ru]
skipping: [monitoring.bitrixdemo24.ru]

TASK [install_node_exporter : Create textfile collector dir] *********************************************************************************************************************************************************************************************
changed: [runner.bitrixdemo24.ru]
changed: [gitlab.bitrixdemo24.ru]
changed: [app.bitrixdemo24.ru]
changed: [monitoring.bitrixdemo24.ru]

TASK [install_node_exporter : Allow node_exporter port in SELinux on RedHat OS family] *******************************************************************************************************************************************************************
skipping: [app.bitrixdemo24.ru]
skipping: [gitlab.bitrixdemo24.ru]
skipping: [runner.bitrixdemo24.ru]
skipping: [monitoring.bitrixdemo24.ru]

TASK [install_node_exporter : Ensure Node Exporter is enabled on boot] ***********************************************************************************************************************************************************************************
changed: [runner.bitrixdemo24.ru]
changed: [app.bitrixdemo24.ru]
changed: [monitoring.bitrixdemo24.ru]
changed: [gitlab.bitrixdemo24.ru]

RUNNING HANDLER [install_node_exporter : restart node_exporter] ******************************************************************************************************************************************************************************************
changed: [runner.bitrixdemo24.ru]
changed: [app.bitrixdemo24.ru]
changed: [gitlab.bitrixdemo24.ru]
changed: [monitoring.bitrixdemo24.ru]

PLAY RECAP ***********************************************************************************************************************************************************************************************************************************************
app.bitrixdemo24.ru        : ok=16   changed=7    unreachable=0    failed=0    skipped=16   rescued=0    ignored=0   
gitlab.bitrixdemo24.ru     : ok=15   changed=7    unreachable=0    failed=0    skipped=14   rescued=0    ignored=0   
monitoring.bitrixdemo24.ru : ok=15   changed=7    unreachable=0    failed=0    skipped=14   rescued=0    ignored=0   
runner.bitrixdemo24.ru     : ok=15   changed=7    unreachable=0    failed=0    skipped=14   rescued=0    ignored=0   

olegnizamov@olegnizamov:~/projects/devops-diplom-yandexcloud/resultansible$ 

```
</details>

**Что необходимо для сдачи задания?**

1. Репозиторий со всеми Terraform манифестами и готовность продемонстрировать создание всех ресурсов с нуля.
2. Репозиторий со всеми Ansible ролями и готовность продемонстрировать установку всех сервисов с нуля.
3. Скриншоты веб-интерфейсов всех сервисов работающих по HTTPS на вашем доменном имени.

* `https://www.you.domain` (WordPress)
* `https://gitlab.you.domain` (Gitlab)
* `https://grafana.you.domain` (Grafana)
* `https://prometheus.you.domain` (Prometheus)
* `https://alertmanager.you.domain` (Alert Manager)

5. Все репозитории рекомендуется хранить на одном из ресурсов ([github.com](https://github.com/) или [gitlab.com](https://about.gitlab.com/)).

```
Ответ: 
```
![](diplom.50.png)

![](diplom.51.png)

![](diplom.52.png)

![](diplom.53.png)

![](diplom.54.png)


Ссылки для себя:
https://cloud.yandex.ru/docs/vpc/operations/get-static-ip

https://cloud.yandex.ru/docs/compute/operations/images-with-pre-installed-software/get-list  

yc compute image list --folder-id standard-images

https://webhamster.ru/mytetrashare/index/mtb0/15749415036y9pxcsihd

terraform apply -auto-approve

terraform destroy -auto-approve

ansible-playbook nginx.yml -i hosts

ansible-playbook mysql.yml -i hosts

ansible-playbook wordpress.yml -i hosts

ansible-playbook gitlab.yml -i hosts

