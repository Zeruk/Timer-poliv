	LIST		p=16f876a
	__CONFIG 	0x3F3A
	
;; переменные
STATUS		EQU		83h
INTCON		EQU		8Bh
TRISA		EQU		85h
TRISB		EQU		86h
TRISC		EQU		87h
PORTA		EQU		05h
PORTB		EQU		06h
PORTC		EQU		07h
PCL			EQU		02h
ADCON0		EQU		1Fh
ADCON1		EQU		9Fh
;; DS1302 константы
RST			EQU		.2
SCLK		EQU		.0
IO			EQU		.1
DS_W_MINUTES	EQU		82h
DS_R_MINUTES	EQU		83h
DS_W_HOUR	EQU		84h
DS_R_HOUR	EQU		85h
;DS_W_DAY	EQU		86h
;DS_R_DAY	EQU		87h
;DS_W_MONTH	EQU		88h
;DS_R_MONTH	EQU		89h
DS_WP		EQU		8Eh
;;
B_MODE		EQU		.2
B_SELECT	EQU		.3
;;	Количество показов, чтобы избежать дребезга
RATTLING_COUNT_SHOWING	EQU		.10						;;;!!! ПРОТЕСТИРОВАТЬ !!!
COUNT_TAPS_MODE_CONST	EQU		.9
COUNT_TAPS_MODE_CONST1	EQU		.7
CBLOCK 0x20
IND1		;; 0x20
IND2		;; 0x21
IND3		;; 0x22
IND4		;; x023
IND_TEMP
IBLINKING	;;	=00001110
IDOBLINK		;; 0/1	
;;
COUNT_TAPS_MODE
;;ВРЕМЯ СЕЙЧАС
NOW_MINUTE
NOW_MINUTE10
NOW_HOUR
NOW_HOUR10
;NOW_DAY
;NOW_DAY10
;NOW_MOUNTH
;NOW_MOUNTH10
;NOW_YEAR
;NOW_YEAR10
;;ДЛЯ ЗАДЕРЖКИ
TIMER_COUNTER1
TIMER_COUNTER2
TIMER_COUNTER3
TIMER_COUNTER4	;;для моргания индикаторами
;;ПЕРЕДАЧА/ПРИЕМ БАЙТА
RW_BYTE		;; управляющий байт
RW_BYTE1 	;; Принятый байт/ байт для передачи
;;ДЛЯ ОГРАНИЧЕНИЯ ВВОДА
ENDC
;;******************* конец переменных ********************

;;				!!! Максимум 8 вызовов CALL !!!

org 0
	;;Инициализация
init_lbl
	CLRF		STATUS
	BCF			INTCON,7		;;запрет прерываний
	CLRF		ADCON0
	BCF			STATUS,6 		;;первый бит выбора банка = 0
	BSF			STATUS,5		;;второй = 1   => bank #1
	MOVLW		B'00000111'
	MOVWF		ADCON1
	;; порты: A,B,C
	CLRF		TRISA
	BSF			TRISA,IO
	CLRF		TRISB
	CLRF		TRISC
	BSF			TRISC,2
	BSF			TRISC,3
	BCF			STATUS,5 		;;  BANK0
	CLRF		PORTA
	CLRF		PORTB
	CLRF		PORTC


;; ///////////////////////////////////////////////////////////////////////
;; //////////////////////////////// Main /////////////////////////////////
;; ///////////////////////////////////////////////////////////////////////
MAIN
	MOVLW		B'00000000'
	MOVWF		IBLINKING
	MOVLW		B'00000001'
	MOVWF		TIMER_COUNTER4
	MOVLW		.0
	MOVWF		IND1
	MOVWF		IND2
	MOVWF		IND3
	MOVWF		IND4
	MOVLW		.50
	CALL		SHOWING_DELAY
	MOVLW		.10
	MOVWF		IND1
	MOVWF		IND2
	MOVWF		IND3
	MOVWF		IND4
	CALL		SHOWING
	BTFSS		PORTC,B_MODE ;;проверка нажатия кнопки, если нажата,
	GOTO		$-2  	 	 ;;то следующая инструкция не выполняется
	GOTO		SHOWMENU
GOTO	MAIN
;; ///////////////////////////////////////////////////////////////////////
;; ///////////////////////////////////////////////////////////////////////
;; ///////////////////////////////////////////////////////////////////////

;; **************************** Подпрограммы **************************** 


