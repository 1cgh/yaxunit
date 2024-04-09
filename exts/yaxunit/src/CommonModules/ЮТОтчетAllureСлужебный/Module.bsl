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

Функция ПараметрыГенерацииОтчета() Экспорт
	
	Параметры = ЮТФабрикаСлужебный.ПараметрыГенератораОтчета();
	
	ОписаниеФормата = ЮТФабрикаСлужебный.ОписаниеФорматаОтчета("allure", "Allure 2 (json)");
	ОписаниеФормата.ЗаписьВКаталог = Истина;
	ОписаниеФормата.СамостоятельнаяЗаписьОтчета = Истина;
	Параметры.Форматы.Вставить(ОписаниеФормата.Идентификатор, ОписаниеФормата);
	
	Возврат Параметры;
	
КонецФункции

Процедура ЗаписатьОтчет(РезультатВыполнения, Каталог, Формат, Обработчик) Экспорт
	
#Если ВебКлиент Тогда
	ВызватьИсключение "Формирование отчета в формате Allure не поддерживается в web-клиенте";
#Иначе
	Для Каждого Модуль Из РезультатВыполнения Цикл
		
		Для Каждого Набор Из Модуль.НаборыТестов Цикл
			
			Для Каждого РезультатТеста Из Набор.Тесты Цикл
				
				Попытка
					СохранитьОтчетТеста(РезультатТеста, Набор, Модуль, Каталог);
				Исключение
					ЮТЛогирование.Ошибка("Ошибка сохранения отчета в формате Allure. " + ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
				КонецПопытки;
				
			КонецЦикла;
			
		КонецЦикла;
		
	КонецЦикла;
#КонецЕсли
	
	ЮТАсинхроннаяОбработкаСлужебныйКлиент.ВызватьОбработчик(Обработчик);
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

#Если НЕ ВебКлиент Тогда
Процедура СохранитьОтчетТеста(РезультатТеста, Набор, Модуль, Каталог)
	
	Описание = ОписаниеТеста(РезультатТеста, Набор, Модуль);
	
	ИмяФайла = ЮТФайлы.ОбъединитьПути(Каталог, Описание.uuid + "-result.json");
	Запись = Новый ЗаписьJSON();
	Запись.ОткрытьФайл(ИмяФайла, КодировкаТекста.UTF8, Ложь);
	ЗаписатьJSON(Запись, Описание);
	Запись.Закрыть();
	
КонецПроцедуры

Функция ОписаниеТеста(РезультатТеста, Набор, Модуль) Экспорт
	
	Статусы = ЮТФабрика.СтатусыИсполненияТеста();
	ПредставлениеРежима = СтрШаблон(" [%1]", РезультатТеста.Режим);
	ПолныйИдентификаторТеста = СтрШаблон("%1_%2_%3", РезультатТеста.НомерВНаборе, РезультатТеста.ПолноеИмяМетода, РезультатТеста.Режим);
	
	Описание = НовыйОписаниеТеста();
	Описание.fullName = РезультатТеста.ПолноеИмяМетода + ПредставлениеРежима;
	Описание.name = РезультатТеста.Метод + ПредставлениеРежима;
	Описание.status = СтатусОтчета(РезультатТеста.Статус, Статусы);
	Описание.testCaseId = ЮТОбщий.ХешMD5(ПолныйИдентификаторТеста);
	Описание.start = РезультатТеста.ДатаСтарта;
	Описание.stop = РезультатТеста.ДатаСтарта + РезультатТеста.Длительность;
	
	ОписаниеМодуля = ИмяМодуляПоСхеме(Модуль.МетаданныеМодуля.Имя);
	ИмяНабора = Модуль.МетаданныеМодуля.Имя;
	ИмяВложенногоНабора = Набор.Представление + ПредставлениеРежима;
	
	ДобавитьМетку(Описание, "language", "bsl");
	ДобавитьМетку(Описание, "framework", "YAxUnit");
	
	Если ЗначениеЗаполнено(ОписаниеМодуля.epic) Тогда
		ДобавитьМетку(Описание, "epic", ОписаниеМодуля.epic);
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ОписаниеМодуля.feature) Тогда
		ДобавитьМетку(Описание, "feature", ОписаниеМодуля.feature);
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ОписаниеМодуля.story) Тогда
		ДобавитьМетку(Описание, "story", ОписаниеМодуля.story);
	КонецЕсли;
	
	ДобавитьМетку(Описание, "suite", ИмяНабора);
	Если Модуль.НаборыТестов.Количество() > 1 ИЛИ Модуль.МетаданныеМодуля.Имя <> Набор.Представление Тогда
		ДобавитьМетку(Описание, "subSuite", ИмяВложенногоНабора);
	КонецЕсли;
	
	ДобавитьМетку(Описание, "tag", РезультатТеста.Режим);
	
	Для Каждого Тег Из РезультатТеста.Теги Цикл
		ДобавитьМетку(Описание, "tag", Тег);
	КонецЦикла;
	
	Если ЗначениеЗаполнено(РезультатТеста.Параметры) Тогда
		Для Каждого Параметр Из РезультатТеста.Параметры Цикл
			Описание.parameters.Добавить(Новый Структура("name, value", "П" + Описание.parameters.Количество(), Строка(Параметр)));
			ПолныйИдентификаторТеста = ПолныйИдентификаторТеста + Строка(Параметр);
		КонецЦикла;
	КонецЕсли;
	
	Описание.historyId = ЮТОбщий.ХешMD5(ПолныйИдентификаторТеста);
	
	Для Каждого ОписаниеОшибки Из РезультатТеста.Ошибки Цикл
		
		Описание.statusDetails.message = ЮТСтроки.ДобавитьСтроку(Описание.statusDetails.message, ОписаниеОшибки.Сообщение, Символы.ПС);
		Описание.statusDetails.trace = ЮТСтроки.ДобавитьСтроку(Описание.statusDetails.trace, ОписаниеОшибки.Стек, Символы.ПС);
		
	КонецЦикла;
	
	Если РезультатТеста.Ошибки.Количество() = 0 И РезультатТеста.Статус <> Статусы.Успешно Тогда
		
		Если РезультатТеста.Статус = Статусы.Ожидание Тогда
			Описание.statusDetails.message = "Тест не был вызван";
		Иначе
			Описание.statusDetails.message = "Тест не успешен, но нет сообщений об ошибках"
		КонецЕсли;
		
	КонецЕсли;
	
	Возврат Описание;
	
