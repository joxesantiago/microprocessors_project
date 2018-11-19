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
x .byte "-550, +220, -"						;Saves the string in x
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


;---Process to organize two number and opertator and prepare them to make an operation--------------------------------------------------------

			mov #x, R12						;Here we take the pointer of the string and save it to R12
			mov R12, R15					;Move address of R12 to R15
			mov #0, R12						;Clear R12
			mov.b @R15+,R13					;Move sign of first operand in R13
			mov #002Ch,R4					;Put Ascii symbol of "," to R4
			mov #0x002126,R8				;Point R8 to memory of the output
			mov #0x0000,0(R8)				;Clear contents of address in R8
			call #num1

num1:										;Subroutine to read first operand
			mov.b @R15+,R5					;Reads next number and stores it in dummy R5
			cmp.b R5,R4						;Verify if ended reading (reached a ",")
			jeq sign2						;If finished reading, procede to read next operand
			sub.b #0030h,R5				 	;Substract #30h to ascii number to obtain real number in hex
			call #multOne


multOne:									;subroutine to move units and keep adding digits to operand
			mov.b #000Ah, &MPY				;Here we multiply by ten
			mov.b R6, &OP2					;The number in R6 is going to be multiplied by 10
			nop								;stop time
			mov &RESLO, R6					;&RESLO is the multiplication of the two numbers which is going to be saved in R6
			add R5,R6						;Here we add the current number in R5 and the multiplied value
			call #num1						;Now we read the next ascii character

sign2:
			inc R15							;After we finish reading the first number we increment R15 cause we are pointing to a comma
			mov.b @R15+,R14					;We move the second number to R14
			call #num2						;Proceed to read next ascii number

num2:										;Subroutine to read second operand
			mov.b @R15+,R5					;Reads next number and stores it in dummy R5
			cmp.b R5,R4						;Verify if ended reading (reached a ",")
			jeq oper						;If finished, go to read operator
			sub.b #0030h,R5					;Substract #30h to ascii number to obtain real number in hex
			call #multTwo

multTwo:									;subroutine to move units and keep adding digits to operand
			mov.b #000Ah, &MPY				;Here we multiply by ten
			mov.b R7, &OP2					;The number in R7 is going to be multiplied by 10
			nop								;stop time
			mov &RESLO, R7					;&RESLO is the multiplication of the two numbers which is going to be saved in R7
			add R5,R7						;Here we add the current number in R5 and the multiplied value
			call #num2

oper:
			inc R15							;Increment R15 because it is pointing to space
			mov @R15+,R5					;Move operator to dummy register
			cmp.b #002Bh,R5					;Here we compare if its sum
			jeq sumsign						;Call sum subroutine
			cmp.b #002Dh, R5				;Here we compare if its substraction
			jeq subsign						;Call substraction subroutine
			cmp.b #002Fh,R5					;Here we compare if its division
			jeq division					;Call division Subroutine
			cmp.b #002Ah,R5					;Here we compare if its multiplciation
			jeq multiplication				;Call multiplication subroutine

;Sum Subroutine-------------------------------------------------------------------------------------------------------------------------------------------------
sumsign:
			cmp.b R13,R14					;Compare signs
			jeq sumation					;If equal signs, sum them
			jne findMaxSign					;Else, find largest number and use its sign in result
sumation:
			add R6,R7						;Sum operands and store them in R7
			mov.b R13,0(R8)					;Add sign to R8
			inc R8							;Incrementamos R8 to point to next direction in memory
			mov R7,R9						;R9 is saving the result to be converted to ASCII
			jmp convertToAscii				;Call subroutine that converts bianry back to ascii


findMaxSign:
			cmp R6,R7						;Compare two operands
			jl signIsR13					;If first operand is bigger, call signIs13 subroutine
			jge signIsR14					;Else, call signIs14 subroutine


signIsR13:
			sub R7,R6						;substract R7 from R6 and store in r6
			mov.b R13,0(R8)					;Move sign to R8
			inc R8
			mov R6,R9						;Final real result in r9, ready to be converted to ASCII
			jmp convertToAscii				;Call subroutine that converts bianry back to ascii


signIsR14:
			sub R6,R7
			mov.b R14,0(R8)
			mov R7,R9						;final real result in r9, ready to be converted to ASCII
			inc R8
			jmp convertToAscii



;End Sum SubRoutine--------------------------------------------------------------------------------------------

;Substraction Subroutine---------------------------------------------------------------------------------------
subsign:
			cmp R13,r14						;Compare signs
			jeq findMaxSign2
			jne substraction

substraction:
			add R6,R7
			mov.b R13, 0(R8)
			inc R8
			mov R7,R9
			jmp convertToAscii

findMaxSign2:
			cmp R6,R7
			jl signIs13sub
			jge signIs14sub

signIs13sub:
			sub R7,R6
			mov.b R13,0(R8)
			inc R8
			mov R6,R9
			jmp convertToAscii

signIs14sub:
			sub R6,R7
			mov.b R14,0(R8)
			mov R7,R9						;final real result in r9, ready to be converted to ASCII
			inc R8
			jmp convertToAscii
;End Substraction SubRoutine--------------------------------------------------------------------------------------------
;--------------- Codigo de Jose------------------------------------------------------------------------------------------

multiplication:
			mov.b R6, &MPY					;Here we multiply by R6, first number
			mov.b R7, &OP2					;The number in R7, second number, is going to be multiplied by R6, first number
			nop								;Stop time
			mov &RESLO, R9					;&RESLO is the multiplication of the two numbers which is going to be saved in R8
			call #multdivsign				;Call subrutine multdivsign to determine the sign of the result

division:
			cmp R7,R6					;Verify if second number fits inside first number
			jl multdivsign              ;Call subrutine multdivsign to determine the sign of the result	when we finished
			sub R7,R6					;Substract second number to first number
			inc R9						;Increment number of times that second number fits inside first
			jnz division

multdivsign:
			cmp R13,R14					;Compare both numbers signs
			jz posresult				;If both numbers have the same sign, positive result
			jnz negresult				;If numbers have different signs, negative result
posresult:
			ret

negresult:
			ret
;--------------------------------------------------------------------------------------------------------------------------



convertToAscii:



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