CHAR_TABLE
	ADDWF		PCL,1
	RETLW		B'11000000';0
	RETLW		B'11111001';1
	RETLW		B'10100100';2
	RETLW		B'10110000';3
	RETLW		B'10011001';4
	RETLW		B'10010010';5
	RETLW		B'10000010';6
	RETLW		B'11111000';7
	RETLW		B'10000000';8
	RETLW		B'10010000';9
	RETLW		B'11111111';10
	RETLW		B'10001000';A	11
	RETLW		B'11000110';C	12
	RETLW		B'10000110';E	13
	RETLW		B'10001110';F	14
	RETLW		B'11000010';G	15
	RETLW		B'10001001';H	16
	RETLW		B'11000111';L	17
	RETLW		B'10101011';N	18
	RETLW		B'10001100';P	19
	RETLW		B'11000001';U	20
	RETLW		B'10000010';Б	21
	RETLW		B'10010001';У	22
	RETLW		B'10011001';Ч	23

RETURN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DELAY  ;; 500 циклов
	MOVLW		.221
	MOVWF		TIMER_COUNTER1
	MOVLW		.13
	MOVWF		TIMER_COUNTER2
	DECFSZ		TIMER_COUNTER1,1
	GOTO		$-1
	DECFSZ		TIMER_COUNTER2,1
	GOTO		$-3
	NOP
	NOP
RETURN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SHOWING
	DECFSZ		TIMER_COUNTER4
	GOTO		$+4
	COMF		IDOBLINK,1
	MOVLW		.10
	MOVWF		TIMER_COUNTER4
	
	BTFSS		IDOBLINK,0		;;--
	GOTO		$+2				;;;ДЛЯ МОРГАНИЯ
	BTFSS		IBLINKING,3		;;__
	BSF			PORTC,7
	MOVF		IND1,0
	CALL 		CHAR_TABLE
	MOVWF		PORTB
	CALL		DELAY
	BCF			PORTC,7

	BTFSS		IDOBLINK,0		;;--
	GOTO		$+2				;;;ДЛЯ МОРГАНИЯ
	BTFSS		IBLINKING,2		;;__
	BSF			PORTC,6
	MOVF		IND2,0
	CALL 		CHAR_TABLE
	MOVWF		PORTB
	CALL		DELAY
	BCF			PORTC,6

	BTFSS		IDOBLINK,0		;;--
	GOTO		$+2				;;;ДЛЯ МОРГАНИЯ
	BTFSS		IBLINKING,1		;;__
	BSF			PORTC,5
	MOVF		IND3,0
	CALL 		CHAR_TABLE
	MOVWF		PORTB
	CALL		DELAY
	BCF			PORTC,5

	BTFSS		IDOBLINK,0		;;--
	GOTO		$+2				;;;ДЛЯ МОРГАНИЯ
	BTFSS		IBLINKING,0		;;__
	BSF			PORTC,4
	MOVF		IND4,0
	CALL 		CHAR_TABLE
	MOVWF		PORTB
	CALL		DELAY
	BCF			PORTC,4
RETURN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TRANSMISSION_IN ;;ПРИЕМ ОТ DS1302
	MOVLW		DS_R_MINUTES
	MOVWF		RW_BYTE
	CALL		CONNECT_DS
	CALL		READ_BYTE
	MOVF		RW_BYTE1,0
	ANDLW		B'00001111'
	MOVWF		NOW_MINUTE		;;<**** M

	RRF			RW_BYTE1
	RRF			RW_BYTE1
	RRF			RW_BYTE1
	RRF			RW_BYTE1
	MOVF		RW_BYTE1,0
	ANDLW		B'00001111'
	MOVWF		NOW_MINUTE10		;;<**** 10M

	MOVLW		DS_R_HOUR
	MOVWF		RW_BYTE
	CALL		CONNECT_DS
	CALL		READ_BYTE
	MOVF		RW_BYTE1,0
	ANDLW		B'00001111'
	MOVWF		NOW_HOUR		;;<**** H

	RRF			RW_BYTE1
	RRF			RW_BYTE1
	RRF			RW_BYTE1
	RRF			RW_BYTE1
	MOVF		RW_BYTE1,0
	ANDLW		B'00000011'
	MOVWF		NOW_HOUR10		;;<**** 10H

;	MOVLW		DS_R_DAY
;	MOVWF		RW_BYTE
;	CALL		CONNECT_DS
;	CALL		READ_BYTE
;	MOVF		RW_BYTE1,0
;	ANDLW		B'00001111'
;	MOVWF		NOW_DAY			;; DAY
;	
;	RRF			RW_BYTE1
;	RRF			RW_BYTE1
;	RRF			RW_BYTE1
;	RRF			RW_BYTE1
;	MOVF		RW_BYTE1,0
;	ANDLW		B'0000011'
;	MOVWF		NOW_DAY10	;; 10DAY
RETURN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TRANSMISSION_OUT  ;;ПЕРЕДАЧА данных
	MOVLW		DS_WP	
	MOVWF		RW_BYTE
	CALL		CONNECT_DS
	MOVLW		b'00000000'	
	MOVWF		RW_BYTE1
	CALL		WRITE_BYTE
