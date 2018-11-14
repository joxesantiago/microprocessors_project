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
x .byte "+550, +202, +"						;Saves the string in x
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
;---------------------------------------------------------------------------------
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
; Main loop here
;Cleaning of registers

			clr R15
			clr R5							;Dummy variable for implementation
			clr R14							;Guarda el signo del segundo numero

			clr R6							;Here we are going to save the first number
			clr R7							;Here we are going to save the second number

			clr R8							;Here we are going to save if the number has a negative sign

			clr R9							;Here we are going to save the operation to be execute
							;CLear the memory of R8

			mov #x, R12						;Here we take the pointer of the string and save it to R12
			mov R12, R15					;Movemos la direccion de r12 a R15
			mov #0, R12						;Clear R12
			mov.b @R15+,R13					;Ponemos el signo del primer operando en R13
			mov #002Ch,R4					;Aqui colocamos la comma
			mov #0x002126,R8				;Point R8 to memory of the output
			mov #0x0000,0(R8)
			call #num1

num1:
			mov.b @R15+,R5					;Lee el numero y lo coloca en R5
			cmp.b R5,R4						;Verificar si acabe de leer el signo
			jeq sign2
			sub.b #0030h,R5				 	;Resta 30h a el numero ascii para sacar el valor del numero en hexadecimal
			call #multOne					;Llama a la subrutina para mover las unidades


multOne:
			mov.b #000Ah, &MPY				;Here we multiply by ten the
			mov.b R6, &OP2					;THe number in R6 is going to be multiplied by 10
			nop								;stop time
			mov &RESLO, R6					;&RESLO is the multiplication of the two numbers which is going to be saved in R6
			add R5,R6						;Here we add the current number in R5 and the multiplied value
			call #num1						;NOw we read the next ascii character

sign2:
			inc R15							;After we finish reading the first number we increment R15 cause we are pointing to a comma
			mov.b @R15+,R14					;We move the second number to R14
			call #num2

num2:
			mov.b @R15+,R5					;MOve the current number to our dummy register
			cmp.b R5,R4						;Verificar si lo que acabe de leer es una comma
			jeq oper						;Brinca a la subrutina que guarda el operando a hacer
			sub.b #0030h,R5					;para extraer el numero en decimal del ascii
			call #multTwo

multTwo:
			mov.b #000Ah, &MPY
			mov.b R7, &OP2
			nop
			mov &RESLO, R7
			add R5,R7						;This is the one that stores the multiplication
			call #num2
signClass:


oper:
			inc R15
			mov @R15+,R9
			cmp.b #002Bh,R9					;Here we compare if its sum
			jeq sumsign
			cmp.b #002Dh, R9				;Here we compare if its substraction
			jeq subsign
			cmp.b #002Fh,R9					;Here we compare if its division
			jeq division
			cmp.b #002Ah,R9					;Here we compare if its multiplciation
			jeq multiplication
multsign:
multiplication:
			mov #0, R10
divsign:
division:
			ret
subsign:
			ret

subs:
			ret
sumsign:
			cmp.b R13,R14					;Here we compare the signs of the results
			jeq sumation					;SI es de igual signo simplemente sumas
			jne subs						;Si son de signos distintos lo restas
sumation:

			add R6,R7						;Sum both numbers and save them in R7
			mov.b R13,0(R8)					;Add the sign of the number
			inc R8
			mov R7,1(R8)					;R8 is saving the result


done:
			ret

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

