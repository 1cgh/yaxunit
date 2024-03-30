//©///////////////////////////////////////////////////////////////////////////©//
//
//  Copyright 2021-2024 BIA-Technologies Limited Liability Company
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//©///////////////////////////////////////////////////////////////////////////©//

#Область СлужебныйПрограммныйИнтерфейс

Функция СоздатьЗапись(Знач Менеджер, Знач Данные, Знач ПараметрыЗаписи, Знач ВернутьОбъект) Экспорт
	
	ПараметрыЗаписи = ПараметрыЗаписи(ПараметрыЗаписи);
	
	Объект = НовыйОбъект(Менеджер, Данные, 
		ПараметрыЗаписи.ДополнительныеСвойства, ПараметрыЗаписи.УникальныйИдентификаторСсылки);
	
	КлючЗаписи = ЗаписатьОбъект(Объект, ПараметрыЗаписи);
	
	Если ВернутьОбъект Тогда
		Возврат Объект;
	Иначе
		Возврат КлючЗаписи;
	КонецЕсли;
	
КонецФункции

// Создает новый объект и заполняет его данными
//
// Параметры:
//  Менеджер - Произвольный
//  Данные - Структура - Данные заполнения объекта
//  ДополнительныеСвойства - Структура - Дополнительные свойства объекта
//  УникальныйИдентификаторСсылки - УникальныйИдентификатор - Уникальный идентификатор, который будет установлен в качестве ссылки для объекта
//
// Возвращаемое значение:
//  Произвольный - Созданный объект
Функция НовыйОбъект(Знач Менеджер,
					Знач Данные,
					Знач ДополнительныеСвойства = Неопределено,
					Знач УникальныйИдентификаторСсылки = Неопределено) Экспорт
	
	ОписаниеОбъектаМетаданных = ЮТМетаданные.ОписаниеОбъектаМетаданных(Менеджер);
	Менеджер = ЮТОбщий.Менеджер(ОписаниеОбъектаМетаданных);
	
	ЭтоРегистр = ЮТМетаданные.ЭтоРегистр(ОписаниеОбъектаМетаданных);
	
	Объект = СоздатьОбъект(Менеджер, ОписаниеОбъектаМетаданных.ОписаниеТипа, Данные);
	
	Если ДополнительныеСвойства <> Неопределено Тогда
		ЮТКоллекции.ДополнитьСтруктуру(Объект.ДополнительныеСвойства, ДополнительныеСвойства);
	КонецЕсли;

	Если УникальныйИдентификаторСсылки <> Неопределено И ОписаниеОбъектаМетаданных.ОписаниеТипа.Ссылочный Тогда
		Ссылка = Менеджер.ПолучитьСсылку(УникальныйИдентификаторСсылки);
		Объект.УстановитьСсылкуНового(Ссылка);
	КонецЕсли;
	
	Если ЭтоРегистр Тогда
		
		ЗаполнитьНаборРегистра(Объект, Данные);
		Возврат Объект;
		
	КонецЕсли;
	ЗаполнитьЗначенияСвойств(Объект, Данные);
	
	Если ОписаниеОбъектаМетаданных.ОписаниеТипа.ТабличныеЧасти Тогда
		
		Для Каждого ОписаниеТабличнойЧасти Из ОписаниеОбъектаМетаданных.ТабличныеЧасти Цикл
			
			ИмяТабличнойЧасти = ОписаниеТабличнойЧасти.Ключ;
			Если НЕ Данные.Свойство(ИмяТабличнойЧасти) Тогда
				Продолжить;
			КонецЕсли;
			
			Для Каждого Запись Из Данные[ИмяТабличнойЧасти] Цикл
				Строка = Объект[ИмяТабличнойЧасти].Добавить();
				ЗаполнитьЗначенияСвойств(Строка, Запись);
			КонецЦикла;
			
		КонецЦикла;
		
	КонецЕсли;
	
	ЗаполнитьБазовыеРеквизиты(Объект, ОписаниеОбъектаМетаданных);
	
	Возврат Объект;
	
КонецФункции

