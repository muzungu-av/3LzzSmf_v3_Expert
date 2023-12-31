//+------------------------------------------------------------------+
//|                                            3LzzSmf_v3_Expert.mq4 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      ""
#property version   "1.00"
#property strict

//Буферы
double FP_BuferUp[]; int fp_up_numb = 0;
double FP_BuferDn[]; int fp_dw_numb = 1;
double NP_BuferUp[]; int np_up_numb = 2;
double NP_BuferDn[]; int np_dw_numb = 3;
double HP_BuferUp[]; int hp_up_numb = 4;
double HP_BuferDn[]; int hp_dw_numb = 5;

//входные параметры индюка
double Period1=5; 
double Period2=24; 
double Period3=72; 
string Dev_Step_1="1,3";
string Dev_Step_2="8,5";
string Dev_Step_3="21,12";
int Symbol_1_Kod=140;
int Symbol_2_Kod=141;
int Symbol_3_Kod=142;

//+------------------------------------------------------------------+
//| ВАРИАНТЫ ДОПУСТИМОГО СОСТОЯНИЯ СОВЕТНИКА
//+------------------------------------------------------------------+
#define  _STOP_                             0x000        // начальное состояние
#define  _WAITING_                          0x001        // ожидание сигналов
#define  _NEW_1_LOW_SIGNAL_                 0x002        // появился сигнал (1) Low
#define  _NEW_1_HIGHT_SIGNAL_               0x003        // появился сигнал (1) Hight 
#define  _NEW_2_LOW_SIGNAL_                 0x004        // появился сигнал (2) Low 
#define  _NEW_2_HIGHT_SIGNAL_               0x005        // появился сигнал (2) Hight 
#define  _NEW_3_LOW_SIGNAL_                 0x006        // появился сигнал (3) Low 
#define  _NEW_3_HIGHT_SIGNAL_               0x007        // появился сигнал (3) Hight 

#define  _UPD_1_LOW_SIGNAL_                 0x008        // обновлен существующий сигнал(цена) (1) Low
#define  _UPD_1_HIGHT_SIGNAL_               0x009        // обновлен существующий сигнал(цена) (1) Hight 
#define  _UPD_2_LOW_SIGNAL_                 0x010        // обновлен существующий сигнал(цена) (2) Low 
#define  _UPD_2_HIGHT_SIGNAL_               0x011        // обновлен существующий сигнал(цена) (2) Hight 
#define  _UPD_3_LOW_SIGNAL_                 0x012        // обновлен существующий сигнал(цена) (3) Low 
#define  _UPD_3_HIGHT_SIGNAL_               0x013        // обновлен существующий сигнал(цена) (3) Hight 

int _STATE_ = _STOP_; //текущее состояние

//+------------------------------------------------------------------+
//| состояния цены
//+------------------------------------------------------------------+
double _PRICE_LAST_                         = 0.0;
int    _PRICE_STATE_                        = 0;         //текущее состояние цены
#define     _PRICE_CHANGED_DONW_            0x001        //цены ушла вниз с последнего момента
#define     _PRICE_CHANGED_UP_              0x002        //цены ушла вверх с последнего момента
double _PRICE_LAST_3_PEAK_LOW_              = 0.0;       //хранит цену предыдущего верхнего пика 3-го сигнала 
double _PRICE_LAST_3_PEAK_HIGHT_            = 0.0;       //хранит цену предыдущего нижнего пика 3-го сигнала

