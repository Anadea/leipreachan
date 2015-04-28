# Leipreachan

Самый простой способ создания резервных копий базы данных проекта на сколько это вообще возможно.

## Установка

Добавьте эту строку в ваш Gemfile:

```ruby
gem 'leipreachan'
```

После этого запустите:

    $ bundle

Или установите вручную:

    $ gem install leipreachan

## Использование

### Capistrano 2/3

Для создания резервных копий с помощью Capistrano 3 добавьте в ваш 'Capfile' эту строку:

    require 'leipreachan/capistrano3'

В случае Capistrano 2 необходимо в файл 'deploy.rb' добавить эту строку:

    require 'leipreachan/capistrano2'

Это добавит следующие задачи в Capistrano:

    cap deploy:leipreachan:backup      # Backup database
    cap deploy:leipreachan:list        # List of backups
    cap deploy:leipreachan:restore     # Restore database

Если вы хотите создать резервную копию в процессе деплоя приложения вам необходимо добавить эту строку в 'deploy.rb':

    before "deploy:migrate", "deploy:leipreachan:backup"

Резервная копия будет создана перед миграциями базы данных.

По умолчанию резервная копия создается в 'shared/backups', но если у вас есть необходимость установить свой каталог, это можно сделать с помощью переменной 'backups_folder':

    set :backups_folder, '../../current'

Gem берет за основу каталог с релизом. Учтите это при установке каталога резервных копий.

Для восстановления сделанного бекапа необходимо запустить:

    $ cap [environment] deploy:leipreachan:restore

ВНИМЕНИЕ!!! Восстанавливается **последняя** сделанная резервная копия.

### Интергация в Whenever

Просто добавьте эти строки в ваш 'config/schedule.rb':

```ruby
  every 1.day, :at => '4:30 am' do
    rake "leipreachan:backup"
  end
```
Так же вы можете изменить каталог, куда будут складываться резервные копии. По умолчанию они складываются в './backups', т.е. создается каталог backups в корневом каталоге приложения.

```ruby
  every 1.month, do
    rake "leipreachan:backup DIR=/tmp/database_backups"
  end
```
Есть возможность указать сколько дней хранить резервные копии (обратите внимание, что эта настройка не распространяется на количество резервных копий внутри каталога дня; каждый день их может храниться неограниченное количество). По умолчанию хранится 30 каталогов, разбитых по датам.

```ruby
  every 5.days, do
    rake "leipreachan:backup DAYS=5"
  end
```

### Использование Rake задач

Для работы с резервными копиями базы данных есть неколько rake задач:

    rake leipreachan:backup   # Backup project database; Options: DIR=backups RAILS_ENV=production DAYS=30
    rake leipreachan:list     # List of all backups; Options: DATE=20150130
    rake leipreachan:restore  # Restore project database; Options: DIR=backups RAILS_ENV=production

leipreachan:backup - создаст резервную копию базы данных.
leipreachan:list - выведет список дней и бекапов в последнем дне.
leipreachan:restore - восстановит базу данных из резервной копии.

Опции, которые можно передать из окружения:

* DIR - каталог, куда необходимо сохранить резервную копию
* DATE - показать резервные копии на определенную дату
* DAYS - сколько дней хранить резервные копии
