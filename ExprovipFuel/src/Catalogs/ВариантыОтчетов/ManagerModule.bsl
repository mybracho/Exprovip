///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ПрограммныйИнтерфейс

#Область ДляВызоваИзДругихПодсистем

// СтандартныеПодсистемы.ГрупповоеИзменениеОбъектов

// Возвращает реквизиты объекта, которые разрешается редактировать
// с помощью обработки группового изменения реквизитов.
//
// Возвращаемое значение:
//  Массив из Строка
//
Функция РеквизитыРедактируемыеВГрупповойОбработке() Экспорт
	
	Результат = Новый Массив;
	Результат.Добавить("Описание");
	Результат.Добавить("Автор");
	Результат.Добавить("ТолькоДляАвтора");
	
	Возврат Результат;
	
КонецФункции

// Конец СтандартныеПодсистемы.ГрупповоеИзменениеОбъектов

// СтандартныеПодсистемы.УправлениеДоступом

// Параметры:
//   Ограничение - см. УправлениеДоступомПереопределяемый.ПриЗаполненииОграниченияДоступа.Ограничение.
//
Процедура ПриЗаполненииОграниченияДоступа(Ограничение) Экспорт
	
	Ограничение.Текст =
	"РазрешитьЧтение
	|ГДЕ
	|	Пользовательский = ЛОЖЬ
	|	ИЛИ ТолькоДляАвтора = ЛОЖЬ
	|	ИЛИ ЭтоАвторизованныйПользователь(Автор)
	|;
	|РазрешитьИзменениеЕслиРазрешеноЧтение
	|ГДЕ
	|	ЭтоАвторизованныйПользователь(Автор)";
	
	Ограничение.ТекстДляВнешнихПользователей = Ограничение.Текст;
	
КонецПроцедуры

// Конец СтандартныеПодсистемы.УправлениеДоступом

#КонецОбласти

#КонецОбласти

#КонецЕсли

#Область ОбработчикиСобытий

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

Процедура ОбработкаПолученияФормы(ВидФормы, Параметры, ВыбраннаяФорма, ДополнительнаяИнформация, СтандартнаяОбработка)
	// Переопределение для целей избранного - вместо карточки с настройками размещения отчета будет открываться его
	// основная форма.
	Если ВидФормы = "ФормаОбъекта" Тогда
		СсылкаВарианта = ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(Параметры, "Ключ");
		Если Не ЗначениеЗаполнено(СсылкаВарианта) Тогда
			ВызватьИсключение НСтр("ru = 'Новый вариант отчета можно создать только из формы отчета'");
		КонецЕсли;
		ПоказатьКарточку = ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(Параметры, "ПоказатьКарточку");
		Если ПоказатьКарточку = Истина Тогда
			Возврат;
		КонецЕсли;
		
		ПараметрыОткрытия = ВариантыОтчетов.ПараметрыОткрытия(СсылкаВарианта);
		
		ВариантыОтчетовКлиентСервер.ДополнитьСтруктуруКлючом(ПараметрыОткрытия, "ВыполнятьЗамеры", Ложь);
		
		Если ПараметрыОткрытия.ТипОтчета = "Внутренний" Или ПараметрыОткрытия.ТипОтчета = "Расширение" Тогда
			Вид = "Отчет";
		ИначеЕсли ПараметрыОткрытия.ТипОтчета = "Дополнительный" Тогда
			Вид = "ВнешнийОтчет";
			Если Не ПараметрыОткрытия.Свойство("Подключен") Тогда
				ВариантыОтчетов.ПриПодключенииОтчета(ПараметрыОткрытия);
			КонецЕсли;
			Если Не ПараметрыОткрытия.Подключен Тогда
				ВызватьИсключение НСтр("ru = 'Вариант внешнего отчета можно открыть только из формы отчета.'");
			КонецЕсли;
		Иначе
			ВызватьИсключение НСтр("ru = 'Вариант внешнего отчета можно открыть только из формы отчета.'");
		КонецЕсли;
		
		ПолноеИмяОтчета = Вид + "." + ПараметрыОткрытия.ИмяОтчета;
		
		КлючУникальности = ОтчетыКлиентСервер.КлючУникальности(ПолноеИмяОтчета, ПараметрыОткрытия.КлючВарианта);
		ПараметрыОткрытия.Вставить("КлючПараметровПечати",        КлючУникальности);
		ПараметрыОткрытия.Вставить("КлючСохраненияПоложенияОкна", КлючУникальности);
		
		СтандартнаяОбработка = Ложь;
		Если ПараметрыОткрытия.ТипОтчета = "Дополнительный" Тогда // Для платформы.
			ОбщегоНазначенияКлиентСервер.ДополнитьСтруктуру(ПараметрыОткрытия, Параметры);
			ВыбраннаяФорма = "Справочник.ВариантыОтчетов.ФормаОбъекта";
			Параметры.Вставить("ПараметрыОткрытияФормыОтчета", ПараметрыОткрытия);
			Возврат;
		КонецЕсли;
		ВыбраннаяФорма = ПолноеИмяОтчета + ".Форма";
		ОбщегоНазначенияКлиентСервер.ДополнитьСтруктуру(Параметры, ПараметрыОткрытия);
	КонецЕсли;
КонецПроцедуры

#КонецЕсли

Процедура ОбработкаПолученияПолейПредставления(Поля, СтандартнаяОбработка)
	
	Поля.Добавить("Наименование");
	Поля.Добавить("Ссылка");
	Поля.Добавить("Пользовательский");
	Поля.Добавить("ПредопределенныйВариант");
	Поля.Добавить("ТипОтчета");
	СтандартнаяОбработка = Ложь;
	