КонецФункции

Функция НовыйОписаниеТеста()
	
	Описание = Новый Структура;
	Описание.Вставить("uuid", ЮТТестовыеДанные.УникальнаяСтрока());
	Описание.Вставить("historyId", "");
	Описание.Вставить("testCaseId", "");
	Описание.Вставить("fullName", "");
	Описание.Вставить("name", "");
	Описание.Вставить("parameters", Новый Массив());
	Описание.Вставить("links", Новый Массив());
	Описание.Вставить("labels", Новый Массив());
	Описание.Вставить("status", "");
	Описание.Вставить("statusDetails", НовыйОписаниеСтатуса());
	Описание.Вставить("start", 0);
	Описание.Вставить("stop", 0);
	Описание.Вставить("steps", Новый Массив());
	
	Возврат Описание;
	
КонецФункции

Функция НовыйОписаниеСтатуса()
	
	Описание = Новый Структура();
	Описание.Вставить("message");
	Описание.Вставить("trace");
	
	Возврат Описание;
	
КонецФункции

Функция СтатусОтчета(Статус, Статусы)
	
	Если Статус = Статусы.Успешно Тогда
		СтатусОтчета = "passed";
	ИначеЕсли Статус = Статусы.Ошибка Тогда
		СтатусОтчета = "failed";
	ИначеЕсли Статус = Статусы.Пропущен Тогда
		СтатусОтчета = "skipped";
	Иначе
		СтатусОтчета = "broken";
	КонецЕсли;
	
	Возврат СтатусОтчета;
	
КонецФункции

Процедура ДобавитьМетку(ОписаниеТеста, ИмяМетки, Значение)
	ОписаниеТеста.labels.Добавить(Новый Структура("name, value", ИмяМетки, Значение));
КонецПроцедуры

Функция ИмяМодуляПоСхеме(ИмяМодуля)
	
	Части = СтрРазделить(ИмяМодуля, "_");
	Описание = Новый Структура("epic, feature, story");
	Если Части.Количество() <> 2 И Части.Количество() <> 3 Тогда
		Описание.epic = ИмяМодуля;
		Возврат Описание;
	КонецЕсли;
	
	Эпик = ТипОбъектаПоПрефиксу(Части[0]);
	
	Описание.epic = Эпик;
	Описание.feature = Части[1];
	
	Если Части.Количество() = 3 Тогда
		Описание.story = ТипМодуляПоСуффиксу(Части[2]);
	КонецЕсли;
	
	Возврат Описание;
	
КонецФункции

Функция ТипОбъектаПоПрефиксу(Префикс)
	
	ТипОбъекта = Неопределено;
	
	Если Префикс = "ОМ" Тогда ТипОбъекта = "Общий модуль";
	ИначеЕсли Префикс = "РБ" Тогда ТипОбъекта = "Регистр бухгалтерии";
	ИначеЕсли Префикс = "РН" Тогда ТипОбъекта = "Регистр накопления";
	ИначеЕсли Префикс = "РР" Тогда ТипОбъекта = "Регистр расчета";
	ИначеЕсли Префикс = "РС" Тогда ТипОбъекта = "Регистр сведений";
	ИначеЕсли Префикс = "БП" Тогда ТипОбъекта = "Бизнес процесс";
	ИначеЕсли Префикс = "Спр" Тогда ТипОбъекта = "Справочник";
	ИначеЕсли Префикс = "ПС" Тогда ТипОбъекта = "План счетов";
	ИначеЕсли Префикс = "ПВР" Тогда ТипОбъекта = "План видов расчета";
	ИначеЕсли Префикс = "ПВХ" Тогда ТипОбъекта = "План видов характеристик";
	ИначеЕсли Префикс = "Док" Тогда ТипОбъекта = "Документ";
	ИначеЕсли Префикс = "Пер" Тогда ТипОбъекта = "Перечисление";
	ИначеЕсли Префикс = "ПО" Тогда ТипОбъекта = "План обмена";
	ИначеЕсли Префикс = "Зад" Тогда ТипОбъекта = "Задача";
	ИначеЕсли Префикс = "Обр" Тогда ТипОбъекта = "Обработка";
	ИначеЕсли Префикс = "Отч" Тогда ТипОбъекта = "Отчет";
	Иначе ТипОбъекта = Префикс;
	КонецЕсли;
	
	Возврат ТипОбъекта;
КонецФункции

Функция ТипМодуляПоСуффиксу(Суффикс)
	
	ТипМодуля = Неопределено;
	
	Если Суффикс = "МО" Тогда ТипМодуля = "Модуль объекта";
	ИначеЕсли Суффикс = "ММ" Тогда ТипМодуля = "Модуль менеджера";
	ИначеЕсли Суффикс = "НЗ" Тогда ТипМодуля = "Модуль набора записей";
	Иначе ТипМодуля = Суффикс;
	КонецЕсли;
	
	Возврат ТипМодуля;
	
КонецФункции
#КонецЕсли

#КонецОбласти
