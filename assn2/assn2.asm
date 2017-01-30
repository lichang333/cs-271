TITLE Programming Assignment #2 (assn2.asm)

; Author: Alec Merdler
;
; Description: Write a program to calculate Fibonacci numbers.
;	           Display the program title and programmer’s name. Then get the user’s name, and greet the user.
;	           Prompt the user to enter the number of Fibonacci terms to be displayed. Advise the user to enter an integer
;		            in the range [1 .. 46].
;	           Get and validate the user input (n).
;	           Calculate and display all of the Fibonacci numbers up to and including the nth term. The results should be
;		            displayed 5 terms per line with at least 5 spaces between terms.
;	           Display a parting message that includes the user’s name, and terminate the program.

INCLUDE Irvine32.inc

.data
programPrompt		BYTE	"Fibonacci Numbers, programmed by Alec Merdler", 0
namePrompt			BYTE	"Enter your name: ", 0
instructionsPrompt	BYTE	"Enter the number of Fibonacci terms you would like to see. Please enter a number between [1 - 46]: ", 0
ecMessage			BYTE	"EC: Doing something awesome: Setting background/text color", 0
numTerms			DWORD	?
prev1				DWORD	?
prev2				DWORD	?
spaces				BYTE	"     ", 0
farewellMessage		BYTE	"Farewell, ", 0
firstOne			BYTE	"1", 0
firstTwo			BYTE	"1     1     ", 0
firstThree          BYTE    "1     1     2", 0
temp				DWORD	?
moduloFive			DWORD	5
UPPERLIMIT = 46
LOWERLIMIT = 1
buffer				BYTE 21 DUP(0)
byteCount			DWORD	?
greeting			BYTE	"Hello, ",0
tooHighError		BYTE	"The number you entered is too high! It must be 46 or below. ", 0
tooLowError			BYTE	"The number you entered is too low! It must be 1 or above. ", 0

; **EC: Doing something awesome: Setting  Background Color and Text Color
backgroundColor     DWORD   19
textColor           DWORD   16

.code
main PROC
	; **EC: Doing something awesome like setting the text color
    mov     eax, textColor
    imul    eax, 16
    add     eax, backgroundColor
    call    setTextColor

	; Section: introduction
    mov		edx, OFFSET programPrompt
    call	WriteString
    call	CrLf

    ; Extra Credit Message
    mov		edx, OFFSET ecMessage
    call	WriteString
    call	CrLf

    ; Get user's name
    mov		edx, OFFSET namePrompt
    call	WriteString
    mov		edx, OFFSET buffer
    mov		ecx, SIZEOF	buffer
    call	ReadString
    mov		byteCount, eax

    ; Greet the user
    mov		edx, OFFSET greeting
    call	WriteString
    mov		edx, OFFSET buffer
    call	WriteString
    call	CrLf

	; Section: userInstructions
    instructions:
    mov		edx, OFFSET instructionsPrompt
    call	WriteString

	; Section: getUserData
    call	ReadInt
    mov		numTerms, eax

	; Validate user data
    cmp		eax, UPPERLIMIT
    jg		inputHigh
    cmp		eax, LOWERLIMIT
    jl		inputLow
    je		inputOne
    cmp		eax, 2
    je		inputTwo
    cmp     eax, 3
    je      inputThree

	; Section: displayFibs
    ; Prepare loop (post-test), do the first two manually
    mov		ecx, numTerms
    sub		ecx, 3
    mov		eax, 1
    call	WriteDec
    mov		edx, OFFSET spaces
    call	WriteString
    call	WriteDec
    mov		edx, OFFSET spaces
    call	WriteString
    mov		prev2, eax
    mov		eax, 2
    call	WriteDec
    mov		edx, OFFSET spaces
    call	WriteString
    mov		prev1, eax

    fib:
    add		eax, prev2
    call	WriteDec
    mov		edx, OFFSET spaces
    call	WriteString
    mov		temp, eax
    mov		eax, prev1
    mov		prev2, eax
    mov		eax, temp
    mov		prev1, eax
    mov		edx, ecx
    cdq
    div		moduloFive
    cmp		edx, 0
    jne		skip
    call	CrLf

    skip:
    mov		eax, temp
    loop    fib
    jmp		farewell

    inputHigh:
    mov		edx, OFFSET tooHighError
    call	WriteString
    jmp		instructions

    inputLow:
    mov		edx, OFFSET tooLowError
    call	WriteString
    jmp		instructions

    inputOne:
    mov		edx, OFFSET firstOne
    call	WriteString
    jmp		farewell

    inputTwo:
    mov		edx, OFFSET firstTwo
    call	WriteString
    jmp		farewell

    inputThree:
    mov     edx, OFFSET firstThree
    call    WriteString
    jmp     farewell

    ; Section: farewell
    farewell:
    call	CrLf
    mov		edx, OFFSET farewellMessage
    call	WriteString
    mov		edx, OFFSET buffer
    call	WriteString
    call	CrLf

	exit
main ENDP

END main
