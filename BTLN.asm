$NOLIST
$INCLUDE (REG51.INC)
$LIST

;==================================================
; PASSWORD LOCK - 8051 ASSEMBLY (Keil A51)
; LCD 4-bit, Keypad 4x3, Relay, Buzzer
;==================================================

; ---------- Khai bao BIT ----------
LCD_RS  BIT 0A7H        ; P2.7
LCD_RW  BIT 0A6H        ; P2.6
LCD_EN  BIT 0A5H        ; P2.5
LCD_D4  BIT 0A4H        ; P2.4
LCD_D5  BIT 0A3H        ; P2.3
LCD_D6  BIT 0A2H        ; P2.2
LCD_D7  BIT 0A1H        ; P2.1
RELAY   BIT 0B6H        ; P3.6
BUZZ    BIT 0B7H        ; P3.7

; ---------- Khai bao RAM ----------
KEY     EQU 30H
I_CNT   EQU 31H
J_CNT   EQU 32H
BUZZ_CT EQU 33H
COL_V   EQU 34H
ROW_V   EQU 35H
MASK_B  EQU 36H
COL_MSK EQU 37H
CHECK   EQU 40H
PASS    EQU 50H

;==================================================
        ORG  0000H
        LJMP MAIN

;==================================================
; VUNG DATA ROM
;==================================================
        ORG  0030H

KEYPAD_TBL:
        DB '1','2','3'
        DB '4','5','6'
        DB '7','8','9'
        DB '*','0','#'

COL_MASK_TBL:
        DB 0EFH, 0DFH, 0BFH

ROW_MASK_TBL:
        DB 01H, 02H, 04H, 08H

MSG_ENTER:
        DB "ENTER PASSWORD:",0
MSG_LOAD:
        DB "Load...",0
MSG_WARN:
        DB "Warning...",0
MSG_ERROR:
        DB "Error...",0

;==================================================
; CODE
;==================================================
        ORG  0100H

DELAY_MS:
        PUSH 06H
DMS_OUT:
        MOV  R6,#123
DMS_IN:
        DJNZ R6,DMS_IN
        DJNZ R7,DMS_OUT
        POP  06H
        RET

DELAY_US:
        DJNZ R7,DELAY_US
        RET

LCD_ENABLE:
        SETB LCD_EN
        MOV  R7,#3
        LCALL DELAY_US
        CLR  LCD_EN
        MOV  R7,#50
        LCALL DELAY_US
        RET

LCD_SEND4BIT:
        MOV  C,ACC.0
        MOV  LCD_D4,C
        MOV  C,ACC.1
        MOV  LCD_D5,C
        MOV  C,ACC.2
        MOV  LCD_D6,C
        MOV  C,ACC.3
        MOV  LCD_D7,C
        RET

LCD_SENDCOMMAND:
        PUSH ACC
        SWAP A
        ANL  A,#0FH
        LCALL LCD_SEND4BIT
        LCALL LCD_ENABLE
        POP  ACC
        ANL  A,#0FH
        LCALL LCD_SEND4BIT
        LCALL LCD_ENABLE
        RET

LCD_CLEAR:
        MOV  A,#01H
        LCALL LCD_SENDCOMMAND
        MOV  R7,#10
        LCALL DELAY_US
        RET

LCD_INIT:
        MOV  A,#00H
        LCALL LCD_SEND4BIT
        MOV  R7,#20
        LCALL DELAY_MS
        CLR  LCD_RS
        CLR  LCD_RW
        MOV  A,#03H
        LCALL LCD_SEND4BIT
        LCALL LCD_ENABLE
        MOV  R7,#5
        LCALL DELAY_MS
        LCALL LCD_ENABLE
        MOV  R7,#100
        LCALL DELAY_US
        LCALL LCD_ENABLE
        MOV  A,#02H
        LCALL LCD_SEND4BIT
        LCALL LCD_ENABLE
        MOV  A,#28H
        LCALL LCD_SENDCOMMAND
        MOV  A,#0CH
        LCALL LCD_SENDCOMMAND
        MOV  A,#06H
        LCALL LCD_SENDCOMMAND
        MOV  A,#01H
        LCALL LCD_SENDCOMMAND
        RET

LCD_GOTOXY:
        MOV  R7,#250
        LCALL DELAY_US
        MOV  R7,#250
        LCALL DELAY_US
        MOV  R7,#250
        LCALL DELAY_US
        MOV  R7,#250
        LCALL DELAY_US
        MOV  A,R5
        JNZ  GXY_ROW1
        MOV  A,#80H
        ADD  A,R4
        SJMP GXY_SEND
GXY_ROW1:
        MOV  A,#0C0H
        ADD  A,R4
GXY_SEND:
        LCALL LCD_SENDCOMMAND
        MOV  R7,#50
        LCALL DELAY_US
        RET

LCD_PUTCHAR:
        SETB LCD_RS
        LCALL LCD_SENDCOMMAND
        CLR  LCD_RS
        RET

LCD_PUTS:
        CLR  A
        MOVC A,@A+DPTR
        JZ   LPS_END
        LCALL LCD_PUTCHAR
        INC  DPTR
        SJMP LCD_PUTS
LPS_END:
        RET

WARNING:
        MOV  BUZZ_CT,#10
