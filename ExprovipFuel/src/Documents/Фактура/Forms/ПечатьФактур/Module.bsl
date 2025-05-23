
#Область ОписаниеПеременных

#КонецОбласти

#Область ОбработчикиСобытийФормы
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Если Параметры.Свойство("СтруктураПечати") = Ложь Тогда
		Возврат;
	КонецЕсли;
	СтруктураПечати = Параметры.СтруктураПечати; 	
	ЗаполнитьТаблицуПечати(СтруктураПечати);
	ЗаполнитьТаблицаДанные(СтруктураПечати);
	Фактура = СтруктураПечати.Фактура;
КонецПроцедуры

#КонецОбласти


#Область ОбработчикиСобытийЭлементовШапкиФормы

// Код процедур и функций

#КонецОбласти

#Область ОбработчикиКомандФормы
&НаКлиенте
Процедура ВыбратьВсе(Команда)
	Для Каждого СтрокаТаблица Из ТаблицаПечати Цикл
		СтрокаТаблица.Выбран = Истина;
	КонецЦикла;	
КонецПроцедуры

&НаКлиенте
Процедура СнятьВсе(Команда)
	Для Каждого СтрокаТаблица Из ТаблицаПечати Цикл
		СтрокаТаблица.Выбран = Ложь;
	КонецЦикла;	
КонецПроцедуры

&НаКлиенте
Процедура ПечатьФактуры(Команда)
	Для Каждого СтрокаТЧ Из ТаблицаПечати Цикл
		Если Не СтрокаТЧ.Выбран Тогда
			Продолжить;
		КонецЕсли;	
		Структура = ПолучитьТабличныйДокумент(СтрокаТЧ.Контрагент, СтрокаТЧ.ЭтапОплаты, СтрокаТЧ.НомерФактуры);
		ТабличныйДокумент = Структура.ТабличныйДокумент;		
		ТабличныйДокумент.Показать(Структура.ИмяФайла);
	КонецЦикла;		
КонецПроцедуры