Процедура Удалить(Знач Ссылки) Экспорт
	
	Если ТипЗнч(Ссылки) <> Тип("Массив") Тогда
		Ссылки = ЮТКоллекции.ЗначениеВМассиве(Ссылки);
	КонецЕсли;
	
	Ошибки = Новый Массив;
	
	Для Каждого Ссылка Из Ссылки Цикл
		
		ТипЗначения = ТипЗнч(Ссылка);
		Если Ссылка = Неопределено ИЛИ ЮТТипыДанныхСлужебный.ЭтоТипПеречисления(ТипЗначения) Тогда
			Продолжить;
		КонецЕсли;
		
		Попытка
			Если ЮТТипыДанныхСлужебный.ЭтоСсылочныйТип(ТипЗначения) Тогда
				Объект = Ссылка.ПолучитьОбъект();
				Если Объект <> Неопределено Тогда
					Объект.Удалить();
				КонецЕсли;
			Иначе
				Менеджер = ЮТОбщий.Менеджер(ТипЗначения);
				Запись = Менеджер.СоздатьМенеджерЗаписи();
				ЗаполнитьЗначенияСвойств(Запись, Ссылка);
				Запись.Прочитать();
				Запись.Удалить();
			КонецЕсли;
		Исключение
			
			Ошибки.Добавить(ЮТРегистрацияОшибокСлужебный.ПредставлениеОшибки("Удаление " + Ссылка, ИнформацияОбОшибке()));
			
		КонецПопытки;
		
	КонецЦикла;
	
	ОбновитьНумерациюОбъектов();
	
	Если ЗначениеЗаполнено(Ошибки) Тогда
		ВызватьИсключение СтрСоединить(Ошибки, Символы.ПС);
	КонецЕсли;
	
КонецПроцедуры

Функция ФикцияЗначенияБазы(Знач ТипЗначения, Знач РеквизитыЗаполнения = Неопределено) Экспорт
	
	ОбъектМетаданных = Метаданные.НайтиПоТипу(ТипЗначения);
	
	Если ОбъектМетаданных = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Если Метаданные.Перечисления.Содержит(ОбъектМетаданных) Тогда
		
		Возврат СлучайноеЗначениеПеречисления(ОбъектМетаданных);
		
	КонецЕсли;
	
	ОписаниеОбъектаМетаданных = ЮТМетаданные.ОписаниеОбъектаМетаданных(ОбъектМетаданных);
	Менеджер = ЮТОбщий.Менеджер(ОбъектМетаданных);
	
	Объект = СоздатьОбъект(Менеджер, ОписаниеОбъектаМетаданных.ОписаниеТипа, РеквизитыЗаполнения);
	
	Если ЗначениеЗаполнено(РеквизитыЗаполнения) Тогда
		ЗаполнитьЗначенияСвойств(Объект, РеквизитыЗаполнения);
	КонецЕсли;
	
	ЗаполнитьБазовыеРеквизиты(Объект, ОписаниеОбъектаМетаданных);
	
	Возврат ЗаписатьОбъект(Объект, ПараметрыЗаписи());
	
КонецФункции

Функция ЗагрузитьИзМакета(Знач Макет,
						  Знач ОписанияТипов,
						  КэшЗначений,
						  Знач ЗаменяемыеЗначения,
						  Знач ПараметрыЗаполнения,
						  Знач ТаблицаЗначений) Экспорт
	
	Таблица = ЮТТестовыеДанныеСлужебныйТаблицыЗначений.ЗагрузитьИзМакета(Макет,
																 ОписанияТипов,
																 КэшЗначений,
																 ЗаменяемыеЗначения,
																 ПараметрыЗаполнения);
	
	Если ТаблицаЗначений Тогда
		Возврат Таблица;
	КонецЕсли;
	
	Реквизиты = СтрСоединить(ЮТКоллекции.ВыгрузитьЗначения(Таблица.Колонки, "Имя"), ",");
	Результат = Новый Массив(Таблица.Количество());
	
	Для Инд = 0 По Таблица.Количество() - 1 Цикл
		Запись = Новый Структура(Реквизиты);
		ЗаполнитьЗначенияСвойств(Запись, Таблица[Инд]);
		Результат[Инд] = Запись;
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

Функция СлучайноеЗначениеПеречисления(Знач Перечисление) Экспорт
	
	Менеджер = ЮТОбщий.Менеджер(Перечисление);
	
	НомерЗначения = ЮТТестовыеДанные.СлучайноеПоложительноеЧисло(Менеджер.Количество());
	Возврат Менеджер.Получить(НомерЗначения - 1);
	
КонецФункции

Функция СлучайноеПредопределенноеЗначение(Менеджер, Отбор) Экспорт
	
	ИмяТаблицы = ЮТМетаданные.НормализованноеИмяТаблицы(Менеджер);
	Условия = ЮТест.Предикат(Отбор)
		.Реквизит("Предопределенный").Равно(Истина);
	
	ОписаниеЗапроса = ЮТЗапросыСлужебныйКлиентСервер.ОписаниеЗапроса(ИмяТаблицы, Условия, "Ссылка");
	
	Данные = ЮТЗапросы.РезультатЗапроса(ОписаниеЗапроса);
	
	Если Данные.Количество() = 1 Тогда
		Значение = Данные[0].Ссылка;
	ИначеЕсли Данные.Количество() > 1 Тогда
		Индекс = ЮТест.Данные().СлучайноеЧисло(0, Данные.Количество() - 1);
		Значение = Данные[Индекс].Ссылка;
	Иначе
		Значение = Неопределено;
	КонецЕсли;
	
	Возврат Значение;
	
