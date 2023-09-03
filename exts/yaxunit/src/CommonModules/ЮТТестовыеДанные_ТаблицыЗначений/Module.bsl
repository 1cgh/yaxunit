//©///////////////////////////////////////////////////////////////////////////©//
//
//  Copyright 2021-2023 BIA-Technologies Limited Liability Company
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
	
Функция ЗагрузитьИзМакета(Макет, ОписанияТипов, КэшЗначений, ЗаменяемыеЗначения, ПараметрыЗаполнения) Экспорт
	
	ДанныеМакета = ДанныеМакета(Макет);
	ТипДанныхМакета = ТипЗнч(ДанныеМакета);
	
	Если ТипДанныхМакета = Тип("ТабличныйДокумент") Тогда
		Результат = ЗагрузитьДанныеИзТабличногоДокумента(ДанныеМакета, ОписанияТипов, ЗаменяемыеЗначения, КэшЗначений, ПараметрыЗаполнения);
	ИначеЕсли ТипДанныхМакета = Тип("ТекстовыйДокумент") ИЛИ ТипДанныхМакета = Тип("Строка") Тогда
		Результат = ЗагрузитьДанныеИзСтроки(ДанныеМакета, ОписанияТипов, ЗаменяемыеЗначения, КэшЗначений, ПараметрыЗаполнения);
	Иначе
		ВызватьИсключение "Макет должен быть либо табличным, либо текстовым документом";
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ЗагрузитьДанныеИзТабличногоДокумента(ДанныеМакета, ОписанияТипов, ЗаменяемыеЗначения, КэшЗначений, ПараметрыЗаполнения)
	
	КолонкиМакета = Новый Массив();
	Для Инд = 1 По ДанныеМакета.ШиринаТаблицы Цикл
		ИмяКолонки = ДанныеМакета.Область(1, Инд).Текст;
		КолонкиМакета.Добавить(ИмяКолонки);
	КонецЦикла;
	
	Колонки = ОписаниеКолонок(КолонкиМакета, ОписанияТипов);
	ПодготовитьПараметрыЗаполненияТаблицы(КэшЗначений, ЗаменяемыеЗначения, ПараметрыЗаполнения, Колонки);
	ПараметрыСоздания = ПараметрыЗаполнения.СозданиеОбъектовМетаданных;
		
	ТаблицаЗначений = Новый ТаблицаЗначений();
	Для Каждого ОписаниеКолонки Из Колонки Цикл
		ТаблицаЗначений.Колонки.Добавить(ОписаниеКолонки.Имя, ОписаниеКолонки.ОписаниеТипа);
	КонецЦикла;
	
	Выборка = ВыборкаИзТабличногоДокумента(ДанныеМакета);
	
	Пока Выборка.Следующий() Цикл
		
		Строка = ТаблицаЗначений.Добавить();
		
		Для Каждого ОписаниеКолонки Из Колонки Цикл
			
			ЗначениеПредставления = Выборка[ОписаниеКолонки.Индекс];
			
			Если ПустаяСтрока(ЗначениеПредставления) Тогда
				Продолжить;
			КонецЕсли;
			
			Значение = ЗначениеЯчейки(Выборка, ЗначениеПредставления, ОписаниеКолонки, ЗаменяемыеЗначения, КэшЗначений, ПараметрыСоздания);
			Строка[ОписаниеКолонки.Имя] = Значение;
			
		КонецЦикла;
		
	КонецЦикла;
	
	Возврат ТаблицаЗначений;
	
КонецФункции