// Получить табличный документ.
// 
// Параметры:
//  КонтрагентСсылка - СправочникСсылка.Контрагенты - Контрагент ссылка
//  ЭтапОплаты - Число - Этап оплаты
//  НомерФактуры Номер фактуры
// 
// Возвращаемое значение:
//  Структура - Получить табличный документ:
// * ТабличныйДокумент - ТабличныйДокумент - 
// * ИмяФайла - Строка - 
&НаСервере
Функция ПолучитьТабличныйДокумент(КонтрагентСсылка, ЭтапОплаты, НомерФактуры)
	Структура = Новый Структура;
	Структура.Вставить("ТабличныйДокумент", Новый ТабличныйДокумент());
	Структура.Вставить("ИмяФайла", "");
	
	ТаблицаДанныеВременная = ТаблицаДанные.Выгрузить();
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ТаблицаДанные", ТаблицаДанныеВременная);
	Запрос.УстановитьПараметр("Контрагент", КонтрагентСсылка); 
	Запрос.УстановитьПараметр("ЭтапОплаты", ЭтапОплаты);
	
	#Область ТекстЗапроса
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ТаблицаДанные.Клиент,
	|	ТаблицаДанные.Продукт,
	|	ТаблицаДанные.ЭтапОплаты,
	|	ТаблицаДанные.Количество,
	|	ТаблицаДанные.Сумма,
	|	ТаблицаДанные.СуммаСкидки,
	|	ТаблицаДанные.Итого,
	|	ТаблицаДанные.Валюта,
	|	ТаблицаДанные.ДатаТранзакции,
	|	ТаблицаДанные.МестоТранзакции,
	|	ТаблицаДанные.Карта,
	|	ТаблицаДанные.Автомобиль,
	|	ТаблицаДанные.Цена,
	|	ТаблицаДанные.Скидка,
	|	ТаблицаДанные.ЦенаСоСкидкой
	|ПОМЕСТИТЬ ВТ_Данные
	|ИЗ
	|	&ТаблицаДанные КАК ТаблицаДанные
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТ_Данные.Клиент КАК Клиент,
	|	ВТ_Данные.Продукт КАК Продукт,
	|	СУММА(ВТ_Данные.Количество) КАК Количество,
	|	СУММА(ВТ_Данные.Сумма) КАК Сумма,
	|	СУММА(ВТ_Данные.СуммаСкидки) КАК СуммаСкидки,
	|	СУММА(ВТ_Данные.Итого) КАК Итого,
	|	Номенклатура.ЭтоДороги КАК ЭтоДороги,
	|	МАКСИМУМ(ВТ_Данные.Валюта) КАК Валюта
	|ИЗ
	|	ВТ_Данные КАК ВТ_Данные
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Номенклатура КАК Номенклатура
	|		ПО ВТ_Данные.Продукт = Номенклатура.Ссылка
	|ГДЕ
	|	ВТ_Данные.Клиент = &Контрагент
	|	И ВТ_Данные.ЭтапОплаты = &ЭтапОплаты
	|СГРУППИРОВАТЬ ПО
	|	ВТ_Данные.Клиент,
	|	ВТ_Данные.Продукт,
	|	Номенклатура.ЭтоДороги
	|
	|УПОРЯДОЧИТЬ ПО
	|	Клиент,
	|	ЭтоДороги,
	|	Продукт
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТ_Данные.Клиент,
	|	ВТ_Данные.Продукт,
	|	ВТ_Данные.ЭтапОплаты,
	|	ВТ_Данные.Количество,
	|	ВТ_Данные.Сумма,
	|	ВТ_Данные.СуммаСкидки,
	|	ВТ_Данные.Итого,
	|	ВТ_Данные.Валюта,
	|	ВТ_Данные.ДатаТранзакции,
	|	ВТ_Данные.МестоТранзакции,
	|	ЕСТЬNULL(Номенклатура.ЭтоДороги, ЛОЖЬ) КАК ЭтоДороги,
	|	ВТ_Данные.Карта,
	|	ВТ_Данные.Автомобиль,
	|	ВТ_Данные.Цена,
	|	ВТ_Данные.Скидка,
	|	ВТ_Данные.ЦенаСоСкидкой
	|ПОМЕСТИТЬ ВТ_Детализация
	|ИЗ
	|	ВТ_Данные КАК ВТ_Данные
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Номенклатура КАК Номенклатура
	|		ПО ВТ_Данные.Продукт = Номенклатура.Ссылка
	|ГДЕ
	|	ВТ_Данные.Клиент = &Контрагент
	|	И ВТ_Данные.ЭтапОплаты = &ЭтапОплаты
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТ_Детализация.Клиент,
	|	ВТ_Детализация.Продукт,
	|	ВТ_Детализация.ЭтапОплаты,
	|	ВТ_Детализация.Количество КАК Количество,
	|	ВТ_Детализация.Сумма КАК Сумма,
	|	ВТ_Детализация.СуммаСкидки КАК СуммаСкидки,
	|	ВТ_Детализация.Итого КАК Итого,
	|	ВТ_Детализация.Валюта,
	|	ВТ_Детализация.ДатаТранзакции,
	|	ВТ_Детализация.МестоТранзакции,
	|	ВТ_Детализация.ЭтоДороги КАК ЭтоДороги,
	|	ВТ_Детализация.Карта,
	|	ВТ_Детализация.Автомобиль,
	|	ВТ_Детализация.Цена,
	|	ВТ_Детализация.Скидка,
	|	ВТ_Детализация.ЦенаСоСкидкой
	|ИЗ
	|	ВТ_Детализация КАК ВТ_Детализация
	|
	|УПОРЯДОЧИТЬ ПО
	|	ВТ_Детализация.ЭтоДороги
	|ИТОГИ
	|	СУММА(Итого),
	|	СУММА(СуммаСкидки),
	|	СУММА(Сумма),
	|	СУММА(Количество)
	|ПО
	|	ЭтоДороги";
	#КонецОбласти
	
	ТабличныйДокумент = Новый ТабличныйДокумент;
	
	Макет = Документы.Фактура.ПолучитьМакет("ПечатьФактуры");
	ОбластьТитул = Макет.ПолучитьОбласть("Титул");
	ОбластьШапка = Макет.ПолучитьОбласть("Шапка");
	ОбластьСтрокаТитул = Макет.ПолучитьОбласть("СтрокаТитул");
	ОбластьИтогТитул = Макет.ПолучитьОбласть("ИтогТитул");
	ОбластьСтрока = Макет.ПолучитьОбласть("Строка");
	ОбластьИтог = Макет.ПолучитьОбласть("Итог");
	ОбластШапкаБелтол = Макет.ПолучитьОбласть("ШапкаБелтол");
	ОбластьПодвал = Макет.ПолучитьОбласть("Подвал");
	
	МассивРезультататов = Запрос.ВыполнитьПакет();
	
	ДатаДокумента = Формат(Фактура.Дата, "ДФ=dd.MM.yyyy;");
	
	СтруктураРеквизитовКлиента = ПолучитьРеквизитыКлиента(КонтрагентСсылка);
	ОбластьТитул.Параметры.Заполнить(СтруктураРеквизитовКлиента);
	ОбластьТитул.Параметры.НомерФактуры = НомерФактуры;
	ОбластьТитул.Параметры.ДатаДокумента = ДатаДокумента;
	
	ТабличныйДокумент.Вывести(ОбластьТитул);
	
	Выборка = МассивРезультататов[1].Выбрать();
	ИтогСумма = 0;
	ВалютаФактуры = Справочники.Валюты.ПустаяСсылка();
	Пока Выборка.Следующий() Цикл
		ОбластьСтрокаТитул.Параметры.ВидПродукта = Выборка.Продукт;
		ОбластьСтрокаТитул.Параметры.Количество = Выборка.Количество;
		ОбластьСтрокаТитул.Параметры.Стоимость = Выборка.Сумма;
		ОбластьСтрокаТитул.Параметры.СуммаСкидки = Выборка.СуммаСкидки;
		ОбластьСтрокаТитул.Параметры.Итог = Выборка.Итого;	
		ТабличныйДокумент.Вывести(ОбластьСтрокаТитул);
		
		ИтогСумма = ИтогСумма + Выборка.Итого;
		ВалютаФактуры = Выборка.Валюта;
	КонецЦикла;
	ИтогОкругленный = Окр(ИтогСумма);
	ОбластьИтогТитул.Параметры.ИтогОкругленный = ИтогОкругленный;
	ОбластьИтогТитул.Параметры.ИтогОкругление = Окр(ИтогСумма) - ИтогСумма;
	ОбластьИтогТитул.Параметры.Валюта = ВалютаФактуры;
	ОбластьИтогТитул.Параметры.СуммаФактурыПрописью	= Exprovip.ПрописьЧисла(ИтогОкругленный, ВалютаФактуры);						
	ТабличныйДокумент.Вывести(ОбластьИтогТитул);
	ТабличныйДокумент.ВывестиГоризонтальныйРазделительСтраниц();
	флагЕстьТопливо = Ложь;
	
	ЦветФона = Новый Цвет(82, 198, 222);
	
	ВыборкаДетализация = МассивРезультататов[3].Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам, "ЭтоДороги");
	Пока ВыборкаДетализация.Следующий() Цикл
		Если ВыборкаДетализация.ЭтоДороги Тогда
			Если флагЕстьТопливо Тогда
				ТабличныйДокумент.ВывестиГоризонтальныйРазделительСтраниц();
			КонецЕсли;
			ОбластШапкаБелтол.Параметры.НазваниеКлиента = СтруктураРеквизитовКлиента.НазваниеКлиента;
			ОбластШапкаБелтол.Параметры.Тариф = СтруктураРеквизитовКлиента.Тариф;
			ОбластШапкаБелтол.Параметры.ДатаДокумента = ДатаДокумента;
			ТабличныйДокумент.Вывести(ОбластШапкаБелтол);
		Иначе
			ОбластьШапка.Параметры.НазваниеКлиента = СтруктураРеквизитовКлиента.НазваниеКлиента;
			ОбластьШапка.Параметры.Тариф = СтруктураРеквизитовКлиента.Тариф;
			ОбластьШапка.Параметры.ДатаДокумента = ДатаДокумента;
			ТабличныйДокумент.Вывести(ОбластьШапка);
			флагЕстьТопливо = Истина;
		КонецЕсли;
		ВыборкаДетальныеЗаписи = ВыборкаДетализация.Выбрать();
		Счетчик = 0;
		Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
			Счетчик = Счетчик + 1;
			ОбластьСтрока.Параметры.Заполнить(ВыборкаДетальныеЗаписи);
			ОбластьСтрока.Параметры.Скидка = СтрШаблон("%1%%", Формат(ВыборкаДетальныеЗаписи.Скидка, "ЧН=0;"));
			ОбластьОформления = ТабличныйДокумент.Вывести(ОбластьСтрока);
			Если Счетчик % 2 = 0 Тогда
				ТабличныйДокумент.Область(
					ОбластьОформления.Верх,
					1,
					ОбластьОформления.Низ,
					ТабличныйДокумент.ШиринаТаблицы).ЦветФона = ЦветФона;				
			КонецЕсли;			
		КонецЦикла;
		ОбластьИтог.Параметры.ИтогКоличество = ВыборкаДетализация.Количество;
		ОбластьИтог.Параметры.ИтогСумма = ВыборкаДетализация.Сумма;
		ОбластьИтог.Параметры.ИтогСуммаСкидки = ВыборкаДетализация.СуммаСкидки;
		ОбластьИтог.Параметры.ИтогИтого	= ВыборкаДетализация.Итого;
		
		ОбластьОформления = ТабличныйДокумент.Вывести(ОбластьИтог);
		Если Счетчик % 2 <> 0 Тогда
			ТабличныйДокумент.Область(
				ОбластьОформления.Верх,
				1,
				ОбластьОформления.Низ,
				ТабличныйДокумент.ШиринаТаблицы).ЦветФона = ЦветФона;				
		КонецЕсли;
		ТабличныйДокумент.Вывести(ОбластьПодвал);
	КонецЦикла;	
	
	ТабличныйДокумент.Вывести(ОбластьИтогТитул);
	ТабличныйДокумент.АвтоМасштаб = Истина;
	ТабличныйДокумент.ОтображатьСетку = Ложь;
	ТабличныйДокумент.ОтображатьЗаголовки = Ложь;
		
	Структура.ТабличныйДокумент = ТабличныйДокумент;
	Структура.ИмяФайла = СтрШаблон("%1_%2", КонтрагентСсылка.Логин, Формат(НомерФактуры, "ЧГ=0;"));		
		
	Возврат Структура;	

