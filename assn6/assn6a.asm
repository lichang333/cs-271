TITLE Programming Assignment #6 Low Level I/O (assn6a.asm)

; ====================================================================================================================
; Author: Alec Merdler
; Description:
;   Write and test a MASM program to perform the following tasks:
;   1. User’s numeric input must be validated the hard way: Read the user's input as a string, and convert the string
;      to numeric form. If the user enters non-digits or the number is too large for 32-bit registers, an error message
;      should be displayed and the  number should be discarded.
;   2. Conversion routines must appropriately use the lodsb and/or stosb operators.
;   3. All procedure parameters must be passed on the system stack.
;   4. Addresses of prompts, identifying strings, and other memory locations should be passed by address to the macros.
;   5. Used registers must be saved and restored by the called procedures and macros.
;   6. The stack must be “cleaned up” by the called procedure.
;   7. The usual requirements regarding documentation, readability, user-friendliness, etc., apply.
; ====================================================================================================================

INCLUDE Irvine32.inc

.data
MIN      = 0
LO       = 30h
HI       = 39h
MAX_SIZE = 10

welcomeMessage       BYTE     "Designing low-level I/O procedures programmed by Alec Merdler.", 0
descriptionMessage1  BYTE     "Please provide 10 unsigned decimal integers. Each number needs to be small enough to fit inside a 32 bit register.", 0
descriptionMessage2  BYTE     "After you have finished inputting the raw numbers I will display a list of the integers, their sum, and their average value.", 0
inputPrompt          BYTE     ". Please enter an unsigned integer: ", 0
errorMessage         BYTE     "ERROR: You did not enter an unsigned number or your number was too big.", 0
spacingMessage       BYTE     ", ", 0
farewellMessage      BYTE     "Thanks for playing!", 0
inputMessage         BYTE     "You entered the following numbers: ", 0
sumMessage           BYTE     "The sum of these numbers is: ", 0
averageMessage       BYTE     "The average is: ",0
request              DWORD    10 DUP(0)
requestCount         DWORD    ?
list                 DWORD    MAX_SIZE DUP(?)
strResult            db       16 dup (0)

currentNumber        DWORD    1


; ====================================================================================================================
;             Macro: getString
;       Description: Prompt the user for input and store input as string.
;          Receives:  instruction: instruction string message
;                         request: input buffer
;                    requestCount: number of digits entered
;                    currentIndex: current input number
;           Returns: none
; Registers Changed: edx
; ====================================================================================================================
getString MACRO instruction, request, requestCount, currentIndex
    push       edx
    push       ecx
    push       eax
    push       ebx

    mov        eax, currentIndex
    call       WriteDec

    mov        edx, OFFSET inputPrompt
    call       WriteString
    mov        edx, OFFSET request
    mov        ecx, SIZEOF    request
    call       ReadString
    mov        requestCount, 00000000h
    mov        requestCount, eax

    pop        ebx
    pop        eax
    pop        ecx
    pop        edx

ENDM


; ====================================================================================================================
;             Macro: displayString
;       Description: Prints the given message
;          Receives: message: message string
;           Returns: none
; Registers Changed: edx
; ====================================================================================================================
displayString MACRO message
    push       edx
    mov        edx, message
    call       WriteString
    pop        edx

ENDM

.code
; ====================================================================================================================
;         Procedure: main
;       Description: Calls other procedures to drive the program.
;          Receives: none
;           Returns: none
; Registers Changed: edx
; ====================================================================================================================
 main PROC
    call       introduction

    push       OFFSET list
    push       OFFSET request
    push       OFFSET requestCount
    call       readVal
    call       CrLf

    push       OFFSET averageMessage
    push       OFFSET sumMessage
    push       OFFSET list
    call       displayAve
    call       CrLf

    push       edx
    mov        edx, OFFSET inputMessage
    call       WriteString
    pop        edx

    push       OFFSET strResult
    push       OFFSET list
    call       writeVal
    call       CrLf

    push       OFFSET farewellMessage
    call       farewell

    exit
main ENDP


; ====================================================================================================================
;         Procedure: introduction
;       Description: Prints program instructions and introduction.
;          Receives: none
;           Returns: none
; Registers Changed: none
; ====================================================================================================================
introduction PROC
    call       CrLf
    mov        edx, OFFSET welcomeMessage
    call       WriteString
    call       CrLf
    call       CrLf

    mov        edx, OFFSET descriptionMessage1
    call       WriteString
    mov        edx, OFFSET descriptionMessage2
    call       WriteString
    call       CrLf

    ret
introduction ENDP