//цифр после запятой
int  _DIGITS_;
//коэффициент для расчета пипсов
int _K_DIGITS_PIPS_;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   _DIGITS_ = (int)MarketInfo(NULL,MODE_DIGITS);
   _K_DIGITS_PIPS_ = MathPow(10, _DIGITS_);
   
   Print("_K_DIGITS_PIPS_ = " + _K_DIGITS_PIPS_);
   SetIndexBuffer(fp_up_numb, FP_BuferUp);
   SetIndexBuffer(fp_dw_numb, FP_BuferDn);
   
   SetIndexBuffer(np_up_numb, NP_BuferUp);
   SetIndexBuffer(np_dw_numb, NP_BuferDn);
   
   SetIndexBuffer(hp_up_numb, HP_BuferUp);
   SetIndexBuffer(hp_dw_numb, HP_BuferDn);

   
   // сделать всякие проверки баланса, открытых ордеров, возможности торговать
   // и переход в состояние ожидания
    _STATE_ = _WAITING_;
   
   _PRICE_STATE_ = 0;
    
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
  _STATE_ = _STOP_;
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
   int shift = 0;
   double lw_1 = iCustom(NULL, 0, "3_Level_v3/3_Level_Semafor_V3", Period1,Period2,Period3,Dev_Step_1,Dev_Step_2,Dev_Step_3,Symbol_1_Kod,Symbol_2_Kod, Symbol_3_Kod,  fp_up_numb, shift);
   double hi_1 = iCustom(NULL, 0, "3_Level_v3/3_Level_Semafor_V3", Period1,Period2,Period3,Dev_Step_1,Dev_Step_2,Dev_Step_3,Symbol_1_Kod,Symbol_2_Kod, Symbol_3_Kod,  fp_dw_numb, shift);
   
   double lw_2 = iCustom(NULL, 0, "3_Level_v3/3_Level_Semafor_V3", Period1,Period2,Period3,Dev_Step_1,Dev_Step_2,Dev_Step_3,Symbol_1_Kod,Symbol_2_Kod, Symbol_3_Kod,  np_up_numb, shift);
   double hi_2 = iCustom(NULL, 0, "3_Level_v3/3_Level_Semafor_V3", Period1,Period2,Period3,Dev_Step_1,Dev_Step_2,Dev_Step_3,Symbol_1_Kod,Symbol_2_Kod, Symbol_3_Kod,  np_dw_numb, shift);
   
   double lw_3 = iCustom(NULL, 0, "3_Level_v3/3_Level_Semafor_V3", Period1,Period2,Period3,Dev_Step_1,Dev_Step_2,Dev_Step_3,Symbol_1_Kod,Symbol_2_Kod, Symbol_3_Kod,  hp_up_numb, shift);
   double hi_3 = iCustom(NULL, 0, "3_Level_v3/3_Level_Semafor_V3", Period1,Period2,Period3,Dev_Step_1,Dev_Step_2,Dev_Step_3,Symbol_1_Kod,Symbol_2_Kod, Symbol_3_Kod,  hp_dw_numb, shift);
   
   double current_price = priceBid();
   signal_price_handler(current_price,lw_1, hi_1, lw_2, hi_2, lw_3, hi_3);
}
  

//Обработка сигналов и выставление состояния сигналов и состояния цены
//это глаза индикатора
void signal_price_handler(double current_price, double lw_1, double hi_1, double lw_2, double hi_2, double lw_3, double hi_3) {
   if (signal_handler(lw_1, hi_1, lw_2, hi_2, lw_3, hi_3)) {
      // изменилось состояние индикатора (новый сигнал)
      printMessageOnNewSignals();
   } else if (price_handler(current_price)) {
      // состояние индикатора принципиально не изменилось, но обновился HIGHT/LOW  3-го сигнала индикатора
      printMessageOnUpdatedSignals();
   } 
}  

  
//отслеживает обновление цены - она стала выше, ниже, если ранее было состояние "_NEW_..._SIGNAL_"  или  "_UPD_..._SIGNAL_"
bool price_handler(double current_price) {
   bool result = false;
   //при первом запуске установить цену
   if(_PRICE_LAST_ == 0 ) {
      _PRICE_LAST_ = current_price;
   }
   //если цена повысилась
   if (current_price > _PRICE_LAST_ && (_STATE_ == _NEW_1_HIGHT_SIGNAL_ || _STATE_ == _NEW_2_HIGHT_SIGNAL_ || _STATE_ == _NEW_3_HIGHT_SIGNAL_ ||
                                        _STATE_ == _UPD_1_HIGHT_SIGNAL_ || _STATE_ == _UPD_2_HIGHT_SIGNAL_ || _STATE_ == _UPD_3_HIGHT_SIGNAL_)) {
      _PRICE_STATE_ = _PRICE_CHANGED_UP_;
      _PRICE_LAST_ = current_price;      
      result = true;
      switch_to_upd_state();
      //последний макс экстремум запомним
      if (_STATE_ == _UPD_3_HIGHT_SIGNAL_) {
         _PRICE_LAST_3_PEAK_HIGHT_ = current_price;    
      }
   }
   //если цена понизилась
   if (current_price < _PRICE_LAST_ && (_STATE_ == _NEW_1_LOW_SIGNAL_ || _STATE_ == _NEW_2_LOW_SIGNAL_ || _STATE_ == _NEW_3_LOW_SIGNAL_ ||
                                        _STATE_ == _UPD_1_LOW_SIGNAL_ || _STATE_ == _UPD_2_LOW_SIGNAL_ || _STATE_ == _UPD_3_LOW_SIGNAL_)) {
      _PRICE_STATE_ = _PRICE_CHANGED_DONW_;
      _PRICE_LAST_ = current_price;
      result = true;
      switch_to_upd_state();
      //последний мин экстремум запомним
      if (_STATE_ == _UPD_3_LOW_SIGNAL_) {
         _PRICE_LAST_3_PEAK_LOW_ = current_price;    
      }
   }  
   return result;
}
  