КонецФункции	
#КонецОбласти

#Область СлужебныеПроцедурыИФункции


// Получить реквизиты клиента.
// 
// Параметры:
//  КонтрагентСсылка Контрагент ссылка
// 
// Возвращаемое значение:
//  Структура - Получить реквизиты клиента:
// * НазваниеКлиента - Строка 
// * ПолноеНаименование - Строка
// * ЮридическийАдрес - Строка - 
// * ПочтовыйКод - Строка
// * Тариф - СправочникСсылка.Скидки - 
// * НИП - Строка
Функция ПолучитьРеквизитыКлиента(КонтрагентСсылка)
	СтруктураРеквизитов = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(КонтрагентСсылка, "Наименование, НаименованиеПолное, ПочтовыйКод, НИП");
	
	ЮридическийАдрес = УправлениеКонтактнойИнформацией.КонтактнаяИнформацияОбъекта(КонтрагентСсылка, Справочники.ВидыКонтактнойИнформации.ЮрАдресКонтрагента);
	
	Структура = Новый Структура;
	Структура.Вставить("НазваниеКлиента", СтруктураРеквизитов.Наименование);
	Структура.Вставить("ПолноеНаименование", СтруктураРеквизитов.НаименованиеПолное);
	Структура.Вставить("ЮридическийАдрес", ЮридическийАдрес);								
	Структура.Вставить("ПочтовыйКод", СтруктураРеквизитов.ПочтовыйКод);
	Структура.Вставить("Тариф", Exprovip.ПолучитьВидСкидкиКонтрагента(КонтрагентСсылка, Фактура.Дата));
	Структура.Вставить("НИП", СтруктураРеквизитов.НИП);
	
	Возврат Структура;	
	