// Загрузить данные из текстового документа.
// 
// Параметры:
//  ДанныеМакета - ТекстовыйДокумент
//  ОписанияТипов Описания типов
//  ЗаменяемыеЗначения Заменяемые значения
//  КэшЗначений Кэш значений
//  ПараметрыЗаполнения Параметры заполнения
// 
// Возвращаемое значение:
//  ТаблицаЗначений - Загрузить данные из текстового документа
Функция ЗагрузитьДанныеИзСтроки(ДанныеМакета, ОписанияТипов, ЗаменяемыеЗначения, КэшЗначений, ПараметрыЗаполнения) Экспорт
	
	Разделитель = "|";
	Чтение = ПострочноеЧтение(ДанныеМакета);
	
	Пока СледующаяСтрока(Чтение) Цикл
		
		Строка = СокрЛП(Чтение.Строка);
		
		Если НЕ СтрНачинаетсяС(Строка, Разделитель) Тогда
			Продолжить;
		КонецЕсли;
		
		КолонкиМакета = ЮТОбщий.РазложитьСтрокуВМассивПодстрок(Строка, Разделитель, Истина);
		
		СледующаяСтрока(Чтение);
		Прервать;
		
	КонецЦикла;
	
	Колонки = ОписаниеКолонок(КолонкиМакета, ОписанияТипов);
	ПодготовитьПараметрыЗаполненияТаблицы(КэшЗначений, ЗаменяемыеЗначения, ПараметрыЗаполнения, Колонки);
	ПараметрыСоздания = ПараметрыЗаполнения.СозданиеОбъектовМетаданных;
	
	ТаблицаЗначений = Новый ТаблицаЗначений();
	Для Каждого ОписаниеКолонки Из Колонки Цикл
		ТаблицаЗначений.Колонки.Добавить(ОписаниеКолонки.Имя, ОписаниеКолонки.ОписаниеТипа);
	КонецЦикла;
	
	Пока СледующаяСтрока(Чтение) Цикл
		
		Строка = СокрЛП(Чтение.Строка);
		
		Если ПустаяСтрока(Строка) Тогда
			Продолжить;
		ИначеЕсли НЕ СтрНачинаетсяС(Строка, Разделитель) Тогда
			Прервать;
		КонецЕсли;
		
		СтрокаДанных = ТаблицаЗначений.Добавить();
		Блоки = ЮТОбщий.РазложитьСтрокуВМассивПодстрок(Строка, Разделитель, Истина);
		
		Для Каждого ОписаниеКолонки Из Колонки Цикл
			
			ЗначениеПредставления = Блоки[ОписаниеКолонки.Индекс];
			
			Если ПустаяСтрока(ЗначениеПредставления) Тогда
				Продолжить;
			КонецЕсли;
			
			Значение = ЗначениеЯчейки(Блоки, ЗначениеПредставления, ОписаниеКолонки, ЗаменяемыеЗначения, КэшЗначений, ПараметрыСоздания);
			СтрокаДанных[ОписаниеКолонки.Имя] = Значение;
			
		КонецЦикла;
		
	КонецЦикла;
	
	Возврат ТаблицаЗначений;
	
КонецФункции

Функция ПострочноеЧтение(Текст)
	
	ПараметрыЧтения = Новый Структура;
	
	ПараметрыЧтения.Вставить("ИзТекстовогоДокумента", Ложь);
	ПараметрыЧтения.Вставить("ИзЧтенияТекста", Ложь);
	ПараметрыЧтения.Вставить("ДостиглиКонца", Ложь);
	ПараметрыЧтения.Вставить("Строка", Неопределено);
	
	Если ТипЗнч(Текст) = Тип("ТекстовыйДокумент") Тогда
		ПараметрыЧтения.ИзТекстовогоДокумента = Истина;
		ПараметрыЧтения.Вставить("ТекстовыйДокумент", Текст);
		ПараметрыЧтения.Вставить("КоличествоСтрок", Текст.КоличествоСтрок());
		ПараметрыЧтения.Вставить("ИндексСтроки", 0);
	ИначеЕсли ТипЗнч(Текст) = Тип("Строка") Тогда
		ПараметрыЧтения.ИзЧтенияТекста = Истина;
		Кодировка = КодировкаТекста.UTF8;
		Поток = ПолучитьДвоичныеДанныеИзСтроки(Текст, Кодировка).ОткрытьПотокДляЧтения();
		Чтение = Новый ЧтениеТекста(Поток, Кодировка);
		ПараметрыЧтения.Вставить("Чтение", Чтение);
		ПараметрыЧтения.Вставить("Поток", Поток);
	Иначе
		ВызватьИсключение "Неподдерживаемый параметр";
	КонецЕсли;
	
	Возврат ПараметрыЧтения;
	