КонецПроцедуры

Процедура ОбработкаПолученияПредставления(Данные, Представление, СтандартнаяОбработка)
	
	Если ВариантыОтчетовВызовСервера.ЭтоПредопределенныйВариантОтчета(Данные) Тогда
		Данные.Ссылка = Данные.ПредопределенныйВариант;
	КонецЕсли;
	
#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.Мультиязычность") Тогда
		МодульМультиязычностьКлиентСервер = ОбщегоНазначения.ОбщийМодуль("МультиязычностьКлиентСервер");
		МодульМультиязычностьКлиентСервер.ОбработкаПолученияПредставления(Данные, Представление, СтандартнаяОбработка);
	КонецЕсли;
#Иначе
	Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("СтандартныеПодсистемы.Мультиязычность") Тогда
		МодульМультиязычностьКлиентСервер = ОбщегоНазначенияКлиент.ОбщийМодуль("МультиязычностьКлиентСервер");
		МодульМультиязычностьКлиентСервер.ОбработкаПолученияПредставления(Данные, Представление, СтандартнаяОбработка);
	КонецЕсли;
#КонецЕсли
	
КонецПроцедуры

#КонецОбласти

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область СлужебныйПрограммныйИнтерфейс

////////////////////////////////////////////////////////////////////////////////
// Обработчики обновления.

// Регистрирует данные к обновлению в плане обмена ОбновлениеИнформационнойБазы
//  см. Стандарты и методики разработки прикладных решений: Параллельный режим отложенного обновления.
//
// Параметры:
//  Параметры - см. ОбновлениеИнформационнойБазы.ОсновныеПараметрыОтметкиКОбработке
//
Процедура ЗарегистрироватьДанныеКОбработкеДляПереходаНаНовуюВерсию(Параметры) Экспорт 
	Запрос = Новый Запрос("
	|ВЫБРАТЬ
	|	Варианты.Ссылка
	|ИЗ
	|	Справочник.ВариантыОтчетов КАК Варианты
	|ГДЕ
	|	Варианты.Отчет = &УниверсальныйОтчет
	|	И Варианты.Пользовательский
	|");
	УниверсальныйОтчет = ОбщегоНазначения.ИдентификаторОбъектаМетаданных(Метаданные.Отчеты.УниверсальныйОтчет);
	Запрос.УстановитьПараметр("УниверсальныйОтчет", УниверсальныйОтчет);
	
	Ссылки = Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Ссылка");
	
	ОбновлениеИнформационнойБазы.ОтметитьКОбработке(Параметры, Ссылки);
КонецПроцедуры

// Обрабатывает данные, зарегистрированные в плане обмена ОбновлениеИнформационнойБазы
//  см. Стандарты и методики разработки прикладных решений: Параллельный режим отложенного обновления.
//
// Параметры:
//  Параметры - см. ОбновлениеИнформационнойБазы.ОсновныеПараметрыОтметкиКОбработке
//
Процедура ОбработатьДанныеДляПереходаНаНовуюВерсию(Параметры) Экспорт 
	ОбъектМетаданных = Метаданные.Справочники.ВариантыОтчетов;
	ПолноеИмяОбъекта = ОбъектМетаданных.ПолноеИмя();
	
	Обработано = 0;
	Отказано = 0;
	
	Вариант = ОбновлениеИнформационнойБазы.ВыбратьСсылкиДляОбработки(Параметры.Очередь, ПолноеИмяОбъекта);
	Пока Вариант.Следующий() Цикл 
		Попытка
			Отчеты.УниверсальныйОтчет.УстановитьИсточникДанныхВарианта(Вариант.Ссылка);
			Обработано = Обработано + 1;
		Исключение
			// Если не удалось обработать вариант отчета, повторяем попытку снова.
			Отказано = Отказано + 1;
			
			ШаблонКомментария = НСтр("ru = 'Не удалось установить источник данных варианта отчета %1.
				|Возможно он поврежден и не подлежит восстановлению.
				|
				|Техническая информация о проблеме: %2'");
			Комментарий = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				ШаблонКомментария, Вариант.Ссылка, ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
			ЗаписьЖурналаРегистрации(
				ОбновлениеИнформационнойБазы.СобытиеЖурналаРегистрации(),
				УровеньЖурналаРегистрации.Предупреждение,
				ОбъектМетаданных,
				Вариант.Ссылка,
				Комментарий);
		КонецПопытки;
	КонецЦикла;
	
	Параметры.ОбработкаЗавершена = ОбновлениеИнформационнойБазы.ОбработкаДанныхЗавершена(Параметры.Очередь, ПолноеИмяОбъекта);
	Если Обработано = 0 И Отказано <> 0 Тогда
		ШаблонСообщения = НСтр("ru = 'Не удалось обработать некоторые варианты отчетов: %1'");
		ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонСообщения, Отказано);
		
		ВызватьИсключение ТекстСообщения;
	Иначе
		ШаблонКомментария = НСтр("ru = 'Обработан очередной пакет вариантов отчетов: %1'");
		Комментарий = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонКомментария, Обработано);
		ЗаписьЖурналаРегистрации(
			ОбновлениеИнформационнойБазы.СобытиеЖурналаРегистрации(),
			УровеньЖурналаРегистрации.Информация,
			ОбъектМетаданных,,
			Комментарий);
	КонецЕсли;
КонецПроцедуры

#КонецОбласти

#КонецЕсли