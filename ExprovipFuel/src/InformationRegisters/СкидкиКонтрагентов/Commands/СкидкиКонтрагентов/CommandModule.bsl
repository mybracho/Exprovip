
&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
	СтруктураПараметров = Новый Структура;
	Отбор = Новый Структура;
	Отбор.Вставить("Контрагент", ПараметрКоманды);
	СтруктураПараметров.Вставить("Отбор", Отбор);

	ОткрытьФорму("РегистрСведений.СкидкиКонтрагентов.ФормаСписка", СтруктураПараметров,
		ПараметрыВыполненияКоманды.Источник, ПараметрыВыполненияКоманды.Уникальность, ПараметрыВыполненияКоманды.Окно,
		ПараметрыВыполненияКоманды.НавигационнаяСсылка);	

КонецПроцедуры