КонецФункции

Функция СледующаяСтрока(ПараметрыЧтения)
	
	Если ПараметрыЧтения.ДостиглиКонца Тогда
		ВызватьИсключение "Построчное чтение уже завершено. Обнаружена попытка чтения завершенного потока";
	КонецЕсли;
	
	Если ПараметрыЧтения.ИзТекстовогоДокумента Тогда
		
		ЮТОбщий.Инкремент(ПараметрыЧтения.ИндексСтроки);
		Если ПараметрыЧтения.ИндексСтроки > ПараметрыЧтения.КоличествоСтрок Тогда
			ПараметрыЧтения.ДостиглиКонца = Истина;
			Возврат Ложь;
		КонецЕсли;
		ПараметрыЧтения.Строка = ПараметрыЧтения.ТекстовыйДокумент.ПолучитьСтроку(ПараметрыЧтения.ИндексСтроки);
		
	ИначеЕсли ПараметрыЧтения.ИзЧтенияТекста Тогда
		
		ПараметрыЧтения.Строка = ПараметрыЧтения.Чтение.ПрочитатьСтроку();
		
		Если ПараметрыЧтения.Строка = Неопределено Тогда
			ПараметрыЧтения.Чтение.Закрыть();
			ПараметрыЧтения.Поток.Закрыть();
			ПараметрыЧтения.ДостиглиКонца = Истина;
			Возврат Ложь;
		КонецЕсли;
		
	КонецЕсли;
	
	Возврат Истина;
	
КонецФункции

Функция ВыборкаИзТабличногоДокумента(ТабличныйДокумент)
	
	ВсегоСтрок = ТабличныйДокумент.ВысотаТаблицы;
	ВсегоКолонок = ТабличныйДокумент.ШиринаТаблицы;
	
	Область = ТабличныйДокумент.Область(1, 1, ВсегоСтрок, ВсегоКолонок);
	
	ИсточникДанных = Новый ОписаниеИсточникаДанных(Область);
	ПостроительОтчета = Новый ПостроительОтчета;
	ПостроительОтчета.ИсточникДанных = ИсточникДанных;
	ПостроительОтчета.Выполнить();
	
	Возврат ПостроительОтчета.Результат.Выбрать();
	
КонецФункции

Функция ДанныеМакета(Знач Макет)
	
	ТипПараметра = ТипЗнч(Макет);
	ДанныеМакета = Неопределено;
	
	Если ТипПараметра = Тип("ТабличныйДокумент")
		ИЛИ ТипПараметра = Тип("ТекстовыйДокумент")
		ИЛИ ТипПараметра = Тип("Строка") И СтрНачинаетсяС(Макет, "|") Тогда
		ДанныеМакета = Макет;
	ИначеЕсли ТипПараметра = Тип("Строка") Тогда
		ДанныеМакета = ЮТОбщийВызовСервера.Макет(Макет);
	Иначе
		ВызватьИсключение ЮТОбщий.НеподдерживаемыйПараметрМетода("ЮТТестовыеДанныеВызовСервера.ДанныеМакета", Макет);
	КонецЕсли;
	
	Возврат ДанныеМакета;
	
КонецФункции

