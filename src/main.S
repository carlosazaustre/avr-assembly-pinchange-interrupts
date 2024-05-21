;
; Program: Interrupt on pin change
; Description: Activa PB5 siempre que PB0 se active usando interrupciones por cambio de pin,, 
;              Activa PB1 mientras el MCU no está "modo de suspensión" solo para verificar el modo de suspensión
; Created: 21/05/2024
;

#include <avr/io.h>

.text

; Rutina de interrupción
.global PCINT0_vect
PCINT0_vect:
  ; Set PB5 a PB0, Salta a la siguiente instrucción si PB0 está activo
  sbis _SFR_IO_ADDR(PINB), PB0 ; sbis (Skip if Bit in I/O Register is Set)
  rjmp int_clear_output 
  sbi _SFR_IO_ADDR(PORTB), PB5 ; Si no está activo PB0, activa PB5
  rjmp int_continue
int_clear_output:
  cbi _SFR_IO_ADDR(PORTB), PB5 ; Ponemos PB5 a 0
int_continue:
  reti

.global main
main:
  ; Configuramos PCINT0 (PB0)
  ; PCICR (Pin Change Interrupr Control Register)
  ; [ -, - ,-, -, -, PCIE2, PCIE1, PCIE0]
  ; PCIE0: Habilita interrupciones en de cambio lógico de PCINT[0..7] = PB[0..7]
  ldi r16, _BV(PCIE0)
  sts PCICR, r16
  ; PCMSK0 (Pin Change Mask Register 0)
  ; [PCINT7, PCINT6, PCINT5, PCINT4, PCINT3, PCINT2, PCINT1, PCINT0]
  ; PCINT0: Activo, lanza interrupción cuando PCINT0 (PB0) cambie
  ldi r16, _BV(PCINT0)
  sts PCMSK0, r16

  ; Configuramos el Port B
  ldi r16, _BV(PB5)  ; PB5 como salida, el resto de PORTB como entrada
  out _SFR_IO_ADDR(DDRB), r16
  ldi r16, ~_BV(PB5)            ; Activa resistencia de pull-ups.
  out _SFR_IO_ADDR(PORTB), r16

  ; Programa principal
  sei                           ; Habilita las interrupciones globales
  ldi r16, _BV(SM1) | _BV(SE)   ; Activa el modo de ahorro de energía (power-down mode)
  out _SFR_IO_ADDR(SMCR), r16

loop:
  sleep
  rjmp loop