КонецФункции

Процедура УстановитьЗначенияРеквизитов(Знач Ссылка, Знач ЗначенияРеквизитов, Знач ПараметрыЗаписи = Неопределено) Экспорт
	
	Объект = Ссылка.ПолучитьОбъект();
	ПараметрыЗаписи = ПараметрыЗаписи(ПараметрыЗаписи);
	
	Для Каждого Элемент Из ЗначенияРеквизитов Цикл
		Объект[Элемент.Ключ] = Элемент.Значение;
	КонецЦикла;
	
	ЗаписатьОбъект(Объект, ПараметрыЗаписи);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Создать объект.
//
// Параметры: ОписаниеМенеджера -
// См. ОписаниеМенеджера
//  Менеджер - Произвольный - Менеджер
//  ОписаниеТипа - см. ЮТМетаданные.СтруктураОписанияОбъектаМетаданных
//  Данные - Структура
// Возвращаемое значение:
//  Произвольный - Создать объект
Функция СоздатьОбъект(Менеджер, ОписаниеТипа, Данные)
	
	Если ОписаниеТипа.Конструктор = "СоздатьЭлемент" Тогда
		
		ЭтоГруппа = ?(Данные = Неопределено, Ложь, ЮТКоллекции.ЗначениеСтруктуры(Данные, "ЭтоГруппа", Ложь));
		Если ЭтоГруппа Тогда
			Результат = Менеджер.СоздатьГруппу();
		Иначе
			Результат = Менеджер.СоздатьЭлемент();
		КонецЕсли;
		
	ИначеЕсли ОписаниеТипа.Конструктор = "СоздатьДокумент" Тогда
		Результат = Менеджер.СоздатьДокумент();
	ИначеЕсли ОписаниеТипа.Конструктор = "СоздатьСчет" Тогда
		Результат = Менеджер.СоздатьСчет();
	ИначеЕсли ОписаниеТипа.Конструктор = "СоздатьВидРасчета" Тогда
		Результат = Менеджер.СоздатьВидРасчета();
	ИначеЕсли ОписаниеТипа.Конструктор = "СоздатьУзел" Тогда
		Результат = Менеджер.СоздатьУзел();
	ИначеЕсли ОписаниеТипа.Конструктор = "СоздатьНаборЗаписей" Тогда
		Результат = Менеджер.СоздатьНаборЗаписей();
	ИначеЕсли ОписаниеТипа.Конструктор = "СоздатьМенеджерЗаписи" Тогда
		Результат = Менеджер.СоздатьМенеджерЗаписи();
	ИначеЕсли ОписаниеТипа.Конструктор = "СоздатьБизнесПроцесс" Тогда
		Результат = Менеджер.СоздатьБизнесПроцесс();
	ИначеЕсли ОписаниеТипа.Конструктор = "СоздатьЗадачу" Тогда
		Результат = Менеджер.СоздатьЗадачу();
	Иначе
		ВызватьИсключение СтрШаблон("Для %1 не поддерживается создание записей ИБ", ОписаниеТипа.Имя);
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

// Записать объект.
//
// Параметры:
//  Объект - Произвольный -  Объект
//  ПараметрыЗаписи - см. ЮТОбщий.ПараметрыЗаписи
//
// Возвращаемое значение:
//  ЛюбаяСсылка
Функция ЗаписатьОбъект(Объект, ПараметрыЗаписи)
	
	Если ПараметрыЗаписи.ОбменДаннымиЗагрузка Тогда
		Объект.ОбменДанными.Загрузка = Истина;
	КонецЕсли;
	
	Попытка
		
		Если ПараметрыЗаписи.РежимЗаписи <> Неопределено Тогда
			Объект.Записать(ПараметрыЗаписи.РежимЗаписи);
		Иначе
			Объект.Записать();
		КонецЕсли;
		
		Если ПараметрыЗаписи.ОбменДаннымиЗагрузка Тогда
			Объект.ОбменДанными.Загрузка = Ложь;
		КонецЕсли;
		
		Возврат КлючЗаписи(Объект);
		
	Исключение
		
		ЮТРегистрацияОшибок.ДобавитьПояснениеОшибки(СтрШаблон("Не удалось записать объект `%1` (%2)", Объект, ТипЗнч(Объект)));
		ВызватьИсключение;
		
	КонецПопытки;
	
КонецФункции

