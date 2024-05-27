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

Процедура ВызовУстаревшегоМетода(УстаревшийМетод, РекомендуемыйМетод, Версия) Экспорт
	
	Сообщение = СтрШаблон("Используется устаревший метод '%1'. В следующих релизах он будет удален", УстаревшийМетод);
	
	Если ЗначениеЗаполнено(РекомендуемыйМетод) Тогда
		Сообщение = СтрШаблон("%1. Рекомендуется использовать '%2'", Сообщение, РекомендуемыйМетод);
	КонецЕсли;
	
	ЮТЛогирование.Предостережение(Сообщение);
	
	Если ЮТСтроки.СравнитьВерсии(Версия, ВерсияЗапретаИспользованияУстаревших()) <= 0 Тогда
		ВызватьИсключение Сообщение;
	Иначе
		ЮТОбщий.СообщитьПользователю(Сообщение);
	КонецЕсли;
	
КонецПроцедуры

#Область ПроверкаМетодов

// МетодМодуляСуществует
// Проверяет существование публичного (экспортного) метода у модуля
//
// Параметры:
//  ИмяМодуля - Строка - Имя модуля, метод которого нужно поискать
//  ИмяМетода - Строка - Имя метода, который ищем
//  Кешировать - Булево - Признак кеширования результата проверки
//
// Возвращаемое значение:
//  Булево - Метод найден
Функция МетодМодуляСуществует(ИмяМодуля, ИмяМетода, Кешировать = Истина) Экспорт
	
	ЮТПроверкиСлужебный.ПроверитьТипПараметра(ИмяМодуля, Тип("Строка"), "ЮТОбщий.МетодМодуляСуществует", "ИмяМодуля");
	ЮТПроверкиСлужебный.ПроверитьТипПараметра(ИмяМетода, Тип("Строка"), "ЮТОбщий.МетодМодуляСуществует", "ИмяМетода");
	
	Если Кешировать Тогда
		Возврат ЮТСлужебныйПовторногоИспользования.МетодМодуляСуществует(ИмяМодуля, ИмяМетода);
	КонецЕсли;
	
	ПолноеИмяМетода = СтрШаблон("%1.%2", ИмяМодуля, ИмяМетода);
	Алгоритм = ПолноеИмяМетода + "(,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,)";
	
	Ошибка = ВыполнитьВыражениеСПерехватомОшибки(Алгоритм);
	
	ТипОшибки = ЮТРегистрацияОшибокСлужебный.ТипОшибки(Ошибка, ПолноеИмяМетода);
	Возврат ТипОшибки = ЮТФабрикаСлужебный.ТипыОшибок().МногоПараметров;
	
КонецФункции

// Проверяет существование публичного (экспортного) метода у объекта
//
// Параметры:
//  Объект - Произвольный - Объект, метод которого нужно поискать
//  ИмяМетода - Строка - Имя метода, который ищем
//
// Возвращаемое значение:
//  Булево - Метод найден
Функция МетодОбъектаСуществует(Объект, ИмяМетода) Экспорт
	
#Если ВебКлиент Тогда
	ВызватьИсключение ЮТИсключения.МетодНеДоступен("ЮТОбщий.МетодОбъектаСуществует");
#Иначе
	ЮТПроверкиСлужебный.ПроверитьТипПараметра(ИмяМетода, Тип("Строка"), "ЮТОбщий.МетодМодуляСуществует", "ИмяМетода");
	
	ПолноеИмяМетода = СтрШаблон("Объект.%1", ИмяМетода);
	Алгоритм = ПолноеИмяМетода + "(,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,)";
	
	Ошибка = ВыполнитьВыражениеСПерехватомОшибки(Алгоритм, , Объект);
	
	ТипОшибки = ЮТРегистрацияОшибокСлужебный.ТипОшибки(Ошибка, ПолноеИмяМетода);
	Возврат ТипОшибки = ЮТФабрикаСлужебный.ТипыОшибок().МногоПараметров;
#КонецЕсли
	
КонецФункции

#КонецОбласти

#Область ВызовМетодов

