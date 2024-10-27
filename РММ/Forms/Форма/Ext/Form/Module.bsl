﻿&НаКлиенте
Процедура РассчитатьСумму()
    Строка = Элементы.Корзина.ТекущиеДанные;
	Цена = НайтиЦенуПоНаименованию(Строка.Товар);
	Строка.Сумма = Строка.Количество * Цена;
	ОбщаяСумма = ОбщаяСумма + Строка.Сумма;
КонецПроцедуры

&НаСервере
Функция НайтиТовар(Код)
	СсылкаНаТовар = Справочники.Номенклатура.НайтиПоКоду(Код);
	Возврат СсылкаНаТовар.ПолучитьОбъект().Наименование;
КонецФункции

&НаСервере
Функция НайтиЦенуПоКоду(Код)
	СсылкаНаТовар = Справочники.Номенклатура.НайтиПоКоду(Код);
	Возврат СсылкаНаТовар.ПолучитьОбъект().Цена;
КонецФункции

&НаСервере
Функция НайтиЦенуПоНаименованию(Наименование)
	СсылкаНаТовар = Справочники.Номенклатура.НайтиПоНаименованию(Наименование);
	Возврат СсылкаНаТовар.ПолучитьОбъект().Цена;
КонецФункции

&НаКлиенте
Процедура Выбрать(Команда)
	ТоварыОбщее = ТоварыОбщее + 1;
	Для каждого Выбор из Элементы.Товары.ВыделенныеСтроки Цикл
		стр = НайтиТовар(Выбор);
		Флаг = Ложь;
		Для каждого Строка из Корзина цикл	
			Если Строка.Товар = стр Тогда
				ОбщаяСумма = ОбщаяСумма - Строка.Сумма;
				Строка.Количество = Строка.Количество + 1;
				Строка.Сумма = Строка.Количество * Строка.Цена;
				ОбщаяСумма = ОбщаяСумма + Строка.Сумма;
				Флаг = Истина
			КонецЕсли   
			
		КонецЦикла;
		
		Если не Флаг Тогда
			стрКорзина = Корзина.Добавить();
			стрКорзина.Товар = стр; 
			стрКорзина.Цена = НайтиЦенуПоНаименованию(стр);
			стрКорзина.Количество = 1; 
			стрКорзина.Сумма = стрКорзина.Цена * стрКорзина.Количество;
			ОбщаяСумма = ОбщаяСумма + стрКорзина.Сумма;
			Позиции = Позиции + 1;
		КонецЕсли;
	КонецЦикла
КонецПроцедуры

&НаКлиенте
Процедура КорзинаЦенаПриИзменении(Элемент)
	РассчитатьСумму()	
КонецПроцедуры

&НаКлиенте
Процедура КорзинаКоличествоПриИзменении(Элемент)
	РассчитатьСумму();
	ТоварыОбщее = ТоварыОбщее + Элементы.Корзина.ТекущиеДанные.Количество;
;
КонецПроцедуры

&НаСервере
Функция ОформитьЗаказНаСервере()
	НовДок = Документы.ЗаказКлиента.СоздатьДокумент();    
	НовДок.Дата = ТекущаяДата();
	
	Для каждого Строка из Корзина цикл
		СтрокаТЧ = НовДок.Корзина.Добавить();
		СтрокаТЧ.Номенклатура = Строка.Товар;
		СтрокаТЧ.Цена = Строка.Цена;
		СтрокаТЧ.Количество = Строка.Количество;
		СтрокаТЧ.Сумма = Строка.Сумма;
	КонецЦикла;
	
	НовДок.Записать(); 
	
	Возврат НовДок.Ссылка;
КонецФункции

&НаКлиенте
Процедура ОформитьЗаказ(Команда)
	СсылкаНаДокумент = ОформитьЗаказНаСервере();
	ОткрытьЗначение(СсылкаНаДокумент);
КонецПроцедуры

&НаКлиенте
Процедура ПроизводительОбработкаВыбора(Элемент, ВыбранноеЗначение, ДополнительныеДанные, СтандартнаяОбработка)
	Для каждого Элемент из Товары Цикл
		Если Элемент.ТекущиеДанные.Производитель <> ВыбранноеЗначение Тогда
			Элемент.Видимость = Ложь
		КонецЕсли
	КонецЦикла;
КонецПроцедуры

&НаСервере
Процедура ТоварПриИзмененииНаСервере()
		
	
	
	Если Товар <> "" Тогда 
		ФильтрПоНаименованию = " И Номенклатура.Наименование Подобно (""%" + Товар + "%"") "; 
	Иначе
		ФильтрПоНаименованию = "";
	КонецЕсли;
	
	Если Производитель <> "" Тогда 
		ФильтрПоПроизводителю = " И Номенклатура.Производитель.Наименование Подобно (""%" + Производитель + "%"") "; 
	Иначе
		ФильтрПоПроизводителю = "";
	КонецЕсли; 
	
	//Если Группа <> "" Тогда
	//	"ВЫБРАТЬ
	//	|	Номенклатура.Наименование КАК Наименование,
	//	|	Номенклатура.Родитель КАК Родитель
	//	|ИЗ
	//	|	Справочник.Номенклатура КАК Номенклатура
	//	|ГДЕ
	//	|	Номенклатура.ЭтоГруппа
	//	|	И Номенклатура.Наименование ПОДОБНО (""%" + Группа + "%"")"
	//	
	//	ФильтрПоГруппе = " И Номенклатура.Родитель в иерархии &Родитель";
	//Иначе 
	//	ФильтрПоГруппе = "";
	//КонецЕсли;
	//
	Товары.ТекстЗапроса = "ВЫБРАТЬ
	                      |	Номенклатура.Код КАК Код,
	                      |	Номенклатура.Наименование КАК Наименование,
	                      |	Номенклатура.Ссылка КАК Ссылка,
	                      |	Номенклатура.Производитель КАК Производитель
	                      |ИЗ
	                      |	Справочник.Номенклатура КАК Номенклатура
	                      |ГДЕ
	                      |	ИСТИНА
	                      |	И НЕ Номенклатура.ЭтоГруппа
						  | "
						   + ФильтрПоНаименованию + ФильтрПоПроизводителю;// + ФильтрПоГруппе;  
						   
	Товары.Параметры.УстановитьЗначениеПараметра("Родитель", Группа.Наименование); 
							   
	
КонецПроцедуры

&НаКлиенте
Процедура ТоварПриИзменении(Элемент)
	ТоварПриИзмененииНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура ПроизводительПриИзменении(Элемент)
	ТоварПриИзмененииНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура ГруппаПриИзменении(Элемент)
	ТоварПриИзмененииНаСервере();
КонецПроцедуры


