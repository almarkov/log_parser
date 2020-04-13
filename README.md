необходим установленный postgresql, perl (Plack, DBI)

инициализация таблиц
```
perl init.pl
```

парсинг файла и вставка данных
```
perl parser.pl [path_to_file] [input_pack_size]
```

запуск приложения
```
plackup server.psgi
```

страница доступна на http://localhost:5000/