Процедура ВыполнитьМетодОбъекта(Объект, ИмяМетода, Параметры = Неопределено) Экспорт
	
	Выражение = "Объект." + СтрокаВызоваМетода(ИмяМетода, Параметры, "Параметры");
	ВыполнитьВыражение(Выражение, Параметры, Объект, Ложь);
	
КонецПроцедуры

Функция ВыполнитьМетодОбъектаСПерехватомОшибки(Объект, ИмяМетода, Параметры = Неопределено) Экспорт
	
	Выражение = "Объект." + СтрокаВызоваМетода(ИмяМетода, Параметры, "Параметры");
	Возврат ВыполнитьВыражениеСПерехватомОшибки(Выражение, Параметры, Объект, Ложь);
	
КонецФункции

Процедура ВыполнитьМетодКонфигурации(ИмяМодуля, ИмяМетода, Параметры = Неопределено) Экспорт
	
	ПолноеИмяМетода = ЮТСтроки.ДобавитьСтроку(ИмяМодуля, ИмяМетода, ".");
	Выражение = СтрокаВызоваМетода(ПолноеИмяМетода, Параметры, "Параметры");
	
	ВыполнитьВыражение(Выражение, Параметры, , Ложь);
	
КонецПроцедуры

Функция ВыполнитьМетодКонфигурацииСПерехватомОшибки(ИмяМодуля, ИмяМетода, Параметры = Неопределено) Экспорт
	
	ПолноеИмяМетода = ЮТСтроки.ДобавитьСтроку(ИмяМодуля, ИмяМетода, ".");
	Выражение = СтрокаВызоваМетода(ПолноеИмяМетода, Параметры, "Параметры");
	
	Возврат ВыполнитьВыражениеСПерехватомОшибки(Выражение, Параметры, , Ложь);
	
КонецФункции

Функция ВычислитьБезопасно(Выражение, Параметры = Неопределено) Экспорт
	
	Возврат ВычислитьВыражение(Выражение, Параметры, Истина);
	
КонецФункции

Функция ВызватьФункциюКонфигурацииНаСервере(ИмяМодуля, ИмяМетода, Параметры = Неопределено) Экспорт
	
	Если НЕ ЮТСтроки.ЭтоВалидноеИмяПеременной(ИмяМодуля) Тогда
		ВызватьИсключение "Передано невалидное имя общего модуля в `ЮТМетодыСлужебный.ВызватьФункциюКонфигурацииНаСервере`";
	КонецЕсли;
	
	Если НЕ ЮТСтроки.ЭтоВалидноеИмяПеременной(ИмяМетода) Тогда
		ВызватьИсключение "Передано невалидное имя метода в `ЮТМетодыСлужебный.ВызватьФункциюКонфигурацииНаСервере`";
	КонецЕсли;
	
	Возврат ЮТОбщийСлужебныйВызовСервера.ВызватьФункциюКонфигурацииНаСервере(ИмяМодуля, ИмяМетода, Параметры);
	
КонецФункции

Функция ВызватьФункциюОбъекта(Объект, ИмяМетода, Параметры = Неопределено) Экспорт
	
	Выражение = "Объект." + СтрокаВызоваМетода(ИмяМетода, Параметры);
	Возврат ВычислитьВыражение(Выражение, Параметры);
	
КонецФункции

Функция ВызватьФункциюКонфигурации(ИмяМодуля, ИмяМетода, Параметры, Безопасно = Истина) Экспорт
	
	ПолноеИмяМетода = ЮТСтроки.ДобавитьСтроку(ИмяМодуля, ИмяМетода, ".");
	Выражение = СтрокаВызоваМетода(ПолноеИмяМетода, Параметры);
	
	Возврат ВычислитьВыражение(Выражение, Параметры, Безопасно);
	
КонецФункции

