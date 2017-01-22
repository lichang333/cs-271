TITLE Programming Assignment #1 (assn1.asm)

; Author: Alec Merdler
;
; Description: Prompt user for two integers, then output the sum, difference, product,
;              and quotient/remainder of the input.
;              Validate first number is greater than the second
;              Loop the program until user quits
;              Calculate the floating point result of division

INCLUDE Irvine32.inc

.data
programTitle		BYTE	"Programming Assignment #1 - Alec Merdler", 0
instructions		BYTE	"Please enter two numbers, and I'll show you the sum, difference, product, quotient, and remainder.", 0
firstPrompt			BYTE	"First Number: ", 0
secondPrompt	    BYTE	"Second Number: ", 0
firstNum			DWORD	?
secondNum		    DWORD	?
goodbyeMessage		BYTE	"Goodbye", 0
equalSign		    BYTE	" = ", 0
sum					DWORD	?
additionSign		BYTE	" + ",0
difference			DWORD	?
minusSign	        BYTE	" - ",0
product				DWORD	?
multiplicationSign	BYTE	" * ",0
quotient			DWORD	?
divisionSign		BYTE	" / ",0
remainder			DWORD	?
remainderSign		BYTE	" remainder ", 0
EC1Message			BYTE	"**EC: Program verifies first number greater than second", 0
warningMessage		BYTE	"The first number must be greater than the second!", 0
EC2Message			BYTE	"**EC: Program calculates the quotient as a floating-point number, rounded to the nearest .001", 0
floatSign		    BYTE	"EC: Floating-point value: ", 0
EC2FloatingPoint	REAL4	?
oneThousand			DWORD	1000
bigInt			    DWORD	0
floatRemainder		DWORD	?
dot					BYTE	".", 0
firstPart			DWORD	?
secondPart			DWORD	?
temp				DWORD	?
repeatPrompt		BYTE	"EC: Continue? (1 - yes / 0 - no): ", 0
EC3Explain			BYTE	"**EC: Program loops until the user decides to quit.", 0
doRepeat			DWORD	?

.code
main PROC

	; Introduction - prints out the program description and extra credit options
    mov		edx, OFFSET programTitle
    call	WriteString
    call	Crlf
    call    Crlf
    mov		edx, OFFSET EC1Message
    call	WriteString
    call	Crlf
    mov		edx, OFFSET EC2Message
    call	WriteString
    call	Crlf
    mov		edx, OFFSET EC3Explain
    call	WriteString
    call	Crlf

	; Get The Data - prompt for and receive input from the user
    start:
        mov		edx, OFFSET instructions
        call	WriteString
        call	Crlf

        mov		edx, OFFSET firstPrompt
        call	WriteString
        call	ReadInt
        mov		firstNum, eax

        mov		edx, OFFSET secondPrompt
        call	WriteString
        call	ReadInt
        mov		secondNum, eax

        ; Jump if second number greater than first
        mov		eax, secondNum
        cmp		eax, firstNum
        jg		warning
        jle		calculate

    ; Display warning message and jump to end
    warning:
        mov		edx, OFFSET warningMessage
        call	WriteString
        call	Crlf
        jg		rerun

    ; Calculate Required Values - perform the calculations
    calculate:
        ; sum
        mov		eax, firstNum
        add		eax, secondNum
        mov		sum, eax

        ; difference
        mov		eax, firstNum
        sub		eax, secondNum
        mov		difference, eax

        ; product
        mov		eax, firstNum
        mov		ebx, secondNum
        mul		ebx
        mov		product, eax

        ; quotient
        mov		edx, 0
        mov		eax, firstNum
        cdq
        mov		ebx, secondNum
        cdq
        div		ebx
        mov		quotient, eax
        mov		remainder, edx

        ; Floating point representation of quotient and remainder
        fld		firstNum
        fdiv	secondNum
        fimul	oneThousand
        frndint
        fist	bigInt
        fst		EC2FloatingPoint

    ; Display Results

        ; sum
        mov		eax, firstNum
        call	WriteDec
        mov		edx, OFFSET additionSign
        call	WriteString
        mov		eax, secondNum
        call	WriteDec
        mov		edx, OFFSET equalSign
        call	WriteString
        mov		eax, sum
        call	WriteDec
        call	Crlf

        ; difference
        mov		eax, firstNum
        call	WriteDec
        mov		edx, OFFSET minusSign
        call	WriteString
        mov		eax, secondNum
        call	WriteDec
        mov		edx, OFFSET equalSign
        call	WriteString
        mov		eax, difference
        call	WriteDec
        call	Crlf

        ; product
        mov		eax, firstNum
        call	WriteDec
        mov		edx, OFFSET multiplicationSign
        call	WriteString
        mov		eax, secondNum
        call	WriteDec
        mov		edx, OFFSET equalSign
        call	WriteString
        mov		eax, product
        call	WriteDec
        call	Crlf

        ; quotient
        mov		eax, firstNum
        call	WriteDec
        mov		edx, OFFSET divisionSign
        call	WriteString
        mov		eax, secondNum
        call	WriteDec
        mov		edx, OFFSET equalSign
        call	WriteString
        mov		eax, quotient
        call	WriteDec
        mov		edx, OFFSET remainderSign
        call	WriteString
        mov		eax, remainder
        call	WriteDec
        call	Crlf

        ; Floating point division
        mov		edx, OFFSET floatSign
        call	WriteString
        mov		edx, 0
        mov		eax, bigInt
        cdq
        mov		ebx, 1000
        cdq
        div		ebx
        mov		firstPart, eax
        mov		floatRemainder, edx
        mov		eax, firstPart
        call	WriteDec
        mov		edx, OFFSET dot
        call	WriteString
        mov		eax, firstPart
        mul		oneThousand
        mov		temp, eax
        mov		eax, bigInt
        sub		eax, temp
        mov		secondPart, eax
        call	WriteDec
        call	Crlf
        call    Crlf

    ; Loop until user quits
    rerun:
        mov	    edx, OFFSET repeatPrompt
        call	WriteString
        call	ReadInt
        mov		doRepeat, eax
        cmp		eax, 1
        je		start

        ; Say Goodbye
        mov		edx, OFFSET goodbyeMessage
        call	WriteString
        call	Crlf

	exit
main ENDP

END main