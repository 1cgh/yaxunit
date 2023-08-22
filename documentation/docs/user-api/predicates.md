---
tags: [Начало, Предикаты, Утверждения, Запросы, Мокирование]
---

# Предикаты

Предикаты это утверждения, которые вы можете передавать в качестве параметров.
Они расширяют и унифицируют функциональность тестового движка.

```bsl
Процедура АктуализацияУведомлений() Экспорт
	
	ИмяРегистра = "РегистрСведений.ОповещенияПользователя";
	Объект = ТестовыеДанные.Объект();
	
	УсловиеУведомления = ЮТест.Предикат()
		.Реквизит("Источник").Равно(Объект)
		.Реквизит("ТипОповещения").Равно(Справочники.ТипыОповещенийПользователя.Уведомление1)
		.Получить();
	
	ЮТест.ОжидаетЧтоТаблицаБазы(ИмяРегистра)
		.НеСодержитЗаписи(УсловиеУведомления);
	
	УведомленияВызовСервера.АктуализацияУведомлений();
	
	ЮТест.ОжидаетЧтоТаблицаБазы(ИмяРегистра)
		.СодержитЗаписи(УсловиеУведомления);
	
	ДанныеУведомления = ЮТЗапросы.Запись(ИмяРегистра, УсловиеУведомления);
	
	ЮТест.ОжидаетЧто(ДанныеУведомления)
		.Свойство("Прочитано").ЭтоЛожь()
		.Свойство("Пользователь").Равно(Справочники.ГруппыОповещенийПользователей.Инженер);
	
КонецПроцедуры
```

Механизм предикатов:

* позволяет формировать наборы утверждений и передавать их в качества параметров;
* используется для проверки коллекций, записей базы и так далее;
* построен по модели текучих выражения и имеет схожий с базовыми утверждениями синтаксис (`ЮТест.ОжидаетЧто()`);

## Примеры использования

* Проверка коллекции

    ```bsl
    ЮТест.ОжидаетЧто(Коллекция)
        .ЛюбойЭлементСоответствуетПредикату(ЮТест.Предикат()
            .Реквизит("Число").Равно(2)); // Проверят, что в коллекции есть элементы с реквизитом `Число`, которое равно `2`

    ЮТест.ОжидаетЧто(Коллекция)
        .КаждыйЭлементСоответствуетПредикату(ЮТест.Предикат()
            .Заполнено().ИмеетТип("Массив")); // Проверят, что каждый элемент коллекции это заполненный массив
    ```

* Описания параметров метода при мокировании

    Например, имеем метод, который принимает в параметрах структуру. Необходимо вернуть 2 разных результата в зависимости от значения реквизита входной структуры.

    ```bsl
    Мокито.Обучение(Модуль)
        .Когда(Модуль.Посчитать(ЮТест.Предикат()
                .Реквизит("Оператор").Равно("Сложить")))
        .ВернутьРезультат(Результат1)

        .Когда(Модуль.Посчитать(ЮТест.Предикат()
                .Реквизит("Оператор").Равно("Вычесть")))
        .ВернутьРезультат(Результат2);
    ```

* Утверждения, проверяющие данные в базе на основании предикатов.

    ```bsl
    ЮТест.ОжидаетЧтоТаблица("Справочник.Товары").СодержитЗаписи(
        ЮТест.Предикат()
            .Реквизит("Наименование").Равно("Товар 1")
            .Реквизит("Ссылка").НеРавно(Исключение)
    );
    ```

* Получение записей из базы

    ```bsl
    ДанныеТовара = ЮТЗапросы.Запись("Справочник.Товары", ЮТест.Предикат()
            .Реквизит("Наименование").Равно("Товар 1")
            .Реквизит("Ссылка").НеРавно(Исключение));
    ```

## Особенности

### Особенности контекста

Предикаты как и большинство механизмов построены на текучих выражениях с сохранением состояния в глобальном контексте.

Это приводит к тому, что вы не можете сразу использовать несколько предикатов, например

```bsl
Мокито.Обучение(Модуль)
    .Когда(Модуль.СделатьЧтоТо(
        ЮТест.Предикат().ИмеетТип("Строка"),
        ЮТест.Предикат().ИмеетТип("Число")))
    .ВернутьРезультат(Результат1);
```

В этом примере 1С сначала вычислит выражения для всех параметров, а потом передаст их в метод и мы получим для обоих параметров один и тот же предикат, ожидающий тип `Число`.
Потому что состояние первого предиката будет заменено вторым. Для обхода этой проблемы можно использовать метод `Получить`, который возвращает текущее состояние.

```bsl
Мокито.Обучение(Модуль)
    .Когда(Модуль.СделатьЧтоТо(
        ЮТест.Предикат().ИмеетТип("Строка").Получить(),
        ЮТест.Предикат().ИмеетТип("Число")))
    .ВернутьРезультат(Результат1);
```

Такая же история при сохранение предикатов в переменные.

```bsl
ПроверкаСтрока = ЮТест.Предикат().ИмеетТип("Строка");
ПроверкаЧисло = ЮТест.Предикат().ИмеетТип("Число");
```

`ПроверкаСтрока` и `ПроверкаЧисло` будут равны и содержать одинаковые условия. Проблему также можно обойти используя метод `Получить`.

```bsl
ПроверкаСтрока = ЮТест.Предикат().ИмеетТип("Строка").Получить();
ПроверкаЧисло = ЮТест.Предикат().ИмеетТип("Число").Получить();
```

### Особенности реализации

Сам модуль предикатов используется только для формирования утверждений/условий. 

Реализацией проверок и формированием условий занимаются другие модули и возможна ситуация, когда некоторые предикаты еще не реализованы или не поддерживаются каким-либо механизмом. Например, проверка заполненности не поддерживается запросами.