;; очистили бит защиты записи

;; записываем в DS минуты 
	MOVF		NOW_MINUTE10,0
	MOVWF		RW_BYTE1
	RLF			RW_BYTE1,1
	RLF			RW_BYTE1,1
	RLF			RW_BYTE1,1
	RLF			RW_BYTE1,1
	MOVF		NOW_MINUTE,0
	IORWF		RW_BYTE1,1
	MOVLW		DS_W_MINUTES
	MOVWF		RW_BYTE
	CALL		CONNECT_DS
	CALL		WRITE_BYTE
	
; Часы:
	MOVF		NOW_HOUR10,0
	MOVWF		RW_BYTE1	;00000001
	RLF			RW_BYTE1,1	;00000010
	RLF			RW_BYTE1,1	;00000100
	RLF			RW_BYTE1,1	;00001000
	RLF			RW_BYTE1,1	;00010000
	MOVF		NOW_HOUR,0
	IORWF		RW_BYTE1,1
	BCF			RW_BYTE1,7
	MOVLW		DS_W_HOUR
	MOVWF		RW_BYTE
	CALL		CONNECT_DS
	CALL		WRITE_BYTE
	
	BCF			PORTA,RST
	BCF			PORTA,IO
RETURN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CONNECT_DS
	BSF			PORTA,RST
	BCF			STATUS,6 		;;первый бит выбора банка = 0
	BSF			STATUS,5		;;второй = 1   => bank #1
	BCF			TRISA,IO		;;0=output
	BCF			STATUS,5		;;второй = 0   => bank #0
		CONNECT_DS_BEFORE_SETBIT
		BCF			PORTA,SCLK ;;4 тика между включением и выключением Sclk = 1мкс при 4Мц
		BTFSS		RW_BYTE,0
		GOTO		CONNECT_DS_BEFORE_SETBIT1
		BSF			PORTA,IO
		GOTO		CONNECT_DS_AFTER_SETBIT
			CONNECT_DS_BEFORE_SETBIT1
			BCF			PORTA,IO
			NOP
		CONNECT_DS_AFTER_SETBIT
		BSF			PORTA,SCLK
		RRF			RW_BYTE,1		
		BCF			RW_BYTE,7
		INCF		RW_BYTE,1
		DECFSZ		RW_BYTE,1
		GOTO		CONNECT_DS_BEFORE_SETBIT
RETURN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
READ_BYTE
	BCF			STATUS,6 		;;первый бит выбора банка = 0
	BSF			STATUS,5		;;второй = 1   => bank #1
	BSF			TRISA,IO		;;1=input
	BCF			STATUS,5		;;второй = 0   => bank #0
	MOVLW		.8
	MOVWF		TIMER_COUNTER1
	CLRF		RW_BYTE1
READ_BYTE_1
	RRF			RW_BYTE1
	BCF			PORTA,SCLK
	NOP
	BTFSC		PORTA,IO
	GOTO		READ_BYTE_BEFORE
	BCF			RW_BYTE1,7
	GOTO		READ_BYTE_AFTER
READ_BYTE_BEFORE
	BSF			RW_BYTE1,7
READ_BYTE_AFTER
	BSF			PORTA,SCLK
	NOP
	NOP
	DECFSZ		TIMER_COUNTER1,1
	GOTO		READ_BYTE_1

	BCF			PORTA, SCLK
	BCF			PORTA,RST
	BCF			PORTA,IO
RETURN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
WRITE_BYTE
	BCF			STATUS,6 		;;первый бит выбора банка = 0
	BSF			STATUS,5		;;второй = 1   => bank #1
	BCF			TRISA,IO		;; IO = 0 = output
	BCF			STATUS,5		;;второй = 0   => bank #0

	MOVLW		.8
	MOVWF		TIMER_COUNTER1

; RW_BYTE1 - Байт с данными
	DECFSZ		TIMER_COUNTER1
	GOTO		$+2
	RETURN
	BCF			PORTA,SCLK
	NOP
	BCF			PORTA,IO
	BTFSS		RW_BYTE1,7
	GOTO		$+2
	BSF			PORTA,IO
	NOP
	BSF			PORTA,SCLK
	NOP
	RRF			RW_BYTE1
	GOTO		$-.13