//переводит состояние в  _UPD_ (это происходит когда мин/макс значение индикатора обновилось)
void switch_to_upd_state() {
   switch(_STATE_) {                                         
      case _NEW_1_HIGHT_SIGNAL_ : _STATE_ = _UPD_1_HIGHT_SIGNAL_; break;
      case _NEW_2_HIGHT_SIGNAL_ : _STATE_ = _UPD_2_HIGHT_SIGNAL_; break;
      case _NEW_3_HIGHT_SIGNAL_ : _STATE_ = _UPD_3_HIGHT_SIGNAL_; break;
      case _NEW_1_LOW_SIGNAL_ : _STATE_ = _UPD_1_LOW_SIGNAL_; break;
      case _NEW_2_LOW_SIGNAL_ : _STATE_ = _UPD_2_LOW_SIGNAL_; break;
      case _NEW_3_LOW_SIGNAL_ : _STATE_ = _UPD_3_LOW_SIGNAL_; break;
   }  
}  
  
  
//переводит советник в новое состояние в зависимости от сингалов советника
bool signal_handler (double lw_1, double hi_1, double lw_2, double hi_2, double lw_3, double hi_3) {

   //проверка на возможность работы
   if (_STATE_ < 0) {Print("***  Советник остановлен, состояние: " + _STATE_ + "  ***"); return false;}
   
   //проверка был ли сигнал от индикатора
   if (lw_1 == 0 && hi_1 == 0 && lw_2 == 0 && hi_2 == 0 && lw_3 == 0 && hi_3 == 0) {
      return false;  
   }
   int temp_state = _STATE_;
   string msg = "";
   //сигнал (3)
   if (lw_3 != 0 || hi_3 != 0) {
      if (lw_3 != 0 && hi_3 == 0 && _STATE_ != _NEW_3_LOW_SIGNAL_ && _STATE_ != _UPD_3_LOW_SIGNAL_) {
         temp_state = _NEW_3_LOW_SIGNAL_;
         msg = "NEW_3_LOW_SIGNAL";
         //хотя сейчас это нижний экстремум, но последний экстр был на хаях hight
         _PRICE_LAST_3_PEAK_LOW_ = lw_3;
       //  Print("_PRICE_LAST_3_PEAK_HIGHT_ = " + _PRICE_LAST_3_PEAK_HIGHT_);
       //   Print(msg + " - " + _PRICE_LAST_);
      }
      if (hi_3 != 0 && lw_3 == 0 && _STATE_ != _NEW_3_HIGHT_SIGNAL_ && _STATE_ != _UPD_3_HIGHT_SIGNAL_) {
         temp_state = _NEW_3_HIGHT_SIGNAL_;
         msg = "NEW_3_HIGHT_SIGNAL";
         //хотя сейчас это верхний экстремум, но последний экстр был на лоях low
         _PRICE_LAST_3_PEAK_HIGHT_ = hi_3;
       //  Print("_PRICE_LAST_3_PEAK_LOW_ = " + _PRICE_LAST_3_PEAK_LOW_);
        //  Print(msg + " - " + _PRICE_LAST_);
      }
   } else
   //сигнал (2)
   if (lw_2 != 0 || hi_2 != 0) {
      if (lw_2 != 0 && hi_2 == 0 && _STATE_ != _NEW_2_LOW_SIGNAL_ && _STATE_ != _UPD_2_LOW_SIGNAL_) {
         temp_state = _NEW_2_LOW_SIGNAL_;
          msg = "NEW_2_LOW_SIGNAL";
      }
      if (hi_2 != 0 && lw_2 == 0 && _STATE_ != _NEW_2_HIGHT_SIGNAL_ && _STATE_ != _UPD_2_HIGHT_SIGNAL_) {
         temp_state = _NEW_2_HIGHT_SIGNAL_;
          msg = "NEW_2_HIGHT_SIGNAL";
      }
   } else
   //сигнал (1)
   if (lw_1 != 0 || hi_1 != 0) {
      if (lw_1 != 0 && hi_1 == 0 && _STATE_ != _NEW_1_LOW_SIGNAL_ && _STATE_ != _UPD_1_LOW_SIGNAL_) {
         temp_state = _NEW_1_LOW_SIGNAL_;
         msg = "NEW_1_LOW_SIGNAL";
      }
      if (hi_1 != 0 && lw_1 == 0  && _STATE_ != _NEW_1_HIGHT_SIGNAL_ && _STATE_ != _UPD_1_HIGHT_SIGNAL_) {
         temp_state = _NEW_1_HIGHT_SIGNAL_;
         msg = "NEW_1_HIGHT_SIGNAL";
      }
   }
   
   if (temp_state != _STATE_) {
      _STATE_ = temp_state;
      //сброс состояния цены
      _PRICE_STATE_ = 0;
      return true;
   } else {
      return false;
   }
}  
  
