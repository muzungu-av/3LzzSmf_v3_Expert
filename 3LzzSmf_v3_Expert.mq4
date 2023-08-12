//+------------------------------------------------------------------+
//|                                                         TEST.mq4 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
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
//| Отрицательные состояния - останавливают советника
//+------------------------------------------------------------------+
#define  _STOP_                             0x000       // начальное состояние
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
#define  _UPD_2_HIGHT_SIGNAL_               0x011       // обновлен существующий сигнал(цена) (2) Hight 
#define  _UPD_3_LOW_SIGNAL_                 0x012       // обновлен существующий сигнал(цена) (3) Low 
#define  _UPD_3_HIGHT_SIGNAL_               0x013       // обновлен существующий сигнал(цена) (3) Hight 

int _STATE_ = _STOP_; //текущее состояние


// состояния цены
double _PRICE_LAST_                         = 0.0;
int    _PRICE_STATE_                        = 0;        //текущее состояние цены
#define     _PRICE_CHANGED_DONW_            0x001        //цены ушла вниз с последнего момента
#define     _PRICE_CHANGED_UP_              0x002        //цены ушла вверх с последнего момента


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if (Digits == 3 || Digits == 5)
   {
    //---   TakeProfit *= 10;
    //---   StopLoss   *= 10;
   }
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
   
   if (signal_handler(lw_1, hi_1, lw_2, hi_2, lw_3, hi_3)) {
      // изменилось состояние индикатора (новый сигнал)
   } else if (price_handler()) {
      if (_PRICE_STATE_ == _PRICE_CHANGED_UP_) {
         // состояние индикатора принципиально не изменилось, но обновилась цена
         Print("_PRICE_CHANGED_UP_ - " + _PRICE_LAST_);
      }
      if (_PRICE_STATE_ == _PRICE_CHANGED_DONW_) {
         // состояние индикатора принципиально не изменилось, но обновилась цена
         Print("_PRICE_CHANGED_DOWN_ - " + _PRICE_LAST_);
      }
   }
   
}
  
  
//отслеживает обновление цены - она стала выше, ниже, если ранее было состояние "_NEW_..._SIGNAL_"  или  "_UPD_..._SIGNAL_"
bool price_handler() {
   bool result = false;
   double current_price = priceBid();
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
   }
   //если цена понизилась
   if (current_price < _PRICE_LAST_ && (_STATE_ == _NEW_1_LOW_SIGNAL_ || _STATE_ == _NEW_2_LOW_SIGNAL_ || _STATE_ == _NEW_3_LOW_SIGNAL_ ||
                                        _STATE_ == _UPD_1_LOW_SIGNAL_ || _STATE_ == _UPD_2_LOW_SIGNAL_ || _STATE_ == _UPD_3_LOW_SIGNAL_)) {
      _PRICE_STATE_ = _PRICE_CHANGED_DONW_;
      _PRICE_LAST_ = current_price;
      result = true;
      switch_to_upd_state();
   }  
   return result;
}
  

//переводит состояние в  _UPD_ (это происходит когда значение индикатора обновилось)
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
      }
      if (hi_3 != 0 && lw_3 == 0 && _STATE_ != _NEW_3_HIGHT_SIGNAL_ && _STATE_ != _UPD_3_HIGHT_SIGNAL_) {
         temp_state = _NEW_3_HIGHT_SIGNAL_;
         msg = "NEW_3_HIGHT_SIGNAL";
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
      Print(msg + " - " + _PRICE_LAST_);
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

//запрос текущей цены
double priceBid() {
   //double PriceAsk=MarketInfo(0,MODE_ASK);
   //double PriceBid=MarketInfo(0,MODE_BID);
   //Отображаем окно с полученными значениями
   //MessageBox("Bid="+PriceBid+" Ask="+PriceAsk);
   return Close[0];
}