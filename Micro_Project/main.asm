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
sum .byte "+"								;debuging purposes
rest .byte "-"								;debuging purposes
div .byte "/"								;debuging purposes
mult .byte "*"								;debuging purposes
comma .byte ","								;debuging purposes
neg .byte "-"								;debuging purposes

;x .word "+500, +200, *"
;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer


;--------------------------------------------------------------------------------
;---------------------------------------------------------------------------------
; Main loop here
			clr R15
			clr R13
			clr r6							;Here we are going to save the first number
			clr r7							;Here we are going to save the second number
			clr r8							;Here we are going to save if the numer has a negative sign
			clr r9							;Here we are going to save the operation


			mov #x, R12						;Here we take the pointer of the string and save it to R12
			mov R12, R15					;Movemos la direccion de r12 a R15
			mov #0, R12						;Clear R12
			mov.b @R15+,R13				;Ponemos el signo del primer operando en R13
			mov #002Ch,R4
			;mov @R15+,R15				;This is our delimiter, we save the pointer to it in R4


			call #num1

num1:
			mov.b @R15+,R5
											;Mover primer numero a R5, incrementa R15 para el proximo caracter
			;inv R15
			cmp.b R5,R4						;Verificar si acabe de leer el primer operando
			jeq sign2					    ;Brincamos a leer el proximo numero ***************************************************** arreglar
			sub.b #0030h,R5				 	;para extraer el numero en decimal del ascii
			call #multOne					;


multOne:
			mov.b #000Ah, &MPY
			mov.b R6, &OP2
			nop
			mov &RESLO, R6
			add R5,R6
			call #num1					;Resultado de operando 1 en R6

sign2:
			inc R15
			mov.b @R15+,R14
			call #num2

num2:
			mov.b @R15+,R5
											;Mover primer numero a R5, incrementa R15 para el proximo caracter
			cmp.b R5,R4						;Verificar si acabe de leer el primer operando
			;jeq #op					;Brincamos a leer el proximo numero ***************************************************** arreglar
			sub.b #0030h,R5					;para extraer el numero en decimal del ascii
			call #multTwo

multTwo:
			mov.b #000Ah, &MPY
			mov.b R7, &OP2
			nop
			mov &RESLO, R7
			add R5,R7
			call #num2					;Resultado de operando 1 en R6


;incR15:
			;inc R15

done:
			ret


;--------------------OLD---------------------------------------------------------
;--------------------------------------------------------------------------------
;COSAS PARA RECORDAR:

	;HAY QUE USAR EL SIGNO DE COMA COMO DELIMITADOR!!!!!!!!
	;MULTIPLIACION--> Si tienes dos numeros con signos negativos NO PASA NADA pq el signo esta en ascii asi q no hay complemento
	;HAy que tener en cuenta si son signos distintos hay que escribir en ascii el negativo en el resultado
	;SUMA Y RESTA --> si tienes dos numeros con signo opuesto el que tiene el negativo si tienes que hacerle el 2's complement para ejecutar la operacion
	;!!!SI se colocan dos numero que su resultado de MAS DE 16 BITS hay que colocar un error
	;!!!Hay que hacer un error de division entre 0
	;DIVISION
		;- Solo devolvemos la parte entera de la division
		; -Siempre se divide el mas grande entre el mas peque~o ( esto hay que colocarlo en el reporte)
	;Hay que desarrollar pruebas para demostrar que el programa trabaja e incluirlas en el reporte

;---------------------------------------------------------------------------------

;---------------------------------------------------------------------------------
; Main loop here
			;mov #x, R12						;Here we take the pointer of the string and save it to R12
			;mov #comma,R4					;This is our delimiter, we save the pointer to it in R4
			;mov #neg,R5						;THis is going to be used to compare if the sign of the number is a negative number
			;mov #sum,R6						;This is going to save the positive
			;clr r6							;Here we are going to save the first number
			;clr r7							;Here we are going to save the second number
			;clr r8							;Here we are going to save if the numer has a negative sign
			;clr r9							;Here we are going to save the operation
			;mov #y, R13
			;call #organize
;organize:									;Subrutina que comienza el proceso de traducir las letras
			;mov R12,R15						;NOw the start of the string is pointed in R15
			;mov #0,R12						;Cleaning R12, by default the calling convention the result is going to be there because of the return

;rep:										;esta subrutina es para leer el string completo
			;cmp.b #0,0(R15)					;Here we compare if the string is at the end, the end of a string is 0 in ascii
			;jeq done						;Jump to done if its the end of the string
			;cmp.b @R15,R5					;Here we compare if the caracter is a negative sign
			;jeq nega
			;cmp.b @R15,R4					;Here we compare if what we are currently reading is a comma, our delimiter
			;jeq num
			;cmp.b @R15,R6					;Aqui verifica si es el signo de suma
			;jeq nextch
			;cmp.b @R15,
			;mov @R15,R9
			;mov.b @R15,R10
			;rla.b R10
			;rla.b R10
			;rla.b R10
			;rla.b R10
			;jmp nextch						;Aqui me muevo al siguiente caracter

;nega:
			;mov @R15,R6						;here we save the negative sign
											; DEBE HABER ALGUNA FORMA DE NO TENER QUE GUARDAR Q ES NEGATIVO EN ALGUN REGISTRO
											;VERIFICA SI EXISTE ALGUN FLAG PARA ESE CARACTER EN ESPECIFICO Q ME DIGA SI ES NEGATIVO

;num:										;In this subroutine we save each number to r6 and r7
			;mov


;nextch: inc R15 							;This subroutine moves to the next character
		;jmp rep

;done:
			;ret
;--------------------------------------------------------------------------------
			;mov @R7+,R6
			;cmp sum,R6

			;mov 0(R7), R7
			;mov 2(R7), R8					;Se guarda
			;mov 4(R7), R9
			;mov 6(R7), R10
			;mov 8(R7), R11
			;mov 10(R7), R12
			;mov 12(R7), R13
			;mov 14(R7), R14

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