WRN_LP:
        SETB BUZZ
        MOV  R7,#200
        LCALL DELAY_MS
        CLR  BUZZ
        MOV  R7,#200
        LCALL DELAY_MS
        DJNZ BUZZ_CT,WRN_LP
        RET

DELAY_3S:
        PUSH 05H
        MOV  R5,#12
D3S_LP:
        MOV  R7,#255
        LCALL DELAY_MS
        DJNZ R5,D3S_LP
        POP  05H
        RET

DELAY_500MS:
        MOV  R7,#255
        LCALL DELAY_MS
        MOV  R7,#245
        LCALL DELAY_MS
        RET

;--------------------------------------------------
; QUETPHIM - Tra ve A=ASCII phim, A=0 neu khong co
;--------------------------------------------------
QUETPHIM:
        MOV  P1,#0FFH
        MOV  P1,#0FH
        NOP
        NOP
        NOP
        NOP
        MOV  A,P1
        ANL  A,#0FH
        CJNE A,#0FH,QP_SCAN
        MOV  A,#00H
        RET

QP_SCAN:
        MOV  COL_V,#0

QP_COL_NEXT:
        MOV  DPTR,#COL_MASK_TBL
        MOV  A,COL_V
        MOVC A,@A+DPTR
        MOV  COL_MSK,A
        MOV  P1,A
        MOV  R6,#123
QP_CDLY:
        DJNZ R6,QP_CDLY
        MOV  ROW_V,#0

QP_ROW_NEXT:
        MOV  DPTR,#ROW_MASK_TBL
        MOV  A,ROW_V
        MOVC A,@A+DPTR
        MOV  MASK_B,A
        MOV  A,P1
        ANL  A,MASK_B
        JNZ  QP_ROW_INC

QP_WAIT:
        MOV  A,P1
        ANL  A,MASK_B
        JZ   QP_WAIT
        MOV  A,ROW_V
        MOV  B,#3
        MUL  AB
        ADD  A,COL_V
        MOV  DPTR,#KEYPAD_TBL
        MOVC A,@A+DPTR
        RET

QP_ROW_INC:
        INC  ROW_V
        MOV  A,ROW_V
        CJNE A,#4,QP_ROW_NEXT
        INC  COL_V
        MOV  A,COL_V
        CJNE A,#3,QP_COL_NEXT
        MOV  A,#00H
        RET

;--------------------------------------------------
; SOSANH - A=1 neu bang, A=0 neu khac
;--------------------------------------------------
SOSANH:
        MOV  R0,#PASS
        MOV  R1,#CHECK
        MOV  R7,#6
SS_LP:
        MOV  A,@R0
        MOV  B,@R1
        CJNE A,B,SS_FAIL
        INC  R0
        INC  R1
        DJNZ R7,SS_LP
        MOV  A,#1
        RET
SS_FAIL:
        MOV  A,#0
        RET

;==================================================
; MAIN
;==================================================
MAIN:
        MOV  R0,#PASS
        MOV  @R0,#'1'
        INC  R0
        MOV  @R0,#'1'
        INC  R0
        MOV  @R0,#'1'
        INC  R0
        MOV  @R0,#'1'
        INC  R0
        MOV  @R0,#'1'
        INC  R0
        MOV  @R0,#'1'

        LCALL LCD_INIT
        CLR  RELAY
        CLR  BUZZ
        MOV  J_CNT,#0

MAIN_LOOP:
        LCALL LCD_CLEAR
        MOV  R4,#0
        MOV  R5,#0
        LCALL LCD_GOTOXY
        MOV  DPTR,#MSG_ENTER
        LCALL LCD_PUTS
        MOV  R4,#0
        MOV  R5,#1
        LCALL LCD_GOTOXY
        MOV  I_CNT,#0

INP_LP:
        LCALL QUETPHIM
        JZ   INP_LP
        MOV  KEY,A
        MOV  R4,I_CNT
        MOV  R5,#1
        LCALL LCD_GOTOXY
        MOV  A,KEY
        LCALL LCD_PUTCHAR
        MOV  A,I_CNT
        ADD  A,#CHECK
        MOV  R0,A
        MOV  A,KEY
        MOV  @R0,A
        MOV  KEY,#0
        INC  I_CNT
        MOV  A,I_CNT
        CJNE A,#6,INP_LP

        LCALL SOSANH
        JZ   ML_WRONG

        MOV  R4,#0
        MOV  R5,#1
        LCALL LCD_GOTOXY
        MOV  DPTR,#MSG_LOAD
        LCALL LCD_PUTS
        SETB RELAY
        LCALL DELAY_3S
        CLR  RELAY
        MOV  J_CNT,#0
        LJMP MAIN_LOOP

ML_WRONG:
        INC  J_CNT
        MOV  A,J_CNT
        CJNE A,#3,ML_ERR
        MOV  R4,#0
        MOV  R5,#1
        LCALL LCD_GOTOXY
        MOV  DPTR,#MSG_WARN
        LCALL LCD_PUTS
        LCALL WARNING
        MOV  J_CNT,#0
        LJMP MAIN_LOOP

ML_ERR:
        MOV  R4,#0
        MOV  R5,#1
        LCALL LCD_GOTOXY
        MOV  DPTR,#MSG_ERROR
        LCALL LCD_PUTS
        LCALL DELAY_500MS
        LJMP MAIN_LOOP

        END