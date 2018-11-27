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
x .byte "-285, -45, *"                 ;Saves the string in x
sum .byte "+"                               ;debuging purposes
rest .byte "-"                              ;debuging purposes
div .byte "/"                               ;debuging purposes
mult .byte "*"                              ;debuging purposes
comma .byte ","                             ;debuging purposes
neg .byte "-"                               ;debuging purposes
y .byte "              "                    ;output string

;x .word "+500, +200, *"
;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer
;---------------------------------------------------------------------------------
;COSAS PARA RECORDAR:

    ;HAY QUE USAR EL SIGNO DE COMA COMO DELIMITADOR!!!!!!!!
    ;MULTIPLIACION--> Si tienes dos numeros con signos negativos NO PASA NADA pq el signo esta en ascii asi q no hay complemento
    ;Hay que tener en cuenta si son signos distintos hay que escribir en ascii el negativo en el resultado
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
            clr R5                            ;Dummy variable for implementation
            clr R14                           ;Guarda el signo del segundo numero
            clr R6                            ;Here we are going to save the first number
            clr R7                            ;Here we are going to save the second number
            clr R8                            ;Here we are going to save if the number has a negative sign
            clr R9                            ;Here we are going to save the operation to be execute
                                              ;CLear the memory of R8


;---Process to organize two number and opertator and prepare them to make an operation--------------------------------------------------------

            mov #x, R12                       ;Here we take the pointer of the string and save it to R12
            mov R12, R15                      ;Move address of R12 to R15
            mov #0, R12                       ;Clear R12
            mov.b @R15+,R13                   ;Move sign of first operand in R13
            mov #002Ch,R4                     ;Put Ascii symbol of "," to R4
            mov #y,R8                  ;Point R8 to memory of the output
            mov #0x0000,0(R8)                 ;Clear contents of address in R8
            call #num1

num1:                                        ;Subroutine to read first operand
            mov.b @R15+,R5                   ;Reads next number and stores it in dummy R5
            cmp.b R5,R4                      ;Verify if ended reading (reached a ",")
            jeq sign2                        ;If finished reading, procede to read next operand
            sub.b #0030h,R5                  ;Substract #30h to ascii number to obtain real number in hex
            call #multOne


multOne:                                     ;subroutine to move units and keep adding digits to operand
            mov.b #0000Ah, &MPY              ;Here we multiply by ten
            mov R6, &OP2                     ;The number in R6 is going to be multiplied by 10
            nop                              ;stop time
            mov &RESLO, R6                   ;&RESLO is the multiplication of the two numbers which is going to be saved in R6
            add R5,R6                        ;Here we add the current number in R5 and the multiplied value
            call #num1                       ;Now we read the next ascii character

sign2:
            inc R15                          ;After we finish reading the first number we increment R15 cause we are pointing to a comma
            mov.b @R15+,R14                  ;We move the sign of second number to R14
            call #num2                       ;Proceed to read next ascii number

num2:                                        ;Subroutine to read second operand
            mov.b @R15+,R5                   ;Reads next number and stores it in dummy R5
            cmp.b R5,R4                      ;Verify if ended reading (reached a ",")
            jeq oper                       	 ;If finished, go to read operator
            sub.b #0030h,R5                  ;Substract #30h to ascii number to obtain real number in hex
            call #multTwo

multTwo:                                     ;subroutine to move units and keep adding digits to operand
            mov.b #000Ah, &MPY               ;Here we multiply by ten
            mov R7, &OP2                     ;The number in R7 is going to be multiplied by 10
            nop                              ;stop time
            mov &RESLO, R7                   ;&RESLO is the multiplication of the two numbers which is going to be saved in R7
            add R5,R7                        ;Here we add the current number in R5 and the multiplied value
            call #num2

oper:
            inc R15
            clr R5                           ;Increment R15 because it is pointing to space
            mov.b @R15+,R5                   ;Move operator to dummy register
            cmp.b #002Bh,R5                  ;Here we compare if its sum
            jeq sumsign                      ;Call sum subroutine
            cmp.b #002Dh, R5                 ;Here we compare if its substraction
            jeq subsign                      ;Call substraction subroutine
            cmp.b #002Fh,R5                  ;Here we compare if its division
            jeq division                     ;Call division Subroutine
            cmp.b #002Ah,R5                  ;Here we compare if its multiplciation
            jeq multiplication               ;Call multiplication subroutine

;Sum Subroutine-------------------------------------------------------------------------------------------------------------------------------------------------
sumsign:
            cmp.b R13,R14                    ;Compare signs
            jeq sumation                     ;If equal signs, sum them
            jne findMaxSign                  ;Else, find largest number and use its sign in result
sumation:
            add R6,R7                        ;Sum operands and store them in R7
            mov.b R13,0(R8)                  ;Add sign to R8
            inc R8                           ;Incrementamos R8 to point to next direction in memory
            mov R7,R9                        ;R9 is saving the result to be converted to ASCII
            jmp startConvertion              ;Call subroutine that converts bianry back to ascii


findMaxSign:
            cmp R6,R7                        ;Compare two operands
            jl signIsR13                     ;If first operand is bigger, call signIs13 subroutine
            jge signIsR14                    ;Else, call signIs14 subroutine


