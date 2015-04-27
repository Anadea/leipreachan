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

### Capistrano 3

Для создания резервных копий с помощью Capistrano добавьте в ваш 'Capfile' эту строку:

    require 'leipreachan/capistrano3'

Это добавить следующие задачи в Capistrano:

    cap deploy:leipreachan:backup      # Backup database
    cap deploy:leipreachan:list        # List of backups
    cap deploy:leipreachan:restore     # Restore database

Если вы хотите создать резервную копию в процессе делоя приложения вам необходимо добавить эту строку в 'deploy.rb':

    before "deploy:migrate", "deploy:leipreachan:backup"

Резервная копия будет создана перед миграциями базы даных.

По умолчанию резервная копия создается в 'shared/backups', но если у вас есть необходимость установить свой каталог, это можно сделать с помощью переменной 'backups_folder':

    set :backups_folder, '../../current'

Gem берет за основу каталог с релизом. Учтите это при установке каталога резервных копий.

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
    rake "leipreachan:backup MAX=5"
  end
```