Функция ОписаниеКолонок(КолонкиМакета, ОписанияТипов)
	
	Колонки = Новый Массив();
	ВсеКолонки = Новый Массив();
	
	ОсновныеКолонки = Новый Структура();
	
	Для Инд = 0 По КолонкиМакета.ВГраница() Цикл
		
		ИмяКолонки = КолонкиМакета[Инд];
		ЧастиИмени = СтрРазделить(ИмяКолонки, ".");
		
		Если ПустаяСтрока(ИмяКолонки) ИЛИ ОписанияТипов[ЧастиИмени[0]] = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		
		ЭтоВложенныйРеквизит = ЧастиИмени.Количество() = 2;
		ЭтоОсновнойРеквизит = ЧастиИмени.Количество() = 1;
		
		ОписаниеКолонки = ОписаниеКолонки(Инд);
		
		Если ЭтоОсновнойРеквизит Тогда
			ОписаниеКолонки.Имя = ИмяКолонки;
		Иначе
			ОписаниеКолонки.Имя = ЧастиИмени[1];
		КонецЕсли;
		
		ОписаниеКолонки.ОписаниеТипа = ОписанияТипов[ИмяКолонки];
		
		Если ОписаниеКолонки.ОписаниеТипа = Неопределено И ЭтоВложенныйРеквизит Тогда
			
			Родитель = ОсновныеКолонки[ЧастиИмени[0]];
			Реквизиты = Родитель.ОписаниеОбъектаМетаданных.Реквизиты;
			
			Если Реквизиты.Свойство(ЧастиИмени[1]) Тогда
				ОписаниеКолонки.ОписаниеТипа = Реквизиты[ЧастиИмени[1]].Тип;
			Иначе
				Продолжить; // TODO
			КонецЕсли;
			
		КонецЕсли;
		
		ДозаполнитьОписаниеКолонки(ОписаниеКолонки);
		
		ВсеКолонки.Добавить(ОписаниеКолонки);
		
		Если ЭтоОсновнойРеквизит Тогда
			
			Колонки.Добавить(ОписаниеКолонки);
			ОсновныеКолонки.Вставить(ИмяКолонки, ОписаниеКолонки);
			
		ИначеЕсли ЭтоВложенныйРеквизит Тогда
			
			Родитель = ОсновныеКолонки[ЧастиИмени[0]];
			Родитель.ДополнительныеРеквизиты.Добавить(ОписаниеКолонки);
			
		Иначе
			
			ВызватьИсключение СтрШаблон("Недопустимо использовать несколько точек в имени колонки, `%1`", ИмяКолонки);
			
		КонецЕсли;
		
	КонецЦикла;
	
	Для Каждого ОписаниеКолонки Из ВсеКолонки Цикл
		ОписаниеКолонки.Составное = ЗначениеЗаполнено(ОписаниеКолонки.ДополнительныеРеквизиты);
	КонецЦикла;
	
	Возврат Колонки;
	
КонецФункции

Функция ОписаниеКолонки(Индекс)
	
	ОписаниеКолонки = Новый Структура;
	ОписаниеКолонки.Вставить("Индекс", Индекс);
	ОписаниеКолонки.Вставить("Имя", "");
	
	ОписаниеКолонки.Вставить("ОписаниеТипа", Неопределено);
	ОписаниеКолонки.Вставить("ТипЗначения", Неопределено);
	ОписаниеКолонки.Вставить("Ссылочный", Ложь);
	ОписаниеКолонки.Вставить("ДополнительныеРеквизиты", Новый Массив());
	ОписаниеКолонки.Вставить("Составное", Ложь);
	ОписаниеКолонки.Вставить("Менеджер", Неопределено);
	ОписаниеКолонки.Вставить("ОписаниеОбъектаМетаданных", Неопределено);
	ОписаниеКолонки.Вставить("ЭтоПеречисление", Ложь);
	ОписаниеКолонки.Вставить("ЭтоЧисло", Ложь);
	ОписаниеКолонки.Вставить("ЭтоДата", Ложь);
	
	Возврат ОписаниеКолонки;
	
КонецФункции