#КонецОбласти

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция СтрокаВызоваМетода(ПолноеИмяМетода, Параметры, ИмяМассиваПараметров = "Параметры")
	
	Если СтрЗаканчиваетсяНа(ПолноеИмяМетода, ")") Тогда
		Выражение = ПолноеИмяМетода;
	ИначеЕсли НЕ ЗначениеЗаполнено(Параметры) Тогда
		Выражение = ПолноеИмяМетода + "()";
	ИначеЕсли ТипЗнч(Параметры) = Тип("Массив") Тогда
		Выражение = СтрШаблон("%1(%2)", ПолноеИмяМетода, СтрокаПараметровМетода(Параметры, ИмяМассиваПараметров));
	Иначе
		ВызватьИсключение СтрШаблон("Не верный тип параметров `%1` для вызова метода (%2), должен быть массив", ТипЗнч(Параметры), ПолноеИмяМетода);
	КонецЕсли;
	
	Возврат Выражение;
	
КонецФункции

Процедура ВыполнитьВыражение(Выражение, Параметры = Неопределено, Объект = Неопределено, Безопасно = Истина)
	
	// BSLLS:ExecuteExternalCodeInCommonModule-off
#Если ВебКлиент Тогда
	ВызватьИсключение ЮТИсключения.МетодНеДоступен("ЮТМетодыСлужебный.ВыполнитьВыражение");
#КонецЕсли
	
#Если ТонкийКлиент Тогда
	Выполнить(Выражение);
#ИначеЕсли НЕ ВебКлиент Тогда
	Если Безопасно Тогда
		УстановитьБезопасныйРежим(Истина);
		Выполнить(Выражение);
	Иначе
		//@skip-check server-execution-safe-mode
		Выполнить(Выражение);
	КонецЕсли;
#КонецЕсли
	// BSLLS:ExecuteExternalCodeInCommonModule-on
	
КонецПроцедуры

Функция ВыполнитьВыражениеСПерехватомОшибки(Выражение, Параметры = Неопределено, Объект = Неопределено, Безопасно = Истина)
	
	// BSLLS:ExecuteExternalCodeInCommonModule-off
#Если ВебКлиент Тогда
	ВызватьИсключение ЮТИсключения.МетодНеДоступен("ЮТМетодыСлужебный.ВыполнитьВыражение");
#КонецЕсли
	
	Попытка
#Если ТонкийКлиент Тогда
		Выполнить(Выражение);
#ИначеЕсли НЕ ВебКлиент Тогда
		Если Безопасно Тогда
			УстановитьБезопасныйРежим(Истина);
			Выполнить(Выражение);
		Иначе
			//@skip-check server-execution-safe-mode
			Выполнить(Выражение);
		КонецЕсли;
#КонецЕсли
	Исключение
		Возврат ИнформацияОбОшибке();
	КонецПопытки;
	
	Возврат Неопределено;
	// BSLLS:ExecuteExternalCodeInCommonModule-on
	
КонецФункции

Функция ВычислитьВыражение(Выражение, Параметры = Неопределено, Безопасно = Истина)
	
	// BSLLS:ExecuteExternalCodeInCommonModule-off
	Если НЕ Безопасно Тогда
		//@skip-check server-execution-safe-mode
		Возврат Вычислить(Выражение);
	КонецЕсли;
	
#Если НЕ ВебКлиент И НЕ ТонкийКлиент Тогда
	УстановитьБезопасныйРежим(Истина);
	Попытка
		Значение = Вычислить(Выражение);
	Исключение
		УстановитьБезопасныйРежим(Ложь);
		ВызватьИсключение;
	КонецПопытки;
	
	УстановитьБезопасныйРежим(Ложь);
#Иначе
	Значение = Вычислить(Выражение);
#КонецЕсли
	
	Возврат Значение;
	// BSLLS:ExecuteExternalCodeInCommonModule-on
	
КонецФункции

Функция ВерсияЗапретаИспользованияУстаревших()
	
	Возврат "23.01";
	
КонецФункции

Функция СтрокаПараметровМетода(Параметры, ИмяПеременнойСПараметрами)
	
	СписокПараметров = Новый Массив();
	
	Для Инд = 0 По Параметры.ВГраница() Цикл
		
		Если Параметры[Инд] = Мокито.ПараметрПоУмолчанию() Тогда
			СписокПараметров.Добавить("");
		Иначе
			СписокПараметров.Добавить(СтрШаблон("%1[%2]", ИмяПеременнойСПараметрами, Инд));
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат СтрСоединить(СписокПараметров, ", ");
	
КонецФункции

#КонецОбласти
