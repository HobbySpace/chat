# Установка Tinode

Файл конфигурации [`tinode.conf`](./server/tinode.conf) содержит подробные инструкции по настройке сервера.

## Установка из бинарных файлов

1. Посетите [страницу релизов](https://github.com/tinode/chat/releases/), выберите последний или наиболее подходящий релиз. Из списка бинарных файлов скачайте тот, который подходит для вашей базы данных и платформы. После загрузки бинарного файла распакуйте его в выбранную директорию, перейдите в эту директорию с помощью `cd`.

2. Убедитесь, что ваша база данных запущена. Убедитесь, что она настроена на прием соединений с `localhost`. В случае MySQL, Tinode попытается подключиться как `root` без пароля. В случае PostgreSQL, Tinode попытается подключиться как `postgres` с паролем `postgres`. См. примечания ниже (_Сборка из исходников_, раздел 4) о том, как настроить Tinode для использования другого пользователя или пароля. Требуется MySQL 5.7 или выше (используйте InnoDB, а не MyISAM движок хранения). MySQL 5.6 или ниже **не будет работать**, использование MyISAM **вызовет проблемы**. Требуется PostgreSQL 13 или выше. PostgreSQL 12 или ниже **не будет работать**.

3. Запустите инициализатор базы данных `init-db` (или `init-db.exe` в Windows):
	```
	./init-db -data=data.json
	```

4. Запустите сервер `tinode` (или `tinode.exe` в Windows). Он будет работать без каких-либо параметров.
	```
	./tinode
	```

5. Протестируйте установку, открыв в браузере http://localhost:6060/


## Docker

См. [инструкции](./docker/README.md)


## Сборка из исходников

1. Установите [окружение Go](https://golang.org/doc/install). Инструкции по установке ниже предназначены для Go 1.18 и новее.

2. ОПЦИОНАЛЬНО, только если вы намерены изменять код: Установите [protobuf](https://developers.google.com/protocol-buffers/) и [gRPC](https://grpc.io/docs/languages/go/quickstart/), включая [генератор кода](https://developers.google.com/protocol-buffers/docs/reference/go-generated) для Go.

3. Убедитесь, что одна из следующих баз данных установлена и запущена:
 * MySQL 5.7 или выше, настроенная с движком `InnoDB`. MySQL 5.6 или ниже **не будет работать**.
 * PostgreSQL 13 или выше. PostgreSQL 12 или ниже **не будет работать**.
 * MongoDB 4.4 или выше. MongoDB 4.2 и ниже **не будет работать**.
 * RethinkDB (устарело, поддержка будет прекращена в 2027 году).

4. Получите, соберите сервер Tinode и инициализатор базы данных tinode-db:
  - **MySQL**:
	```
	go install -tags mysql github.com/tinode/chat/server@latest
	go install -tags mysql github.com/tinode/chat/tinode-db@latest
	```
  - **PostgreSQL**:
	```
	go install -tags postgres github.com/tinode/chat/server@latest
	go install -tags postgres github.com/tinode/chat/tinode-db@latest
	```
  - **MongoDB**:
	```
	go install -tags mongodb github.com/tinode/chat/server@latest
	go install -tags mongodb github.com/tinode/chat/tinode-db@latest
	```
  - **RethinkDb**:
	```
	go install -tags rethinkdb github.com/tinode/chat/server@latest
	go install -tags rethinkdb github.com/tinode/chat/tinode-db@latest
	```
  - **Все** (объединить все вышеперечисленные адаптеры БД):
	```
	go install -tags "mysql rethinkdb mongodb postgres" github.com/tinode/chat/server@latest
	go install -tags "mysql rethinkdb mongodb postgres" github.com/tinode/chat/tinode-db@latest
	```

    Шаги выше устанавливают бинарные файлы Tinode в `$GOPATH/bin/`, исходники и вспомогательные файлы находятся в `$GOPATH/pkg/mod/github.com/tinode/chat@vX.XX.X/`, где `X.XX.X` — это установленная версия, например `0.19.1`.

    Обратите внимание на требуемую опцию сборки **`-tags rethinkdb`**, **`-tags mysql`**, **`-tags mongodb`** или **`-tags postgres`**.

    Вы также можете опционально определить `main.buildstamp` для сервера, добавив опцию сборки, например, с временной меткой:
    ```
    go install -tags mysql -ldflags "-X main.buildstamp=`date -u '+%Y%m%dT%H:%M:%SZ'`" github.com/tinode/chat/server@latest
    ```
    Значение `buildstamp` будет отправлено сервером клиентам.

    Сборка с Go 1.17 или ниже **завершится ошибкой**!

5. Откройте `tinode.conf` (находится в `$GOPATH/pkg/mod/github.com/tinode/chat@vX.XX.X/server/`). Проверьте, что параметры подключения к базе данных корректны для вашей базы данных. Если вы используете MySQL, убедитесь, что [DSN](https://github.com/go-sql-driver/mysql#dsn-data-source-name) в разделе `"mysql"` подходит для вашей установки MySQL. Опция `parseTime=true` обязательна.
```js
	"mysql": {
		"dsn": "root@tcp(localhost)/tinode?parseTime=true",
		"database": "tinode"
	},
```

6. Убедитесь, что вы указали имя адаптера в вашем `tinode.conf`. Например, вы хотите запустить Tinode с MySQL:
```js
	"store_config": {
		...
		"use_adapter": "mysql",
		...
	},
```

7. Теперь, когда вы собрали бинарные файлы, следуйте инструкциям в разделе _Запуск автономного сервера_.


## Запуск автономного сервера

Если вы следовали инструкциям в предыдущем разделе, то бинарные файлы Tinode установлены в `$GOPATH/bin/`, исходники и вспомогательные файлы находятся в `$GOPATH/pkg/mod/github.com/tinode/chat@vX.XX.X/`, где `X.XX.X` — это установленная версия, например `0.19.1`.

Перейдите в директорию исходников (замените `X.XX.X` на вашу фактическую версию, например `0.19.1`):
```
cd $GOPATH/pkg/mod/github.com/tinode/chat@vX.XX.X
```

1. Убедитесь, что ваша база данных запущена:
 - **MySQL**: https://dev.mysql.com/doc/mysql-startstop-excerpt/5.7/en/mysql-server.html
	```
	mysql.server start
	```
 - **PostgreSQL**: https://www.postgresql.org/docs/current/app-pg-ctl.html
	```
	pg_ctl start
	```
 - **MongoDB**: https://docs.mongodb.com/manual/administration/install-community/
MongoDB должен работать как одноузловой репликасет. См. https://docs.mongodb.com/manual/administration/replica-set-deployment/
	```
	mongod
	```
 - **RethinkDB**: https://www.rethinkdb.com/docs/start-a-server/
	```
	rethinkdb --bind all --daemon
	```

2. Запустите инициализатор БД
	```
	$GOPATH/bin/tinode-db -config=./tinode-db/tinode.conf
	```
	добавьте флаг `-data=./tinode-db/data.json`, если вы хотите загрузить тестовые данные:
	```
	$GOPATH/bin/tinode-db -config=./tinode-db/tinode.conf -data=./tinode-db/data.json
	```

	Инициализатор БД нужно запускать только один раз за установку. См. [инструкции](tinode-db/README.md) для дополнительных опций.

3. Распакуйте JS клиент в директорию, например `$HOME/tinode/webapp/`, распаковав `https://github.com/tinode/webapp/archive/master.zip` и `https://github.com/tinode/tinode-js/archive/master.zip` в ту же директорию.

4. Скопируйте или создайте символическую ссылку на директорию шаблонов `./server/templ` в `$GOPATH/bin/templ`
	```
	ln -s ./server/templ $GOPATH/bin
	```

5. Запустите сервер
	```
	$GOPATH/bin/server -config=./server/tinode.conf -static_data=$HOME/tinode/webapp/
	```

6. Протестируйте установку, открыв в браузере [http://localhost:6060/](http://localhost:6060/). Статические файлы из пути `-static_data` обслуживаются в корне веб-сервера `/`. Вы можете изменить это, отредактировав строку `static_mount` в файле конфигурации.

**Важно!** Если вы запускаете Tinode вместе с другим веб-сервером, таким как Apache или nginx, имейте в виду, что вам нужно запускать веб-приложение с URL, обслуживаемого Tinode. Иначе это не будет работать.


## Запуск кластера

- Установите и запустите базу данных, запустите инициализатор БД, распакуйте JS файлы и создайте ссылку или скопируйте директорию шаблонов, как описано в предыдущем разделе. И MySQL, и RethinkDB поддерживают [кластерный](https://www.mysql.com/products/cluster/) [режим](https://www.rethinkdb.com/docs/start-a-server/#a-rethinkdb-cluster-using-multiple-machines). Вы можете рассмотреть это для повышения отказоустойчивости.

- Кластер ожидает как минимум два узла. Рекомендуется минимум три узла.

- Следующий раздел настраивает кластер.

```
	"cluster_config": {
		// Имя текущего узла.
		"self": "",
		// Список всех узлов кластера, включая текущий.
		"nodes": [
			{"name": "one", "addr":"localhost:12001"},
			{"name": "two", "addr":"localhost:12002"},
			{"name": "three", "addr":"localhost:12003"}
		],
		// Конфигурация функции отказоустойчивости. Не изменяйте.
		"failover": {
			"enabled": true,
			"heartbeat": 100,
			"vote_after": 8,
			"node_fail_after": 16
		}
	}
```
* `self` — это имя текущего узла. Обычно удобнее указать имя текущего узла в командной строке, используя опцию `cluster_self`. Значение командной строки переопределяет значение файла конфигурации. Если значение не предоставлено ни в файле конфигурации, ни через командную строку, кластеризация отключена.
* `nodes` определяет отдельные узлы кластера. Пример определяет три узла с именами `one`, `two` и `three`, работающие на localhost на указанных портах связи кластера. Адреса кластера не нужно открывать для внешнего мира.
* `failover` — это экспериментальная функция, которая мигрирует топики с вышедших из строя узлов кластера, сохраняя их доступными:
  * `enabled` включает режим отказоустойчивости; режим отказоустойчивости требует как минимум три узла в кластере.
  * `heartbeat` интервал в миллисекундах между сигналами пульса, отправляемыми ведущим узлом ведомым узлам для обеспечения их доступности.
  * `vote_after` количество неудачных сигналов пульса перед избранием нового ведущего узла.
  * `node_fail_after` количество сигналов пульса, которые ведомый узел пропускает, прежде чем он считается недоступным.

Если вы тестируете кластер со всеми узлами, работающими на одном хосте, вы также должны переопределить порты `listen` и `grpc_listen`. Вот пример запуска двух узлов кластера с одного хоста, используя тот же файл конфигурации:
```
$GOPATH/bin/tinode -config=./server/tinode.conf -static_data=./server/webapp/ -listen=:6060 -grpc_listen=:6080 -cluster_self=one &
$GOPATH/bin/tinode -config=./server/tinode.conf -static_data=./server/webapp/ -listen=:6061 -grpc_listen=:6081 -cluster_self=two &
```
Bash скрипт [run-cluster.sh](./server/run-cluster.sh) может оказаться полезным.

### Включение Push-уведомлений

Следуйте [инструкциям](./docs/faq.md#q-how-to-setup-push-notifications-with-google-fcm).


### Включение видеозвонков

Видеозвонки используют [WebRTC](https://en.wikipedia.org/wiki/WebRTC). WebRTC — это протокол peer to peer: после установления звонка клиентские приложения обмениваются данными напрямую. Прямой обмен данными эффективен, но создает проблему, когда стороны недоступны из интернета. WebRTC решает это с помощью серверов [ICE](https://en.wikipedia.org/wiki/Interactive_Connectivity_Establishment), которые реализуют протоколы [TURN(S)](https://en.wikipedia.org/wiki/Traversal_Using_Relays_around_NAT) и [STUN](https://en.wikipedia.org/wiki/STUN) в качестве резервного варианта.

Tinode не предоставляет серверы ICE из коробки. Вы должны установить и настроить (или приобрести) свои собственные серверы, иначе видеозвонки и голосовые звонки будут недоступны.

После того, как вы получите конфигурацию ICE TURN/STUN от вашего поставщика услуг, добавьте ее в раздел `"webrtc"` - `"ice_servers"` (или `"ice_servers_file"`) в `tinode.conf`. Также измените `"webrtc"` - `"enabled"` на `true`. Пример конфигурации предоставлен в `tinode.conf` только для иллюстрации. ОН НЕ БУДЕТ РАБОТАТЬ, потому что использует фиктивные значения вместо реальных адресов серверов.

Вы можете найти эту информацию полезной для выбора серверов: https://gist.github.com/yetithefoot/7592580


### Примечание о запуске сервера в фоновом режиме

Нет [чистого способа](https://github.com/golang/go/issues/227) демонизировать процесс Go внутренне. Необходимо использовать внешние инструменты, такие как оператор shell `&`, `systemd`, `launchd`, `SMF`, `daemon tools`, `runit` и т.д., для запуска процесса в фоновом режиме.

Особое примечание для пользователей [nohup](https://en.wikipedia.org/wiki/Nohup): `exit` должен быть выполнен сразу после вызова `nohup`, чтобы корректно закрыть сессию переднего плана:

```
nohup $GOPATH/bin/server -config=./server/tinode.conf -static_data=$HOME/tinode/webapp/ &
exit
```

Иначе `SIGHUP` может быть получен сервером, если соединение shell разорвано до завершения ssh сессии (указывается как `Connection to XXX.XXX.XXX.XXX port 22: Broken pipe`). В таком случае сервер завершит работу, потому что `SIGHUP` перехватывается сервером и интерпретируется как запрос на завершение работы.

Для более подробной информации см. https://github.com/tinode/chat/issues/25.