Процедура ЗаполнитьБазовыеРеквизиты(Объект, ОписаниеОбъектаМетаданных)
	
	АнглийскийЯзык = ЮТОбщийСлужебныйВызовСервера.ЭтоАнглийскийВстроенныйЯзык();
	ИмяТипаДокумент = ?(АнглийскийЯзык, "Document", "Документ");
	ИмяРеквизитаКод = ?(АнглийскийЯзык, "Code", "Код");
	ИмяРеквизитаНаименование = ?(АнглийскийЯзык, "Description", "Наименование");
	
	ОписаниеТипа = ОписаниеОбъектаМетаданных.ОписаниеТипа;
	Если ОписаниеТипа.Имя = ИмяТипаДокумент Тогда
		Если НЕ ЗначениеЗаполнено(Объект.Дата) Тогда
			Объект.Дата = ТекущаяДатаСеанса();
		КонецЕсли;
		Если НЕ ЗначениеЗаполнено(Объект.Номер) Тогда
			Объект.УстановитьНовыйНомер();
		КонецЕсли;
	КонецЕсли;
	
	Если ОписаниеОбъектаМетаданных.Реквизиты.Свойство(ИмяРеквизитаКод)
		И ОписаниеОбъектаМетаданных.Реквизиты[ИмяРеквизитаКод].Обязательный
		И НЕ ЗначениеЗаполнено(Объект.Код) Тогда
		Объект.УстановитьНовыйКод();
	КонецЕсли;
	
	Если ОписаниеОбъектаМетаданных.Реквизиты.Свойство(ИмяРеквизитаНаименование)
		И ОписаниеОбъектаМетаданных.Реквизиты[ИмяРеквизитаНаименование].Обязательный
		И НЕ ЗначениеЗаполнено(Объект.Наименование) Тогда
		Объект.Наименование = ЮТТестовыеДанные.СлучайнаяСтрока();
	КонецЕсли;
	
КонецПроцедуры

Функция КлючЗаписи(Объект)
	
	ТипЗначения = ТипЗнч(Объект);
	
	Если ЮТТипыДанныхСлужебный.ЭтоТипОбъекта(ТипЗначения) Тогда
		
		Возврат Объект.Ссылка;
		
	ИначеЕсли ЮТТипыДанныхСлужебный.ЭтоМенеджерЗаписи(ТипЗначения) Тогда
		
		Описание = ЮТМетаданные.ОписаниеОбъектаМетаданных(Объект);
		
		КлючевыеРеквизиты = Новый Структура();
		Для Каждого Реквизит Из Описание.Реквизиты Цикл
			Если Реквизит.Значение.ЭтоКлюч Тогда
				КлючевыеРеквизиты.Вставить(Реквизит.Ключ, Объект[Реквизит.Ключ]);
			КонецЕсли;
		КонецЦикла;
		
		Менеджер = ЮТОбщий.Менеджер(Описание);
		Возврат Менеджер.СоздатьКлючЗаписи(КлючевыеРеквизиты);
		
	ИначеЕсли ЮТТипыДанныхСлужебный.ЭтоТипНабораЗаписей(ТипЗначения) Тогда
		
		КлючевыеРеквизиты = Новый Структура();
		
		Для Каждого ЭлементОтбора Из Объект.Отбор Цикл
			КлючевыеРеквизиты.Вставить(ЭлементОтбора.Имя, ЭлементОтбора.Значение);
		КонецЦикла;
		
		Менеджер = ЮТОбщий.Менеджер(Объект);
		Возврат Менеджер.СоздатьКлючЗаписи(КлючевыеРеквизиты);
		
	Иначе
		
		Сообщение = ЮТИсключения.НеподдерживаемыйПараметрМетода("ЮТТестовыеДанныеВызовСервера.КлючЗаписи", Объект);
		ВызватьИсключение Сообщение;
		
	КонецЕсли;
	
КонецФункции

Функция ПараметрыЗаписи(ВходящиеПараметрыЗаписи = Неопределено)
	
	Если ВходящиеПараметрыЗаписи = Неопределено Тогда
		Возврат ЮТОбщий.ПараметрыЗаписи();
	Иначе
		ПараметрыЗаписи = ЮТОбщий.ПараметрыЗаписи();
		ЗаполнитьЗначенияСвойств(ПараметрыЗаписи, ВходящиеПараметрыЗаписи);
		Возврат ПараметрыЗаписи;
	КонецЕсли;
	
КонецФункции

Процедура ЗаполнитьНаборРегистра(Набор, ДанныеЗаписи)
	
	Запись = Набор.Добавить();
	ЗаполнитьЗначенияСвойств(Запись, ДанныеЗаписи);
	
	Для Каждого ЭлементОтбора Из Набор.Отбор Цикл
		ЭлементОтбора.Установить(Запись[ЭлементОтбора.Имя]);
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти
