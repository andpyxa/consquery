﻿
&НаКлиенте
Перем мИндексыКартинкиДляТипов;

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)

	ОбработкаОбъект = РеквизитФормыВЗначение("Объект");  
	
     // установим внутреннее строковое представление типа значения объекта обработки
    ТипОбработка = ЗначениеВСтрокуВнутр(ТипЗнч(ОбработкаОбъект));
	
	СеансовыеДанные = Новый Структура();	
	СеансовыеДанные.Вставить("ИдентификаторСеанса", Новый УникальныйИдентификатор);
	СеансовыеДанные.Вставить("КЭШ"                , Новый Структура);
	
	ТипыИсточниковДанных     = гТипыИсточниковДанных(ТипОбработка, СеансовыеДанные);
	ОперацииСЗапросами       = гОперацииСЗапросами(ТипОбработка, СеансовыеДанные);
	
	Режим               = Параметры.Режим;
	Тип                 = Параметры.Тип;
	ИмяЭлементаИзОблака = Параметры.ИмяЭлементаИзОблака;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	мИндексыКартинкиДляТипов = гПолучитьИндексыКартинкиДляТипов(ТипОбработка, СеансовыеДанные);
	
	ПредыдущийЭлемент = Неопределено;
	
	Если Тип = ТипыИсточниковДанных.Пакет Тогда 
		ЗаполнитьПакетамиИзОблака(Отказ);			
	Иначе
		ЗаполнитьЗапросамиИлиПакетамиИзОблакаПоИсторииИспользования(Отказ);
	КонецЕсли;
	
	Если Не Отказ Тогда 
		Если Режим = ОперацииСЗапросами.СохранитьКАК ИЛИ Режим = ОперацииСЗапросами.Сохранить ИЛИ Режим = ОперацииСЗапросами.СохранитьВОблако Тогда 
			Элементы.КнопкаВыполнить.Заголовок = "Сохранить";
			типЭлемента = Тип;
		ИначеЕсли Режим = ОперацииСЗапросами.ЗагрузитьИзОблака Тогда 
			Если СписокЭлементовИзОблака.Количество() = 0 Тогда 
				ПоказатьПредупреждение(,"Вы еще не сохраняли запросы в облаке.", 10, "Диалог выбора файла в облаке");
				Отказ = Истина;
			Иначе
				Элементы.КнопкаВыполнить.Заголовок = "Загрузить";
			КонецЕсли;
		Иначе
			Сообщить("Не определен режим открытия диалога. Обратитесь к разработчику.", СтатусСообщения.Важное); // #рефакторинг сделать более информативное сообщение, упростить отправку ошибки
			Отказ = Истина;
		КонецЕсли;
		
		Если не Отказ Тогда 
			УстановитьВидимостьНеВключатьПодчиненныеЗапросы();
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры // ПриОткрытии()

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура УровеньВверх(Команда)
	
	Отказ = Ложь;
	
	Если ТекущийПакет = "-1" Тогда 
		Возврат;
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(ТекущийПуть) ИЛИ ТекущийПуть.Количество() = 0 Тогда 
		
		идТекущегоЭлемента = ТекущийПакет;
		ЗаполнитьПакетамиИзОблака(Отказ);		
	Иначе
		
		идТекущегоЭлемента = ТекущийПуть[0].Значение.id;
		
		Если ТекущийПуть.Количество() = 1 Тогда 
			идРодителя = Неопределено;
		Иначе
			идРодителя = ТекущийПуть[1].Значение.id; // выбираем второй элемент массива
		КонецЕсли;
		
		ЗаполнитьЗапросамиИзОблака(ТекущийПакет, идРодителя, Отказ);		
	КонецЕсли;
	
	Если Не Отказ Тогда 
		Элементы.СписокЭлементовИзОблака.ТекущаяСтрока = СписокЭлементовИзОблака.НайтиСтроки(Новый Структура("id", идТекущегоЭлемента))[0].ПолучитьИдентификатор();
		УстановитьВидимостьНеВключатьПодчиненныеЗапросы();
	КонецЕсли;
	
КонецПроцедуры // УровеньВверх()

&НаКлиенте
Процедура Домой(Команда)
	ЗаполнитьПакетамиИзОблака(Неопределено);
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовПодвалаФормы

&НаКлиенте
Процедура КнопкаВыполнить(Команда)
	КнопкаВыполнитьНажатиеДействие();
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыСписокЭлементовИзОблака

&НаКлиенте
Процедура СписокЭлементовИзОблакаПриАктивизацииСтроки(Элемент)
	
	лТекущиеДанные = Элемент.ТекущиеДанные;
	Если лТекущиеДанные <> Неопределено Тогда 
		// если список источников не пуст
		Если Не гЭтоЗапись(ТипОбработка, СеансовыеДанные, Режим) Тогда 
			ИмяЭлементаИзОблака = лТекущиеДанные.Имя;
			ТипЭлемента = лТекущиеДанные.Тип;
			УстановитьВидимостьНеВключатьПодчиненныеЗапросы();
			ПредыдущийЭлемент = Новый Структура("Имя, Тип", лТекущиеДанные.Имя, лТекущиеДанные.Тип);
		ИначеЕсли лТекущиеДанные <> Неопределено И лТекущиеДанные.Тип = Тип Тогда 
			Если ПредыдущийЭлемент <> Неопределено Тогда 
				ИмяЭлементаИзОблака = лТекущиеДанные.Имя;
			КонецЕсли;
			ПредыдущийЭлемент = Новый Структура("Имя, Тип", лТекущиеДанные.Имя, лТекущиеДанные.Тип);
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СписокЭлементовИзОблакаВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	Отказ = Ложь;
	
	лТекущаяСтрока = СписокЭлементовИзОблака.НайтиПоИдентификатору(ВыбраннаяСтрока);
	
	Если Тип = ТипыИсточниковДанных.Пакет ИЛИ лТекущаяСтрока.Тип = ТипыИсточниковДанных.Код Тогда 
		Если лТекущаяСтрока.Тип = Тип Тогда 
			ИмяЭлементаИзОблака = лТекущаяСтрока.Имя;
		КонецЕсли;
		КнопкаВыполнитьНажатиеДействие();
	Иначе
		Если лТекущаяСтрока.Тип = ТипыИсточниковДанных.Пакет Тогда 
			ЗаполнитьЗапросамиИзОблака(лТекущаяСтрока.id, Неопределено, Отказ);
		ИначеЕсли лТекущаяСтрока.Тип = ТипыИсточниковДанных.Запрос Тогда 
			ЗаполнитьЗапросамиИзОблака(ТекущийПакет, лТекущаяСтрока.id, Отказ);
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ОбновитьСписок(Команда)
	ОбновитьДействие();
КонецПроцедуры

&НаКлиенте
Процедура Удалить(Команда)
	ПоказатьВопрос(Новый ОписаниеОповещения("ПослеЗакрытияВопросаУдалитьПакет", ЭтаФорма, Новый Структура),
		"Удалить выбранные элементы?",
		РежимДиалогаВопрос.ДаНет,,
		КодВозвратаДиалога.Да,
		"Удаление сохраненных данных в облаке.");
КонецПроцедуры

#Область ПрограммноДобавляемыеОбработчики

&НаКлиенте
Процедура СоздатьНовыйПакет(Команда)
	ПоказатьВводСтроки(Новый ОписаниеОповещения("ПоказатьВводСтрокиСоздатьНовыйПакетПродолжить", ЭтаФорма, Новый Структура),
		гСтроковыеКонтанты(ТипОбработка, СеансовыеДанные, "ИмяНовогоПакетаЗапроса"), "Введите название пакета", 100, Истина);
КонецПроцедуры // СоздатьНовыйПакет()

&НаКлиенте
Процедура Опубликовать(Команда)
	
	лТекущиеДанные = Элементы.СписокЭлементовИзОблака.ТекущиеДанные;
	
	Если лТекущиеДанные <> Неопределено Тогда 
		Если лТекущиеДанные.Тип = ТипыИсточниковДанных.Запрос Тогда 
			
			лДополнительныеПараметры = Новый Структура;
			лДополнительныеПараметры.Вставить("идПакетаВОблаке"     , ТекущийПакет);
			лДополнительныеПараметры.Вставить("идЗапроса"           , лТекущиеДанные.id);
			лДополнительныеПараметры.Вставить("идСтрокиКода"        , Неопределено);
			лДополнительныеПараметры.Вставить("включатьПодчиненные" , Ложь);
			
			ПоказатьВводСтроки(Новый ОписаниеОповещения("ПоказатьВводСтрокиОпубликоватьПродолжить", ЭтаФорма, лДополнительныеПараметры),, "Введите email пользователя", 100, Ложь);
		Иначе
			ПоказатьПредупреждение(Новый ОписаниеОповещения("ПоказатьПредупреждениеПродолжить", ЭтаФорма), "Опубликовать можно только запрос.");
		КонецЕсли;
	Иначе
		ПоказатьПредупреждение(Новый ОписаниеОповещения("ПоказатьПредупреждениеПродолжить", ЭтаФорма), "Не выбран объект для публикации.");
	КонецЕсли;
	
КонецПроцедуры // Опубликовать()

#КонецОбласти

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

#Область ГлобальныеПроцедурыИФункции

&НаСервереБезКонтекста
Функция гДобавитьНовыйПакетЗапросовВОблако(ТипОбработка, СеансовыеДанные, Соединение, Строка)
	Возврат ОбъектОбработки(ТипОбработка, СеансовыеДанные).гДобавитьНовыйПакетЗапросовВОблако(Соединение, Строка);
КонецФункции // гДобавитьНовыйПакетЗапросовВОблако()

&НаСервереБезКонтекста
Функция гОпубликоватьВОблаке(ТипОбработка, СеансовыеДанные, Соединение, email, идПакетаВОблаке, идЗапроса, идСтрокиКода, включатьПодчиненные)
	Возврат ОбъектОбработки(ТипОбработка, СеансовыеДанные).гОпубликоватьВОблаке(Соединение, email, идПакетаВОблаке, идЗапроса, идСтрокиКода, включатьПодчиненные);
КонецФункции // гОпубликоватьВОблаке()

&НаСервереБезКонтекста
Функция гСтроковыеКонтанты(ТипОбработка, СеансовыеДанные, ИмяКонстанты)
	Возврат ОбъектОбработки(ТипОбработка, СеансовыеДанные).гСтроковыеКонтанты(ИмяКонстанты);
КонецФункции // гСтроковыеКонтанты()

&НаСервереБезКонтекста
Функция гУдалитьФайлыСЗапросамиВОблаке(ТипОбработка, СеансовыеДанные, соединение, списокИдВОблаке, НастройкиПрокси = Неопределено)
	Возврат ОбъектОбработки(ТипОбработка, СеансовыеДанные).гУдалитьФайлыСЗапросамиВОблаке(соединение, списокИдВОблаке, НастройкиПрокси);
КонецФункции // гУдалитьФайлыСЗапросамиВОблаке()

&НаСервереБезКонтекста
Функция гУдалитьЭлементыПоСпискуВОблаке(ТипОбработка, СеансовыеДанные, соединение, идПакета, списокИдЗапросовВОблаке, списокИдКодаВОблаке, НастройкиПрокси = Неопределено)
	Возврат ОбъектОбработки(ТипОбработка, СеансовыеДанные).гУдалитьЭлементыПоСпискуВОблаке(соединение, идПакета, списокИдЗапросовВОблаке, списокИдКодаВОблаке, НастройкиПрокси);
КонецФункции // гУдалитьЭлементыПоСпискуВОблаке()

&НаСервереБезКонтекста
Функция гОперацииСЗапросами(ТипОбработка, СеансовыеДанные)
	
	Возврат ОбъектОбработки(ТипОбработка, СеансовыеДанные).гОперацииСЗапросами();
	
КонецФункции

&НаСервереБезКонтекста
Функция гЭтоЗапись(ТипОбработка, СеансовыеДанные, Режим)
	
	Возврат ОбъектОбработки(ТипОбработка, СеансовыеДанные).гЭтоЗапись(Режим);
	
КонецФункции

&НаСервереБезКонтекста
Функция гИдентификаторНовогоОбъектаВОблаке(ТипОбработка, СеансовыеДанные)
	
	Возврат ОбъектОбработки(ТипОбработка, СеансовыеДанные).гИдентификаторНовогоОбъектаВОблаке();
	
КонецФункции // гПолучитьСписокПакетовВОблаке()

&НаСервереБезКонтекста
Функция гПолучитьСписокПакетовВОблаке(ТипОбработка, СеансовыеДанные, ИдентификаторСессии)
	
	Возврат ОбъектОбработки(ТипОбработка, СеансовыеДанные).гПолучитьСписокПакетовВОблаке(ИдентификаторСессии);
	
КонецФункции // гПолучитьСписокПакетовВОблаке()

&НаСервереБезКонтекста
Функция гПолучитьСписокПакетовИЛИЗапросовВОблакеПоИсторииИспользования(ТипОбработка, СеансовыеДанные, ИдентификаторСессии, НастройкиПрокси = Неопределено)
	
	Возврат ОбъектОбработки(ТипОбработка, СеансовыеДанные).гПолучитьСписокПакетовИЛИЗапросовВОблакеПоИсторииИспользования(ИдентификаторСессии, НастройкиПрокси);
	
КонецФункции // гПолучитьСписокПакетовИЛИЗапросовВОблакеПоИсторииИспользования()

&НаСервереБезКонтекста
Функция гПолучитьСписокЗапросовВОблаке(ТипОбработка, СеансовыеДанные, лСоединение, идПакета, идРодителя)
	
	Возврат ОбъектОбработки(ТипОбработка, СеансовыеДанные).гПолучитьСписокЗапросовВОблаке(лСоединение, идПакета, идРодителя);
	
КонецФункции // гПолучитьСписокЗапросовВОблаке()

&НаСервереБезКонтекста
Функция гВосстановитьИдентификаторСессииConsqueryCloud(ТипОбработка, СеансовыеДанные) Экспорт 
	
	Возврат ОбъектОбработки(ТипОбработка, СеансовыеДанные).гВосстановитьИдентификаторСессииConsqueryCloud();
	
КонецФункции // ВосстановитьИдентификаторСессииConsqueryCloud()

&НаСервереБезКонтекста
Функция гТипыИсточниковДанных(ТипОбработка, СеансовыеДанные);
	Возврат ОбъектОбработки(ТипОбработка, СеансовыеДанные).гТипыИсточниковДанных();
КонецФункции

&НаСервереБезКонтекста
Функция гПолучитьИндексыКартинкиДляТипов(ТипОбработка, СеансовыеДанные);
	Возврат ОбъектОбработки(ТипОбработка, СеансовыеДанные).гПолучитьИндексыКартинкиДляТипов();
КонецФункции // гПолучитьИндексыКартинкиДляТипов()

#КонецОбласти

#Область ИнтерфейсныеПроцедурыИФункции

&НаСервере
Процедура ДобавитьПунктКонтекстногоМенюСоздатьНовыйПакет()
	Если Элементы.Найти("СписокЭлементовИзОблакаКонтекстноеМенюСоздатьНовыйПакет") = Неопределено Тогда 
		Кнопка = Элементы.Вставить("СписокЭлементовИзОблакаКонтекстноеМенюСоздатьНовыйПакет", 
			Тип("КнопкаФормы"), Элементы.СписокЭлементовИзОблака.КонтекстноеМеню, Элементы.Найти("СписокЭлементовИзОблакаКонтекстноеМенюУдалить"));
		Кнопка.ИмяКоманды = "СоздатьНовыйПакет";
		Кнопка.Заголовок  = "Создать новый пакет";
	КонецЕсли;
КонецПроцедуры // ДобавитьПунктКонтекстногоМенюСоздатьНовыйПакет()

&НаСервере
Процедура УдалитьПунктКонтекстногоМенюСоздатьНовыйПакет()
	Если Элементы.Найти("СписокЭлементовИзОблакаКонтекстноеМенюСоздатьНовыйПакет") <> Неопределено Тогда 
		Элементы.Удалить(Элементы.Найти("СписокЭлементовИзОблакаКонтекстноеМенюСоздатьНовыйПакет"));
	КонецЕсли;		
КонецПроцедуры // УдалитьПунктКонтекстногоМенюСоздатьНовыйПакет()

&НаСервере
Процедура ДобавитьПунктКонтекстногоМенюОпубликовать()
	Если Элементы.Найти("СписокЭлементовИзОблакаКонтекстноеМенюОпубликовать") = Неопределено Тогда 
		Кнопка = Элементы.Вставить("СписокЭлементовИзОблакаКонтекстноеМенюОпубликовать", 
			Тип("КнопкаФормы"), Элементы.СписокЭлементовИзОблака.КонтекстноеМеню, Элементы.Найти("СписокЭлементовИзОблакаКонтекстноеМенюУдалить"));
		Кнопка.ИмяКоманды = "Опубликовать";
		Кнопка.Заголовок  = "Опубликовать";
	КонецЕсли;
КонецПроцедуры // ДобавитьПунктКонтекстногоМенюОпубликовать()

&НаСервере
Процедура УдалитьПунктКонтекстногоМенюОпубликовать()
	Если Элементы.Найти("СписокЭлементовИзОблакаКонтекстноеМенюОпубликовать") <> Неопределено Тогда 
		Элементы.Удалить(Элементы.Найти("СписокЭлементовИзОблакаКонтекстноеМенюСоздатьНовыйПакет"));
	КонецЕсли;		
КонецПроцедуры // УдалитьПунктКонтекстногоМенюОпубликовать()

&НаКлиенте
Процедура ОбновитьСтрокуСПутемКЗапросу(ИмяПакета)
	
	Если гЭтоЗапись(ТипОбработка, СеансовыеДанные, Режим) Тогда 
		Если Тип = ТипыИсточниковДанных.Пакет Тогда 
			Заголовок = "Выберите пакет для записи";
		ИначеЕсли Тип = ТипыИсточниковДанных.Запрос Тогда 
			Заголовок = "Выберите запрос для записи";
		ИначеЕсли Тип = ТипыИсточниковДанных.Код Тогда 
			Заголовок = "Выберите код для записи";
		Иначе
			Заголовок = "ошибка: неопределен тип для записи";
		КонецЕсли;
	Иначе
		Если ИмяПакета = Неопределено Тогда 
			Заголовок = "Выберите пакет с запросами";
		Иначе
			Заголовок = "Выберите запрос или код";
		КонецЕсли;	
	КонецЕсли;
	
	Если ИмяПакета = Неопределено Тогда 
		Путь = "";
	Иначе
		лПутьВнутриПакета = "";
		Если ЗначениеЗаполнено(ТекущийПуть) Тогда 
			Для Каждого Строка Из ТекущийПуть Цикл
				лПутьВнутриПакета = Строка.Значение.name + " \ " + лПутьВнутриПакета;
			КонецЦикла;
		КонецЕсли;
		Путь = "[" + ИмяПакета + "] \ " + лПутьВнутриПакета;
	КонецЕсли;	
КонецПроцедуры // ОбновитьСтрокуСПутемКЗапросу()

&НаКлиенте
Процедура УстановитьВидимостьНеВключатьПодчиненныеЗапросы()
	Элементы.НеВключатьПодчиненныеЗапросы.Видимость = (ТипЭлемента = ТипыИсточниковДанных.Запрос);
КонецПроцедуры	
	
#КонецОбласти

#Область ОбработчикиИнтерактивныхДействий

&НаКлиенте
Процедура ПоказатьВводСтрокиСоздатьНовыйПакетПродолжить(Строка, ДополнительныеПараметры) Экспорт
	
	Если СписокЭлементовИзОблака.НайтиСтроки(Новый Структура("Имя", Строка)).Количество() = 0 Тогда 
		
		лСоединение = гВосстановитьИдентификаторСессииConsqueryCloud(ТипОбработка, СеансовыеДанные);
		
		Результат = гДобавитьНовыйПакетЗапросовВОблако(ТипОбработка, СеансовыеДанные, лСоединение, Строка);	

		Если Результат.Статус <> "OK" Тогда 
			Сообщить(Результат.ТекстОшибки, СтатусСообщения.Важное);
		Иначе
			ЗаполнитьПакетамиИзОблака(Неопределено);
		КонецЕсли;
	Иначе
		ПоказатьПредупреждение(, "Пакет с именем [" + Строка + "] уже существует. Укажите другое имя пакета.");
		Возврат;
	КонецЕсли;
КонецПроцедуры // ПоказатьВводСтрокиСоздатьНовыйПакетПродолжить()

&НаКлиенте
Процедура ПоказатьВводСтрокиОпубликоватьПродолжить(email, ДополнительныеПараметры) Экспорт
	
	лСоединение = гВосстановитьИдентификаторСессииConsqueryCloud(ТипОбработка, СеансовыеДанные);
	
	Результат = гОпубликоватьВОблаке(ТипОбработка, СеансовыеДанные, лСоединение, email, 
		ДополнительныеПараметры.идПакетаВОблаке, ДополнительныеПараметры.идЗапроса, ДополнительныеПараметры.идСтрокиКода, ДополнительныеПараметры.включатьПодчиненные);	

	Если Результат.Статус <> "OK" Тогда 
		Сообщить(Результат.ТекстОшибки, СтатусСообщения.Важное);
	Иначе
		Сообщить("Публикация прошла успешно", СтатусСообщения.Информация);
	КонецЕсли;

КонецПроцедуры // ПоказатьВводСтрокиОпубликоватьПродолжить()

&НаКлиенте
Процедура ПоказатьПредупреждениеПродолжить(ДополнительныеПараметры) Экспорт
	
КонецПроцедуры // ПоказатьПредупреждениеПродолжить()

&НаКлиенте
Процедура ПослеЗакрытияВопросаУдалитьПакет(Результат, Параметры) Экспорт
	
	Если Результат = КодВозвратаДиалога.Да Тогда 
		лСоединение       = гВосстановитьИдентификаторСессииConsqueryCloud(ТипОбработка, СеансовыеДанные);
		лСписокИдКодов    = Новый Массив;
		лСписокИдПакетов  = Новый Массив;
		лСписокИдЗапросов = Новый Массив;
		
		Для каждого лСтрокаСФайлом Из Элементы.СписокЭлементовИзОблака.ВыделенныеСтроки Цикл
			
			лТекущаяСтрока = СписокЭлементовИзОблака.НайтиПоИдентификатору(лСтрокаСФайлом);
			
			Если лТекущаяСтрока.Тип = ТипыИсточниковДанных.Пакет Тогда 
				лСписокИдПакетов.Добавить(лТекущаяСтрока.id);
			ИначеЕсли лТекущаяСтрока.Тип = ТипыИсточниковДанных.Запрос Тогда 
				лСписокИдЗапросов.Добавить(лТекущаяСтрока.id);
			ИначеЕсли лТекущаяСтрока.Тип = ТипыИсточниковДанных.Код Тогда 
				лСписокИдКодов.Добавить(лТекущаяСтрока.id);
			КонецЕсли;
		КонецЦикла; 
		
		Если лСписокИдПакетов.Количество() > 0 Тогда 
			Результат = гУдалитьФайлыСЗапросамиВОблаке(ТипОбработка, СеансовыеДанные, лСоединение, ПолучитьJSONЗначения(лСписокИдПакетов));	
		Иначе
			Результат = гУдалитьЭлементыПоСпискуВОблаке(ТипОбработка, СеансовыеДанные, лСоединение, ТекущийПакет, ПолучитьJSONЗначения(лСписокИдЗапросов), ПолучитьJSONЗначения(лСписокИдКодов));
		КонецЕсли;
		
		Если Результат.Статус <> "OK" Тогда 
			Сообщить(Результат.ТекстОшибки, СтатусСообщения.Важное);
		Иначе
			ОбновитьДействие();
			Если Не ПустаяСтрока(Результат.Информация) Тогда 
				Сообщить(Результат.Информация, СтатусСообщения.Информация);
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры // ПослеЗакрытияВопросаУдалитьПакет()

&НаКлиенте
Процедура ЗакрытьформуСВыбором(ПараметрыЗакрытия)	
	Закрыть(ПараметрыЗакрытия);	
КонецПроцедуры // закрытьформуСВыбором()

&НаКлиенте
Процедура ОбработкаРезультатаВопроса(РезультатВопроса, ДополнительныеПараметры) Экспорт
	Если РезультатВопроса = КодВозвратаДиалога.Да Тогда 
		ЗакрытьформуСВыбором(ДополнительныеПараметры);
	КонецЕсли;
КонецПроцедуры	

&НаКлиенте
Процедура КнопкаВыполнитьНажатиеДействие()
	
	Если Не ЗначениеЗаполнено(ИмяЭлементаИзОблака) Тогда 
		ПоказатьПредупреждение(, "Введите имя элемента.");
		Возврат;		
	КонецЕсли;
	
	лЭтоЗапись = гЭтоЗапись(ТипОбработка, СеансовыеДанные, Режим);
	
	Если лЭтоЗапись и Тип <> ТипЭлемента Тогда 
		ПоказатьПредупреждение(, "Выберите элемент с типом " + Тип +" или введите новый.");
		Возврат;
	КонецЕсли;
	
	Если лЭтоЗапись и Тип = ТипыИсточниковДанных.Код И ПолучитьИдЗапросаПоПути(ТекущийПуть) = Неопределено Тогда 
		ПоказатьПредупреждение(, "Выберите запрос, для которого необходимо сохранить код.");
		Возврат;
	КонецЕсли;
	
	лСтруктураПараметров = Новый Структура;
	лСтруктураПараметров.Вставить("Выбран"                    , Истина);
	лСтруктураПараметров.Вставить("Имя"                       , ИмяЭлементаИзОблака);
	лСтруктураПараметров.Вставить("Тип"                       , ТипЭлемента);
	лСтруктураПараметров.Вставить("ИдПакета"                  , ТекущийПакет);
	лСтруктураПараметров.Вставить("ИдРодительскогоЗапроса"    , ПолучитьИдЗапросаПоПути(ТекущийПуть));
	лСтруктураПараметров.Вставить("ИдЗапроса"                 , ПолучитьИдЗапросаПоПути(ТекущийПуть));
	лСтруктураПараметров.Вставить("ИдКода"                    , Неопределено);
	
	// далее дозаполняются! ключи: ИдПакета, ИдРодительскогоЗапроса, ИдЗапроса, ИДКода, ВключатьПодчиненныеЗапросы
	
	лВыбранныйЭлементМассив = СписокЭлементовИзОблака.НайтиСтроки(Новый Структура("Имя, Тип", ИмяЭлементаИзОблака, ТипЭлемента));
	
	лВыбранныйЭлемент = ?(лВыбранныйЭлементМассив.Количество() > 0, лВыбранныйЭлементМассив[0], Неопределено);
	
	Если типЭлемента = ТипыИсточниковДанных.Запрос Тогда 
		лСтруктураПараметров.Вставить("ВключатьПодчиненныеЗапросы", Не НеВключатьПодчиненныеЗапросы);
	КонецЕсли;
	
	Если лВыбранныйЭлемент <> Неопределено Тогда 
		лИдентификатор = лВыбранныйЭлемент.id;
		
		Если типЭлемента = ТипыИсточниковДанных.Код Тогда 
			лСтруктураПараметров.Вставить("ИдКода"   , лИдентификатор);
		ИначеЕсли типЭлемента = ТипыИсточниковДанных.Запрос Тогда 
			лСтруктураПараметров.Вставить("ИдЗапроса"                 , лИдентификатор);
		ИначеЕсли типЭлемента = ТипыИсточниковДанных.Пакет Тогда 
			лСтруктураПараметров.Вставить("ИдПакета", лИдентификатор);
		КонецЕсли;
		
		Если Режим = ОперацииСЗапросами.СохранитьКАК Тогда 
			ПоказатьВопрос(Новый ОписаниеОповещения("ОбработкаРезультатаВопроса", ЭтаФорма, лСтруктураПараметров),
				"""" + ИмяЭлементаИзОблака + """ уже существует. 
					|Вы хотите его перезаписать",
				РежимДиалогаВопрос.ДаНет,,
				КодВозвратаДиалога.Да,
				"Сохранить как...");
			Возврат;
		КонецЕсли;
	ИначеЕсли лЭтоЗапись Тогда 
		Если типЭлемента = ТипыИсточниковДанных.Код Тогда 
			лСтруктураПараметров.Вставить("ИдКода"   , гИдентификаторНовогоОбъектаВОблаке(ТипОбработка, СеансовыеДанные));
		ИначеЕсли типЭлемента = ТипыИсточниковДанных.Запрос Тогда 
			лСтруктураПараметров.Вставить("ИдЗапроса", гИдентификаторНовогоОбъектаВОблаке(ТипОбработка, СеансовыеДанные));
		ИначеЕсли типЭлемента = ТипыИсточниковДанных.Пакет Тогда 
			лСтруктураПараметров.Вставить("ИдПакета", гИдентификаторНовогоОбъектаВОблаке(ТипОбработка, СеансовыеДанные));
		КонецЕсли;
	Иначе
		ПоказатьПредупреждение(, "Выберите существующий пакет с запросами.");
		Возврат;
	КонецЕсли;
	
	Закрыть(лСтруктураПараметров);

КонецПроцедуры // КнопкаВыполнитьНажатиеДействие()

&НаКлиенте
Процедура ОбновитьДействие(Отказ = Ложь)
	
	Если ТекущийПакет = Неопределено ИЛИ ТекущийПакет = "-1" Тогда 
		ЗаполнитьПакетамиИзОблака(Отказ);
	Иначе
		идРодителя = ?(ЗначениеЗаполнено(ТекущийПуть), ТекущийПуть[0].Значение.id, Неопределено);
		ЗаполнитьЗапросамиИзОблака(ТекущийПакет, идРодителя, Отказ);
	КонецЕсли;
	
КонецПроцедуры // ОбновитьДействие()

#КонецОбласти

&НаСервереБезКонтекста
Функция ОбъектОбработки(ТипОбработка, СеансовыеДанные)
	Результат = Новый (ЗначениеИзСтрокиВнутр(ТипОбработка));
	Результат.гСеансовыеДанные = СеансовыеДанные;
	Возврат Результат;
КонецФункции

&НаКлиенте
Функция ПолучитьJSONЗначения(Значение)
	ЗаписьJSON = Новый ЗаписьJSON;
	ЗаписьJSON.ПроверятьСтруктуру = Ложь;
	ЗаписьJSON.УстановитьСтроку(Новый ПараметрыЗаписиJSON(,,,,,,Истина));
	ЗаписатьJSON(ЗаписьJSON, Значение, Новый НастройкиСериализацииJSON);
	Возврат ЗаписьJSON.Закрыть();
КонецФункции

&НаКлиенте
Функция ПолучитьИдЗапросаПоПути(Путь)
	Если Не ЗначениеЗаполнено(Путь) ИЛИ Путь.Количество() = 0 Тогда 
		Возврат Неопределено
	Иначе
		Возврат Путь[0].Значение.id
	КонецЕсли;
КонецФункции // ПолучитьИдЗапросаПоПути()

&НаКлиентеНаСервереБезКонтекста
Функция ПолучитьСписокЗначенийИзМассива(Массив)
	
	Если Не ЗначениеЗаполнено(Массив) Тогда 
		Возврат Неопределено
	КонецЕсли;
	
	лСписокЗначений = Новый СписокЗначений;
	Для Каждого ЭлементМассива Из Массив Цикл
		лСписокЗначений.Добавить(ЭлементМассива);
	КонецЦикла;
		
	Возврат лСписокЗначений;
	
КонецФункции // ПолучитьСписокЗначенийИзМассива()

&НаКлиенте
Процедура ЗаполнитьСписокДаннымиИзОблака(лДанныеОблака, ЭтоСписокПакетов)
	
	СписокЭлементовИзОблака.Очистить();
	Если ЭтоСписокПакетов Тогда 
		Для каждого лДанныеПакета Из лДанныеОблака.СписокПакетов Цикл
			лНоваяСтрока = СписокЭлементовИзОблака.Добавить();
			лНоваяСтрока.Имя         = лДанныеПакета.name;
			лНоваяСтрока.Тип         = ТипыИсточниковДанных.Пакет;
			лНоваяСтрока.ТипКартинка = мИндексыКартинкиДляТипов.Получить(лНоваяСтрока.Тип);
			лНоваяСтрока.Создан      = лДанныеПакета.dateCreate;
			лНоваяСтрока.Изменен     = лДанныеПакета.dateMod;
			лНоваяСтрока.Информация  = лДанныеПакета.idUser + " | Запросов: " + лДанныеПакета.queryCount;
			лНоваяСтрока.id          = лДанныеПакета.id;
		КонецЦикла; 
		ТекущийПуть  = Неопределено;
		ТекущийПакет = "-1";
		
		ОбновитьСтрокуСПутемКЗапросу(Неопределено);
		
		ДобавитьПунктКонтекстногоМенюСоздатьНовыйПакет();		
		УдалитьПунктКонтекстногоМенюОпубликовать();		
		
	Иначе
		лТипЭлементаСписка = Неопределено;
		
		Для каждого лДанныеПакета Из лДанныеОблака.Список Цикл
			лНоваяСтрока = СписокЭлементовИзОблака.Добавить();
			лНоваяСтрока.Имя        = лДанныеПакета.name;
			лНоваяСтрока.Создан     = лДанныеПакета.dateCreate;
			лНоваяСтрока.Изменен    = лДанныеПакета.dateMod;
			лНоваяСтрока.Информация = лДанныеПакета.info;
			лНоваяСтрока.id         = лДанныеПакета.id;
			
			Если ТипыИсточниковДанных.Свойство(лДанныеПакета.type, лТипЭлементаСписка) = Неопределено Тогда 
				лНоваяСтрока.Тип = "не определен";
			Иначе
				лНоваяСтрока.Тип = лТипЭлементаСписка;
			КонецЕсли;			
			
			лНоваяСтрока.ТипКартинка = мИндексыКартинкиДляТипов.Получить(лНоваяСтрока.Тип);
			
		КонецЦикла;
		
		ТекущийПуть  = ПолучитьСписокЗначенийИзМассива(лДанныеОблака.ПутьКРодителю);
		ТекущийПакет = лДанныеОблака.идПакета;
		
		ОбновитьСтрокуСПутемКЗапросу(лДанныеОблака.ИмяПакета);
		
		УдалитьПунктКонтекстногоМенюСоздатьНовыйПакет();		
		ДобавитьПунктКонтекстногоМенюОпубликовать();		
		
	КонецЕсли;
	
КонецПроцедуры // ЗаполнитьСписокДаннымиИзОблака()

&НаКлиенте
Процедура ЗаполнитьПакетамиИзОблака(Отказ)
	
	лИдентификаторСессии   = гВосстановитьИдентификаторСессииConsqueryCloud(ТипОбработка, СеансовыеДанные);
	лДанныеОблака = гПолучитьСписокПакетовВОблаке(ТипОбработка, СеансовыеДанные, лИдентификаторСессии);
	
	Если лДанныеОблака.Статус <> "OK" Тогда 
		Сообщить(лДанныеОблака.ТекстОшибки, СтатусСообщения.Важное);		
		Если лДанныеОблака.НеобходимоПереподключиться Тогда 
			Оповестить("НеобходимоПереподключиться", Истина, ЭтаФорма);
		КонецЕсли;
		Отказ = Истина;
	Иначе
		ЗаполнитьСписокДаннымиИзОблака(лДанныеОблака, Истина)
	КонецЕсли;
КонецПроцедуры // ЗаполнитьПакетамиИзОблака()

&НаКлиенте
Процедура ЗаполнитьЗапросамиИзОблака(идПакета, идРодителя, Отказ)
	
	лСоединение   = гВосстановитьИдентификаторСессииConsqueryCloud(ТипОбработка, СеансовыеДанные);
	лДанныеОблака = гПолучитьСписокЗапросовВОблаке(ТипОбработка, СеансовыеДанные, лСоединение, идПакета, идРодителя);
	
	Если лДанныеОблака.Статус <> "OK" Тогда 
		Сообщить(лДанныеОблака.ТекстОшибки, СтатусСообщения.Важное);		
		Если лДанныеОблака.НеобходимоПереподключиться Тогда 
			Оповестить("НеобходимоПереподключиться", Истина, ЭтаФорма);
		КонецЕсли;
		Отказ = Истина;
	Иначе
		ЗаполнитьСписокДаннымиИзОблака(лДанныеОблака, Ложь)
	КонецЕсли;	
	
КонецПроцедуры // ЗаполнитьЗапросамиИзОблака()

&НаКлиенте
Процедура ЗаполнитьЗапросамиИлиПакетамиИзОблакаПоИсторииИспользования(Отказ)
	
	лИдентификаторСессии   = гВосстановитьИдентификаторСессииConsqueryCloud(ТипОбработка, СеансовыеДанные);
	лДанныеОблака = гПолучитьСписокПакетовИЛИЗапросовВОблакеПоИсторииИспользования(ТипОбработка, СеансовыеДанные, лИдентификаторСессии);

	Если лДанныеОблака.Статус <> "OK" Тогда 
		Сообщить(лДанныеОблака.ТекстОшибки, СтатусСообщения.Важное);		
		Если лДанныеОблака.НеобходимоПереподключиться Тогда 
			Оповестить("НеобходимоПереподключиться", Истина, ЭтаФорма);
		КонецЕсли;
		Отказ = Истина;
	Иначе
		ЗаполнитьСписокДаннымиИзОблака(лДанныеОблака, лДанныеОблака.ЭтоСписокПакетов);
	КонецЕсли;
	
КонецПроцедуры // ЗаполнитьЗапросамиИлиПакетамиИзОблакаПоИсторииИспользования()

#КонецОбласти