Процедура ДозаполнитьОписаниеКолонки(ОписаниеКолонки)
	
	ТипЗначения = ОписаниеКолонки.ОписаниеТипа.Типы()[0];
	ОписаниеКолонки.ТипЗначения = ТипЗначения;
	
	ОписаниеКолонки.Ссылочный = ЮТТипыДанныхСлужебный.ЭтоСсылочныйТип(ТипЗначения);
	ОписаниеКолонки.ЭтоЧисло = ТипЗначения = Тип("Число");
	ОписаниеКолонки.ЭтоДата = ТипЗначения = Тип("Дата");
	
	Если ОписаниеКолонки.Ссылочный Тогда
		ОписаниеКолонки.ОписаниеОбъектаМетаданных = ЮТМетаданные.ОписаниеОбъектаМетаданных(ТипЗначения);
		ОписаниеКолонки.ЭтоПеречисление = ЮТМетаданные.ЭтоПеречисление(ОписаниеКолонки.ОписаниеОбъектаМетаданных);
		ОписаниеКолонки.Менеджер = ЮТОбщий.Менеджер(ОписаниеКолонки.ОписаниеОбъектаМетаданных);
	КонецЕсли;
		
КонецПроцедуры

Функция ЗначениеЯчейки(СтрокаДанных, ЗначениеПредставления, ОписаниеКолонки, ЗаменяемыеЗначения, КэшЗначений, ПараметрыСоздания)
	
	Значение = ЗаменяемыеЗначения[ЗначениеПредставления];
	
	КэшироватьЗначение = Значение = Неопределено И ОписаниеКолонки.Менеджер <> Неопределено;
	
	Если КэшироватьЗначение Тогда
		Если КэшЗначений[ОписаниеКолонки.Менеджер] = Неопределено Тогда
			КэшЗначений.Вставить(ОписаниеКолонки.Менеджер, Новый Соответствие());
		Иначе
			Значение = КэшЗначений[ОписаниеКолонки.Менеджер][ЗначениеПредставления];
		КонецЕсли;
	КонецЕсли;
	
	Если Значение <> Неопределено Тогда
		Возврат Значение;
	КонецЕсли;
	
	ЗначенияРеквизитов = ЗначенияРеквизитов(СтрокаДанных, ОписаниеКолонки, ЗаменяемыеЗначения, КэшЗначений, ПараметрыСоздания);
	Если ОписаниеКолонки.Составное Тогда
		Значение = ПривестиЗначениеКолонки(ОписаниеКолонки, ЗначениеПредставления, ЗначенияРеквизитов, ПараметрыСоздания);
	Иначе
		Значение = ПривестиЗначениеКолонки(ОписаниеКолонки, ЗначениеПредставления, ЗначенияРеквизитов, ПараметрыСоздания);
	КонецЕсли;
	
	Если КэшироватьЗначение Тогда
		КэшЗначений[ОписаниеКолонки.Менеджер].Вставить(ЗначениеПредставления, Значение);
	КонецЕсли;
	
	Возврат Значение;
	
КонецФункции

Процедура ПодготовитьПараметрыЗаполненияТаблицы(КэшЗначений, ЗаменяемыеЗначения, ПараметрыЗаполнения, Колонки)
	
	Если ЗаменяемыеЗначения = Неопределено Тогда
		ЗаменяемыеЗначения = Новый Соответствие;
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(КэшЗначений) Тогда
		КэшЗначений = Новый Соответствие;
	КонецЕсли;
	
	Для Каждого Колонка Из Колонки Цикл
		
		Если НЕ Колонка.Ссылочный Тогда
			Продолжить;
		КонецЕсли;
		
		Если КэшЗначений[Колонка.Менеджер] = Неопределено Тогда
			КэшЗначений.Вставить(Колонка.Менеджер, Новый Соответствие);
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