RETURN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SHOWING_DELAY		;;	W ЦИКЛОВ ПОКАЗА ИЗОБРАЖЕНИЯ
	MOVWF		TIMER_COUNTER3
SHOWING_DELAY_before_cycle1
	CALL		SHOWING
	DECFSZ		TIMER_COUNTER3
	GOTO		SHOWING_DELAY_before_cycle1
	NOP
RETURN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BUTTON_MODE_PROCESSING ;;После обнаружения нажатия
	MOVLW		RATTLING_COUNT_SHOWING	;;защита от дребезга
	CALL		SHOWING_DELAY
	CALL		SHOWING
	BTFSC		PORTC,B_MODE
	GOTO		$-2
	MOVLW		RATTLING_COUNT_SHOWING	;;защита от дребезга
	CALL		SHOWING_DELAY	
RETURN
BUTTON_SELECT_PROCESSING ;;После обнаружения нажатия
	MOVLW		RATTLING_COUNT_SHOWING	;;защита от дребезга
	CALL		SHOWING_DELAY
	CALL		SHOWING
	BTFSC		PORTC,B_SELECT
	GOTO		$-2
	MOVLW		RATTLING_COUNT_SHOWING	;;защита от дребезга
	CALL		SHOWING_DELAY	
RETURN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;					ПРОЦЕДУРА УСТАНОВКИ ВРЕМЕНИ							;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SET_TIME;;Установка времени				
	CALL		BUTTON_SELECT_PROCESSING
	CALL		TRANSMISSION_IN
	NOP
	MOVF		NOW_MINUTE,0
	MOVWF		IND4
	MOVF		NOW_MINUTE10,0
	MOVWF		IND3
	MOVF		NOW_HOUR,0
	MOVWF		IND2
	MOVF		NOW_HOUR10,0
	MOVWF		IND1
	MOVLW		B'00000001'
	MOVWF		IBLINKING		;;МОРГАЕТ ЧЕТВЕРТЫЙ ИНДИКАТОР
SET_TIME_MIN
	CALL		SHOWING
	BTFSS		PORTC,B_SELECT
	GOTO		$+.11
	INCF		IND4,1 ;; СОХРАНЯЕТСЯ В F
	MOVF		IND4,0
	MOVWF		IND_TEMP
	MOVLW		.9
	SUBWF		IND_TEMP,1
	DECFSZ		IND_TEMP
	GOTO		$+3
	MOVLW		.0
	MOVWF		IND4
	CALL		BUTTON_SELECT_PROCESSING
	BTFSS		PORTC,B_MODE
	GOTO		SET_TIME_MIN
	RLF			IBLINKING		;;МОРГАЕТ ТРЕТИЙ ИНД
	CALL	BUTTON_MODE_PROCESSING

SET_TIME_MIN10
	CALL		SHOWING
	BTFSS		PORTC,B_SELECT
	GOTO		$+.11
	INCF		IND3,1 ;; СОХРАНЯЕТСЯ В F
	MOVF		IND3,0
	MOVWF		IND_TEMP
	MOVLW		.5
	SUBWF		IND_TEMP,1
	DECFSZ		IND_TEMP
	GOTO		$+3
	MOVLW		.0
	MOVWF		IND3
	CALL		BUTTON_SELECT_PROCESSING
	BTFSS		PORTC,B_MODE
	GOTO		SET_TIME_MIN10
	MOVLW		B'00001100'
	MOVWF		IBLINKING		;;МОРГАЕТ ВТОРОЙ И ПЕРВЫЙ ИНД
	CALL	BUTTON_MODE_PROCESSING
SET_TIME_HOUR
	CALL		SHOWING
	BTFSS		PORTC,B_SELECT
	GOTO		$+.27
	INCF		IND2,1 ;; СОХРАНЯЕТСЯ В F
	MOVF		IND2,0
	MOVWF		IND_TEMP
	MOVLW		.9						
	SUBWF		IND_TEMP,1					
	DECFSZ		IND_TEMP
	GOTO		$+.4
	MOVLW		.0
	MOVWF		IND2
	INCF		IND1,1
	MOVF		IND1,0
	MOVWF		IND_TEMP
	MOVLW		.1							
	SUBWF		IND_TEMP,1	;; 1я цифра - 2				
	DECFSZ		IND_TEMP
	GOTO		$+.10
	MOVF		IND2,0
	MOVWF		IND_TEMP	
	MOVLW		.3
	SUBWF		IND_TEMP,1	;; 2я цифра - 4				
	DECFSZ		IND_TEMP
	GOTO		$+.4
		MOVLW		.0
		MOVWF		IND1
		MOVWF		IND2
	CALL		BUTTON_SELECT_PROCESSING
	BTFSS		PORTC,B_MODE
	GOTO		SET_TIME_HOUR

