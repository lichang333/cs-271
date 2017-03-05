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
inputLowMessage			   BYTE   "The number you entered was too small. ", 0
inputHighMessage		   BYTE   "The number you entered was too big. ", 0
showMorePrompt             BYTE   "Press enter to show more.", 0
spacesMessage			   BYTE	  "   ", 0
farewellMessage			   BYTE	  "Farewell!", 0
numValues				   DWORD  ?
currentValue               DWORD  ?
isCompositeFlag            DWORD  0
currentRow                 DWORD  0
currentPage                DWORD  0
ec1Message                 BYTE   "**EC: Align the output columns.", 0
ec2Message                 BYTE   "**EC: Display more composites, but show them one page at a time.", 0

LOWER_LIMIT    = 1
UPPER_LIMIT    = 400
VALUES_PER_ROW = 10


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
; Description: Prints welcome message and extra credit messages.
; ==============================================================================
introduction PROC
    call    CrLf
    mov	    edx, OFFSET welcomeMessage
    call    WriteString
    call    CrLf
    mov     edx, OFFSET ec1Message
    call    WriteString
    call    CrLf
    mov     edx, OFFSET ec2Message
    call    WriteString
    call    CrLf
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
    mov     numValues, eax
    cmp		eax, LOWER_LIMIT
    jb		invalidLow
    cmp		eax, UPPER_LIMIT
    jg		invalidHigh
    jmp		valid

    invalidHigh:
    mov		edx, OFFSET inputHighMessage
    call	WriteString
    call	CrLf
    jmp		getInput

    invalidLow:
    mov		edx, OFFSET inputLowMessage
    call	WriteString
    call	CrLf
    jmp		getInput

    valid:

    ret
getUserData ENDP


; ==============================================================================
;   Procedure: showComposites
; Description: Calculate and display the number of composites stored in
;              <numValues>.
; ==============================================================================
showComposites PROC
    ; Set initial value of the potential composite number and loop counter
    mov     currentValue, 4
    mov     ecx, numValues

    ; Call procedure to check if the current value is composite, then print
    calculate:
    call    isComposite
    cmp     isCompositeFlag, 1
    jl      notComposite
    ; Print the composite number
    mov     eax, currentValue
    call    WriteDec
    ; Check if a new row is needed
    add     currentRow, 1
    cmp     currentRow, VALUES_PER_ROW
    je      newRow
    ; Print spaces if not on a new row
    mov     edx, OFFSET spacesMessage
    call    WriteString
    jmp     nextComposite

    ; Reset row counter and print a newline
    ; **EC: Prompt user to press enter to show next page
    newRow:
    call    CrLf
    mov     edx, OFFSET showMorePrompt
    call    WriteString
    call    ReadInt
    mov     currentRow, 0
    call    CrLf
    jmp     nextComposite

    ; Add 1 back to loop counter because the number was not composite
    notComposite:
    add     ecx, 1
    jmp     nextComposite

    ; Increment the current value and loop
    nextComposite:
    add     currentValue, 1
    loop    calculate

    ret
showComposites ENDP


; ==============================================================================
;   Procedure: isComposite
; Description: Sets <isCompositeFlag> to either 0 or 1 if the value stored in
;              <currentValue> is a composite number.
; ==============================================================================
isComposite PROC
    mov    isCompositeFlag, 0
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

    checkPrime:
    cmp    ebx, 1
    jg     isNotPrime
    jl     isPrime

    isPrime:
    mov    isCompositeFlag, 0
    jmp    finished

    isNotPrime:
    mov    isCompositeFlag, 1
    jmp    finished

    finished:

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