Функция ЗначенияРеквизитов(СтрокаТаблицы, ОписаниеКолонки, ЗаменяемыеЗначения, КэшЗначений, Параметры)
	
	ЗначенияРеквизитов = Новый Структура();
	
	Для Каждого ОписаниеВложеннойКолонки Из ОписаниеКолонки.ДополнительныеРеквизиты Цикл
		
		ПредставлениеЗначения = СтрокаТаблицы[ОписаниеВложеннойКолонки.Индекс];
		Если ПустаяСтрока(ПредставлениеЗначения) Тогда
			Продолжить;
		КонецЕсли;
		
		Значение = ЗначениеЯчейки(СтрокаТаблицы, ПредставлениеЗначения, ОписаниеВложеннойКолонки, ЗаменяемыеЗначения, КэшЗначений, Параметры);
		ЗначенияРеквизитов.Вставить(ОписаниеВложеннойКолонки.Имя, Значение);
		
	КонецЦикла;
	
	ОписаниеОбъектаМетаданных = ОписаниеКолонки.ОписаниеОбъектаМетаданных;
	
	Если ОписаниеОбъектаМетаданных <> Неопределено И ОписаниеОбъектаМетаданных.ОписаниеТипа.Имя = "Справочник" Тогда
		ИмяРеквизита = "Наименование";
		Если ОписаниеОбъектаМетаданных.Реквизиты.Свойство(ИмяРеквизита) = Неопределено Тогда
			ИмяРеквизита = "Код";
		КонецЕсли;
		ЗначенияРеквизитов.Вставить(ИмяРеквизита, СтрокаТаблицы[ОписаниеКолонки.Индекс]);
	КонецЕсли;
	
	Возврат ЗначенияРеквизитов;
	
КонецФункции

Функция ПривестиЗначениеКолонки(ОписаниеКолонки, ЗначениеПредставления, ЗначенияРеквизитов, ПараметрыЗаписи)
	
	Если ОписаниеКолонки.ЭтоПеречисление Тогда
		Значение = ОписаниеКолонки.Менеджер[ЗначениеПредставления];
	ИначеЕсли ОписаниеКолонки.Ссылочный Тогда
		Значение = СоздатьНовуюЗапись(ОписаниеКолонки, ЗначенияРеквизитов, ПараметрыЗаписи);
	ИначеЕсли ОписаниеКолонки.ЭтоДата Тогда
		Значение = ЮТПреобразования.ПривестиЗначениеКДате(ОписаниеКолонки.ОписаниеТипа, ЗначениеПредставления);
	ИначеЕсли ОписаниеКолонки.ЭтоЧисло Тогда
		Значение = ЮТПреобразования.ПривестиЗначениеКЧислу(ОписаниеКолонки.ОписаниеТипа, ЗначениеПредставления);
	Иначе
		Значение = ОписаниеКолонки.ОписаниеТипа.ПривестиЗначение(ЗначениеПредставления);
	КонецЕсли;
	
	Возврат Значение;
	
КонецФункции

Функция СоздатьНовуюЗапись(ОписаниеКолонки, ЗначенияРеквизитов, ПараметрыЗаписи)
	
	Конструктор = ЮТТестовыеДанные.КонструкторОбъекта(ОписаниеКолонки.Менеджер);
	
	Если ЗначениеЗаполнено(ЗначенияРеквизитов) Тогда
		Для Каждого ДанныеЗначения Из ЗначенияРеквизитов Цикл
			Конструктор.Установить(ДанныеЗначения.Ключ, ДанныеЗначения.Значение);
		КонецЦикла;
	КонецЕсли;
	
	Если ПараметрыЗаписи.ФикцияОбязательныхПолей Тогда
		Конструктор.ФикцияОбязательныхПолей();
	КонецЕсли;
	
	Возврат Конструктор.Записать(, ПараметрыЗаписи.ПараметрыЗаписи.ОбменДаннымиЗагрузка);
	
КонецФункции

#КонецОбласти