;;	здесь должно быть TRANSMITION_OUT
	MOVLW		.0
	MOVWF		IBLINKING
	CALL		TRANSMISSION_OUT
RETURN

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;
;;						Структура меню:
;;
;;
;;							  		  Вход
;;										|
;;		установка времени включения		|		установка времени/даты
;;										|				минуты
;;			1	|	2	|	3			|			десятки минут
;;										|				часы
;;										|			десятки часов
;;										|				дата
;;										|			    месяц
;;										|				год
;;
;;
;;		операция ввода, возвращает в W результат для каждой цифры
;;
;;
;;
;;
;;
;;

SHOWMENU
	MOVLW		COUNT_TAPS_MODE_CONST 	;;	устанавливается счетчик нажатий	
						;;	кнопки mode, когда = 0, выход на уровень вверх.
	MOVWF		COUNT_TAPS_MODE

	MOVLW		.16
	MOVWF		IND2
	MOVLW		.1
	MOVWF		IND3			;; "HI"
	MOVLW		.10
	MOVWF		IND1
	MOVWF		IND4
;;	50 циклов показа картинки
	MOVLW		.50
	CALL		SHOWING_DELAY
	CALL		SHOWING
	BTFSC		PORTC,B_MODE
	GOTO		$-2
	MOVLW		RATTLING_COUNT_SHOWING
	CALL		SHOWING_DELAY		;;ОТПУСТИЛИ КНОПКУ
	SHOWMENU_before_transmit
		CALL		TRANSMISSION_IN
		NOP
		MOVF		NOW_MINUTE,0
		MOVWF		IND4
		MOVF		NOW_MINUTE10,0
		MOVWF		IND3
		MOVF		NOW_HOUR,0
		MOVWF		IND2
		MOVF		NOW_HOUR10,0
		MOVWF		IND1
		MOVLW		.3
		CALL		SHOWING_DELAY
		BTFSS		PORTC,B_MODE
		GOTO		SHOWMENU_before_transmit		
SHOWMENU_change_time
	MOVLW		.8	
	MOVWF		IND1
	MOVLW		.19	
	MOVWF		IND2
	MOVLW		.13	
	MOVWF		IND3
	MOVLW		.10	
	MOVWF		IND4

	DECFSZ		COUNT_TAPS_MODE
	GOTO		$+2
	GOTO		MAIN
	CALL		BUTTON_MODE_PROCESSING
	CALL		SHOWING
	BTFSS		PORTC,B_MODE
	GOTO		$+2	
	GOTO		SHOWMENU_change_shedule
	BTFSS		PORTC,B_SELECT
	GOTO		$-5
;;
	CALL		SET_TIME
	GOTO		SHOWMENU_before_transmit

SHOWMENU_change_shedule
	MOVLW		.19	
	MOVWF		IND1
	MOVLW		.13	
	MOVWF		IND2
	MOVLW		.10	
	MOVWF		IND3
	MOVLW		.10	
	MOVWF		IND4

	DECFSZ		COUNT_TAPS_MODE
	GOTO		$+2
	GOTO		MAIN
	CALL		BUTTON_MODE_PROCESSING
	CALL		SHOWING
	BTFSS		PORTC,B_MODE
	GOTO		$-2
	GOTO SHOWMENU_reset

SHOWMENU_reset
	MOVLW		.12	
	MOVWF		IND1
	MOVLW		.21	
	MOVWF		IND2
	MOVLW		.19	
	MOVWF		IND3
	MOVLW		.0	
	MOVWF		IND4

	DECFSZ		COUNT_TAPS_MODE
	GOTO		$+2
	GOTO		MAIN
	CALL		BUTTON_MODE_PROCESSING
	CALL		SHOWING
	BTFSS		PORTC,B_MODE
	GOTO		$-2
	GOTO		SHOWMENU_manual_control

SHOWMENU_manual_control
	MOVLW		.19	
	MOVWF		IND1
	MOVLW		.22	
	MOVWF		IND2
	MOVLW		.23	
	MOVWF		IND3
	MOVLW		.16	
	MOVWF		IND4
	
	DECFSZ		COUNT_TAPS_MODE
	GOTO		$+2
	GOTO		MAIN
	CALL		BUTTON_MODE_PROCESSING
	CALL		SHOWING
	BTFSS		PORTC,B_MODE
	GOTO		$-2
GOTO SHOWMENU_change_time

GOTO	MAIN
end