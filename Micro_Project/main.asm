;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file
            
;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.
	.sect ".sysmem"
x .byte "+500, +200, +"						;Saves the string in x
sum .byte "+"
rest .byte "-"
div .byte "/"
mult .byte "*"

;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer


;-------------------------------------------------------------------------------
; Main loop here
			mov #x,R7						;saves the pointer to the string to R7
			mov.b sum,
			mov 0(R7), R7
			mov 2(R7), R8					;Se guarda
			mov 4(R7), R9
			mov 6(R7), R10
			mov 8(R7), R11
			mov 10(R7), R12
			mov 12(R7), R13
			mov 14(R7), R14




;Ale lo q quieres es leer los signos dentro de ese string, los tres.
; Una opcion para no usar tanta memoria es crear if statements. Si todos son + pues haces la subrutina de suma relax
; Si hay uno negativo dentro de los primeros dos pues haces el 2's complement...
; sigue pensando esto ma~ana... tienes sue~o

;--------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack
            
;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET

            .end