; ====================================================================================================================
;         Procedure: readVal
;       Description: Receives and validates integers from the user and
;                    transforms decimal values into strings.
;          Receives: an array to store values in, a buffer to read the input
;           Returns: puts user's integers into an array of strings
; Registers Changed: edx, eax, ecx, ebx
; ====================================================================================================================
readVal PROC
    push       ebp
    mov        ebp, esp
    mov        ecx, 10
    mov        edi, [ebp + 16]

    ; Call macro to receive user input as a string
    getInput:
    getString inputPrompt, request, requestCount, currentNumber

    ; Get parameters from the stack
    push       ecx
    ; Parameter holding request
    mov        esi, [ebp + 12]
    ; Parameter holding number of digits in request
    mov        ecx, [ebp + 8]
    mov        ecx, [ecx]
    cld
    ; Clear eax and use ebx as an accumulator
    mov        eax, 00000000
    mov        ebx, 00000000

    ; Load request into eax one byte at a time
    convertToInt:
    lodsb

    ; Perform error checking
    cmp        eax, LO
    jb         inputError
    cmp        eax, HI
    ja         inputError

    sub        eax, LO
    push       eax
    mov        eax, ebx
    mov        ebx, MAX_SIZE
    mul        ebx
    mov        ebx, eax
    pop        eax
    add        ebx, eax
    mov        eax, ebx

    mov        eax, 00000000
    loop       convertToInt

    ; Put eax into list array
    mov        eax, ebx
    stosd

    ; Proceed to next element
    add        esi, 4
    pop        ecx
    loop       getInput
    jmp        readValEnd

    inputError:
    pop        ecx
    mov        edx, OFFSET  errorMessage
    call       WriteString
    call       CrLf
    jmp        getInput

    readValEnd:
    pop ebp

    ret 12
readVal ENDP


; ====================================================================================================================
;         Procedure: writeVal
;       Description: Utilizes 'displayString' macro to convert strings to ASCII
;                    and print to console.
;          Receives:    list: @array
;                    request: number of array elements
;           Returns: none
; Registers Changed: eax, ecx, ebx, edx
; ====================================================================================================================
writeVal PROC
    ; Get parameters from the stack
    push       ebp
    mov        ebp, esp
    ; Parameter holding list of input numbers
    mov        edi, [ebp + 8]
    mov        ecx, 10

    outerLoop:
    push       ecx
    mov        eax, [edi]
    ; Calculate number of digits using base 10
    mov        ecx, 10
    xor        bx, bx

    divide:
    ; high part = 0
    xor        edx, edx
    div        ecx
    ; DL should be between 0 and 9
    push       dx
    ; count number of digits
    inc        bx
    ; Check if eax is zero
    test       eax, eax
    jnz        divide

    mov        cx, bx
    lea        esi, strResult
    ; Print each input number by converting to ASCII, then calling macro
    nextDigit:
    pop        ax
    add        ax, '0'
    mov        [esi], ax

    displayString OFFSET strResult

    ; Proceed to next digit
    loop       nextDigit

    ; Print space between elements
    pop        ecx
    mov        edx, OFFSET spacingMessage
    call       WriteString
    mov        edx, 0
    mov        ebx, 0
    add        edi, 4
    loop       outerLoop

    pop        ebp

    ret        8
writeVal ENDP


; ====================================================================================================================
;         Procedure: displayAve
;       Description: Calculates the average and sum of a given array of numbers
;          Receives: list: @array
;           Returns: none
; Registers Changed: eax, ebx, ecx, edx
; ====================================================================================================================
displayAve PROC
    ; Get parameters from stack
    push       ebp
    mov        ebp, esp
    ; Parameter holding list of input numbers
    mov        esi, [ebp + 8]
    mov        eax, 10
    mov        edx, 0
    mov        ebx, 0
    mov        ecx, eax

    medianLoop:
    mov        eax, [esi]
    add        ebx, eax
    add        esi, 4
    loop       medianLoop

    endMedianLoop:
    mov        edx, 0
    mov        eax, ebx
    mov        edx, [ebp + 12]
    call       WriteString
    call       WriteDec
    call       CrLf
    mov        edx, 0
    mov        ebx, 10
    div        ebx
    mov        edx, [ebp + 16]
    call       WriteString
    call       WriteDec
    call       CrLf

    endDisplayMedian:
    pop        ebp

    ret        12
displayAve ENDP


; ====================================================================================================================
;         Procedure: farewell
;       Description: Prints farewell message.
;          Receives: message: string message
;           Returns: none
; Registers Changed: edx
; ====================================================================================================================
farewell PROC
    push       ebp
    mov        ebp, esp
    ; Parameter holding farewell message
    mov        edx, [ebp + 8]

    call       CrLf
    call       WriteString
    call       CrLf
    pop        ebp

    ret        4
farewell ENDP

exit
END main