КонецФункции	


// Получить последний номер печати.
// 
// Возвращаемое значение:
//  Число - Получить последний номер печати
&НаСервере
Функция ПолучитьПоследнийНомерПечати()
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	МАКСИМУМ(НомераФактур.НомерФактуры) КАК ПоследнийНомерФактуры
	|ИЗ
	|	РегистрСведений.НомераФактур КАК НомераФактур";
	
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда
		Возврат Выборка.ПоследнийНомерФактуры;
	Иначе
		Возврат 0;
	КонецЕсли;		
КонецФункции

&НаСервере
Процедура ЗаполнитьТаблицаДанные(СтруктураПечати)
	Для Каждого ЭлементМассива Из СтруктураПечати.Строки Цикл
		НоваяСтрока = ТаблицаДанные.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, ЭлементМассива);
	КонецЦикла;	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьТаблицуПечати(СтруктураПечати)
	ТаблицаКлиентов = Новый ТаблицаЗначений;
	ТаблицаКлиентов.Колонки.Добавить("Клиент", Новый ОписаниеТипов("СправочникСсылка.Контрагенты"));
	ТаблицаКлиентов.Колонки.Добавить("Фактура", Новый ОписаниеТипов("ДокументСсылка.Фактура"));
	ТаблицаКлиентов.Колонки.Добавить("ЭтапОплаты", Новый ОписаниеТипов("Число"));
	
	Для Каждого ЭлементМассива ИЗ СтруктураПечати.Клиенты Цикл
		НоваяСтрока = ТаблицаКлиентов.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, ЭлементМассива);
	КонецЦикла;	
	
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ТаблицаКлиентов", ТаблицаКлиентов);
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ТаблицаКлиентов.Клиент КАК Контрагент,
	|	ТаблицаКлиентов.Фактура КАК Фактура,
	|	ТаблицаКлиентов.ЭтапОплаты КАК ЭтапОплаты
	|ПОМЕСТИТЬ ВТ_ТаблицаКлиентов
	|ИЗ
	|	&ТаблицаКлиентов КАК ТаблицаКлиентов
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТ_ТаблицаКлиентов.Контрагент КАК Контрагент,
	|	ВТ_ТаблицаКлиентов.Фактура КАК Фактура,
	|	ВТ_ТаблицаКлиентов.ЭтапОплаты,
	|	ЕСТЬNULL(НомераФактур.НомерФактуры, 0) КАК НомерФактуры
	|ИЗ
	|	ВТ_ТаблицаКлиентов КАК ВТ_ТаблицаКлиентов
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.НомераФактур КАК НомераФактур
	|		ПО ВТ_ТаблицаКлиентов.Контрагент = НомераФактур.Контрагент
	|		И ВТ_ТаблицаКлиентов.Фактура = НомераФактур.Фактура
	|
	|УПОРЯДОЧИТЬ ПО
	|	Контрагент,
	|	ЭтапОплаты
	|ИТОГИ
	|	МАКСИМУМ(НомерФактуры) КАК НомерФактуры,
	|	МАКСИМУМ(Фактура) КАК Фактура
	|ПО
	|	Контрагент";
	
	ПоследнийНомерПечати = ПолучитьПоследнийНомерПечати();
	
	ВыборкаКонтрагент = Запрос.Выполнить().Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам, "Контрагент");
	Пока ВыборкаКонтрагент.Следующий() Цикл
		Если ВыборкаКонтрагент.НомерФактуры = 0 Тогда
			ПоследнийНомерПечати = ПоследнийНомерПечати + 1;
			НомерФактуры = ПоследнийНомерПечати;
			СоздатьНомерФактуры(ВыборкаКонтрагент.Контрагент, ВыборкаКонтрагент.Фактура, НомерФактуры);
		Иначе
			НомерФактуры = ВыборкаКонтрагент.НомерФактуры;	
		КонецЕсли;
		ВыборкаДетальныеЗаписи = ВыборкаКонтрагент.Выбрать();
		Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
			НоваяСтрока = ТаблицаПечати.Добавить();
			НоваяСтрока.Контрагент = ВыборкаКонтрагент.Контрагент;
			НоваяСтрока.ЭтапОплаты = ВыборкаДетальныеЗаписи.ЭтапОплаты;
			НоваяСтрока.НомерФактуры = НомерФактуры;
		КонецЦикла;	
	КонецЦикла;		
КонецПроцедуры

&НаСервере
Процедура СоздатьНомерФактуры(Контрагент, Фактура, НомерФактуры)
	МенеджерЗаписи = РегистрыСведений.НомераФактур.СоздатьМенеджерЗаписи();
	МенеджерЗаписи.Контрагент = Контрагент;
	МенеджерЗаписи.Фактура = Фактура;
	МенеджерЗаписи.НомерФактуры = НомерФактуры;
	МенеджерЗаписи.Записать();
КонецПроцедуры	

#КонецОбласти
