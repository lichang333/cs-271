TITLE Programming Assignment #3 (assn3.asm)

; Author: Alec Merdler
; Description: Write and test a MASM program to perform the following tasks:
;              1. Display the program title and programmer’s name.
;              2. Get the user’s name, and greet the user.
;              3. Display instructions for the user.
;              4. Repeatedly prompt the user to enter a number. Validate the user input to be in [-100, -1] (inclusive).
;		          Count and accumulate the valid user numbers until a non-negative number is entered. (The non-
;		          negative number is discarded.)
;              5. Calculate the (rounded integer) average of the negative numbers. 6. Display:
;	              i. the number of negative numbers entered (Note: if no negative numbers were entered, display a
;                    special message and skip to iv.)
;	              ii. the sum of negative numbers entered
;	              iii. the average, rounded to the nearest integer (e.g. -20.5 rounds to -20)
;	              iv. a parting message (with the user’s name)

INCLUDE Irvine32.inc

.data
programPrompt		   BYTE	 "Integer Accumulator, programmed by Alec Merdler", 0
namePrompt			   BYTE	 "Enter your name: ", 0
constraintsMessage	   BYTE	 "Please enter numbers between [-100, -1].", 0
quitMessage		       BYTE	 "Enter a non-negative number when you are finished to see results.", 0
numInputPrompt		   BYTE	 " Enter a number: ", 0
greetingMessage		   BYTE	 "Welcome, ", 0
farewellMessage		   BYTE	 "Exiting Integer Accumulator program. Goodbye, ", 0
number                 DWORD ?
userName			   BYTE  21 DUP(0)
count				   DWORD 1
accumulator			   DWORD 0
totalMessage		   BYTE	 "The total is:               ", 0
numQuantityMessage     BYTE	 "Quantity of numbers:         ", 0
roundedAvgMessage	   BYTE	 "The rounded average is:     ", 0
roundedAvg		       DWORD 0
remainder			   DWORD ?
decimalPointString     BYTE	 ".",0
floatingPointMessage   BYTE	 "As a floating-point number: ", 0
temp				   DWORD ?
subtractor			   DWORD ?
floatingPoint		   DWORD ?
ecMessage1             BYTE  "**EC: Calculate and display the average as a floating-point number.", 0
ecMessage2	           BYTE  "**EC: Number the lines during user input.", 0
ecMessage3             BYTE  "**EC: Do something astoundingly creative (set background/text color).", 0
textColor              DWORD 19
backgroundColor        DWORD 16
LOWER_LIMIT      = -100
UPPER_LIMIT      = -1
NEG_ONE_THOUSAND = -1000
ONE_THOUSAND     = 1000

.code
main PROC
    ; **EC: Do something astoundingly creative (set background/text color).
    mov     eax, backgroundColor
    imul    eax, 16
    add     eax, textColor
    call    setTextColor

    ; Display the program title and programmer’s name.
    call	 CrLf
    mov		 edx, OFFSET programPrompt
    call	 WriteString
    call	 CrLf

    ; Display extra credit messages
    mov		 edx, OFFSET ecMessage1
    call	 WriteString
    call	 CrLf
    mov		 edx, OFFSET ecMessage2
    call	 WriteString
    call	 CrLf
    mov      edx, OFFSET ecMessage3
    call     WriteString
    call     CrLf

    ; Get the user’s name, and greet the user.
    mov		edx, OFFSET namePrompt
    call	WriteString
    mov		edx, OFFSET userName
    mov		ecx, SIZEOF userName
    call	ReadString
    mov		edx, OFFSET greetingMessage
    call	WriteString
    mov		edx, OFFSET userName
    call	WriteString
    call	CrLF

    ; Display instructions for the user.
    mov		edx, OFFSET constraintsMessage
    call	WriteString
    call	CrLf
    mov		edx, OFFSET quitMessage
    call	WriteString
    call	CrLf
    mov		ecx, 0

    ; Repeatedly prompt the user to enter a number.
    getInput:
    mov		eax, count
    call	WriteDec
    add		eax, 1
    mov		count, eax
    mov	    edx, OFFSET numInputPrompt
    call	WriteString
    call    ReadInt
    mov     number, eax
    cmp		eax, LOWER_LIMIT
    jb		calculate;
    cmp		eax, UPPER_LIMIT
    jg		calculate
    add		eax, accumulator
    mov		accumulator, eax
    loop	getInput

    ; Count and accumulate the valid user numbers
    calculate:
    mov		eax, count
    sub		eax, 2
    jz		farewell
    mov		eax, accumulator
    call	CrLF

    ; Display the sum of negative numbers entered.
    mov		edx, OFFSET  totalMessage
    call	WriteString
    mov		eax, accumulator
    call	WriteInt
    call	CrLF

    ; Display the number of negative numbers entered.
    mov		edx, OFFSET numQuantityMessage
    call	WriteString
    mov		eax, count
    sub		eax, 2
    call	WriteDec
    call	CrLf

    ; Display the average, rounded to the nearest integer.
    mov		edx, OFFSET roundedAvgMessage
    call	WriteString
    mov		eax, 0
    mov		eax, accumulator
    cdq
    mov		ebx, count
    sub		ebx, 2
    idiv	ebx
    mov		roundedAvg, eax
    call	WriteInt
    call	CrLf

    ; **EC: Calculate and display the average as a floating-point number, rounded to the nearest .001.
    mov		remainder, edx
    mov		edx, OFFSET floatingPointMessage
    call	WriteString
    call	WriteInt
    mov		edx, OFFSET decimalPointString
    call	WriteString
    mov		eax, remainder
    mov     ebx, NEG_ONE_THOUSAND
    mul     ebx
    mov		remainder, eax ; eax now holds remainder * -1000
    mov		eax, count
    sub		eax, 2
    mov     ebx, ONE_THOUSAND
    mul		ebx
    mov		subtractor, eax
    fld		remainder
    fdiv	subtractor
    mov     temp, ONE_THOUSAND
    fimul	temp
    frndint
    fist	floatingPoint
    mov		eax, floatingPoint
    call	WriteDec
    call	CrLf

    ; Display a parting message (with the user's name).
    farewell:
    call	CrLf
    mov		edx, OFFSET farewellMessage
    call	WriteString
    mov		edx, OFFSET userName
    call	WriteString
    call	CrLf
    call	CrLf

exit
main ENDP

END main