signIsR13:
            sub R7,R6                        ;substract R7 from R6 and store in r6
            mov.b R13,0(R8)                  ;Move sign to R8
            inc R8
            mov R6,R9                        ;Final real result in r9, ready to be converted to ASCII
            jmp startConvertion              ;Call subroutine that converts bianry back to ascii


signIsR14:
            sub R6,R7
            mov.b R14,0(R8)
            mov R7,R9                        ;final real result in r9, ready to be converted to ASCII
            inc R8
            jmp startConvertion



;End Sum SubRoutine--------------------------------------------------------------------------------------------

;Substraction Subroutine---------------------------------------------------------------------------------------
subsign:
            cmp R13,r14                        ;Compare signs
            jeq findMaxSign2
            jne substraction

substraction:
            add R6,R7
            mov.b R13, 0(R8)
            inc R8
            mov R7,R9
            jmp startConvertion

findMaxSign2:
            cmp R6,R7
            jl signIs13sub
            jge signIs14sub

signIs13sub:
            sub R7,R6
            mov.b #002Dh,0(R8)
            inc R8
            mov R6,R9
            jmp startConvertion

signIs14sub:
            sub R6,R7
            mov.b #002Bh,0(R8)
            mov R7,R9                        ;final real result in r9, ready to be converted to ASCII
            inc R8
            jmp startConvertion
;End Substraction SubRoutine--------------------------------------------------------------------------------------------
;--------------- Codigo de Jose------------------------------------------------------------------------------------------

multiplication:
            mov R6, &MPY                    ;Here we multiply by R6, first number
            mov R7, &OP2                    ;The number in R7, second number, is going to be multiplied by R6, first number
            nop                                ;Stop time
            mov &RESLO, R9                    ;&RESLO is the multiplication of the two numbers which is going to be saved in R8
            jmp multdivsign                    ;Jump subrutine multdivsign to determine the sign of the result

division:
            cmp R7,R6                    ;Verify if second number fits inside first number
            jl multdivsign              ;Call subrutine multdivsign to determine the sign of the result    when we finished
            sub R7,R6                    ;Substract second number to first number
            inc R9                        ;Increment number of times that second number fits inside first
            jnz division

multdivsign:
            cmp R13,R14                    ;Compare both numbers signs
            jz posresult                ;If both numbers have the same sign, positive result
            jnz negresult                ;If numbers have different signs, negative result
posresult:
            mov.b #0x002B, 0(R8)
            inc R8
            jmp startConvertion

negresult:
            mov.b #0x002D, 0(R8)
            inc R8
           ; jmp startConvertion
;--------------------------------------------------------------------------------------------------------------------------
;-------------------------------Subroutine to write the ascii result------------------------------------------------------
startConvertion:
            clr R13						;Clear R13 to move ascii result inversed
            clr R14						;Use R14 as our counter of digits
            mov #0x002300,R13			;Set directon of R13
            mov #0,0(R13)           	;Clear contents in directoin of R13
convert:
            cmp #0, R9					;If R9 is 0, we finished converting
            jeq invertResult			;Go to invert ascii result
            mov R9,R10					;Move R9 to R10 because R10 has the number that will give us the mod of 10
            call #mod					;Call mod routine to calculate module of our real result, this give us the unity of out real number

mod:									; Routine to calculate module of our real result, this give us the unity of out real number
            cmp #0x000A,R10				;If R10 is less than 10, it means our module is in R10
            jl convertToAscii			;Jump to converting binary number to ascii
            sub #0x000A,R10				;substract 10 from R10
            jmp mod						;Repeat module

convertToAscii:							;This routine converts binary number to an ascii by adding 30h
            add #0x0030, R10			;Add 30h to module to obtain its ascii representation
            mov.b R10,0(R13)			;Move ascii to address of R13
            inc R13						;increment address of R13
            mov R9, R5					;Use R5 as dummy to divide R9
            clr R9						;Clear R9
   	        jmp divideByTen				;Jump to divide by 10

divideByTen:
            cmp #0x000A, R5				;Check if number is less than 10
            jl incNumDigits				;If less than 10, we finished dividing and R9 contains the result of division
            sub #0x000A,R5				;Substract 10 from R5
            inc R9						;Increment R9
            jmp divideByTen				;Jmp again to divide by 10

incNumDigits:
			inc R14						;Increment our digits counter
			jmp convert					;Jump to convert our next digit to ascii
            ;mov.b @R12,0(R8)

;---------------------------Final result routine--------------------------------------------------------------------------------
invertResult:							;Subroutine that puts the converted asciis in correct order in our output
			dec R13
            cmp.b #0, R14				;Check if finished passing digits to output register
            jeq done					;We are done
            mov.b 0(R13), R5			;Use R5 as dummy
            mov.b R5, 0(R8)				;Move dummy to address of output register
            inc R8						;Increment address of output Register to put our next digit
            dec R14
            jmp invertResult			;Back to inverting next digit

done:									;We are done, give us an A.
            jmp $

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


;Got it, thanks!
;Thanks a lot.
;Thank you!
