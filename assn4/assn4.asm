TITLE Programming Assignment #4 (assn4.asm)

; Author: Alec Merdler
; Description:
;   Write a program to calculate composite numbers. First, the user is instructed to enter the number of composites
;   to be displayed, and is prompted to enter an integer in the range [1 .. 400]. The user enters a number, n, and
;   the program verifies that 1 <= n <= 400. If n is out of range, the user is re- prompted until s/he enters a value
;   in the specified range. The program then calculates and displays all of the composite numbers up to and including
;   the nth composite. The results should be displayed 10 composites per line with at least 3 spaces between the numbers.

INCLUDE Irvine32.inc

.data
welcomeMessage			   BYTE	  "Composites Numbers, programmed by Alec Merdler", 0
inputPrompt			       BYTE	  "Enter number of composites to display [1, 400]: ", 0
belowError				   BYTE   "The number you entered was too small. ", 0
aboveError				   BYTE   "The number you entered was too big. ", 0
spaces					   BYTE	  "   ", 0
farewellMessage			   BYTE	  "Farewell!", 0
userNumber				   DWORD  ?
currentValue               DWORD  ?
isCompositeFlag            DWORD  0

LOWER_LIMIT = 1
UPPER_LIMIT = 400


.code
; ==============================================================================
;   Procedure: main
; Description: Calls other procedures to drive the program.
; ==============================================================================
main PROC
    call introduction
    call getUserData
    call showComposites
    call farewell

    exit
main ENDP


; ==============================================================================
;   Procedure: introduction
; Description: Prints welcome message.
; ==============================================================================
introduction PROC
    call    CrLf
    mov	    edx, OFFSET welcomeMessage
    call    WriteString
    call    CrLf

    ret
introduction ENDP


; ==============================================================================
;   Procedure: getUserData
; Description: Prompt user for number of composites to show, performing input
;              validation where needed.
; ==============================================================================
getUserData PROC
    getInput:
    mov		edx, OFFSET inputPrompt
    call	WriteString
    call    ReadInt
    mov     userNumber, eax
    cmp		eax, LOWER_LIMIT
    jb		invalidLow
    cmp		eax, UPPER_LIMIT
    jg		invalidHigh
    jmp		valid

    invalidHigh:
    mov		edx, OFFSET aboveError
    call	WriteString
    call	CrLf
    jmp		getInput

    invalidLow:
    mov		edx, OFFSET belowError
    call	WriteString
    call	CrLf
    jmp		getInput

    valid:

    ret
getUserData ENDP


; ==============================================================================
;   Procedure: showComposites
; Description: Calculate and display the number of composites stored in
;              <userNumber>.
; ==============================================================================
showComposites PROC
    ; Set initial value of the potential composite number and loop counter
    mov     currentValue, 4
    mov     ecx, userNumber

    calculate:
    call    isComposite
    cmp     isCompositeFlag, 1
    jl      notComposite
    ; Print the composite number
    mov     eax, currentValue
    call    WriteDec
    call    CrLf
    jmp     nextComposite

    ; Add 1 back to loop counter because the number was not composite
    notComposite:
    add     ecx, 1
    jmp     nextComposite

    nextComposite:
    loop    calculate

    ret
showComposites ENDP


; ==============================================================================
;   Procedure: isComposite
; Description: Sets <isCompositeFlag> to either 0 or 1 if the value stored in
;              <currentValue> is a composite number.
; ==============================================================================
isComposite PROC
    mov    isCompositeFlag, 1
    mov    ebx, currentValue

    ; Subtract 1 from current divisor, divide current value and check remainder
    checkComposite:
    sub    ebx, 1
    mov    edx, currentValue
    mov    eax, currentValue
    cdq
    div    ebx
    cmp    edx, 0
    jg     checkComposite

    ret
isComposite ENDP


; ==============================================================================
;   Procedure: farewell
; Description: Prints farewell message.
; ==============================================================================
farewell PROC
    call	CrLf
    mov		edx, OFFSET farewellMessage
    call	WriteString
    call	CrLf
    call	CrLf

    exit
farewell ENDP

END main