//печать всех сигналов если не 0
void _print_all_signals(double lw_1, double hi_1, double lw_2, double hi_2, double lw_3, double hi_3) {
   if (lw_1 != 0 || hi_1 != 0 || lw_2 != 0 || hi_2 != 0 || lw_3 != 0 || hi_3 != 0) {
         Print("lw_1 = " + lw_1 + ";  hi_1 = " + hi_1 + ";  lw_2 = " + lw_2 + 
               ";  hi_2 = " + hi_2 + ";  lw_3 = " + lw_3 + ";  hi_3 = " + hi_3);
   }
}

//временный код. вывод сообщений о новых сигналах
//ПЕРВЫЕ СИГНАЛЫ пропускает, ждет пока сформируются 2 волны "туда-сюда"
void printMessageOnNewSignals() {
   if (_PRICE_LAST_ != 0 && _PRICE_LAST_3_PEAK_LOW_ != 0 && _PRICE_LAST_3_PEAK_HIGHT_ != 0) {
      if (_STATE_ == _NEW_3_HIGHT_SIGNAL_ ) {
         Print ("новый HIGHT - " + _PRICE_LAST_ + ";  последний LOW   = " + _PRICE_LAST_3_PEAK_LOW_ + ";  pips = " + getPipsStr(_PRICE_LAST_ - _PRICE_LAST_3_PEAK_LOW_)  );
      }
      if (_STATE_ == _NEW_3_LOW_SIGNAL_ ) {
         Print ("новый LOW  - " + _PRICE_LAST_ + ";  последний HIGHT = " + _PRICE_LAST_3_PEAK_HIGHT_ + ";  pips = " + getPipsStr(_PRICE_LAST_3_PEAK_HIGHT_ - _PRICE_LAST_)  );
      }
   }
}

//временный код. вывод сообщений об обновленных сигналах
void printMessageOnUpdatedSignals() {
   if (_PRICE_STATE_ == _PRICE_CHANGED_UP_) {
   }
   if (_PRICE_STATE_ == _PRICE_CHANGED_DONW_) {
   }
}

string getPipsStr(double x) {
  return DoubleToStr(_K_DIGITS_PIPS_ * x, 0);
}

//запрос текущей цены
double priceBid() {
   //double PriceAsk=MarketInfo(0,MODE_ASK);
   //double PriceBid=MarketInfo(0,MODE_BID);
   //Отображаем окно с полученными значениями
   //MessageBox("Bid="+PriceBid+" Ask="+PriceAsk);
   return Close[0];
}